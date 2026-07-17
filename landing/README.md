# DoBre

DoBre helps Mercado Libre sellers estimate a listing price from the amount they want to receive. It presents the key publication variables in a clear flow, so sellers can make faster and more informed pricing decisions.

## Features

- Responsive bilingual landing in Spanish and English.
- Persistent language and color-theme preferences.
- Interactive price simulator for product discovery.
- Platform-specific Android and Windows download actions.
- Android installation guidance for GitHub Releases distribution.
- Accessible navigation, keyboard support, and reduced-motion handling.
- SEO, Open Graph, Twitter Card, sitemap, robots file, and social-share assets.

## Screenshots

Product screenshots will be added here when final branding assets are available.

## Tech Stack

- Flutter for the DoBre application.
- React, Vite, TypeScript, and Tailwind CSS for this landing.
- Cloudflare Pages for static hosting.
- Cloudflare Workers for remote configuration consumed by the Flutter app.

## Repository Structure

```text
dobre/
  lib/                  Flutter application
  cloudflare-worker/    Remote configuration worker
  landing/              React/Vite marketing site
    public/             Static SEO and social assets
    src/components/     Reusable UI components
    src/i18n/           Explicit Spanish and English copy
    src/lib/            Site and release configuration
```

## Local Development

```bash
cd landing
npm install
npm run dev
```

## Production Build

```bash
npm run build
```

For Cloudflare Pages, use `npm run build` as the build command and `dist` as the output directory.

## Downloads

Platform download URLs are intentionally isolated in `src/lib/site-config.ts`:

```ts
releaseConfig.androidDownloadUrl
releaseConfig.windowsDownloadUrl
```

Set either value to `null` to hide its corresponding download action. This landing does not fetch release information at runtime.

## Disclaimer

DoBre is an independent project and is not affiliated with, associated with, or endorsed by Mercado Libre. It uses public information and user-selected settings to generate estimates. Mercado Libre is a registered trademark of its respective owner. Always verify the current official conditions before listing.

## Roadmap

- Replace placeholder visuals with final product screenshots and branding assets.
- Connect release metadata through the existing configuration boundary.
- Extend product documentation as distribution channels grow.

## License

No license has been published for this repository yet. All rights are reserved unless a future license states otherwise.
