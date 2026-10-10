import { useState, useMemo } from 'react'
import { useLanguage } from '../i18n/LanguageProvider'

type Category = 'electronics' | 'fashion' | 'home' | 'other'
type PublicationType = 'classic' | 'free'
type Installments = 1 | 3 | 6 | 12

interface CalculatorState {
  netAmount: number
  category: Category
  publicationType: PublicationType
  installments: Installments
  freeShipping: boolean
}

const COMMISSION_RATES = {
  classic: 0.12,
  free: 0.15,
} as const

const INSTALLMENT_RATES: Record<Installments, number> = {
  1: 0,
  3: 0.08,
  6: 0.12,
  12: 0.18,
} as const

const SHIPPING_COST = 2500

function formatCurrency(amount: number, locale: string): string {
  return new Intl.NumberFormat(locale === 'es' ? 'es-AR' : 'en-US', {
    style: 'decimal',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(Math.round(amount))
}

export function InverseCalculator() {
  const { language, copy } = useLanguage()
  const [state, setState] = useState<CalculatorState>({
    netAmount: 50000,
    category: 'electronics',
    publicationType: 'classic',
    installments: 1,
    freeShipping: false,
  })

  const calculation = useMemo(() => {
    const commissionRate = COMMISSION_RATES[state.publicationType]
    const installmentRate = INSTALLMENT_RATES[state.installments]
    const shippingCost = state.freeShipping ? SHIPPING_COST : 0
    
    const totalRate = commissionRate + installmentRate
    const divisor = 1 - totalRate
    
    if (divisor <= 0) {
      return { suggestedPrice: 0, commission: 0, installmentFee: 0, shippingCost, error: true }
    }
    
    const suggestedPrice = (state.netAmount + shippingCost) / divisor
    const commission = suggestedPrice * commissionRate
    const installmentFee = suggestedPrice * installmentRate
    
    return {
      suggestedPrice: Math.round(suggestedPrice),
      commission: Math.round(commission),
      installmentFee: Math.round(installmentFee),
      shippingCost,
      error: false,
    }
  }, [state])

  const update = <K extends keyof CalculatorState>(key: K, value: CalculatorState[K]) => {
    setState(prev => ({ ...prev, [key]: value }))
  }

  const reset = () => {
    setState({
      netAmount: 50000,
      category: 'electronics',
      publicationType: 'classic',
      installments: 1,
      freeShipping: false,
    })
  }

  return (
    <div 
      className="relative w-full max-w-2xl mx-auto"
      role="region"
      aria-label={copy.calculator.ariaLabel}
    >
      <div className="rounded-3xl border border-line bg-surface p-6 sm:p-8 shadow-[0_24px_60px_rgba(15,23,42,0.14)]">
        {/* Header */}
        <div className="mb-6">
          <p className="text-sm font-bold text-muted uppercase tracking-wider">
            {copy.calculator.label}
          </p>
        </div>

        {/* Net Amount Input */}
        <div className="mb-6">
          <label htmlFor="net-amount" className="field-label">
            <span>{copy.calculator.netAmount}</span>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-2xl font-bold text-muted">$</span>
              <input
                id="net-amount"
                type="number"
                value={state.netAmount}
                onChange={(e) => update('netAmount', Math.max(0, Number(e.target.value)))}
                className="field-input money-input pl-10"
                min="0"
                step="1000"
                aria-describedby="net-amount-help"
              />
            </div>
            <span id="net-amount-help" className="sr-only">
              {copy.calculator.netAmount}
            </span>
          </label>
        </div>

        {/* Options Grid */}
        <div className="grid grid-cols-2 gap-4 mb-6">
          {/* Category */}
          <div>
            <label htmlFor="category" className="field-label">
              <span>{copy.calculator.category}</span>
              <select
                id="category"
                value={state.category}
                onChange={(e) => update('category', e.target.value as Category)}
                className="field-input"
              >
                {copy.calculator.categoryOptions.map((option, index) => {
                  const values: Category[] = ['electronics', 'fashion', 'home', 'other']
                  return (
                    <option key={values[index]} value={values[index]}>
                      {option}
                    </option>
                  )
                })}
              </select>
            </label>
          </div>

          {/* Publication Type */}
          <div>
            <label className="field-label">
              <span>{copy.calculator.publicationType}</span>
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => update('publicationType', 'classic')}
                  className={`flex-1 rounded-xl border px-3 py-2.5 text-sm font-bold transition ${
                    state.publicationType === 'classic'
                      ? 'border-teal bg-teal-soft text-teal'
                      : 'border-line bg-surface text-muted hover:border-teal/50'
                  }`}
                  aria-pressed={state.publicationType === 'classic'}
                >
                  {copy.calculator.publicationOptions[0]}
                </button>
                <button
                  type="button"
                  onClick={() => update('publicationType', 'free')}
                  className={`flex-1 rounded-xl border px-3 py-2.5 text-sm font-bold transition ${
                    state.publicationType === 'free'
                      ? 'border-teal bg-teal-soft text-teal'
                      : 'border-line bg-surface text-muted hover:border-teal/50'
                  }`}
                  aria-pressed={state.publicationType === 'free'}
                >
                  {copy.calculator.publicationOptions[1]}
                </button>
              </div>
            </label>
          </div>

          {/* Installments */}
          <div>
            <label htmlFor="installments" className="field-label">
              <span>{copy.calculator.installments}</span>
              <select
                id="installments"
                value={state.installments}
                onChange={(e) => update('installments', Number(e.target.value) as Installments)}
                className="field-input"
              >
                {[1, 3, 6, 12].map((num) => (
                  <option key={num} value={num}>
                    {num} {language === 'es' ? 'cuota' : num === 1 ? 'installment' : 'installments'}
                  </option>
                ))}
              </select>
            </label>
          </div>

          {/* Shipping */}
          <div>
            <label className="field-label">
              <span>{copy.calculator.shipping}</span>
              <button
                type="button"
                onClick={() => update('freeShipping', !state.freeShipping)}
                className={`w-full rounded-xl border px-3 py-2.5 text-sm font-bold transition ${
                  state.freeShipping
                    ? 'border-teal bg-teal-soft text-teal'
                    : 'border-line bg-surface text-muted hover:border-teal/50'
                }`}
                aria-pressed={state.freeShipping}
              >
                {state.freeShipping ? copy.calculator.freeShipping : copy.calculator.noFreeShipping}
              </button>
            </label>
          </div>
        </div>

        {/* Result */}
        {!calculation.error && calculation.suggestedPrice > 0 && (
          <div className="rounded-2xl bg-teal p-6 text-white">
            <p className="text-xs font-bold uppercase tracking-wider text-white/80">
              {copy.calculator.suggestedPrice}
            </p>
            <p className="mt-2 text-4xl font-extrabold tracking-tight">
              $ {formatCurrency(calculation.suggestedPrice, language)}
            </p>
            
            {/* Breakdown */}
            <div className="mt-5 space-y-2 border-t border-white/20 pt-4 text-sm">
              <div className="flex justify-between">
                <span className="text-white/80">{copy.calculator.commission}</span>
                <span className="font-bold">$ {formatCurrency(calculation.commission, language)}</span>
              </div>
              {calculation.installmentFee > 0 && (
                <div className="flex justify-between">
                  <span className="text-white/80">{copy.calculator.installmentFee}</span>
                  <span className="font-bold">$ {formatCurrency(calculation.installmentFee, language)}</span>
                </div>
              )}
              {calculation.shippingCost > 0 && (
                <div className="flex justify-between">
                  <span className="text-white/80">{copy.calculator.shippingCost}</span>
                  <span className="font-bold">$ {formatCurrency(calculation.shippingCost, language)}</span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Reset Button */}
        <div className="mt-5 flex justify-end">
          <button
            type="button"
            onClick={reset}
            className="text-sm font-bold text-muted hover:text-teal transition"
          >
            {copy.calculator.reset}
          </button>
        </div>
      </div>
    </div>
  )
}
