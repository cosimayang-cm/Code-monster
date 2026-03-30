import { useEffect, useRef, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'

import { useAuth } from '../hooks/useAuth'

const getOAuthErrorMessage = (code: string | null) => {
  switch (code) {
    case 'OAUTH_NOT_CONFIGURED':
      return 'OAuth 尚未完成設定，先用帳密登入，稍後再試。'
    case 'ACCOUNT_DISABLED':
      return '這個帳號已被停用，請聯絡管理員。'
    case 'OAUTH_EMAIL_REQUIRED':
      return 'OAuth 提供者沒有回傳可用 email，無法完成登入。'
    case 'OAUTH_FAILED':
    default:
      return 'OAuth 登入失敗，正在帶你回登入頁...'
  }
}

export const AuthCallbackPage = () => {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const { completeOAuthLogin } = useAuth()
  const [message, setMessage] = useState('正在完成 OAuth 登入...')
  const handledRef = useRef(false)

  useEffect(() => {
    let active = true

    const run = async () => {
      if (handledRef.current) {
        return
      }

      handledRef.current = true

      try {
        const error = searchParams.get('error')

        if (error) {
          if (active) {
            setMessage(getOAuthErrorMessage(error))
          }
          window.setTimeout(() => navigate('/login', { replace: true }), 1000)
          return
        }

        const accessToken = searchParams.get('accessToken')
        const refreshToken = searchParams.get('refreshToken')

        if (!accessToken || !refreshToken) {
          if (active) {
            setMessage('缺少登入資訊，正在回登入頁...')
          }
          window.setTimeout(() => navigate('/login', { replace: true }), 1000)
          return
        }

        if (active) {
          setMessage('已取得 OAuth token，正在建立會員工作階段...')
        }

        completeOAuthLogin({
          accessToken,
          refreshToken,
        })

        if (active) {
          setMessage('登入成功，正在前往系統...')
          window.location.replace('/')
        }
      } catch {
        if (active) {
          setMessage('登入資訊處理失敗，正在回登入頁...')
        }
        window.setTimeout(() => navigate('/login', { replace: true }), 1000)
      }
    }

    void run()

    return () => {
      active = false
    }
  }, [completeOAuthLogin, navigate, searchParams])

  return (
    <main className="mx-auto flex min-h-screen max-w-3xl items-center justify-center px-6 py-12">
      <section className="glass-panel w-full rounded-[2.5rem] p-10 text-center shadow-panel">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          OAuth Callback
        </p>
        <h1 className="mt-5 text-3xl font-semibold text-slate-950">{message}</h1>
      </section>
    </main>
  )
}
