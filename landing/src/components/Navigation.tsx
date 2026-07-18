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
    <header className="relative z-20 mx-auto flex w-full max-w-7xl items-center justify-between px-5 py-5 sm:px-8 lg:px-10">
      <a className="skip-link" href="#main-content">{copy.nav.skip}</a>
      <a href="#inicio" className="rounded-md focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-teal">
        <BrandMark />
      </a>

      <nav className="hidden items-center gap-6 md:flex" aria-label={copy.nav.mainLabel}>
        <a className="nav-link" href={siteConfig.links.howItWorks}>{copy.nav.howItWorks}</a>
        <a className="nav-link" href={siteConfig.links.webExperience}>{copy.nav.webApp}</a>
        {hasDownloads && <a className="nav-link" href={siteConfig.links.downloads}>{copy.nav.downloads}</a>}
        <LanguageSelector />
        <ThemeToggle />
      </nav>

      <div className="flex items-center gap-2 md:hidden">
        <ThemeToggle />
        <button
          className="grid size-10 place-items-center rounded-full border border-line bg-surface text-ink focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-teal"
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
        <nav id="mobile-navigation" className="absolute inset-x-5 top-[76px] grid gap-1 rounded-3xl border border-line bg-surface-raised p-3 shadow-panel md:hidden" aria-label={copy.nav.mobileLabel}>
          <a className="mobile-link" href={siteConfig.links.howItWorks} onClick={closeMenu}>{copy.nav.howItWorks}</a>
          <a className="mobile-link" href={siteConfig.links.webExperience} onClick={closeMenu}>{copy.nav.webApp}</a>
          {hasDownloads && <a className="mobile-link" href={siteConfig.links.downloads} onClick={closeMenu}>{copy.nav.downloads}</a>}
          <div className="mt-2 px-1"><LanguageSelector /></div>
        </nav>
      )}
    </header>
  )
}

function MenuIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M4 7h16M4 12h16M4 17h16" /></svg>
}

function CloseIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="m6 6 12 12M18 6 6 18" /></svg>
}
