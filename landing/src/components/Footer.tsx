import { useLanguage } from '../i18n/LanguageProvider'
import { BrandMark } from './BrandMark'

export function Footer() {
  const { copy } = useLanguage()

  return (
    <footer className="border-t border-line bg-surface px-5 py-6 sm:px-8 lg:px-10">
      <div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 sm:flex-row">
        <div className="flex items-center gap-3">
          <BrandMark compact />
          <span className="text-xs font-medium text-muted">{copy.footer}</span>
        </div>
        <a
          href="https://nanilabs.lat"
          target="_blank"
          rel="noreferrer"
          className="inline-flex items-center gap-2 text-xs font-medium text-muted hover:text-ink transition-colors"
        >
          <span>{copy.footerCreditPre}</span>
          <span className="inline-flex items-center gap-1.5 font-semibold text-ink">
            <svg viewBox="0 0 64 64" className="size-4" aria-hidden="true">
              <rect width="64" height="64" rx="14" fill="#0b111e" />
              <path d="M15 47V17h7.5l13.5 18V17H43v30h-7.5L22 29v18H15z" fill="#38bdf8" />
              <path d="M29 17h7.5l12.5 16.5V47h-7.5L29 30.5V17z" fill="#34d399" fillOpacity="0.85" />
            </svg>
            NaniLabs
          </span>
        </a>
      </div>
    </footer>
  )
}
