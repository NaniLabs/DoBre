type SectionHeadingProps = {
  eyebrow: string
  title: React.ReactNode
  description: string
  align?: 'left' | 'center'
  headingId?: string
}

export function SectionHeading({
  eyebrow,
  title,
  description,
  align = 'left',
  headingId,
}: SectionHeadingProps) {
  const alignment = align === 'center' ? 'mx-auto text-center items-center' : 'items-start'

  return (
    <div className={`flex max-w-2xl flex-col ${alignment}`}>
      <p className="eyebrow">{eyebrow}</p>
      <h2 id={headingId} className="mt-2.5 text-balance text-xl font-semibold leading-snug tracking-tight text-ink sm:text-2xl lg:text-3xl">
        {title}
      </h2>
      <p className="mt-3 max-w-xl text-pretty text-sm leading-relaxed text-muted sm:text-base">
        {description}
      </p>
    </div>
  )
}
