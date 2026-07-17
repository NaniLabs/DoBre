import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { translations, type Language, type Translation } from './translations'

const storageKey = 'dobre-language'

type LanguageContextValue = {
  language: Language
  copy: Translation
  setLanguage: (language: Language) => void
}

const LanguageContext = createContext<LanguageContextValue | null>(null)

function getInitialLanguage(): Language {
  const storedLanguage = window.localStorage.getItem(storageKey)
  if (storedLanguage === 'es' || storedLanguage === 'en') return storedLanguage

  return navigator.language.toLowerCase().startsWith('es') ? 'es' : 'en'
}

function updateMeta(selector: string, value: string) {
  document.querySelector<HTMLMetaElement>(selector)?.setAttribute('content', value)
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguage] = useState<Language>(getInitialLanguage)
  const copy = translations[language]

  useEffect(() => {
    document.documentElement.lang = copy.metadata.documentLanguage
    document.title = copy.metadata.title
    window.localStorage.setItem(storageKey, language)
    updateMeta('meta[name="description"]', copy.metadata.description)
    updateMeta('meta[property="og:title"]', copy.metadata.title)
    updateMeta('meta[property="og:description"]', copy.metadata.description)
    updateMeta('meta[property="og:locale"]', copy.metadata.locale)
    updateMeta('meta[property="og:image"]', copy.metadata.ogImage)
    updateMeta('meta[property="og:image:alt"]', copy.metadata.ogImageAlt)
    updateMeta('meta[name="twitter:title"]', copy.metadata.title)
    updateMeta('meta[name="twitter:description"]', copy.metadata.description)
    updateMeta('meta[name="twitter:image"]', copy.metadata.ogImage)
    updateMeta('meta[name="twitter:image:alt"]', copy.metadata.ogImageAlt)
  }, [copy, language])

  return <LanguageContext.Provider value={{ language, copy, setLanguage }}>{children}</LanguageContext.Provider>
}

export function useLanguage() {
  const context = useContext(LanguageContext)
  if (context == null) throw new Error('useLanguage must be used within LanguageProvider.')

  return context
}
