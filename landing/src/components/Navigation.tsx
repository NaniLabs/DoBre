import { useEffect, useState } from 'react'
import { BrandMark } from './BrandMark'
import { LanguageSelector } from './LanguageSelector'
import { ThemeToggle } from './ThemeToggle'
import { releaseConfig, siteConfig } from '../lib/site-config'
import { useLanguage } from '../i18n/LanguageProvider'

export function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const { copy } = useLanguage()
  const hasDownloads = releaseConfig.androidDownloadUrl != null || releaseConfig.windowsDownloadUrl != null

  const closeMenu = () => setIsMenuOpen(false)

  useEffect(() => {
    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') closeMenu()
    }

    window.addEventListener('keydown', closeOnEscape)
    return () => window.removeEventListener('keydown', closeOnEscape)
  }, [])

  return (
    <header className="sticky top-0 z-20 border-b border-line bg-canvas/90 backdrop-blur-md">
      <div className="mx-auto flex w-full max-w-7xl items-center justify-between px-5 py-3.5 sm:px-8 lg:px-10">
        <a className="skip-link" href="#main-content">{copy.nav.skip}</a>
        <div className="flex items-center gap-3">
          <a href="#inicio" className="rounded-md focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-teal">
            <BrandMark />
          </a>
          <span className="text-line select-none">|</span>
          <a
            href="https://nanilabs.lat"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-1.5 text-xs font-mono text-muted hover:text-ink transition-colors"
          >
            <svg viewBox="0 0 64 64" className="size-3.5" aria-hidden="true">
              <rect width="64" height="64" rx="14" fill="#0b111e" />
              <path d="M15 47V17h7.5l13.5 18V17H43v30h-7.5L22 29v18H15z" fill="#38bdf8" />
              <path d="M29 17h7.5l12.5 16.5V47h-7.5L29 30.5V17z" fill="#34d399" fillOpacity="0.85" />
            </svg>
            nanilabs.lat
          </a>
        </div>

        <nav className="hidden items-center gap-6 md:flex" aria-label={copy.nav.mainLabel}>
          <a className="nav-link" href={siteConfig.links.howItWorks}>{copy.nav.howItWorks}</a>
          {hasDownloads && <a className="nav-link" href={siteConfig.links.downloads}>{copy.nav.downloads}</a>}
          {releaseConfig.donations?.enabled && <a className="nav-link" href={siteConfig.links.support}>{copy.nav.support}</a>}
          <LanguageSelector />
          <ThemeToggle />
        </nav>

        <div className="flex items-center gap-2 md:hidden">
          <ThemeToggle />
          <button
            className="grid size-9 place-items-center rounded-lg border border-line bg-surface text-ink focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-teal"
            type="button"
            aria-label={isMenuOpen ? copy.nav.closeMenu : copy.nav.openMenu}
            aria-expanded={isMenuOpen}
            aria-controls="mobile-navigation"
            onClick={() => setIsMenuOpen((isOpen) => !isOpen)}
          >
            <span className="sr-only">{copy.nav.openMenu}</span>
            {isMenuOpen ? <CloseIcon /> : <MenuIcon />}
          </button>
        </div>

        {isMenuOpen && (
          <nav id="mobile-navigation" className="absolute inset-x-5 top-[64px] grid gap-1 rounded-xl border border-line bg-surface p-3 shadow-panel md:hidden" aria-label={copy.nav.mobileLabel}>
            <a className="mobile-link" href={siteConfig.links.howItWorks} onClick={closeMenu}>{copy.nav.howItWorks}</a>
            {hasDownloads && <a className="mobile-link" href={siteConfig.links.downloads} onClick={closeMenu}>{copy.nav.downloads}</a>}
            {releaseConfig.donations?.enabled && <a className="mobile-link" href={siteConfig.links.support} onClick={closeMenu}>{copy.nav.support}</a>}
            <div className="mt-2 px-1"><LanguageSelector /></div>
          </nav>
        )}
      </div>
    </header>
  )
}

function MenuIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M4 7h16M4 12h16M4 17h16" /></svg>
}

function CloseIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="m6 6 12 12M18 6 6 18" /></svg>
}
