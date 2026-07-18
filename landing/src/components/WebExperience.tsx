import type { ReactNode } from 'react'
import { releaseConfig } from '../lib/site-config'
import { useLanguage } from '../i18n/LanguageProvider'

export function WebExperience() {
  const { copy } = useLanguage()

  return (
    <section id="version-web" className="px-5 py-24 sm:px-8 sm:py-32 lg:px-10" aria-labelledby="web-experience-title">
      <div className="mx-auto max-w-7xl">
        <div className="grid items-end gap-8 lg:grid-cols-[1fr_auto]">
          <div className="max-w-2xl">
            <p className="eyebrow"><span className="size-1.5 rounded-full bg-teal" /> {copy.webExperience.eyebrow}</p>
            <h2 id="web-experience-title" className="mt-6 text-balance text-4xl font-extrabold tracking-[-0.06em] text-ink sm:text-5xl">
              {copy.webExperience.titleStart} <span className="text-gradient">{copy.webExperience.titleAccent}</span>
            </h2>
            <p className="mt-5 max-w-xl text-pretty text-lg leading-8 text-muted">{copy.webExperience.description}</p>
          </div>
          {releaseConfig.webAppUrl != null && (
            <a className="button button-primary button-large w-fit" href={releaseConfig.webAppUrl} target="_blank" rel="noreferrer">
              {copy.webExperience.tryWeb}<ArrowIcon />
            </a>
          )}
        </div>

        <h3 className="mt-12 text-lg font-extrabold tracking-[-0.03em] text-ink">{copy.webExperience.comparisonTitle}</h3>
        <div className="mt-4 grid gap-4 lg:grid-cols-2">
          <ExperienceCard title={copy.webExperience.web.title} points={copy.webExperience.web.points} icon={<BrowserIcon />} />
          <ExperienceCard title={copy.webExperience.app.title} points={copy.webExperience.app.points} icon={<DeviceIcon />} emphasized />
        </div>
        <p className="mt-6 max-w-3xl text-sm font-medium leading-6 text-muted">{copy.webExperience.recommendation}</p>
      </div>
    </section>
  )
}

function ExperienceCard({ title, points, icon, emphasized = false }: { title: string; points: readonly string[]; icon: ReactNode; emphasized?: boolean }) {
  return (
    <article className={`rounded-[1.75rem] border p-7 sm:p-8 ${emphasized ? 'border-teal/30 bg-teal/[0.05] shadow-[0_18px_50px_rgba(15,118,110,0.09)]' : 'border-line bg-surface'}`}>
      <div className="flex items-center gap-3">
        <span className="grid size-10 place-items-center rounded-xl bg-ink text-canvas">{icon}</span>
        <h3 className="text-xl font-extrabold tracking-[-0.04em] text-ink">{title}</h3>
      </div>
      <ul className="mt-7 grid gap-3 text-sm font-medium text-muted sm:grid-cols-2">
        {points.map((point) => <li key={point} className="flex items-start gap-2"><CheckIcon />{point}</li>)}
      </ul>
    </article>
  )
}

function CheckIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="mt-0.5 size-4 shrink-0 text-teal" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m4 10 3.4 3.4L16 5.5" /></svg> }
function ArrowIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 10h12M11 5l5 5-5 5" /></svg> }
function BrowserIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M3 9h18M7 6.5h.01M10 6.5h.01" /></svg> }
function DeviceIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="7" y="2.5" width="10" height="19" rx="2" /><path d="M10.5 18.5h3" /></svg> }
