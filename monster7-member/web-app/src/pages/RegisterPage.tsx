import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'

import { ApiClientError } from '../api/client'
import { useAuth } from '../hooks/useAuth'

const getErrorMessage = (error: unknown) =>
  error instanceof ApiClientError ? error.message : '註冊失敗，請稍後再試。'

export const RegisterPage = () => {
  const { register } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmitting(true)
    setError(null)

    try {
      await register(email, password)
      navigate('/profile', { replace: true })
    } catch (nextError) {
      setError(getErrorMessage(nextError))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-5xl items-center px-6 py-12">
      <div className="grid w-full gap-8 lg:grid-cols-[1fr_1fr]">
        <section className="glass-panel rounded-[2.5rem] p-8 shadow-panel md:p-10">
          <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
            New Member
          </p>
          <h1 className="mt-5 text-4xl font-semibold text-slate-950">建立你的 Monster7 帳號</h1>
          <p className="mt-4 text-sm leading-7 text-slate-600">
            密碼需至少 8 碼，並包含大寫、小寫與數字。註冊完成後會直接進入會員中心。
          </p>
        </section>

        <section className="glass-panel rounded-[2.5rem] p-8 shadow-panel md:p-10">
          <form className="space-y-5" onSubmit={handleSubmit}>
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

            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">Password</label>
              <input
                type="password"
                className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
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
              {submitting ? '建立中...' : '建立帳號'}
            </button>
          </form>

          <p className="mt-6 text-sm text-slate-600">
            已經有帳號？
            <Link to="/login" className="ml-2 font-semibold text-orange-600 hover:text-orange-700">
              直接登入
            </Link>
          </p>
        </section>
      </div>
    </main>
  )
}
