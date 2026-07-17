export const siteConfig = {
  name: 'DoBre',
  description:
    'Indicá cuánto querés recibir y DoBre calcula el precio sugerido para tu publicación de Mercado Libre.',
  links: {
    downloads: '#descargas',
    howItWorks: '#como-funciona',
    simulator: '#simulador',
  },
} as const

/**
 * Punto de extensión para datos de lanzamiento que se podrán conectar luego.
 * La UI consume esta forma sin conocer el origen de los datos.
 */
export interface ReleaseConfig {
  version: string
  changelogUrl: string | null
  androidDownloadUrl: string | null
  windowsDownloadUrl: string | null
  maintenanceMode: boolean
}

export const releaseConfig: ReleaseConfig = {
  version: 'v0.3.0',
  changelogUrl: 'https://github.com/NaniLabs/DoBre/releases/tag/DoBre',

  androidDownloadUrl:
    'https://github.com/NaniLabs/DoBre/releases/download/DoBre/DoBre-v0.3.0.apk',

  windowsDownloadUrl:
    'https://github.com/NaniLabs/DoBre/releases/download/DoBre/DoBreSetup-v0.3.0.exe',

  maintenanceMode: false,
}
