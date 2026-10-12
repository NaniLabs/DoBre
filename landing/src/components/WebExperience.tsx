import type { ReactNode } from 'react'
import { releaseConfig } from '../lib/site-config'
import { useLanguage } from '../i18n/LanguageProvider'

export function WebExperience() {
  const { copy } = useLanguage()

  return (
    <section id="version-web" className="border-b border-line px-5 py-16 sm:px-8 sm:py-20 lg:px-10" aria-labelledby="web-experience-title">
      <div className="mx-auto max-w-7xl">
        <div className="grid items-end gap-6 lg:grid-cols-[1fr_auto]">
          <div className="max-w-2xl">
            <p className="eyebrow">{copy.webExperience.eyebrow}</p>
            <h2 id="web-experience-title" className="mt-2.5 text-balance text-xl font-semibold leading-snug tracking-tight text-ink sm:text-2xl lg:text-3xl">
              {copy.webExperience.titleStart}
            </h2>
            <p className="mt-3 max-w-xl text-pretty text-sm leading-relaxed text-muted sm:text-base">
              {copy.webExperience.description}
            </p>
          </div>
          {releaseConfig.webAppUrl != null && (
            <a
              className="button button-primary button-large w-fit"
              href={releaseConfig.webAppUrl}
              target="_blank"
              rel="noreferrer"
            >
              {copy.webExperience.tryWeb}
              <ArrowIcon />
            </a>
          )}
        </div>

        <div className="mt-8 grid gap-5 lg:grid-cols-2">
          <ExperienceCard
            title={copy.webExperience.web.title}
            points={copy.webExperience.web.points}
            icon={<BrowserIcon />}
          />
          <ExperienceCard
            title={copy.webExperience.app.title}
            points={copy.webExperience.app.points}
            icon={<DeviceIcon />}
          />
        </div>
        <p className="mt-5 max-w-3xl text-xs font-medium leading-relaxed text-muted">
          {copy.webExperience.recommendation}
        </p>
      </div>
    </section>
  )
}

function ExperienceCard({
  title,
  points,
  icon,
}: {
  title: string
  points: readonly string[]
  icon: ReactNode
}) {
  return (
    <article className="rounded-xl border border-line bg-surface p-6">
      <div className="flex items-center gap-3">
        <span className="grid size-9 place-items-center rounded-lg border border-line bg-surface-raised text-ink">
          {icon}
        </span>
        <h3 className="text-base font-semibold tracking-tight text-ink">{title}</h3>
      </div>
      <ul className="mt-5 grid gap-2.5 text-sm text-muted sm:grid-cols-2">
        {points.map((point) => (
          <li key={point} className="flex items-start gap-2">
            <CheckIcon />
            <span>{point}</span>
          </li>
        ))}
      </ul>
    </article>
  )
}

function CheckIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="mt-0.5 size-4 shrink-0 text-teal" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m4 10 3.4 3.4L16 5.5" />
    </svg>
  )
}

function ArrowIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 10h12M11 5l5 5-5 5" />
    </svg>
  )
}

function BrowserIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" className="size-4.5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="4" width="18" height="16" rx="2" />
      <path d="M3 9h18M7 6.5h.01M10 6.5h.01" />
    </svg>
  )
}

function DeviceIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24" className="size-4.5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="7" y="2.5" width="10" height="19" rx="2" />
      <path d="M10.5 18.5h3" />
    </svg>
  )
}
