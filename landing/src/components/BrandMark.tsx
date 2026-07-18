type BrandMarkProps = {
  compact?: boolean
}

export function BrandMark({ compact = false }: BrandMarkProps) {
  return (
    <div className="flex items-center gap-2.5" aria-label="DoBre">
      <img className="size-9" src="/branding/logo.svg" width="36" height="36" alt="" />
      {!compact && (
        <span className="text-lg font-extrabold tracking-[-0.05em] text-ink">
          DoBre
        </span>
      )}
    </div>
  )
}
