import { SectionHeading } from './SectionHeading'
import { useLanguage } from '../i18n/LanguageProvider'

export function HowItWorks() {
  const { copy } = useLanguage()

  return (
    <section id="como-funciona" className="border-b border-line px-5 py-16 sm:px-8 sm:py-20 lg:px-10" aria-labelledby="how-it-works-title">
      <div className="mx-auto max-w-7xl">
        <SectionHeading
          eyebrow={copy.how.eyebrow}
          title={copy.how.titleStart}
          description={copy.how.description}
          headingId="how-it-works-title"
        />
        <div className="mt-10 grid border-y border-line divide-y divide-line lg:grid-cols-3 lg:divide-y-0 lg:divide-x">
          {copy.how.steps.map(([title, description], index) => (
            <article
              key={title}
              className="py-6 lg:px-6 lg:first:pl-0 lg:last:pr-0"
            >
              <span className="mb-5 block font-mono text-xs text-teal">{String(index + 1).padStart(2, '0')} / 03</span>
              <h3 className="text-base font-semibold tracking-tight text-ink">
                {title}
              </h3>
              <p className="mt-2.5 text-sm leading-relaxed text-muted">
                {description}
              </p>
            </article>
          ))}
        </div>
        <div className="mt-8">
          <p className="eyebrow">{copy.trust.label}</p>
          <div className="mt-3 grid border-y border-line divide-y divide-line md:grid-cols-3 md:divide-y-0 md:divide-x">
            {copy.trust.items.map(([title, description]) => (
              <div key={title} className="py-4 md:px-5 md:first:pl-0">
                <h3 className="text-xs font-bold text-ink">{title}</h3>
                <p className="mt-1 text-xs leading-relaxed text-muted">{description}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
