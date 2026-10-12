import { DownloadActions } from './DownloadActions'
import { InverseCalculator } from './InverseCalculator'
import { releaseConfig } from '../lib/site-config'
import { useLanguage } from '../i18n/LanguageProvider'

export function Hero() {
  const { copy } = useLanguage()

  return (
    <section id="inicio" className="relative border-b border-line" aria-labelledby="hero-title">
      <div className="mx-auto grid w-full max-w-7xl items-start gap-10 px-5 py-12 sm:px-8 sm:py-16 lg:grid-cols-[1.05fr_.95fr] lg:items-center lg:gap-12 lg:px-10 lg:py-20">
        <div className="max-w-xl">
          <p className="eyebrow">{copy.hero.eyebrow}</p>
          <h1 id="hero-title" className="mt-3 text-balance text-2xl font-semibold leading-snug tracking-tight text-ink sm:text-3xl lg:text-4xl">
            {copy.hero.titleStart}
          </h1>
          <p className="mt-4 text-pretty text-base leading-relaxed text-muted">
            {copy.hero.description}
          </p>

          <div className="mt-7 flex flex-wrap items-center gap-3">
            {releaseConfig.webAppUrl != null && (
              <a
                className="button button-primary button-large"
                href={releaseConfig.webAppUrl}
                target="_blank"
                rel="noreferrer"
              >
                {copy.hero.tryWeb}
                <ArrowIcon />
              </a>
            )}
          </div>

          <DownloadActions />

          <div className="mt-7 flex flex-wrap items-center gap-x-5 gap-y-2 border-t border-line pt-5 text-xs font-medium text-muted">
            <span className="flex items-center gap-1.5"><CheckIcon /> {copy.hero.noSpreadsheets}</span>
            <span className="flex items-center gap-1.5"><CheckIcon /> {copy.hero.updatable}</span>
            {!releaseConfig.maintenanceMode && (
              <span className="flex items-center gap-1.5 font-mono text-ink">
                <span className="size-1.5 rounded-full bg-teal" /> {copy.hero.available}
              </span>
            )}
          </div>
        </div>

        <div className="w-full lg:justify-self-end">
          <InverseCalculator />
        </div>
      </div>
    </section>
  )
}

function ArrowIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 10h12M11 5l5 5-5 5" />
    </svg>
  )
}

function CheckIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 20 20" className="size-3.5 text-teal" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m4 10 3.4 3.4L16 5.5" />
    </svg>
  )
}
