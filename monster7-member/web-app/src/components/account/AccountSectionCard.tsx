import type { PropsWithChildren, ReactNode } from 'react'

export const AccountSectionCard = ({
  title,
  description,
  action,
  children,
}: PropsWithChildren<{
  title: string
  description: string
  action?: ReactNode
}>) => (
  <section className="glass-panel rounded-[2rem] p-6 shadow-panel">
    <div className="flex flex-col gap-4 border-b border-slate-200/70 pb-4 md:flex-row md:items-start md:justify-between">
      <div>
        <p className="text-xs font-semibold uppercase tracking-[0.35em] text-orange-500">
          Account Section
        </p>
        <h2 className="mt-2 text-2xl font-semibold text-slate-900">{title}</h2>
        <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-600">{description}</p>
      </div>
      {action ? <div>{action}</div> : null}
    </div>
    <div className="mt-5">{children}</div>
  </section>
)
