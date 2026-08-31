import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { resolve } from 'node:path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

const workspaceRoot = resolve(fileURLToPath(new URL('..', import.meta.url)))

function readReleaseConfig() {
  const pubspec = readFileSync(resolve(workspaceRoot, 'pubspec.yaml'), 'utf8')
  const version = pubspec.match(/^version:\s*([^\s+]+)/m)?.[1]

  if (version == null) throw new Error('Could not find a Flutter version in pubspec.yaml.')

  const value = (key: string) => {
    const match = pubspec.match(new RegExp(`^  ${key}:\\s*(.+)$`, 'm'))?.[1]?.trim()
    return match == null || match === 'null' ? null : match
  }

  const rawBaseUrl = value('github_release_base_url') ?? 'https://github.com/NaniLabs/DoBre/releases/download/v{version}'
  const releaseBaseUrl = rawBaseUrl.replace(/{version}/g, version)

  const assetUrl = (assetName: string | null) =>
    assetName == null || releaseBaseUrl == null
      ? null
      : `${releaseBaseUrl}/${assetName.replace(/{version}/g, version)}`

  const changelogUrl = (value('changelog_url') ?? 'https://github.com/NaniLabs/DoBre/releases/tag/v{version}')?.replace(/{version}/g, version)

  let donations = {
    enabled: true,
    cafe: 'https://mpago.la/1dBku5K',
    apoyo: 'https://mpago.la/161b7Ax',
    impulso: 'https://mpago.la/185dDQH',
    custom: 'https://link.mercadopago.com.ar/nanilabs',
  }

  try {
    const rawConfig = JSON.parse(readFileSync(resolve(workspaceRoot, 'assets/config/default_config.json'), 'utf8'))
    if (rawConfig.donations?.links) {
      donations = {
        enabled: rawConfig.donations.enabled ?? true,
        cafe: rawConfig.donations.links.cafe ?? donations.cafe,
        apoyo: rawConfig.donations.links.apoyo ?? donations.apoyo,
        impulso: rawConfig.donations.links.impulso ?? donations.impulso,
        custom: rawConfig.donations.links.custom ?? donations.custom,
      }
    }
  } catch (_) {}

  return {
    version,
    androidDownloadUrl: assetUrl(value('android_asset_name') ?? 'DoBre-v{version}.apk'),
    windowsDownloadUrl: assetUrl(value('windows_asset_name') ?? 'DoBreSetup-v{version}.exe'),
    linuxDownloadUrl: assetUrl(value('linux_asset_name')),
    macosDownloadUrl: assetUrl(value('macos_asset_name')),
    webAppUrl: value('web_app_url'),
    changelogUrl,
    maintenanceMode: value('maintenance_mode') === 'true',
    donations,
  }
}

export default defineConfig({
  define: {
    __DOBRE_RELEASE_CONFIG__: JSON.stringify(readReleaseConfig()),
  },
  plugins: [react(), tailwindcss()],
})

