import { Link } from 'react-router-dom'

export const NotFoundPage = () => (
  <main className="mx-auto flex min-h-screen max-w-3xl items-center justify-center px-6 py-12">
    <section className="glass-panel w-full rounded-[2.5rem] p-10 text-center shadow-panel">
      <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">404</p>
      <h1 className="mt-5 text-3xl font-semibold text-slate-950">找不到這個頁面</h1>
      <p className="mt-4 text-slate-600">這個路由目前不存在，可能是連結已過期或輸入有誤。</p>
      <Link
        to="/"
        className="mt-8 inline-flex rounded-full bg-slate-950 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800"
      >
        回首頁
      </Link>
    </section>
  </main>
)
