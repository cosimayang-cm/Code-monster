import { Link } from 'react-router-dom'

export const HomePage = () => (
  <main className="mx-auto max-w-6xl px-6 py-12 md:px-8 md:py-20">
    <div className="grid gap-8 lg:grid-cols-[1.2fr_0.8fr]">
      <section className="glass-panel rounded-[2.5rem] p-8 shadow-panel md:p-12">
        <p className="text-sm font-semibold uppercase tracking-[0.35em] text-orange-500">
          Cloudflare Member System
        </p>
        <h1 className="mt-6 max-w-3xl text-5xl font-semibold leading-tight text-slate-950 md:text-6xl">
          用 Cloudflare 原生服務打造一套完整會員中心。
        </h1>
        <p className="mt-6 max-w-2xl text-lg leading-8 text-slate-600">
          這個實作包含帳密認證、會員資料管理、OAuth、登入歷史，以及一套獨立的
          admin 後台。前端採 section-based account center，讓個人資料與安全設定更清楚。
        </p>
        <div className="mt-10 flex flex-wrap gap-4">
          <Link
            to="/register"
            className="rounded-full bg-slate-950 px-6 py-3 text-sm font-semibold text-white transition hover:bg-slate-800"
          >
            建立帳號
          </Link>
          <Link
            to="/login"
            className="rounded-full border border-slate-300 bg-white/70 px-6 py-3 text-sm font-semibold text-slate-800 transition hover:border-slate-400"
          >
            會員登入
          </Link>
        </div>
      </section>

      <aside className="space-y-4">
        {[
          '帳密註冊、登入、refresh token',
          '忘記密碼與重設流程',
          '頭像上傳到 R2 public bucket',
          'Google / GitHub OAuth',
          'Admin dashboard、Users、Activity',
        ].map((item) => (
          <div key={item} className="glass-panel rounded-[1.75rem] p-5 shadow-panel">
            <p className="text-sm leading-6 text-slate-700">{item}</p>
          </div>
        ))}
      </aside>
    </div>
  </main>
)
