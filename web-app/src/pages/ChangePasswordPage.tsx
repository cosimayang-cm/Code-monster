import { useState } from 'react'
import { Link } from 'react-router-dom'

import { ApiClientError, apiClient } from '../api/client'

export const ChangePasswordPage = () => {
  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmitting(true)
    setMessage(null)
    setError(null)

    try {
      const nextMessage = await apiClient.changePassword({
        currentPassword,
        newPassword,
      })
      setMessage(nextMessage)
      setCurrentPassword('')
      setNewPassword('')
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '修改密碼失敗，請稍後再試。',
      )
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-12">
      <section className="glass-panel rounded-[2.5rem] p-8 shadow-panel md:p-10">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          Security
        </p>
        <h1 className="mt-5 text-4xl font-semibold text-slate-950">修改密碼</h1>
        <p className="mt-4 text-sm leading-7 text-slate-600">
          新密碼仍需符合至少 8 碼，並包含大寫、小寫與數字。
        </p>

        <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
          <div>
            <label className="mb-2 block text-sm font-medium text-slate-700">目前密碼</label>
            <input
              type="password"
              className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
              value={currentPassword}
              onChange={(event) => setCurrentPassword(event.target.value)}
              required
            />
          </div>

          <div>
            <label className="mb-2 block text-sm font-medium text-slate-700">新密碼</label>
            <input
              type="password"
              className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
              value={newPassword}
              onChange={(event) => setNewPassword(event.target.value)}
              required
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
            disabled={submitting}
          >
            {submitting ? '更新中...' : '更新密碼'}
          </button>
        </form>

        <Link to="/profile" className="mt-6 inline-block text-sm font-semibold text-ocean hover:text-teal-800">
          回會員中心
        </Link>
      </section>
    </main>
  )
}
