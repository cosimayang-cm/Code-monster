import {
  createContext,
  useEffect,
  useRef,
  useState,
  type PropsWithChildren,
} from 'react'

import { apiClient, configureApiClient } from '../api/client'
import type { AuthResponse, AuthTokens, User } from '../types'

interface AuthContextValue {
  user: User | null
  tokens: AuthTokens | null
  isAuthenticated: boolean
  initializing: boolean
  login: (email: string, password: string) => Promise<User>
  register: (email: string, password: string) => Promise<User>
  logout: () => void
  refreshUser: () => Promise<User>
  completeOAuthLogin: (tokens: AuthTokens) => void
}

const STORAGE_KEY = 'monster7-member-auth'

const readStoredTokens = (): AuthTokens | null => {
  const raw = window.localStorage.getItem(STORAGE_KEY)

  if (!raw) {
    return null
  }

  try {
    return JSON.parse(raw) as AuthTokens
  } catch {
    window.localStorage.removeItem(STORAGE_KEY)
    return null
  }
}

const persistTokens = (tokens: AuthTokens | null) => {
  if (!tokens) {
    window.localStorage.removeItem(STORAGE_KEY)
    return
  }

  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(tokens))
}

export const AuthContext = createContext<AuthContextValue | null>(null)

export const AuthProvider = ({ children }: PropsWithChildren) => {
  const [tokens, setTokens] = useState<AuthTokens | null>(() => readStoredTokens())
  const [user, setUser] = useState<User | null>(null)
  const [initializing, setInitializing] = useState(true)
  const tokensRef = useRef<AuthTokens | null>(tokens)

  useEffect(() => {
    tokensRef.current = tokens
    persistTokens(tokens)
  }, [tokens])

  useEffect(() => {
    configureApiClient({
      getTokens: () => tokensRef.current,
      updateTokens: (next) => {
        setTokens((current) => {
          if (!current && (!next.accessToken || !next.refreshToken)) {
            return current
          }

          return {
            accessToken: next.accessToken ?? current?.accessToken ?? '',
            refreshToken: next.refreshToken ?? current?.refreshToken ?? '',
          }
        })
      },
      clearSession: () => {
        setTokens(null)
        setUser(null)
      },
    })
  }, [])

  useEffect(() => {
    let active = true

    const bootstrap = async () => {
      if (!tokensRef.current) {
        if (active) {
          setUser(null)
          setInitializing(false)
        }
        return
      }

      if (user) {
        if (active) {
          setInitializing(false)
        }
        return
      }

      if (active) {
        setInitializing(true)
      }

      try {
        const currentUser = await apiClient.getCurrentUser()

        if (active) {
          setUser(currentUser)
        }
      } catch {
        if (active) {
          setTokens(null)
          setUser(null)
        }
      } finally {
        if (active) {
          setInitializing(false)
        }
      }
    }

    void bootstrap()

    return () => {
      active = false
    }
  }, [tokens?.accessToken, user])

  const applySession = (session: AuthResponse) => {
    setTokens({
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    })
    setUser(session.user)
    return session.user
  }

  const refreshUser = async () => {
    const currentUser = await apiClient.getCurrentUser()
    setUser(currentUser)
    return currentUser
  }

  const login = async (email: string, password: string) =>
    applySession(await apiClient.login({ email, password }))

  const register = async (email: string, password: string) =>
    applySession(await apiClient.register({ email, password }))

  const logout = () => {
    setTokens(null)
    setUser(null)
  }

  const completeOAuthLogin = (nextTokens: AuthTokens) => {
    tokensRef.current = nextTokens
    persistTokens(nextTokens)
    setTokens(nextTokens)
    setUser(null)
    setInitializing(true)
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        tokens,
        isAuthenticated: Boolean(tokens?.accessToken),
        initializing,
        login,
        register,
        logout,
        refreshUser,
        completeOAuthLogin,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}
