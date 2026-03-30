import { useEffect, useState } from 'react'

import { ApiClientError, apiClient } from '../../api/client'
import type { DashboardStats } from '../../types'

export const DashboardPage = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let active = true

    const load = async () => {
      try {
        const nextStats = await apiClient.getDashboardStats()

        if (active) {
          setStats(nextStats)
        }
      } catch (nextError) {
        if (active) {
          setError(
            nextError instanceof ApiClientError
              ? nextError.message
              : '無法載入 dashboard 資料。',
          )
        }
      }
    }

    void load()

    return () => {
      active = false
    }
  }, [])

  return (
    <section className="space-y-6">
      <div className="glass-panel rounded-[2rem] p-6 shadow-panel">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          Dashboard
        </p>
        <h1 className="mt-4 text-4xl font-semibold text-slate-950">系統概覽</h1>
        <p className="mt-3 text-sm leading-7 text-slate-600">
          這裡匯總註冊、活躍、停用與 OAuth 連結比例，方便確認會員系統整體狀況。
        </p>
      </div>

      {error ? (
        <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {error}
        </div>
      ) : null}

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {[
          ['總會員數', stats?.totalUsers ?? 0],
          ['今日註冊', stats?.todayRegistrations ?? 0],
          ['7 日活躍', stats?.activeUsers7d ?? 0],
          ['停用帳號', stats?.disabledUsers ?? 0],
          ['OAuth 連結比例', stats ? `${Math.round(stats.oauthLinkedRatio * 100)}%` : '0%'],
          ['24h 登入次數', stats?.logins24h ?? 0],
        ].map(([label, value]) => (
          <div key={label} className="glass-panel rounded-[1.75rem] p-5 shadow-panel">
            <p className="text-xs uppercase tracking-[0.25em] text-slate-500">{label}</p>
            <p className="mt-4 text-4xl font-semibold text-slate-950">{value}</p>
          </div>
        ))}
      </div>
    </section>
  )
}
