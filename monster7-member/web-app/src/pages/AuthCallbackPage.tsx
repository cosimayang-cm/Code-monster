import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'

import { useAuth } from '../hooks/useAuth'

export const AuthCallbackPage = () => {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const { completeOAuthLogin } = useAuth()
  const [message, setMessage] = useState('正在完成 OAuth 登入...')

  useEffect(() => {
    let active = true

    const run = async () => {
      const error = searchParams.get('error')

      if (error) {
        if (active) {
          setMessage('OAuth 登入失敗，正在帶你回登入頁...')
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

      const user = await completeOAuthLogin({
        accessToken,
        refreshToken,
      })

      if (active) {
        setMessage('登入成功，正在前往會員中心...')
        navigate(user.role === 'admin' ? '/admin/dashboard' : '/profile', {
          replace: true,
        })
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
