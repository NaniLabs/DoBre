import { useLanguage } from '../i18n/LanguageProvider'

const icons = [<CategoryIcon key="category" />, <SlidersIcon key="sliders" />, <RefreshIcon key="refresh" />]

export function TrustStrip() {
  const { copy } = useLanguage()

  return (
    <section className="relative z-10 border-y border-line bg-surface/70" aria-label={copy.trust.label}>
      <div className="mx-auto grid max-w-7xl divide-y divide-line px-5 sm:px-8 md:grid-cols-3 md:divide-x md:divide-y-0 lg:px-10">
        {copy.trust.items.map(([title, description], index) => (
          <article key={title} className="group flex items-center gap-4 px-1 py-6 sm:px-5 md:px-8 md:py-8">
            <span className="grid size-11 shrink-0 place-items-center rounded-2xl border border-line bg-surface-raised text-teal transition duration-300 group-hover:-translate-y-1 group-hover:shadow-card">
              {icons[index]}
            </span>
            <div>
              <h3 className="text-sm font-extrabold tracking-[-0.025em] text-ink">{title}</h3>
              <p className="mt-1 text-sm leading-5 text-muted">{description}</p>
            </div>
          </article>
        ))}
      </div>
    </section>
  )
}

function CategoryIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M12 3.5 20 8v8l-8 4.5L4 16V8l8-4.5Z" /><path d="m4.4 8.2 7.6 4.3 7.6-4.3M12 12.5V20" /></svg>
}

function SlidersIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"><path d="M4 7h16M4 17h16M8 4v6M16 14v6" /></svg>
}

function RefreshIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="M20 11a8 8 0 0 0-14.8-4.2L3.5 9.5M4 13a8 8 0 0 0 14.8 4.2l1.7-2.7M3.5 5.5v4h4M20.5 18.5v-4h-4" /></svg>
}
