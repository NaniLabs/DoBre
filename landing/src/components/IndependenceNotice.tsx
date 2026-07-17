export function IndependenceNotice() {
  return (
    <section className="border-b border-line bg-canvas px-5 py-16 sm:px-8 sm:py-20 lg:px-10" aria-labelledby="independence-title">
      <div className="mx-auto grid max-w-7xl gap-7 rounded-[2rem] border border-line bg-surface-raised p-7 sm:p-9 lg:grid-cols-[auto_1fr] lg:items-start lg:gap-8">
        <span className="grid size-12 place-items-center rounded-2xl bg-teal-soft text-teal"><InfoIcon /></span>
        <div>
          <h2 id="independence-title" className="text-xl font-extrabold tracking-[-0.04em] text-ink">Informacion importante</h2>
          <p className="mt-3 max-w-4xl text-sm leading-6 text-muted sm:text-base">
            DoBre es un proyecto independiente, sin afiliación, asociación ni respaldo de Mercado Libre. Usa información pública y las opciones definidas por cada usuario para generar estimaciones. Mercado Libre® es una marca registrada de su respectivo titular. Antes de publicar, verificá siempre las condiciones oficiales vigentes.
          </p>
        </div>
      </div>
    </section>
  )
}

function InfoIcon() {
  return <svg aria-hidden="true" viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9" /><path d="M12 10.5v5M12 7.5h.01" /></svg>
}
