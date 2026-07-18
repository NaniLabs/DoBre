# DoBre Landing

The official DoBre marketing site. It explains the product, offers the installed Android and Windows releases, and links visitors to the live Web application.

## Stack

- React 19
- Vite
- TypeScript
- Tailwind CSS
- Cloudflare Pages

## Local Development

```bash
npm install
npm run dev
```

## Production Build

```bash
npm run build
```

Deploy `dist/` to Cloudflare Pages.

## Release Data

The landing does not duplicate release metadata. At build time, `vite.config.ts` reads the `dobre_release` block and `version` from the repository-level `pubspec.yaml`, then exposes a typed `releaseConfig` to components.

Update the version once in `pubspec.yaml`; Android and Windows URLs are built from the configured GitHub Release base URL and asset-name templates. Set an asset name to `null` to hide that platform automatically. The same configuration contains the Web app, changelog, maintenance state, and reserved Linux/macOS fields.

## Branding

All replaceable landing assets are in `public/branding/`:

- `logo.svg`, `logo-dark.svg`, and `favicon.svg`
- `icon.png` and `icon.ico`
- `og-image.svg` and `og-image-en.svg`

Replace files in place to update branding without changing component code.

## SEO

The site includes a manifest, canonical and alternate-language metadata, Open Graph and Twitter metadata, `robots.txt`, and `sitemap.xml`. The language provider synchronizes document language and localized social metadata when visitors change language.

## Disclaimer

DoBre is an independent project and is not affiliated with, associated with, or endorsed by Mercado Libre. Always verify the current official conditions before listing.
