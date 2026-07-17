import { SectionHeading } from './SectionHeading'

export function Faq() {
  return (
    <section id="preguntas-frecuentes" className="px-5 py-24 sm:px-8 sm:py-32 lg:px-10" aria-labelledby="faq-title">
      <div className="mx-auto grid max-w-7xl gap-12 lg:grid-cols-[.82fr_1.18fr] lg:items-start">
        <SectionHeading
          eyebrow="Preguntas frecuentes"
          title={<>Informacion clara antes de <span className="text-gradient">publicar.</span></>}
          description="DoBre busca ayudarte a estimar mejor. La decision final sobre cada publicacion siempre es tuya."
          headingId="faq-title"
        />
        <div className="rounded-[2rem] border border-line bg-surface p-2 shadow-[0_18px_55px_rgba(15,23,42,0.05)]">
          <details className="faq-item group" open>
            <summary className="flex cursor-pointer list-none items-center justify-between gap-5 p-5 text-left text-base font-extrabold tracking-[-0.025em] text-ink sm:p-6">
              ¿DoBre está afiliado a Mercado Libre?
              <span className="grid size-8 shrink-0 place-items-center rounded-full border border-line text-teal transition duration-200 group-open:rotate-45"><PlusIcon /></span>
            </summary>
            <div className="px-5 pb-6 text-sm leading-6 text-muted sm:px-6">
              No. DoBre es un proyecto independiente y no tiene afiliación, asociación ni respaldo de Mercado Libre. Las estimaciones se basan en información pública y en la configuración elegida por cada usuario; verificá siempre las condiciones oficiales antes de publicar.
            </div>
          </details>
        </div>
      </div>
    </section>
  )
}

function PlusIcon() {
  return <svg aria-hidden="true" viewBox="0 0 20 20" className="size-4" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M10 4v12M4 10h12" /></svg>
}
