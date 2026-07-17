type BrandMarkProps = {
  compact?: boolean
}

export function BrandMark({ compact = false }: BrandMarkProps) {
  return (
    <div className="flex items-center gap-2.5" aria-label="DoBre">
      <span className="grid size-9 place-items-center rounded-xl bg-[linear-gradient(135deg,#0f766e,#2563eb)] text-base font-black tracking-[-0.12em] text-white shadow-[0_8px_24px_rgba(15,118,110,0.2)]">
        D
      </span>
      {!compact && (
        <span className="text-lg font-extrabold tracking-[-0.05em] text-ink">
          DoBre
        </span>
      )}
    </div>
  )
}
