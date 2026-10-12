type BrandMarkProps = {
  compact?: boolean
}

export function BrandMark({ compact = false }: BrandMarkProps) {
  return (
    <div className="flex items-center gap-2" aria-label="DoBre">
      <img className="size-7" src="/branding/logo.svg" width="28" height="28" alt="" />
      {!compact && (
        <span className="text-base font-bold tracking-tight text-ink">
          DoBre
        </span>
      )}
    </div>
  )
}
