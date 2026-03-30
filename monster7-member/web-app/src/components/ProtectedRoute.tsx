import { Navigate, Outlet, useLocation } from 'react-router-dom'

import { useAuth } from '../hooks/useAuth'

export const ProtectedRoute = ({ requireAdmin = false }: { requireAdmin?: boolean }) => {
  const { initializing, isAuthenticated, tokens, user } = useAuth()
  const location = useLocation()

  if (initializing || (tokens?.accessToken && !user)) {
    return (
      <div className="mx-auto flex min-h-screen max-w-5xl items-center justify-center px-6 py-16">
        <div className="glass-panel rounded-3xl px-8 py-6 text-center shadow-panel">
          <p className="text-sm uppercase tracking-[0.35em] text-slate-500">Loading</p>
          <h1 className="mt-3 text-2xl font-semibold text-slate-900">正在驗證會員狀態</h1>
        </div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />
  }

  if (requireAdmin && user?.role !== 'admin') {
    return (
      <div className="mx-auto flex min-h-screen max-w-4xl items-center justify-center px-6 py-16">
        <div className="glass-panel w-full max-w-xl rounded-[2rem] p-10 text-center shadow-panel">
          <p className="text-sm uppercase tracking-[0.35em] text-orange-500">403</p>
          <h1 className="mt-3 text-3xl font-semibold text-slate-900">這個區域只開放給管理員</h1>
          <p className="mt-4 text-slate-600">
            目前帳號沒有 admin 權限，如果這不是預期行為，請回到會員中心確認。
          </p>
          <Navigate to="/profile" replace />
        </div>
      </div>
    )
  }

  return <Outlet />
}
