import { useLanguage } from '../i18n/LanguageProvider'

export function HeroPreview() {
  const { copy } = useLanguage()

  return (
    <div className="hero-preview relative mx-auto w-full max-w-[31rem]" role="img" aria-label={copy.preview.label}>
      <div className="absolute -inset-8 -z-10 rounded-[3rem] bg-[radial-gradient(circle_at_35%_30%,rgba(94,234,212,0.44),transparent_38%),radial-gradient(circle_at_80%_75%,rgba(147,197,253,0.5),transparent_42%)] blur-2xl" />
      <div className="relative overflow-hidden rounded-[2rem] border border-line bg-surface/80 p-3 shadow-[0_30px_80px_rgba(15,23,42,0.18)] backdrop-blur-xl">
        <div className="flex items-center justify-between px-2 pb-4 pt-1">
          <div className="flex items-center gap-2 text-sm font-bold text-ink"><span className="grid size-7 place-items-center rounded-lg bg-teal text-xs text-white">D</span> DoBre</div>
          <span className="rounded-full bg-teal-soft px-2.5 py-1 text-[0.66rem] font-bold text-teal">{copy.preview.mode}</span>
        </div>
        <div className="rounded-[1.45rem] border border-line bg-surface p-5">
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-muted">{copy.preview.receive}</p>
          <p className="mt-2 text-3xl font-extrabold tracking-[-0.06em] text-ink">$ 50.000</p>
          <div className="my-5 h-px bg-line" />
          <div className="grid grid-cols-2 gap-3 text-sm">
            <MiniField label={copy.preview.category} value={copy.preview.electronics} />
            <MiniField label={copy.preview.installments} value={copy.preview.noInstallments} />
          </div>
          <div className="mt-4 rounded-2xl bg-[linear-gradient(135deg,#0f766e,#2563eb)] p-5 text-white shadow-[0_12px_28px_rgba(15,118,110,0.24)]">
            <p className="text-xs font-semibold uppercase tracking-[0.14em] text-white/70">{copy.preview.suggestedPrice}</p>
            <p className="mt-1 text-3xl font-extrabold tracking-[-0.06em]">$ 63.619</p>
            <div className="mt-4 flex items-center gap-2 text-xs font-medium text-white/80"><CheckIcon /> {copy.preview.variables}</div>
          </div>
        </div>
      </div>
      <div className="absolute -right-3 top-24 hidden rounded-2xl border border-white/70 bg-white/90 px-3 py-2 text-xs font-bold text-teal shadow-card backdrop-blur sm:flex dark:border-white/10 dark:bg-[#162033e6]">
        <CheckIcon /> {copy.preview.ready}
      </div>
    </div>
  )
}

function MiniField({ label, value }: { label: string; value: string }) {
  return <div className="rounded-xl border border-line bg-surface-raised px-3 py-2.5"><p className="text-[0.65rem] font-semibold text-muted">{label}</p><p className="mt-1 truncate text-xs font-bold text-ink">{value}</p></div>
}

function CheckIcon() {
  return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m4 10 3.4 3.4L16 5.5" /></svg>
}
