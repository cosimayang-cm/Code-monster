import { useState } from 'react'
import { Link } from 'react-router-dom'

import { ApiClientError, apiClient } from '../api/client'

export const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [resetLink, setResetLink] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmitting(true)
    setMessage(null)
    setResetLink(null)
    setError(null)

    try {
      const result = await apiClient.forgotPassword(email)
      setMessage(result.message)
      setResetLink(result.resetLink)
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '無法產生 reset link，請稍後再試。',
      )
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-3xl items-center px-6 py-12">
      <section className="glass-panel w-full rounded-[2.5rem] p-8 shadow-panel md:p-10">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          Password Recovery
        </p>
        <h1 className="mt-5 text-4xl font-semibold text-slate-950">忘記密碼</h1>
        <p className="mt-4 text-sm leading-7 text-slate-600">
          目前是測試模式，成功後會直接在畫面顯示 reset link。
        </p>

        <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
          <div>
            <label className="mb-2 block text-sm font-medium text-slate-700">Email</label>
            <input
              type="email"
              className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
            />
          </div>

          {message ? (
            <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              <p>{message}</p>
              {resetLink ? (
                <a className="mt-2 block break-all font-semibold underline" href={resetLink}>
                  {resetLink}
                </a>
              ) : null}
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
            disabled={submitting}
          >
            {submitting ? '產生中...' : '產生 reset link'}
          </button>
        </form>

        <Link to="/login" className="mt-6 inline-block text-sm font-semibold text-ocean hover:text-teal-800">
          回登入頁
        </Link>
      </section>
    </main>
  )
}
