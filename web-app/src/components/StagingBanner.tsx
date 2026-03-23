export const StagingBanner = () => {
  if (import.meta.env.VITE_APP_ENV !== 'staging') {
    return null
  }

  return (
    <div className="sticky top-0 z-50 border-b border-orange-200 bg-orange-500 px-4 py-2 text-center text-sm font-semibold tracking-[0.3em] text-white">
      STAGING
    </div>
  )
}
