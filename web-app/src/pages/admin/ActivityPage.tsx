import { useEffect, useState } from 'react'

import { ApiClientError, apiClient } from '../../api/client'
import type { AdminActivityItem, PaginationMeta } from '../../types'

export const ActivityPage = () => {
  const [rows, setRows] = useState<AdminActivityItem[]>([])
  const [pagination, setPagination] = useState<PaginationMeta | null>(null)
  const [page, setPage] = useState(1)
  const [method, setMethod] = useState('')
  const [from, setFrom] = useState('')
  const [to, setTo] = useState('')
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let active = true

    const load = async () => {
      try {
        const result = await apiClient.getAdminActivity({
          page,
          pageSize: 20,
          method,
          from,
          to,
        })

        if (active) {
          setRows(result.rows)
          setPagination(result.pagination)
        }
      } catch (nextError) {
        if (active) {
          setError(
            nextError instanceof ApiClientError
              ? nextError.message
              : '無法載入活動日誌。',
          )
        }
      }
    }

    void load()

    return () => {
      active = false
    }
  }, [from, method, page, to])

  return (
    <section className="space-y-6">
      <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          Activity
        </p>
        <h1 className="mt-4 text-4xl font-semibold text-slate-950">全站活動日誌</h1>
        <div className="mt-6 grid gap-4 md:grid-cols-3">
          <select
            className="rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
            value={method}
            onChange={(event) => {
              setPage(1)
              setMethod(event.target.value)
            }}
          >
            <option value="">全部登入方式</option>
            <option value="email">Email</option>
            <option value="google">Google</option>
            <option value="github">GitHub</option>
          </select>
          <input
            type="date"
            className="rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
            value={from}
            onChange={(event) => {
              setPage(1)
              setFrom(event.target.value)
            }}
          />
          <input
            type="date"
            className="rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
            value={to}
            onChange={(event) => {
              setPage(1)
              setTo(event.target.value)
            }}
          />
        </div>
      </div>

      {error ? (
        <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {error}
        </div>
      ) : null}

      <div className="space-y-3">
        {rows.map((item) => (
          <div key={item.id} className="glass-panel rounded-[1.75rem] p-5 shadow-panel">
            <div className="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
              <div>
                <p className="text-xs uppercase tracking-[0.25em] text-slate-500">{item.method}</p>
                <h2 className="mt-2 text-lg font-semibold text-slate-900">
                  {item.name ?? item.email}
                </h2>
                <p className="mt-1 text-sm text-slate-600">{item.email}</p>
              </div>
              <div className="text-sm text-slate-500">
                <p>{item.ip_address}</p>
                <p className="mt-1">{item.created_at}</p>
              </div>
            </div>
            <p className="mt-4 text-sm text-slate-600">{item.user_agent}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-slate-600">
          第 {pagination?.page ?? 1} / {pagination?.totalPages ?? 1} 頁，共 {pagination?.total ?? 0} 筆
        </p>
        <div className="flex gap-3">
          <button
            type="button"
            className="rounded-full border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-800 transition hover:border-slate-400 disabled:opacity-50"
            disabled={page <= 1}
            onClick={() => setPage((current) => Math.max(1, current - 1))}
          >
            上一頁
          </button>
          <button
            type="button"
            className="rounded-full bg-slate-950 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:opacity-50"
            disabled={page >= (pagination?.totalPages ?? 1)}
            onClick={() => setPage((current) => current + 1)}
          >
            下一頁
          </button>
        </div>
      </div>
    </section>
  )
}
