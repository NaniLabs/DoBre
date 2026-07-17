import { useEffect, useState } from 'react'
import { BrandMark } from './BrandMark'
import { ThemeToggle } from './ThemeToggle'
import { getPrimaryDownloadUrl, siteConfig } from '../lib/site-config'

export function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

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
      <a className="skip-link" href="#main-content">Saltar al contenido</a>
      <a href="#inicio" className="rounded-md focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-teal">
        <BrandMark />
      </a>

      <nav className="hidden items-center gap-7 md:flex" aria-label="Navegación principal">
        <a className="nav-link" href={siteConfig.links.howItWorks}>Cómo funciona</a>
        <a className="nav-link" href={siteConfig.links.simulator}>Simulador</a>
        <ThemeToggle />
        <a className="button button-primary button-small" href={getPrimaryDownloadUrl()}>
          Descargar app
          <ArrowIcon />
        </a>
      </nav>

      <div className="flex items-center gap-2 md:hidden">
        <ThemeToggle />
        <button
          className="grid size-10 place-items-center rounded-full border border-line bg-surface text-ink focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-teal"
          type="button"
          aria-label={isMenuOpen ? 'Cerrar menú' : 'Abrir menú'}
          aria-expanded={isMenuOpen}
          aria-controls="mobile-navigation"
          onClick={() => setIsMenuOpen((isOpen) => !isOpen)}
        >
          <span className="sr-only">Menú</span>
          {isMenuOpen ? <CloseIcon /> : <MenuIcon />}
        </button>
      </div>

      {isMenuOpen && (
        <nav id="mobile-navigation" className="absolute inset-x-5 top-[76px] grid gap-1 rounded-3xl border border-line bg-surface-raised p-3 shadow-panel md:hidden" aria-label="Navegación móvil">
          <a className="mobile-link" href={siteConfig.links.howItWorks} onClick={closeMenu}>Cómo funciona</a>
          <a className="mobile-link" href={siteConfig.links.simulator} onClick={closeMenu}>Simulador</a>
          <a className="button button-primary mt-2" href={getPrimaryDownloadUrl()} onClick={closeMenu}>Descargar app <ArrowIcon /></a>
        </nav>
      )}
    </header>
  )
}

function ArrowIcon() {
  return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 10h12M11 5l5 5-5 5" /></svg>
}

function MenuIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M4 7h16M4 12h16M4 17h16" /></svg>
}

function CloseIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="m6 6 12 12M18 6 6 18" /></svg>
}
