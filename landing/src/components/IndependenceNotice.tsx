import { useLanguage } from '../i18n/LanguageProvider'

export function IndependenceNotice() {
  const { copy } = useLanguage()

  return (
    <section className="border-b border-line bg-canvas px-5 py-16 sm:px-8 sm:py-20 lg:px-10" aria-labelledby="independence-title">
      <div className="mx-auto grid max-w-7xl gap-7 rounded-[2rem] border border-line bg-surface-raised p-7 sm:p-9 lg:grid-cols-[auto_1fr] lg:items-start lg:gap-8">
        <span className="grid size-12 place-items-center rounded-2xl bg-teal-soft text-teal"><InfoIcon /></span>
        <div>
          <h2 id="independence-title" className="text-xl font-extrabold tracking-[-0.04em] text-ink">{copy.notice.title}</h2>
          <p className="mt-3 max-w-4xl text-sm leading-6 text-muted sm:text-base">{copy.notice.text}</p>
        </div>
      </div>
    </section>
  )
}

function InfoIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9" /><path d="M12 10.5v5M12 7.5h.01" /></svg> }
