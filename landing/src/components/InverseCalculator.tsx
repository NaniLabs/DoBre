import { useState, useMemo } from 'react'
import { useLanguage } from '../i18n/LanguageProvider'

type CategoryId =
  | 'electronics'
  | 'computing'
  | 'cellphones'
  | 'home'
  | 'fashion'
  | 'vehicle_accessories'

type PublicationType = 'classic' | 'premium'
type InstallmentPlan = '0' | '3' | '6' | '12'

interface CalculatorState {
  netAmount: number
  category: CategoryId
  publicationType: PublicationType
  installments: InstallmentPlan
  freeShipping: boolean
}

const CATEGORY_KEYS: CategoryId[] = [
  'electronics',
  'computing',
  'cellphones',
  'home',
  'fashion',
  'vehicle_accessories',
]

// Official rates from assets/config/default_config.json
const CATEGORY_FEES: Record<CategoryId, { classic: number; premium: number }> = {
  electronics: { classic: 0.15, premium: 0.1714 },
  computing: { classic: 0.15, premium: 0.1714 },
  cellphones: { classic: 0.13, premium: 0.165 },
  home: { classic: 0.13, premium: 0.165 },
  fashion: { classic: 0.135, premium: 0.1714 },
  vehicle_accessories: { classic: 0.14, premium: 0.1714 },
}

const INSTALLMENT_RATES: Record<InstallmentPlan, number> = {
  '0': 0.0,
  '3': 0.084,
  '6': 0.123,
  '12': 0.192,
}

function getFixedCharge(publishedPrice: number): number {
  if (publishedPrice <= 12000) return 900
  if (publishedPrice < 33000) return 1800
  return 0
}

function getShippingCost(publishedPrice: number, freeShipping: boolean): number {
  if (!freeShipping) return 0
  if (publishedPrice < 33000) return 8596
  if (publishedPrice < 50000) return 6140
  return 6600
}

