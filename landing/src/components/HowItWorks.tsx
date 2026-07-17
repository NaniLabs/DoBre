import { SectionHeading } from './SectionHeading'

const steps = [
  {
    number: '01',
    title: 'Decís cuánto querés recibir.',
    description: 'Partís de tu objetivo, no de una cuenta aproximada.',
    visual: <AmountVisual />,
  },
  {
    number: '02',
    title: 'Elegís la publicación.',
    description: 'Categoría, tipo, cuotas y envío. Solo lo que realmente importa.',
    visual: <OptionsVisual />,
  },
  {
    number: '03',
    title: 'DoBre hace el resto.',
    description: 'Obtenés un precio sugerido claro para publicar con seguridad.',
    visual: <ResultVisual />,
  },
]

export function HowItWorks() {
  return (
    <section id="como-funciona" className="relative overflow-hidden px-5 py-24 sm:px-8 sm:py-32 lg:px-10" aria-labelledby="how-it-works-title">
      <div className="absolute right-0 top-1/3 -z-10 size-96 rounded-full bg-teal/8 blur-[100px]" />
      <div className="mx-auto max-w-7xl">
        <SectionHeading
          eyebrow="Una cuenta, sin vueltas"
          title={<>De tu objetivo a un <span className="text-gradient">precio para publicar.</span></>}
          description="El flujo está pensado para que la decisión importante se sienta simple: saber cuánto pedir para llegar a lo que querés recibir."
          headingId="how-it-works-title"
        />
        <div className="relative mt-14 grid gap-6 lg:mt-16 lg:grid-cols-3 lg:gap-8">
          <div className="flow-line absolute left-[16.5%] right-[16.5%] top-10 hidden lg:block" aria-hidden="true" />
          {steps.map((step) => (
            <article key={step.number} className="relative rounded-[2rem] border border-line bg-surface p-6 shadow-[0_18px_55px_rgba(15,23,42,0.05)] transition duration-300 hover:-translate-y-1 hover:shadow-card sm:p-7">
              <span className="relative z-10 grid size-11 place-items-center rounded-2xl bg-ink font-mono text-xs font-medium text-canvas ring-8 ring-canvas">{step.number}</span>
              <div className="mt-8">{step.visual}</div>
              <h3 className="mt-7 text-xl font-extrabold tracking-[-0.045em] text-ink">{step.title}</h3>
              <p className="mt-3 max-w-sm text-sm leading-6 text-muted">{step.description}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  )
}

function AmountVisual() {
  return <div className="relative h-36 overflow-hidden rounded-2xl border border-line bg-surface-raised p-5"><p className="font-mono text-[0.65rem] font-medium uppercase tracking-[0.14em] text-muted">Quiero recibir</p><p className="mt-2 text-3xl font-extrabold tracking-[-0.06em] text-ink">$ 50.000</p><span className="absolute bottom-5 right-5 size-2 rounded-full bg-teal shadow-[0_0_0_5px_color-mix(in_srgb,var(--teal)_15%,transparent)]" /></div>
}

function OptionsVisual() {
  return <div className="grid h-36 grid-cols-2 gap-3 rounded-2xl border border-line bg-surface-raised p-4"><OptionPill label="Categoría" value="Electrónica" /><OptionPill label="Cuotas" value="Sin cuotas" /><OptionPill label="Publicación" value="Clásica" /><OptionPill label="Envío" value="Gratis" /></div>
}

function OptionPill({ label, value }: { label: string; value: string }) {
  return <div className="rounded-xl border border-line bg-surface px-3 py-2"><p className="text-[0.6rem] font-bold text-muted">{label}</p><p className="mt-1 text-xs font-extrabold text-ink">{value}</p></div>
}

function ResultVisual() {
  return <div className="flex h-36 flex-col justify-between overflow-hidden rounded-2xl bg-[linear-gradient(135deg,#0f766e,#2563eb)] p-5 text-white shadow-[0_12px_30px_rgba(15,118,110,0.2)]"><p className="font-mono text-[0.65rem] font-medium uppercase tracking-[0.14em] text-white/70">Precio sugerido</p><div className="flex items-end justify-between gap-2"><p className="text-3xl font-extrabold tracking-[-0.06em]">$ 63.619</p><span className="grid size-7 place-items-center rounded-full bg-white/15"><CheckIcon /></span></div></div>
}

function CheckIcon() {
  return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m4 10 3.4 3.4L16 5.5" /></svg>
}
