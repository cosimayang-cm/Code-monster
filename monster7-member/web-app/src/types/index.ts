export type UserRole = 'user' | 'admin'
export type OAuthProvider = 'google' | 'github'
export type LoginMethod = 'email' | OAuthProvider

export interface User {
  id: string
  email: string
  name: string | null
  bio: string | null
  avatar_url: string | null
  role: UserRole
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface AuthTokens {
  accessToken: string
  refreshToken: string
}

export interface AuthResponse extends AuthTokens {
  user: User
}

export interface ApiErrorShape {
  error: {
    code: string
    message: string
    details?: unknown
  }
}

export interface PaginationMeta {
  page: number
  pageSize: number
  total: number
  totalPages: number
}

export interface LoginHistoryItem {
  id: string
  method: LoginMethod
  ip_address: string
  user_agent: string
  created_at: string
}

export interface OAuthAccount {
  id: string
  provider: OAuthProvider
  provider_email: string | null
  created_at: string
}

export interface DashboardStats {
  totalUsers: number
  todayRegistrations: number
  activeUsers7d: number
  disabledUsers: number
  oauthLinkedRatio: number
  logins24h: number
}

export interface AdminUserSummary {
  id: string
  email: string
  name: string | null
  role: UserRole
  is_active: boolean
  created_at: string
}

export interface AdminActivityItem extends LoginHistoryItem {
  email: string
  name: string | null
}

export interface AdminUserDetail extends User {
  oauthAccounts: Array<{
    provider: OAuthProvider
    provider_email: string | null
    created_at: string
  }>
  recentLogins: Array<{
    method: LoginMethod
    ip_address: string
    user_agent: string
    created_at: string
  }>
}
