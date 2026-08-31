import { useLanguage } from '../i18n/LanguageProvider'
import { releaseConfig } from '../lib/site-config'
import { SectionHeading } from './SectionHeading'

export function SupportSection() {
  const { copy } = useLanguage()
  const donations = releaseConfig.donations

  if (!donations?.enabled) return null

  const items = [
    {
      emoji: '☕',
      title: copy.donations.cafe,
      amount: copy.donations.cafeAmount,
      href: donations.cafe,
      highlight: false,
    },
    {
      emoji: '❤️',
      title: copy.donations.apoyo,
      amount: copy.donations.apoyoAmount,
      href: donations.apoyo,
      highlight: true,
    },
    {
      emoji: '🚀',
      title: copy.donations.impulso,
      amount: copy.donations.impulsoAmount,
      href: donations.impulso,
      highlight: false,
    },
    {
      emoji: '✨',
      title: copy.donations.custom,
      amount: copy.donations.customAmount,
      href: donations.custom,
      highlight: false,
    },
  ]

  return (
    <section id="apoyo" className="border-t border-line bg-canvas px-5 py-24 sm:px-8 sm:py-32 lg:px-10" aria-labelledby="support-title">
      <div className="mx-auto max-w-7xl">
        <SectionHeading
          eyebrow={copy.donations.eyebrow}
          title={
            <>
              {copy.donations.titleStart} <span className="text-gradient">{copy.donations.titleAccent}</span>
            </>
          }
          description={copy.donations.description}
          headingId="support-title"
        />

        <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {items.map((item) => (
            <a
              key={item.title}
              href={item.href}
              target="_blank"
              rel="noreferrer"
              className={`group flex flex-col justify-between rounded-[1.75rem] border p-6 transition duration-200 hover:-translate-y-1 hover:shadow-card ${
                item.highlight
                  ? 'border-teal/40 bg-teal/[0.05] shadow-[0_18px_45px_rgba(15,118,110,0.08)] ring-1 ring-teal/30'
                  : 'border-line bg-surface hover:border-teal/30'
              }`}
            >
              <div>
                <div className="flex items-center justify-between">
                  <span className="text-3xl">{item.emoji}</span>
                  <span
                    className={`rounded-full px-3 py-1 text-xs font-extrabold ${
                      item.highlight ? 'bg-teal text-canvas' : 'bg-surface-raised text-muted border border-line'
                    }`}
                  >
                    {item.amount}
                  </span>
                </div>
                <h3 className="mt-5 text-xl font-extrabold tracking-[-0.03em] text-ink group-hover:text-teal transition-colors">
                  {item.title}
                </h3>
                <p className="mt-1 text-xs text-muted">Mercado Pago</p>
              </div>

              <div className="mt-6 flex items-center justify-between pt-4 border-t border-line/60 text-sm font-bold text-teal">
                <span>Colaborar</span>
                <span className="grid size-7 place-items-center rounded-full bg-teal-soft text-teal group-hover:bg-teal group-hover:text-canvas transition">
                  <ArrowUpRightIcon />
                </span>
              </div>
            </a>
          ))}
        </div>

        <div className="mt-8 flex items-center justify-center gap-2 text-center text-xs font-medium text-muted">
          <LockIcon />
          <span>{copy.donations.secureNote}</span>
        </div>
      </div>
    </section>
  )
}

function ArrowUpRightIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 14 14 6M8 6h6v6" />
    </svg>
  )
}

function LockIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4 shrink-0 text-muted" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="9" width="12" height="8" rx="2" />
      <path d="M7 9V6a3 3 0 0 1 6 0v3" />
    </svg>
  )
}
