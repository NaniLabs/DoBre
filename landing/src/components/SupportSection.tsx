import { useLanguage } from '../i18n/LanguageProvider'
import { releaseConfig } from '../lib/site-config'
import { SectionHeading } from './SectionHeading'

export function SupportSection() {
  const { copy } = useLanguage()
  const donations = releaseConfig.donations

  if (!donations?.enabled) return null

  const items = [
    {
      icon: <CoffeeIcon />,
      title: copy.donations.cafe,
      amount: copy.donations.cafeAmount,
      href: donations.cafe,
      highlight: false,
    },
    {
      icon: <HeartIcon />,
      title: copy.donations.apoyo,
      amount: copy.donations.apoyoAmount,
      href: donations.apoyo,
      highlight: true,
    },
    {
      icon: <RocketIcon />,
      title: copy.donations.impulso,
      amount: copy.donations.impulsoAmount,
      href: donations.impulso,
      highlight: false,
    },
    {
      icon: <SparklesIcon />,
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
              {copy.donations.titleStart} <span className="text-teal">{copy.donations.titleAccent}</span>
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
                  <span className="grid size-10 place-items-center rounded-xl border border-line bg-surface-raised text-teal">
                    {item.icon}
                  </span>
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

function CoffeeIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M17 8h1a4 4 0 1 1 0 8h-1" />
      <path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V8z" />
      <line x1="6" y1="2" x2="6" y2="4" />
      <line x1="10" y1="2" x2="10" y2="4" />
      <line x1="14" y1="2" x2="14" y2="4" />
    </svg>
  )
}

function HeartIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.29 1.51 4.04 3 5.5l7 7z" />
    </svg>
  )
}

function RocketIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z" />
      <path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z" />
      <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0" />
      <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5" />
    </svg>
  )
}

function SparklesIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3z" />
      <path d="M19 14l.75 2.25L22 17l-2.25.75L19 20l-.75-2.25L16 17l2.25-.75L19 14z" />
      <path d="M5 16l.5 1.5L7 18l-1.5.5L5 20l-.5-1.5L3 18l1.5-.5L5 16z" />
    </svg>
  )
}
