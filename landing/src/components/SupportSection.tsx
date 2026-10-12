import { useLanguage } from '../i18n/LanguageProvider'
import { releaseConfig } from '../lib/site-config'
import { SectionHeading } from './SectionHeading'

export function SupportSection() {
  const { copy } = useLanguage()
  const donations = releaseConfig.donations

  if (!donations?.enabled) return null

  const items = [
    {
      title: copy.donations.cafe,
      amount: copy.donations.cafeAmount,
      href: donations.cafe,
    },
    {
      title: copy.donations.apoyo,
      amount: copy.donations.apoyoAmount,
      href: donations.apoyo,
    },
    {
      title: copy.donations.impulso,
      amount: copy.donations.impulsoAmount,
      href: donations.impulso,
    },
    {
      title: copy.donations.custom,
      amount: copy.donations.customAmount,
      href: donations.custom,
    },
  ]

  return (
    <section id="apoyo" className="border-b border-line bg-canvas px-5 py-16 sm:px-8 sm:py-20 lg:px-10" aria-labelledby="support-title">
      <div className="mx-auto max-w-7xl">
        <SectionHeading
          eyebrow={copy.donations.eyebrow}
          title={copy.donations.titleStart}
          description={copy.donations.description}
          headingId="support-title"
        />

        <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {items.map((item) => (
            <a
              key={item.title}
              href={item.href}
              target="_blank"
              rel="noreferrer"
              className="group flex flex-col justify-between rounded-xl border border-line bg-surface p-5 transition hover:border-teal/50"
            >
              <div>
                <div className="flex items-center justify-between gap-2">
                  <h3 className="text-sm font-semibold text-ink">
                    {item.title}
                  </h3>
                  <span className="rounded-md border border-line bg-surface-raised px-2.5 py-1 font-mono text-xs font-semibold text-ink">
                    {item.amount}
                  </span>
                </div>
                <p className="mt-1.5 text-xs text-muted">Mercado Pago</p>
              </div>

              <div className="mt-5 flex items-center justify-between border-t border-line pt-3 text-xs font-semibold text-ink group-hover:text-teal transition-colors">
                <span>Mercado Pago</span>
                <ArrowUpRightIcon />
              </div>
            </a>
          ))}
        </div>

        <p className="mt-5 text-xs text-muted">
          {copy.donations.secureNote}
        </p>
      </div>
    </section>
  )
}

function ArrowUpRightIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="size-3.5" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 14 14 6M8 6h6v6" />
    </svg>
  )
}