function calculateReceived(
  publishedPrice: number,
  commissionRate: number,
  installmentRate: number,
  freeShipping: boolean
): number {
  if (publishedPrice <= 0) return 0
  const commission = publishedPrice * commissionRate
  const installmentCost = publishedPrice * installmentRate
  const fixedCharge = getFixedCharge(publishedPrice)
  const shippingCost = getShippingCost(publishedPrice, freeShipping)
  return publishedPrice - commission - installmentCost - fixedCharge - shippingCost
}

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
    installments: '0',
    freeShipping: false,
  })

  const calculation = useMemo(() => {
    const commissionRate = CATEGORY_FEES[state.category][state.publicationType]
    const installmentRate =
      state.publicationType === 'premium' ? INSTALLMENT_RATES[state.installments] : 0

    if (state.netAmount <= 0) {
      return {
        suggestedPrice: 0,
        commission: 0,
         commissionPct: Math.round(commissionRate * 1000) / 10,
        installmentFee: 0,
        installmentPct: Math.round(installmentRate * 1000) / 10,
        fixedCharge: 0,
        shippingCost: 0,
        error: false,
      }
    }

    // Binary search matching lib/services/pricing_calculator.dart
    let min = 0
    let max = state.netAmount * 2 + 50000
    for (let i = 0; i < 65; i++) {
      const mid = (min + max) / 2
      const net = calculateReceived(mid, commissionRate, installmentRate, state.freeShipping)
      if (net < state.netAmount) {
        min = mid
      } else {
        max = mid
      }
    }

    const suggestedPrice = Math.round(max)
    const commission = Math.round(suggestedPrice * commissionRate)
    const installmentFee = Math.round(suggestedPrice * installmentRate)
    const fixedCharge = getFixedCharge(suggestedPrice)
    const shippingCost = getShippingCost(suggestedPrice, state.freeShipping)

    return {
      suggestedPrice,
      commission,
      commissionPct: Math.round(commissionRate * 1000) / 10,
      installmentFee,
      installmentPct: Math.round(installmentRate * 1000) / 10,
      fixedCharge,
      shippingCost,
      error: false,
    }
  }, [state])

  const update = <K extends keyof CalculatorState>(key: K, value: CalculatorState[K]) => {
    setState((prev) => {
      const next = { ...prev, [key]: value }
      if (key === 'publicationType' && value === 'classic') {
        next.installments = '0'
      }
      if (key === 'installments' && value !== '0') {
        next.publicationType = 'premium'
      }
      return next
    })
  }

  const reset = () => {
    setState({
      netAmount: 50000,
      category: 'electronics',
      publicationType: 'classic',
      installments: '0',
      freeShipping: false,
    })
  }

  const installmentLabels: Record<InstallmentPlan, string> =
    language === 'es'
      ? {
          '0': 'Sin cuotas sin interés (0%)',
          '3': '3 cuotas sin interés (8,4%)',
          '6': '6 cuotas sin interés (12,3%)',
          '12': '12 cuotas sin interés (19,2%)',
        }
      : {
          '0': 'No interest-free installments (0%)',
          '3': '3 installments (8.4%)',
          '6': '6 installments (12.3%)',
          '12': '12 installments (19.2%)',
        }

  return (
    <div
      className="relative w-full max-w-xl mx-auto lg:mr-0"
      role="region"
      aria-label={copy.calculator.ariaLabel}
    >
      <div className="rounded-2xl border border-line bg-surface p-5 sm:p-6 shadow-card">
        <div className="mb-4 flex items-center justify-between border-b border-line pb-3">
          <p className="font-mono text-xs font-medium uppercase tracking-wider text-muted">
            {copy.calculator.label}
          </p>
          <button
            type="button"
            onClick={reset}
            className="text-xs font-medium text-muted hover:text-ink transition cursor-pointer"
          >
            {copy.calculator.reset}
          </button>
        </div>

        {/* Net Amount Input */}
        <div className="mb-4">
          <label htmlFor="net-amount" className="field-label">
            <span>{copy.calculator.netAmount}</span>
            <div className="relative">
              <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-base font-semibold text-muted">
                $
              </span>
              <input
                id="net-amount"
                type="number"
                value={state.netAmount}
                onChange={(e) => update('netAmount', Math.max(0, Number(e.target.value)))}
                className="field-input money-input pl-8"
                min="0"
                step="1000"
              />
            </div>
          </label>
        </div>

        {/* Options Grid */}
        <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 mb-5">
          {/* Category */}
          <div>
            <label htmlFor="category" className="field-label">
              <span>{copy.calculator.category}</span>
              <select
                id="category"
                value={state.category}
                onChange={(e) => update('category', e.target.value as CategoryId)}
                className="field-input"
              >
                {copy.calculator.categoryOptions.map((option, index) => (
                  <option key={CATEGORY_KEYS[index]} value={CATEGORY_KEYS[index]}>
                    {option}
                  </option>
                ))}
              </select>
            </label>
          </div>

          {/* Publication Type */}
          <div>
            <div className="field-label">
              <span>{copy.calculator.publicationType}</span>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => update('publicationType', 'classic')}
                  className={`rounded-lg border px-3 py-2 text-xs font-semibold transition cursor-pointer ${
                    state.publicationType === 'classic'
                      ? 'border-teal bg-teal-soft text-teal'
                      : 'border-line bg-surface text-muted hover:text-ink'
                  }`}
                  aria-pressed={state.publicationType === 'classic'}
                >
                  {copy.calculator.publicationOptions[0]}
                </button>
                <button
                  type="button"
                  onClick={() => update('publicationType', 'premium')}
                  className={`rounded-lg border px-3 py-2 text-xs font-semibold transition cursor-pointer ${
                    state.publicationType === 'premium'
                      ? 'border-teal bg-teal-soft text-teal'
                      : 'border-line bg-surface text-muted hover:text-ink'
                  }`}
                  aria-pressed={state.publicationType === 'premium'}
                >
                  {copy.calculator.publicationOptions[1]}
                </button>
              </div>
            </div>
          </div>

          {/* Installments */}
          <div>
            <label htmlFor="installments" className="field-label">
              <span>{copy.calculator.installments}</span>
              <select
                id="installments"
                value={state.installments}
                onChange={(e) => update('installments', e.target.value as InstallmentPlan)}
                className="field-input"
              >
                {(['0', '3', '6', '12'] as InstallmentPlan[]).map((plan) => (
                  <option key={plan} value={plan}>
                    {installmentLabels[plan]}
                  </option>
                ))}
              </select>
            </label>
          </div>

          {/* Shipping */}
          <div>
            <div className="field-label">
              <span>{copy.calculator.shipping}</span>
              <button
                type="button"
                onClick={() => update('freeShipping', !state.freeShipping)}
                className={`w-full rounded-lg border px-3 py-2 text-xs font-semibold transition cursor-pointer text-left truncate ${
                  state.freeShipping
                    ? 'border-teal bg-teal-soft text-teal'
                    : 'border-line bg-surface text-muted hover:text-ink'
                }`}
                aria-pressed={state.freeShipping}
              >
                {state.freeShipping ? copy.calculator.freeShipping : copy.calculator.noFreeShipping}
              </button>
            </div>
          </div>
        </div>

        {/* Result Box - High contrast in both light and dark themes */}
        {!calculation.error && calculation.suggestedPrice > 0 && (
          <div className="rounded-xl border border-line bg-surface-raised p-4 sm:p-5">
            <div className="flex flex-wrap items-baseline justify-between gap-2">
              <p className="font-mono text-xs font-medium uppercase tracking-wider text-teal">
                {copy.calculator.suggestedPrice}
              </p>
              <span className="font-mono text-xs text-muted">
                {copy.calculator.netVerified}: $ {formatCurrency(state.netAmount, language)}
              </span>
            </div>
            <p className="mt-1.5 text-2xl sm:text-3xl font-bold tracking-tight text-ink">
              $ {formatCurrency(calculation.suggestedPrice, language)}
            </p>

            {/* Breakdown */}
            <div className="mt-4 space-y-1.5 border-t border-line pt-3 text-xs">
              <div className="flex justify-between text-muted">
                <span>
                  {copy.calculator.commission} ({calculation.commissionPct}%)
                </span>
                <span className="font-mono font-semibold text-ink">
                  - $ {formatCurrency(calculation.commission, language)}
                </span>
              </div>
              {calculation.installmentFee > 0 && (
                <div className="flex justify-between text-muted">
                  <span>
                    {copy.calculator.installmentFee} ({calculation.installmentPct}%)
                  </span>
                  <span className="font-mono font-semibold text-ink">
                    - $ {formatCurrency(calculation.installmentFee, language)}
                  </span>
                </div>
              )}
              {calculation.fixedCharge > 0 && (
                <div className="flex justify-between text-muted">
                  <span>{copy.calculator.fixedCharge}</span>
                  <span className="font-mono font-semibold text-ink">
                    - $ {formatCurrency(calculation.fixedCharge, language)}
                  </span>
                </div>
              )}
              {calculation.shippingCost > 0 && (
                <div className="flex justify-between text-muted">
                  <span>{copy.calculator.shippingCost}</span>
                  <span className="font-mono font-semibold text-ink">
                    - $ {formatCurrency(calculation.shippingCost, language)}
                  </span>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
