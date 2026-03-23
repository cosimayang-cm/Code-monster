import { useMemo, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'

import { ApiClientError, apiClient } from '../api/client'

export const ResetPasswordPage = () => {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const token = useMemo(() => searchParams.get('token') ?? '', [searchParams])
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmitting(true)
    setMessage(null)
    setError(null)

    try {
      const nextMessage = await apiClient.resetPassword({ token, password })
      setMessage(nextMessage)
      window.setTimeout(() => navigate('/login'), 1200)
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '重設密碼失敗，請稍後再試。',
      )
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-3xl items-center px-6 py-12">
      <section className="glass-panel w-full rounded-[2.5rem] p-8 shadow-panel md:p-10">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          Reset Password
        </p>
        <h1 className="mt-5 text-4xl font-semibold text-slate-950">設定新的密碼</h1>
        {!token ? (
          <div className="mt-8 rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-700">
            沒有找到 reset token，請回到忘記密碼頁重新產生。
          </div>
        ) : null}

        <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
          <div>
            <label className="mb-2 block text-sm font-medium text-slate-700">新密碼</label>
            <input
              type="password"
              className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
              disabled={!token}
            />
          </div>

          {message ? (
            <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              {message}
            </div>
          ) : null}

          {error ? (
            <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
              {error}
            </div>
          ) : null}

          <button
            type="submit"
            className="w-full rounded-2xl bg-slate-950 px-4 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:opacity-60"
            disabled={submitting || !token}
          >
            {submitting ? '重設中...' : '送出新密碼'}
          </button>
        </form>

        <Link to="/login" className="mt-6 inline-block text-sm font-semibold text-ocean hover:text-teal-800">
          回登入頁
        </Link>
      </section>
    </main>
  )
}
