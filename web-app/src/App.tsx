import { Navigate, Route, Routes } from 'react-router-dom'

import { ProtectedRoute } from './components/ProtectedRoute'
import { StagingBanner } from './components/StagingBanner'
import { useAuth } from './hooks/useAuth'
import { AuthCallbackPage } from './pages/AuthCallbackPage'
import { ChangePasswordPage } from './pages/ChangePasswordPage'
import { ForgotPasswordPage } from './pages/ForgotPasswordPage'
import { HomePage } from './pages/HomePage'
import { LoginPage } from './pages/LoginPage'
import { NotFoundPage } from './pages/NotFoundPage'
import { ProfilePage } from './pages/ProfilePage'
import { RegisterPage } from './pages/RegisterPage'
import { ResetPasswordPage } from './pages/ResetPasswordPage'
import { ActivityPage } from './pages/admin/ActivityPage'
import { AdminLayout } from './pages/admin/AdminLayout'
import { DashboardPage } from './pages/admin/DashboardPage'
import { UserDetailPage } from './pages/admin/UserDetailPage'
import { UsersPage } from './pages/admin/UsersPage'

const RootRedirect = () => {
  const { initializing, isAuthenticated, user } = useAuth()

  if (initializing || (isAuthenticated && !user)) {
    return (
      <div className="mx-auto flex min-h-screen max-w-5xl items-center justify-center px-6 py-16">
        <div className="glass-panel rounded-3xl px-8 py-6 text-center shadow-panel">
          <p className="text-sm uppercase tracking-[0.35em] text-slate-500">Loading</p>
          <h1 className="mt-3 text-2xl font-semibold text-slate-900">正在建立會員工作階段</h1>
        </div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return <HomePage />
  }

  return <Navigate to={user?.role === 'admin' ? '/admin/dashboard' : '/profile'} replace />
}

function App() {
  return (
    <div className="app-shell">
      <StagingBanner />
      <Routes>
        <Route path="/" element={<RootRedirect />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/reset-password" element={<ResetPasswordPage />} />
        <Route path="/auth/callback" element={<AuthCallbackPage />} />

        <Route element={<ProtectedRoute />}>
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/change-password" element={<ChangePasswordPage />} />
        </Route>

        <Route element={<ProtectedRoute requireAdmin />}>
          <Route path="/admin" element={<AdminLayout />}>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="users" element={<UsersPage />} />
            <Route path="users/:id" element={<UserDetailPage />} />
            <Route path="activity" element={<ActivityPage />} />
          </Route>
        </Route>

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </div>
  )
}

export default App
