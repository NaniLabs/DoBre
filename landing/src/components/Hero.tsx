import { HeroPreview } from './HeroPreview'
import { DownloadActions } from './DownloadActions'
import { releaseConfig } from '../lib/site-config'
import { useLanguage } from '../i18n/LanguageProvider'

export function Hero() {
  const { copy } = useLanguage()

  return (
    <section id="inicio" className="relative overflow-hidden" aria-labelledby="hero-title">
      <div className="hero-grid pointer-events-none absolute inset-x-0 top-0 h-[44rem] -z-20" />
      <div className="pointer-events-none absolute left-1/2 top-20 -z-10 h-96 w-[36rem] -translate-x-1/2 rounded-full bg-teal/10 blur-[110px]" />
      <div className="mx-auto grid min-h-[calc(100vh-84px)] w-full max-w-7xl items-center gap-14 px-5 pb-20 pt-10 sm:px-8 sm:pt-16 lg:grid-cols-[1.08fr_.92fr] lg:gap-10 lg:px-10 lg:pb-24">
        <div className="animate-enter max-w-2xl">
          <p className="eyebrow"><span className="size-1.5 rounded-full bg-teal" /> {copy.hero.eyebrow}</p>
          <h1 id="hero-title" className="mt-7 text-balance text-[clamp(3rem,7vw,5.8rem)] font-extrabold leading-[0.94] tracking-[-0.075em] text-ink">
            {copy.hero.titleStart} <span className="text-gradient">{copy.hero.titleAccent}</span>
          </h1>
          <p className="mt-7 max-w-xl text-pretty text-lg leading-8 text-muted sm:text-xl">
            {copy.hero.description}
          </p>
          {releaseConfig.webAppUrl != null && <div className="mt-9 flex"><a className="button button-primary button-large" href={releaseConfig.webAppUrl} target="_blank" rel="noreferrer">{copy.hero.tryWeb} <ArrowIcon /></a></div>}
          <DownloadActions />
          <div className="mt-8 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm font-medium text-muted">
            <span className="flex items-center gap-2"><CheckIcon /> {copy.hero.noSpreadsheets}</span>
            <span className="flex items-center gap-2"><CheckIcon /> {copy.hero.updatable}</span>
            {!releaseConfig.maintenanceMode && <span className="flex items-center gap-2"><span className="size-2 rounded-full bg-teal shadow-[0_0_0_4px_rgba(15,118,110,0.12)]" /> {copy.hero.available}</span>}
          </div>
        </div>
        <div className="animate-enter-delayed lg:justify-self-end">
          <HeroPreview />
        </div>
      </div>
    </section>
  )
}

function ArrowIcon() {
  return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 10h12M11 5l5 5-5 5" /></svg>
}

function CheckIcon() {
  return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4 text-teal" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m4 10 3.4 3.4L16 5.5" /></svg>
}
