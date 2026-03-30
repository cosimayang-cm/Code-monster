import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'

import { ApiClientError, apiClient } from '../api/client'
import { AccountSectionCard } from '../components/account/AccountSectionCard'
import { useAuth } from '../hooks/useAuth'
import type { LoginHistoryItem, OAuthAccount } from '../types'

const providerLabel: Record<'google' | 'github', string> = {
  google: 'Google',
  github: 'GitHub',
}

export const ProfilePage = () => {
  const { user, refreshUser, logout } = useAuth()
  const [searchParams] = useSearchParams()
  const [name, setName] = useState(user?.name ?? '')
  const [bio, setBio] = useState(user?.bio ?? '')
  const [message, setMessage] = useState<string | null>(
    searchParams.get('oauthLinked')
      ? `${providerLabel[searchParams.get('oauthLinked') as 'google' | 'github']} 已成功連結。`
      : null,
  )
  const [error, setError] = useState<string | null>(null)
  const [submittingProfile, setSubmittingProfile] = useState(false)
  const [uploadingAvatar, setUploadingAvatar] = useState(false)
  const [history, setHistory] = useState<LoginHistoryItem[]>([])
  const [accounts, setAccounts] = useState<OAuthAccount[]>([])
  const [loadingMeta, setLoadingMeta] = useState(true)

  useEffect(() => {
    setName(user?.name ?? '')
    setBio(user?.bio ?? '')
  }, [user?.bio, user?.name])

  useEffect(() => {
    let active = true

    const loadMeta = async () => {
      try {
        const [historyResult, oauthAccounts] = await Promise.all([
          apiClient.getLoginHistory(1, 20),
          apiClient.getOAuthAccounts(),
        ])

        if (active) {
          setHistory(historyResult.rows)
          setAccounts(oauthAccounts)
        }
      } catch (nextError) {
        if (active) {
          setError(
            nextError instanceof ApiClientError
              ? nextError.message
              : '無法載入會員附加資料。',
          )
        }
      } finally {
        if (active) {
          setLoadingMeta(false)
        }
      }
    }

    void loadMeta()

    return () => {
      active = false
    }
  }, [])

  const refreshMeta = async () => {
    const [historyResult, oauthAccounts] = await Promise.all([
      apiClient.getLoginHistory(1, 20),
      apiClient.getOAuthAccounts(),
    ])
    setHistory(historyResult.rows)
    setAccounts(oauthAccounts)
  }

  const handleProfileSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSubmittingProfile(true)
    setMessage(null)
    setError(null)

    try {
      await apiClient.updateProfile({
        name: name.trim() || null,
        bio: bio.trim() || null,
      })
      await refreshUser()
      setMessage('基本資料已更新。')
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '更新會員資料失敗。',
      )
    } finally {
      setSubmittingProfile(false)
    }
  }

  const handleAvatarChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]

    if (!file) {
      return
    }

    setUploadingAvatar(true)
    setMessage(null)
    setError(null)

    try {
      await apiClient.uploadAvatar(file)
      await refreshUser()
      setMessage('頭像已更新。')
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '頭像上傳失敗。',
      )
    } finally {
      setUploadingAvatar(false)
      event.target.value = ''
    }
  }

  const handleLinkOAuth = async (provider: 'google' | 'github') => {
    setError(null)

    try {
      const authorizationUrl = await apiClient.getLinkOAuthUrl(provider)
      window.location.assign(authorizationUrl)
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '無法啟動 OAuth 連結流程。',
      )
    }
  }

  const handleUnlinkOAuth = async (provider: 'google' | 'github') => {
    setError(null)
    setMessage(null)

    try {
      const nextMessage = await apiClient.unlinkOAuthAccount(provider)
      await refreshMeta()
      setMessage(nextMessage)
    } catch (nextError) {
      setError(
        nextError instanceof ApiClientError
          ? nextError.message
          : '解除 OAuth 連結失敗。',
      )
    }
  }

  return (
    <main className="mx-auto max-w-6xl px-6 py-8 md:px-8 md:py-12">
      <div className="mb-8 flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
            Member Center
          </p>
          <h1 className="mt-4 text-4xl font-semibold text-slate-950">你好，{user?.name || user?.email}</h1>
          <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-600">
            這裡把個人資料、安全設定、OAuth、登入歷史與帳號操作拆成獨立 section，
            之後擴充 email 驗證或更多帳號設定時也比較好維護。
          </p>
        </div>
        <div className="glass-panel rounded-2xl px-5 py-4 shadow-panel">
          <p className="text-xs uppercase tracking-[0.35em] text-slate-500">Role</p>
          <p className="mt-2 text-lg font-semibold text-slate-900">{user?.role}</p>
        </div>
      </div>

      {(message || error) && (
        <div
          className={`mb-6 rounded-2xl border px-4 py-3 text-sm ${
            error
              ? 'border-rose-200 bg-rose-50 text-rose-700'
              : 'border-emerald-200 bg-emerald-50 text-emerald-700'
          }`}
        >
          {error ?? message}
        </div>
      )}

      <div className="space-y-6">
        <AccountSectionCard
          title="基本資料"
          description="更新顯示名稱、簡介與頭像。頭像會上傳到 R2 public bucket，大小上限 5MB。"
        >
          <div className="grid gap-6 lg:grid-cols-[0.7fr_1.3fr]">
            <div className="rounded-[1.5rem] border border-slate-200 bg-white/70 p-5">
              <p className="text-sm font-semibold text-slate-700">目前頭像</p>
              <div className="mt-4 flex h-36 w-36 items-center justify-center overflow-hidden rounded-[1.5rem] bg-slate-100 text-3xl font-semibold text-slate-500">
                {user?.avatar_url ? (
                  <img src={user.avatar_url} alt="Avatar" className="h-full w-full object-cover" />
                ) : (
                  (user?.email?.[0] ?? 'M').toUpperCase()
                )}
              </div>
              <label className="mt-5 inline-flex rounded-full bg-slate-950 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-800">
                {uploadingAvatar ? '上傳中...' : '更換頭像'}
                <input
                  type="file"
                  className="hidden"
                  accept="image/png,image/jpeg,image/webp"
                  onChange={handleAvatarChange}
                  disabled={uploadingAvatar}
                />
              </label>
            </div>

            <form className="space-y-4" onSubmit={handleProfileSubmit}>
              <div>
                <label className="mb-2 block text-sm font-medium text-slate-700">Email</label>
                <input
                  type="email"
                  className="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-slate-500"
                  value={user?.email ?? ''}
                  disabled
                />
              </div>
              <div>
                <label className="mb-2 block text-sm font-medium text-slate-700">顯示名稱</label>
                <input
                  type="text"
                  className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
                  value={name}
                  onChange={(event) => setName(event.target.value)}
                  maxLength={100}
                />
              </div>
              <div>
                <label className="mb-2 block text-sm font-medium text-slate-700">個人簡介</label>
                <textarea
                  className="min-h-32 w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none transition focus:border-orange-400"
                  value={bio}
                  onChange={(event) => setBio(event.target.value)}
                  maxLength={500}
                />
              </div>
              <button
                type="submit"
                className="rounded-full bg-slate-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 disabled:opacity-60"
                disabled={submittingProfile}
              >
                {submittingProfile ? '儲存中...' : '儲存基本資料'}
              </button>
            </form>
          </div>
        </AccountSectionCard>

        <AccountSectionCard
          title="安全"
          description="目前支援修改密碼，未來若擴充 email / phone 變更，會另外加上 re-auth 或 OTP 驗證流程。"
          action={
            <Link
              to="/change-password"
              className="rounded-full border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-800 transition hover:border-slate-400"
            >
              前往修改密碼
            </Link>
          }
        >
          <div className="grid gap-4 md:grid-cols-3">
            {[
              { label: '註冊時間', value: user?.created_at ?? '-' },
              { label: '最後更新', value: user?.updated_at ?? '-' },
              { label: '帳號狀態', value: user?.is_active ? 'Active' : 'Disabled' },
            ].map((item) => (
              <div key={item.label} className="rounded-[1.5rem] border border-slate-200 bg-white/70 p-4">
                <p className="text-xs uppercase tracking-[0.25em] text-slate-500">{item.label}</p>
                <p className="mt-3 text-sm font-medium text-slate-800">{item.value}</p>
              </div>
            ))}
          </div>
        </AccountSectionCard>

        <AccountSectionCard
          title="OAuth 連結"
          description="可以把 Google 或 GitHub 當成額外登入方式。若帳號沒有密碼，不能把最後一個 OAuth 連結解除。"
        >
          <div className="grid gap-4 md:grid-cols-2">
            {(['google', 'github'] as const).map((provider) => {
              const existing = accounts.find((account) => account.provider === provider)

              return (
                <div key={provider} className="rounded-[1.5rem] border border-slate-200 bg-white/70 p-5">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <p className="text-lg font-semibold text-slate-900">{providerLabel[provider]}</p>
                      <p className="mt-2 text-sm text-slate-600">
                        {existing?.provider_email ?? '尚未連結'}
                      </p>
                    </div>
                    {existing ? (
                      <button
                        type="button"
                        className="rounded-full border border-rose-300 px-4 py-2 text-sm font-semibold text-rose-600 transition hover:border-rose-400"
                        onClick={() => handleUnlinkOAuth(provider)}
                      >
                        解除連結
                      </button>
                    ) : (
                      <button
                        type="button"
                        className="rounded-full bg-ocean px-4 py-2 text-sm font-semibold text-white transition hover:bg-teal-800"
                        onClick={() => handleLinkOAuth(provider)}
                      >
                        連結帳號
                      </button>
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        </AccountSectionCard>

        <AccountSectionCard
          title="登入歷史"
          description="列出最近 20 筆登入紀錄，包含登入方式、IP 與 User-Agent。"
        >
          {loadingMeta ? (
            <p className="text-sm text-slate-500">載入中...</p>
          ) : history.length === 0 ? (
            <p className="text-sm text-slate-500">目前還沒有登入歷史。</p>
          ) : (
            <div className="space-y-3">
              {history.map((item) => (
                <div
                  key={item.id}
                  className="rounded-[1.5rem] border border-slate-200 bg-white/70 p-4"
                >
                  <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                    <div>
                      <p className="text-sm font-semibold uppercase tracking-[0.25em] text-slate-500">
                        {item.method}
                      </p>
                      <p className="mt-2 text-sm text-slate-700">{item.user_agent}</p>
                    </div>
                    <div className="text-sm text-slate-500">
                      <p>{item.ip_address}</p>
                      <p>{item.created_at}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </AccountSectionCard>

        <AccountSectionCard
          title="帳號操作"
          description="目前提供安全登出。後續若有刪除帳號或更多偏好設定，也會集中在這一區。"
        >
          <button
            type="button"
            className="rounded-full border border-slate-300 bg-white px-5 py-3 text-sm font-semibold text-slate-800 transition hover:border-slate-400"
            onClick={logout}
          >
            登出
          </button>
        </AccountSectionCard>
      </div>
    </main>
  )
}
