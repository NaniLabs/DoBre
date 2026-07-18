# DoBre

DoBre helps Mercado Libre sellers estimate a listing price from the amount they want to receive. It combines a Flutter application with a production-ready marketing site and a Cloudflare Worker for remote configuration.

## Highlights

- Flutter application for Android, Windows, and Web.
- Remote configuration with bundled and cached offline fallbacks.
- React, Vite, TypeScript, and Tailwind CSS landing page.
- Spanish and English landing experience with light and dark themes.
- Centralized release metadata derived from `pubspec.yaml`.
- Branding assets isolated for straightforward replacement.

## Repository Structure

```text
dobre/
  lib/                        Flutter application
  assets/config/              Bundled configuration fallback
  cloudflare-worker/          Remote configuration API
  landing/                    React/Vite marketing site
    public/branding/          Replaceable brand assets
    src/components/           Reusable UI components
    src/i18n/                 Spanish and English copy
  flutter_launcher_icons.yaml Icon generation configuration
  pubspec.yaml                Single release source of truth
```

## Release Configuration

`pubspec.yaml` is the single source of truth for the app version and release metadata. Update only this line for a new release:

```yaml
version: 0.3.0+2
```

The landing derives Android and Windows download URLs from `dobre_release.github_release_base_url` and each asset name. Use `{version}` in an asset name to insert the Flutter semantic version without its build number.

The same `dobre_release` block contains the Web app URL, changelog URL, maintenance state, and reserved Linux/macOS asset names. Future release-data providers can use the existing landing configuration boundary without changing UI components.

## Build

Install Flutter and run:

```bash
flutter pub get
flutter build apk
flutter build windows
flutter build web
```

Build the landing independently:

```bash
cd landing
npm install
npm run build
```

For Cloudflare Pages, use `npm run build` as the build command and `landing/dist` as the output directory when the repository root is the project root.

## Release Workflow

1. Change `version` in `pubspec.yaml`.
2. Run the Flutter build commands above.
3. Upload the generated APK and Windows installer to the GitHub Release using the asset names configured in `dobre_release`.
4. Run `npm run build` in `landing/` and deploy it to Cloudflare Pages.
5. Commit and push the release.

## Branding

Replace assets in `landing/public/branding/` without changing application or landing code:

- `logo.svg` and `logo-dark.svg`
- `favicon.svg`
- `icon.png` and `icon.ico`
- `og-image.svg` and `og-image-en.svg`

After replacing `icon.png`, generate Flutter platform icons with:

```bash
dart run flutter_launcher_icons
```

The command updates Android, Windows, and Flutter Web icons. It does not modify the Inno Setup configuration.

## OpenAI Tools Used

This project was developed with extensive assistance from OpenAI tools during OpenAI Build Week.

### Codex
Codex was used throughout development to:
- Refactor Flutter and React code.
- Improve project architecture and code organization.
- Simplify repetitive development tasks.
- Help integrate Cloudflare Pages and Cloudflare Workers.
- Improve deployment and release workflows.
- Refine configuration management.

### GPT-5.6
GPT-5.6 was used to:
- Brainstorm features and UX improvements.
- Review technical decisions.
- Improve English copy for the landing page.
- Help prepare the project documentation.
- Assist in preparing the Devpost submission and demo materials.

The final implementation, architecture, testing, and project decisions were completed and reviewed by the project author.

## Disclaimer

DoBre is an independent project and is not affiliated with, associated with, or endorsed by Mercado Libre. It uses public information and user-selected settings to produce estimates. Mercado Libre is a registered trademark of its respective owner. Always verify the current official conditions before listing.

## License

No license has been published for this repository. All rights are reserved unless a future license states otherwise.
