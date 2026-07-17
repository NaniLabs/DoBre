import { useLanguage } from '../i18n/LanguageProvider'

export function LanguageSelector() {
  const { language, copy, setLanguage } = useLanguage()

  return (
    <div className="language-selector" aria-label={copy.nav.language}>
      <button type="button" className={language === 'es' ? 'is-active' : ''} aria-pressed={language === 'es'} onClick={() => setLanguage('es')}>ES</button>
      <span aria-hidden="true">/</span>
      <button type="button" className={language === 'en' ? 'is-active' : ''} aria-pressed={language === 'en'} onClick={() => setLanguage('en')}>EN</button>
    </div>
  )
}
