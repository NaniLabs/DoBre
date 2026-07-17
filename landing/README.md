# Landing de DoBre

Landing independiente de la aplicación Flutter. Está construida con React, Vite, TypeScript y Tailwind CSS.

## Desarrollo

```bash
npm install
npm run dev
```

## Cloudflare Pages

- Framework preset: `Vite`
- Build command: `npm run build`
- Build output directory: `dist`
- Node.js: `22` o superior

Los datos de lanzamiento futuros están aislados en `src/lib/site-config.ts`. La interfaz no depende todavía de ninguna petición de red. Allí quedan preparados `androidDownloadUrl` y `windowsDownloadUrl` para conectarlos manualmente más adelante.

## Recursos reemplazables

- Logo: `src/components/BrandMark.tsx`
- Vista de producto del hero: `src/components/HeroPreview.tsx`
- Textos, enlaces de descarga y datos de lanzamiento: `src/lib/site-config.ts`
