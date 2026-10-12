import { useLanguage } from '../i18n/LanguageProvider'

export function IndependenceNotice() {
  const { copy } = useLanguage()

  return (
    <section className="bg-canvas px-5 py-10 sm:px-8 lg:px-10" aria-labelledby="independence-title">
      <div className="mx-auto max-w-7xl rounded-xl border border-line bg-surface p-5 sm:p-6">
        <h2 id="independence-title" className="text-sm font-semibold text-ink">
          {copy.notice.title}
        </h2>
        <p className="mt-1.5 text-xs leading-relaxed text-muted sm:text-sm">
          {copy.notice.text}
        </p>
      </div>
    </section>
  )
}
