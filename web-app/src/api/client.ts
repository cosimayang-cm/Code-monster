import type {
  AdminActivityItem,
  AdminUserDetail,
  AdminUserSummary,
  AuthResponse,
  AuthTokens,
  DashboardStats,
  LoginHistoryItem,
  OAuthAccount,
  PaginationMeta,
  OAuthProvider,
  User,
} from '../types'

class ApiClientError extends Error {
  status: number
  code: string
  details?: unknown

  constructor(status: number, code: string, message: string, details?: unknown) {
    super(message)
    this.status = status
    this.code = code
    this.details = details
  }
}

interface ApiEnvelope<T> {
  data: T
  pagination?: PaginationMeta
}

interface AuthBridge {
  getTokens: () => AuthTokens | null
  updateTokens: (next: Partial<AuthTokens>) => void
  clearSession: () => void
}

interface RequestOptions extends RequestInit {
  auth?: boolean
  retryOn401?: boolean
}

let authBridge: AuthBridge | null = null
let refreshPromise: Promise<string | null> | null = null

const getBaseUrl = (): string => {
  const configured = import.meta.env.VITE_API_BASE_URL?.trim()

  if (configured) {
    return configured.replace(/\/+$/, '')
  }

  if (import.meta.env.DEV) {
    return 'http://localhost:8787'
  }

  throw new ApiClientError(
    500,
    'CONFIG_ERROR',
    'VITE_API_BASE_URL is not configured for this deployment.',
  )
}

const createApiError = (payload: unknown, status: number): ApiClientError => {
  if (
    payload &&
    typeof payload === 'object' &&
    'error' in payload &&
    payload.error &&
    typeof payload.error === 'object'
  ) {
    const errorShape = payload.error as {
      code?: string
      message?: string
      details?: unknown
    }

    return new ApiClientError(
      status,
      errorShape.code ?? 'UNKNOWN_ERROR',
      errorShape.message ?? 'Request failed.',
      errorShape.details,
    )
  }

  return new ApiClientError(status, 'UNKNOWN_ERROR', 'Request failed.')
}

const doRefreshAccessToken = async (): Promise<string | null> => {
  const tokens = authBridge?.getTokens()

  if (!tokens?.refreshToken) {
    return null
  }

  const response = await fetch(`${getBaseUrl()}/api/auth/refresh`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      refreshToken: tokens.refreshToken,
    }),
  })

  const payload = (await response.json().catch(() => null)) as ApiEnvelope<{
    accessToken: string
  }> | null

  if (!response.ok || !payload?.data?.accessToken) {
    authBridge?.clearSession()
    return null
  }

  authBridge?.updateTokens({ accessToken: payload.data.accessToken })
  return payload.data.accessToken
}

const refreshAccessToken = async (): Promise<string | null> => {
  if (!refreshPromise) {
    refreshPromise = doRefreshAccessToken().finally(() => {
      refreshPromise = null
    })
  }

  return refreshPromise
}

const request = async <T>(path: string, options: RequestOptions = {}): Promise<ApiEnvelope<T>> => {
  const { auth = false, retryOn401 = true, headers, body, ...rest } = options
  const nextHeaders = new Headers(headers)
  const nextBody = body
  const url = path.startsWith('http') ? path : `${getBaseUrl()}${path}`

  if (auth) {
    const accessToken = authBridge?.getTokens()?.accessToken

    if (accessToken) {
      nextHeaders.set('Authorization', `Bearer ${accessToken}`)
    }
  }

  if (nextBody && !(nextBody instanceof FormData)) {
    nextHeaders.set('Content-Type', 'application/json')
  }

  let response = await fetch(url, {
    ...rest,
    headers: nextHeaders,
    body: nextBody,
  })

  if (response.status === 401 && auth && retryOn401) {
    const newAccessToken = await refreshAccessToken()

    if (newAccessToken) {
      nextHeaders.set('Authorization', `Bearer ${newAccessToken}`)
      response = await fetch(url, {
        ...rest,
        headers: nextHeaders,
        body: nextBody,
      })
    }
  }

  const payload = (await response.json().catch(() => null)) as ApiEnvelope<T> | null

  if (!response.ok || !payload) {
    throw createApiError(payload, response.status)
  }

  return payload
}

export const configureApiClient = (bridge: AuthBridge) => {
  authBridge = bridge
}

export const getOAuthLoginUrl = (provider: OAuthProvider): string =>
  `${getBaseUrl()}/api/auth/oauth/${provider}`

