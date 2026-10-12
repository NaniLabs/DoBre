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
        <div className="mt-10 grid gap-5 lg:grid-cols-3">
          {copy.how.steps.map(([title, description]) => (
            <article
              key={title}
              className="rounded-xl border border-line bg-surface p-6"
            >
              <h3 className="text-base font-semibold tracking-tight text-ink">
                {title}
              </h3>
              <p className="mt-2.5 text-sm leading-relaxed text-muted">
                {description}
              </p>
            </article>
          ))}
        </div>
      </div>
    </section>
  )
}
