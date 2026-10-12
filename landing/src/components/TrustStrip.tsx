import { useLanguage } from '../i18n/LanguageProvider'

export function TrustStrip() {
  const { copy } = useLanguage()

  return (
    <section className="border-b border-line bg-surface" aria-label={copy.trust.label}>
      <div className="mx-auto grid max-w-7xl divide-y divide-line px-5 sm:px-8 md:grid-cols-3 md:divide-x md:divide-y-0 lg:px-10">
        {copy.trust.items.map(([title, description]) => (
          <article key={title} className="py-5 md:px-6 md:first:pl-0 md:last:pr-0">
            <h3 className="text-sm font-semibold tracking-tight text-ink">{title}</h3>
            <p className="mt-1 text-xs leading-relaxed text-muted">{description}</p>
          </article>
        ))}
      </div>
    </section>
  )
}
