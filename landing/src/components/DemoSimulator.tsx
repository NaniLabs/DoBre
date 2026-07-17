import { useId, useMemo, useState } from 'react'
import { SectionHeading } from './SectionHeading'

const categories = [
  { value: 'electronics', label: 'Electrónica', rate: 0.15 },
  { value: 'fashion', label: 'Indumentaria', rate: 0.135 },
  { value: 'home', label: 'Hogar y jardín', rate: 0.13 },
  { value: 'sports', label: 'Deportes y fitness', rate: 0.135 },
]

const installments = [
  { value: 'none', label: 'Sin cuotas', rate: 0 },
  { value: '3', label: '3 sin interés', rate: 0.084 },
  { value: '6', label: '6 sin interés', rate: 0.123 },
  { value: '12', label: '12 sin interés', rate: 0.192 },
]

const publicationTypes = [
  { value: 'classic', label: 'Clásica', rate: 0 },
  { value: 'premium', label: 'Premium', rate: 0.03 },
]

export function DemoSimulator() {
  const amountId = useId()
  const categoryId = useId()
  const publicationId = useId()
  const installmentsId = useId()
  const shippingId = useId()
  const [amount, setAmount] = useState('50000')
  const [category, setCategory] = useState(categories[0].value)
  const [publicationType, setPublicationType] = useState(publicationTypes[0].value)
  const [installment, setInstallment] = useState(installments[0].value)
  const [freeShipping, setFreeShipping] = useState(true)

  const suggestedPrice = useMemo(() => {
    const target = Math.max(Number(amount.replace(/[^\d]/g, '')) || 0, 1000)
    const categoryRate = categories.find((item) => item.value === category)?.rate ?? 0
    const publicationRate = publicationTypes.find((item) => item.value === publicationType)?.rate ?? 0
    const installmentRate = installments.find((item) => item.value === installment)?.rate ?? 0
    const shippingCost = freeShipping ? 4400 : 0
    const fixedCost = target < 33000 ? 1800 : 0
    const retainedRate = Math.min(categoryRate + publicationRate + installmentRate, 0.5)

    return Math.ceil((target + shippingCost + fixedCost) / (1 - retainedRate))
  }, [amount, category, publicationType, installment, freeShipping])

  const money = new Intl.NumberFormat('es-AR', {
    style: 'currency',
    currency: 'ARS',
    maximumFractionDigits: 0,
  })

  return (
    <section id="simulador" className="relative overflow-hidden border-y border-line bg-surface px-5 py-24 sm:px-8 sm:py-32 lg:px-10" aria-labelledby="simulator-title">
      <div className="absolute bottom-0 left-1/2 -z-0 h-72 w-[42rem] -translate-x-1/2 rounded-full bg-blue-500/10 blur-[100px]" />
      <div className="relative z-10 mx-auto max-w-7xl">
        <SectionHeading
          eyebrow="Probalo ahora"
          title={<>Una publicación de ejemplo. <span className="text-gradient">Tu resultado al instante.</span></>}
          description="Esto es una demostración visual. La app te permite definir el contexto de una publicación y encontrar un precio sugerido en segundos."
          align="center"
          headingId="simulator-title"
        />
        <div className="mt-14 grid overflow-hidden rounded-[2rem] border border-line bg-canvas shadow-[0_24px_70px_rgba(15,23,42,0.09)] lg:mt-16 lg:grid-cols-[1.08fr_.92fr]">
          <form className="p-6 sm:p-9" onSubmit={(event) => event.preventDefault()}>
            <div className="flex items-center justify-between border-b border-line pb-5">
              <div><p className="text-base font-extrabold tracking-[-0.035em] text-ink">Configurá tu publicación</p><p className="mt-1 text-sm text-muted">Ajustá las variables y mirá el resultado.</p></div>
              <span className="hidden size-10 place-items-center rounded-2xl bg-teal-soft text-teal sm:grid"><SlidersIcon /></span>
            </div>
            <div className="mt-6 grid gap-5 sm:grid-cols-2">
              <label className="field-label sm:col-span-2" htmlFor={amountId}>Monto que querés recibir<input id={amountId} className="field-input money-input" inputMode="numeric" value={amount} onChange={(event) => setAmount(event.target.value)} aria-describedby={`${amountId}-hint`} /><span id={`${amountId}-hint`} className="mt-2 text-xs font-medium text-muted">Monto neto estimado, en pesos argentinos.</span></label>
              <SelectField id={categoryId} label="Categoría" value={category} onChange={setCategory} options={categories} />
              <SelectField id={publicationId} label="Tipo de publicación" value={publicationType} onChange={setPublicationType} options={publicationTypes} />
              <SelectField id={installmentsId} label="Cuotas" value={installment} onChange={setInstallment} options={installments} />
              <div className="field-label"><span>Envío</span><label className="shipping-control" htmlFor={shippingId}><span><strong className="block text-sm text-ink">Envío gratis</strong><span className="mt-0.5 block text-xs font-medium text-muted">Lo absorbe el vendedor</span></span><input id={shippingId} className="sr-only" type="checkbox" checked={freeShipping} onChange={(event) => setFreeShipping(event.target.checked)} /><span className="switch-track" aria-hidden="true"><span className="switch-thumb" /></span></label></div>
            </div>
          </form>
          <div className="relative flex min-h-[22rem] flex-col justify-between overflow-hidden bg-[linear-gradient(150deg,#0f766e,#2563eb)] p-7 text-white sm:p-9">
            <div className="absolute -right-20 -top-16 size-64 rounded-full border border-white/15" /><div className="absolute -bottom-28 -left-20 size-72 rounded-full border border-white/10" />
            <div className="relative flex items-center justify-between"><span className="inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-3 py-1.5 font-mono text-[0.65rem] font-medium uppercase tracking-[0.12em] text-white/85"><span className="size-1.5 rounded-full bg-[#5eead4]" /> Simulación</span><span className="grid size-10 place-items-center rounded-2xl bg-white/10"><CalculatorIcon /></span></div>
            <div className="relative py-9"><p className="text-sm font-semibold text-white/70">Precio sugerido para publicar</p><output className="mt-3 block text-balance text-5xl font-extrabold tracking-[-0.07em] sm:text-6xl" aria-live="polite" aria-atomic="true">{money.format(suggestedPrice)}</output><p className="mt-5 max-w-xs text-sm leading-6 text-white/75">Calculado con las opciones que elegiste en esta demostración.</p></div>
            <div className="relative flex items-center gap-3 border-t border-white/15 pt-5 text-sm font-semibold text-white/85"><span className="grid size-7 place-items-center rounded-full bg-white/15"><CheckIcon /></span> Listo para seguir en DoBre</div>
          </div>
        </div>
        <p className="mx-auto mt-5 max-w-2xl text-center text-xs leading-5 text-muted">El simulador usa valores ilustrativos y no reemplaza la configuración vigente de Mercado Libre dentro de la aplicación.</p>
      </div>
    </section>
  )
}

type SelectOption = { value: string; label: string }

function SelectField({ id, label, value, onChange, options }: { id: string; label: string; value: string; onChange: (value: string) => void; options: SelectOption[] }) {
  return <label className="field-label" htmlFor={id}>{label}<span className="select-wrap"><select id={id} className="field-input appearance-none" value={value} onChange={(event) => onChange(event.target.value)}>{options.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}</select><SelectIcon /></span></label>
}

function SlidersIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"><path d="M4 7h16M4 17h16M8 4v6M16 14v6" /></svg> }
function SelectIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="pointer-events-none absolute right-4 top-1/2 size-4 -translate-y-1/2 text-muted" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="m5 8 5 5 5-5" /></svg> }
function CalculatorIcon() { return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><rect x="5" y="3" width="14" height="18" rx="2" /><path d="M8 7h8M8 12h.01M12 12h.01M16 12h.01M8 16h.01M12 16h.01M16 16h.01" /></svg> }
function CheckIcon() { return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m4 10 3.4 3.4L16 5.5" /></svg> }