export const apiClient = {
  async register(input: { email: string; password: string }): Promise<AuthResponse> {
    const payload = await request<AuthResponse>('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify(input),
    })
    return payload.data
  },

  async login(input: { email: string; password: string }): Promise<AuthResponse> {
    const payload = await request<AuthResponse>('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify(input),
    })
    return payload.data
  },

  async getCurrentUser(): Promise<User> {
    const payload = await request<User>('/api/users/me', {
      auth: true,
    })
    return payload.data
  },

  async updateProfile(input: { name: string | null; bio: string | null }): Promise<User> {
    const payload = await request<User>('/api/users/me', {
      method: 'PUT',
      auth: true,
      body: JSON.stringify(input),
    })
    return payload.data
  },

  async uploadAvatar(file: File): Promise<string> {
    const formData = new FormData()
    formData.append('avatar', file)

    const payload = await request<{ avatar_url: string }>('/api/users/me/avatar', {
      method: 'POST',
      auth: true,
      body: formData,
    })
    return payload.data.avatar_url
  },

  async changePassword(input: {
    currentPassword: string
    newPassword: string
  }): Promise<string> {
    const payload = await request<{ message: string }>('/api/users/me/password', {
      method: 'PUT',
      auth: true,
      body: JSON.stringify(input),
    })
    return payload.data.message
  },

  async forgotPassword(email: string): Promise<{ message: string; resetLink: string | null }> {
    const payload = await request<{ message: string; resetLink: string | null }>(
      '/api/auth/forgot-password',
      {
        method: 'POST',
        body: JSON.stringify({ email }),
      },
    )
    return payload.data
  },

  async resetPassword(input: { token: string; password: string }): Promise<string> {
    const payload = await request<{ message: string }>('/api/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify(input),
    })
    return payload.data.message
  },

  async getLoginHistory(page = 1, pageSize = 20): Promise<{
    rows: LoginHistoryItem[]
    pagination: PaginationMeta
  }> {
    const payload = await request<LoginHistoryItem[]>(
      `/api/users/me/login-history?page=${page}&pageSize=${pageSize}`,
      {
        auth: true,
      },
    )

    return {
      rows: payload.data,
      pagination: payload.pagination as PaginationMeta,
    }
  },

  async getOAuthAccounts(): Promise<OAuthAccount[]> {
    const payload = await request<OAuthAccount[]>('/api/users/me/oauth-accounts', {
      auth: true,
    })
    return payload.data
  },

  async unlinkOAuthAccount(provider: OAuthProvider): Promise<string> {
    const payload = await request<{ message: string }>(
      `/api/users/me/oauth-accounts/${provider}`,
      {
        method: 'DELETE',
        auth: true,
      },
    )
    return payload.data.message
  },

  async getLinkOAuthUrl(provider: OAuthProvider): Promise<string> {
    const payload = await request<{ authorizationUrl: string }>(
      `/api/auth/oauth/${provider}?mode=link`,
      {
        auth: true,
      },
    )
    return payload.data.authorizationUrl
  },

  async getAdminUsers(page = 1, pageSize = 20, search = ''): Promise<{
    rows: AdminUserSummary[]
    pagination: PaginationMeta
  }> {
    const query = new URLSearchParams({
      page: String(page),
      pageSize: String(pageSize),
      ...(search ? { search } : {}),
    })

    const payload = await request<AdminUserSummary[]>(`/api/admin/users?${query.toString()}`, {
      auth: true,
    })

    return {
      rows: payload.data,
      pagination: payload.pagination as PaginationMeta,
    }
  },

  async getAdminUserDetail(id: string): Promise<AdminUserDetail> {
    const payload = await request<AdminUserDetail>(`/api/admin/users/${id}`, {
      auth: true,
    })
    return payload.data
  },

  async updateAdminUserRole(id: string, role: 'user' | 'admin'): Promise<void> {
    await request(`/api/admin/users/${id}/role`, {
      method: 'PUT',
      auth: true,
      body: JSON.stringify({ role }),
    })
  },

  async updateAdminUserStatus(id: string, is_active: boolean): Promise<void> {
    await request(`/api/admin/users/${id}/status`, {
      method: 'PUT',
      auth: true,
      body: JSON.stringify({ is_active }),
    })
  },

  async getDashboardStats(): Promise<DashboardStats> {
    const payload = await request<DashboardStats>('/api/admin/dashboard/stats', {
      auth: true,
    })
    return payload.data
  },

  async getAdminActivity(input: {
    page?: number
    pageSize?: number
    method?: string
    from?: string
    to?: string
  }): Promise<{ rows: AdminActivityItem[]; pagination: PaginationMeta }> {
    const query = new URLSearchParams({
      page: String(input.page ?? 1),
      pageSize: String(input.pageSize ?? 20),
      ...(input.method ? { method: input.method } : {}),
      ...(input.from ? { from: input.from } : {}),
      ...(input.to ? { to: input.to } : {}),
    })

    const payload = await request<AdminActivityItem[]>(
      `/api/admin/dashboard/activity?${query.toString()}`,
      { auth: true },
    )

    return {
      rows: payload.data,
      pagination: payload.pagination as PaginationMeta,
    }
  },
}

export { ApiClientError }
