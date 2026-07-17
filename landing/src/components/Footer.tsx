import { useLanguage } from '../i18n/LanguageProvider'
import { BrandMark } from './BrandMark'

export function Footer() {
  const { copy } = useLanguage()

  return <footer className="border-b border-line bg-canvas px-5 py-8 sm:px-8 lg:px-10"><div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 sm:flex-row"><BrandMark compact /><p className="text-center text-sm font-medium text-muted">{copy.footer}</p></div></footer>
}
