import { useLanguage } from '../i18n/LanguageProvider'
import { SectionHeading } from './SectionHeading'

export function Faq() {
  const { copy } = useLanguage()

  return (
    <section id="preguntas-frecuentes" className="border-b border-line px-5 py-16 sm:px-8 sm:py-20 lg:px-10" aria-labelledby="faq-title">
      <div className="mx-auto grid max-w-7xl gap-8 lg:grid-cols-[.85fr_1.15fr] lg:items-start">
        <SectionHeading
          eyebrow={copy.faq.eyebrow}
          title={copy.faq.titleStart}
          description={copy.faq.description}
          headingId="faq-title"
        />
        <div className="rounded-xl border border-line bg-surface p-6">
          <h3 className="text-base font-semibold tracking-tight text-ink">
            {copy.faq.question}
          </h3>
          <p className="mt-2.5 text-sm leading-relaxed text-muted">
            {copy.faq.answer}
          </p>
        </div>
      </div>
    </section>
  )
}
