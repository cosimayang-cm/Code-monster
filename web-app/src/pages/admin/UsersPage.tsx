import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'

import { ApiClientError, apiClient } from '../../api/client'
import type { AdminUserSummary, PaginationMeta } from '../../types'

export const UsersPage = () => {
  const [users, setUsers] = useState<AdminUserSummary[]>([])
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [pagination, setPagination] = useState<PaginationMeta | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let active = true

    const load = async () => {
      try {
        const result = await apiClient.getAdminUsers(page, 20, search)

        if (active) {
          setUsers(result.rows)
          setPagination(result.pagination)
        }
      } catch (nextError) {
        if (active) {
          setError(
            nextError instanceof ApiClientError
              ? nextError.message
              : '無法載入使用者列表。',
          )
        }
      }
    }

    void load()

    return () => {
      active = false
    }
  }, [page, search])

  return (
    <section className="space-y-6">
      <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
              Users
            </p>
            <h1 className="mt-4 text-4xl font-semibold text-slate-950">會員列表</h1>
          </div>
          <input
            type="search"
            className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400 lg:max-w-sm"
            placeholder="搜尋 email 或 name"
            value={search}
            onChange={(event) => {
              setPage(1)
              setSearch(event.target.value)
            }}
          />
        </div>
      </div>

      {error ? (
        <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {error}
        </div>
      ) : null}

      <div className="glass-panel overflow-hidden rounded-[2rem] shadow-panel">
        <div className="overflow-x-auto">
          <table className="min-w-full border-collapse">
            <thead>
              <tr className="border-b border-slate-200 bg-white/60 text-left text-xs uppercase tracking-[0.25em] text-slate-500">
                <th className="px-5 py-4">Email</th>
                <th className="px-5 py-4">Name</th>
                <th className="px-5 py-4">Role</th>
                <th className="px-5 py-4">Status</th>
                <th className="px-5 py-4">Created</th>
                <th className="px-5 py-4" />
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b border-slate-100 text-sm text-slate-700">
                  <td className="px-5 py-4">{user.email}</td>
                  <td className="px-5 py-4">{user.name ?? '-'}</td>
                  <td className="px-5 py-4">{user.role}</td>
                  <td className="px-5 py-4">{user.is_active ? 'Active' : 'Disabled'}</td>
                  <td className="px-5 py-4">{user.created_at}</td>
                  <td className="px-5 py-4 text-right">
                    <Link
                      to={`/admin/users/${user.id}`}
                      className="font-semibold text-orange-600 hover:text-orange-700"
                    >
                      查看
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
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
