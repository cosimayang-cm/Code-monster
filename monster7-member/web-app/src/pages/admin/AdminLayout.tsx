import { NavLink, Outlet } from 'react-router-dom'

import { useAuth } from '../../hooks/useAuth'

const navigation = [
  { to: '/admin/dashboard', label: 'Dashboard' },
  { to: '/admin/users', label: 'Users' },
  { to: '/admin/activity', label: 'Activity' },
]

export const AdminLayout = () => {
  const { user, logout } = useAuth()

  return (
    <main className="mx-auto min-h-screen max-w-7xl px-6 py-8 md:px-8 md:py-10">
      <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
        <aside className="glass-panel h-fit rounded-[2rem] p-6 shadow-panel">
          <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
            Admin Console
          </p>
          <h1 className="mt-4 text-3xl font-semibold text-slate-950">Monster7 Backoffice</h1>
          <p className="mt-3 text-sm leading-7 text-slate-600">
            這裡是獨立 admin layout，集中處理 dashboard、會員管理與活動日誌。
          </p>

          <nav className="mt-8 space-y-2">
            {navigation.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `block rounded-2xl px-4 py-3 text-sm font-semibold transition ${
                    isActive
                      ? 'bg-slate-950 text-white'
                      : 'bg-white/70 text-slate-700 hover:bg-white'
                  }`
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>

          <div className="mt-8 rounded-[1.5rem] border border-slate-200 bg-white/70 p-4">
            <p className="text-xs uppercase tracking-[0.25em] text-slate-500">Signed in as</p>
            <p className="mt-2 text-sm font-semibold text-slate-900">{user?.email}</p>
          </div>

          <button
            type="button"
            className="mt-6 w-full rounded-2xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-800 transition hover:border-slate-400"
            onClick={logout}
          >
            登出
          </button>
        </aside>

        <div className="min-w-0">
          <Outlet />
        </div>
      </div>
    </main>
  )
}
