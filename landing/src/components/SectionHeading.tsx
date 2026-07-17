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
      <p className="eyebrow"><span className="size-1.5 rounded-full bg-teal" /> {eyebrow}</p>
      <h2 id={headingId} className="mt-6 text-balance text-4xl font-extrabold leading-[1.02] tracking-[-0.06em] text-ink sm:text-5xl">
        {title}
      </h2>
      <p className="mt-5 max-w-xl text-pretty text-base leading-7 text-muted sm:text-lg">
        {description}
      </p>
    </div>
  )
}
