import type { ReactNode } from 'react'
import { releaseConfig } from '../lib/site-config'
import { useLanguage } from '../i18n/LanguageProvider'

export function DownloadActions() {
  const { copy } = useLanguage()
  const hasAndroid = releaseConfig.androidDownloadUrl != null
  const hasWindows = releaseConfig.windowsDownloadUrl != null

  if (!hasAndroid && !hasWindows) return null

  return (
    <div id="descargas" className="mt-9">
      <div className="flex flex-col gap-3 sm:flex-row">
        {releaseConfig.androidDownloadUrl != null && <DownloadButton href={releaseConfig.androidDownloadUrl} label={copy.downloads.android} ariaLabel={copy.downloads.androidAria} icon={<AndroidIcon />} />}
        {releaseConfig.windowsDownloadUrl != null && <DownloadButton href={releaseConfig.windowsDownloadUrl} label={copy.downloads.windows} ariaLabel={copy.downloads.windowsAria} icon={<WindowsIcon />} />}
      </div>
      {hasAndroid && <InstallTutorial />}
    </div>
  )
}

function DownloadButton({ href, label, ariaLabel, icon }: { href: string; label: string; ariaLabel: string; icon: ReactNode }) {
  return <a className="button button-primary button-large download-button" href={href} aria-label={ariaLabel} target="_blank" rel="noreferrer"><span className="grid size-5 place-items-center">{icon}</span>{label}<ArrowIcon /></a>
}

function InstallTutorial() {
  const { copy } = useLanguage()
  return (
    <details className="install-tutorial group">
      <summary>{copy.downloads.tutorialTitle}<ChevronIcon /></summary>
      <div className="install-tutorial-content">
        <p>{copy.downloads.tutorialIntro}</p>
        <ol>{copy.downloads.steps.map((step) => <li key={step}>{step}</li>)}</ol>
        <p className="install-note"><InfoIcon />{copy.downloads.note}</p>
      </div>
    </details>
  )
}

function ArrowIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 10h12M11 5l5 5-5 5" /></svg> }
function ChevronIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4 transition duration-200 group-open:rotate-180" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m5 8 5 5 5-5" /></svg> }
function InfoIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="mt-0.5 size-4 shrink-0" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="10" cy="10" r="7" /><path d="M10 9v4M10 6.5h.01" /></svg> }
function AndroidIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="currentColor"><path d="M17.5 9.5H6.5A1.5 1.5 0 0 0 5 11v7a1.5 1.5 0 0 0 1.5 1.5H8V22h2v-2.5h4V22h2v-2.5h1.5A1.5 1.5 0 0 0 19 18v-7a1.5 1.5 0 0 0-1.5-1.5ZM8.5 15a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5Zm7 0a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5ZM6.5 8.5l-1.1-2 1-.55 1.15 2.05A7 7 0 0 1 12 6.5c1.55 0 3 .5 4.25 1.35l1.15-2.05 1 .55-1.1 2A5 5 0 0 1 19 12H5a5 5 0 0 1 1.5-3.5Z" /></svg> }
function WindowsIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-4.5" fill="currentColor"><path d="m3 5.2 8-1.1v7H3V5.2Zm9 5.9V4l9-1.2v8.3h-9ZM3 12.9h8v7L3 18.8v-5.9Zm9 0h9v8.3L12 20v-7.1Z" /></svg> }
