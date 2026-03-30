import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { ApiClientError, apiClient } from '../../api/client'
import type { AdminUserDetail } from '../../types'

export const UserDetailPage = () => {
  const { id = '' } = useParams()
  const [detail, setDetail] = useState<AdminUserDetail | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [busyAction, setBusyAction] = useState<string | null>(null)

  const loadDetail = async () => {
    const nextDetail = await apiClient.getAdminUserDetail(id)
    setDetail(nextDetail)
  }

  useEffect(() => {
    let active = true

    const run = async () => {
      try {
        const nextDetail = await apiClient.getAdminUserDetail(id)

        if (active) {
          setDetail(nextDetail)
        }
      } catch (nextError) {
        if (active) {
          setError(
            nextError instanceof ApiClientError
              ? nextError.message
              : '無法載入使用者詳情。',
          )
        }
      }
    }

    void run()

    return () => {
      active = false
    }
  }, [id])

  const handleRoleToggle = async () => {
    if (!detail) {
      return
    }

    setBusyAction('role')
    setError(null)

    try {
      await apiClient.updateAdminUserRole(id, detail.role === 'admin' ? 'user' : 'admin')
      await loadDetail()
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '更新角色失敗。',
      )
    } finally {
      setBusyAction(null)
    }
  }

  const handleStatusToggle = async () => {
    if (!detail) {
      return
    }

    setBusyAction('status')
    setError(null)

    try {
      await apiClient.updateAdminUserStatus(id, !detail.is_active)
      await loadDetail()
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '更新帳號狀態失敗。',
      )
    } finally {
      setBusyAction(null)
    }
  }

  if (!detail && !error) {
    return (
      <section className="glass-panel rounded-[2rem] p-6 shadow-panel">
        <p className="text-sm text-slate-500">載入使用者資料中...</p>
      </section>
    )
  }

  return (
    <section className="space-y-6">
      <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
        <Link to="/admin/users" className="text-sm font-semibold text-ocean hover:text-teal-800">
          回使用者列表
        </Link>
        <h1 className="mt-4 text-4xl font-semibold text-slate-950">{detail?.email}</h1>
        <p className="mt-3 text-sm leading-7 text-slate-600">
          可在這裡變更角色、停用或重新啟用帳號，並查看 OAuth 與最近登入紀錄。
        </p>
      </div>

      {error ? (
        <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {error}
        </div>
      ) : null}

      {detail ? (
        <>
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {[
              ['Name', detail.name ?? '-'],
              ['Role', detail.role],
              ['Status', detail.is_active ? 'Active' : 'Disabled'],
              ['Created', detail.created_at],
            ].map(([label, value]) => (
              <div key={label} className="glass-panel rounded-[1.75rem] p-5 shadow-panel">
                <p className="text-xs uppercase tracking-[0.25em] text-slate-500">{label}</p>
                <p className="mt-3 text-lg font-semibold text-slate-900">{value}</p>
              </div>
            ))}
          </div>

          <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
            <div className="flex flex-wrap gap-3">
              <button
                type="button"
                className="rounded-full bg-slate-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:opacity-60"
                onClick={handleRoleToggle}
                disabled={busyAction === 'role'}
              >
                {busyAction === 'role'
                  ? '更新中...'
                  : detail.role === 'admin'
                    ? '降為 user'
                    : '升為 admin'}
              </button>
              <button
                type="button"
                className="rounded-full border border-slate-300 bg-white px-5 py-3 text-sm font-semibold text-slate-800 transition hover:border-slate-400 disabled:opacity-60"
                onClick={handleStatusToggle}
                disabled={busyAction === 'status'}
              >
                {busyAction === 'status'
                  ? '更新中...'
                  : detail.is_active
                    ? '停用帳號'
                    : '重新啟用帳號'}
              </button>
            </div>
          </div>

          <div className="grid gap-6 xl:grid-cols-2">
            <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
              <h2 className="text-2xl font-semibold text-slate-950">OAuth 連結</h2>
              <div className="mt-5 space-y-3">
                {detail.oauthAccounts.length === 0 ? (
                  <p className="text-sm text-slate-500">尚未連結 OAuth 帳號。</p>
                ) : (
                  detail.oauthAccounts.map((account) => (
                    <div key={`${account.provider}-${account.created_at}`} className="rounded-[1.5rem] border border-slate-200 bg-white/70 p-4">
                      <p className="text-sm font-semibold text-slate-900">{account.provider}</p>
                      <p className="mt-2 text-sm text-slate-600">{account.provider_email ?? '-'}</p>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
              <h2 className="text-2xl font-semibold text-slate-950">最近登入</h2>
              <div className="mt-5 space-y-3">
                {detail.recentLogins.length === 0 ? (
                  <p className="text-sm text-slate-500">沒有登入紀錄。</p>
                ) : (
                  detail.recentLogins.map((item) => (
                    <div key={`${item.created_at}-${item.ip_address}`} className="rounded-[1.5rem] border border-slate-200 bg-white/70 p-4">
                      <p className="text-sm font-semibold uppercase tracking-[0.25em] text-slate-500">
                        {item.method}
                      </p>
                      <p className="mt-2 text-sm text-slate-700">{item.ip_address}</p>
                      <p className="mt-1 text-sm text-slate-500">{item.created_at}</p>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </>
      ) : null}
    </section>
  )
}
