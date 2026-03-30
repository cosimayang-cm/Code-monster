import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'

import { ApiClientError, getOAuthLoginUrl } from '../api/client'
import { useAuth } from '../hooks/useAuth'

const getErrorMessage = (error: unknown) =>
  error instanceof ApiClientError ? error.message : '登入失敗，請稍後再試。'

export const LoginPage = () => {
  const { login } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const from =
    typeof location.state === 'object' &&
    location.state &&
    'from' in location.state &&
    typeof location.state.from === 'string'
      ? location.state.from
      : null

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmitting(true)
    setError(null)

    try {
      const user = await login(email, password)
      navigate(from ?? (user.role === 'admin' ? '/admin/dashboard' : '/profile'), {
        replace: true,
      })
    } catch (nextError) {
      setError(getErrorMessage(nextError))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-5xl items-center px-6 py-12">
      <div className="grid w-full gap-8 lg:grid-cols-[0.95fr_1.05fr]">
        <section className="glass-panel rounded-[2.5rem] p-8 shadow-panel md:p-10">
          <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
            Welcome Back
          </p>
          <h1 className="mt-5 text-4xl font-semibold text-slate-950">登入 Monster7 會員中心</h1>
          <p className="mt-4 text-sm leading-7 text-slate-600">
            先用帳密登入也可以，後面再到會員中心連結 Google 或 GitHub。
          </p>
          <div className="mt-8 space-y-3">
            {(['google', 'github'] as const).map((provider) => (
              <button
                key={provider}
                type="button"
                className="w-full rounded-2xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-800 transition hover:border-slate-400"
                onClick={() => window.location.assign(getOAuthLoginUrl(provider))}
              >
                使用 {provider === 'google' ? 'Google' : 'GitHub'} 登入
              </button>
            ))}
          </div>
        </section>

        <section className="glass-panel rounded-[2.5rem] p-8 shadow-panel md:p-10">
          <form className="space-y-5" onSubmit={handleSubmit}>
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">Email</label>
              <input
                type="email"
                className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none ring-0 transition focus:border-orange-400"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
              />
            </div>

            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">Password</label>
              <input
                type="password"
                className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none ring-0 transition focus:border-orange-400"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                required
              />
            </div>

            {error ? (
              <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
                {error}
              </div>
            ) : null}

            <button
              type="submit"
              className="w-full rounded-2xl bg-slate-950 px-4 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:opacity-60"
              disabled={submitting}
            >
              {submitting ? '登入中...' : '登入'}
            </button>
          </form>

          <div className="mt-6 flex items-center justify-between text-sm text-slate-600">
            <Link to="/forgot-password" className="font-semibold text-ocean hover:text-teal-800">
              忘記密碼？
            </Link>
            <Link to="/register" className="font-semibold text-orange-600 hover:text-orange-700">
              沒有帳號，去註冊
            </Link>
          </div>
        </section>
      </div>
    </main>
  )
}
