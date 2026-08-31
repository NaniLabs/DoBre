export const siteConfig = {
  name: 'DoBre',
  description:
    'Indicá cuánto querés recibir y DoBre calcula el precio sugerido para tu publicación de Mercado Libre.',
  links: {
    downloads: '#descargas',
    howItWorks: '#como-funciona',
    webExperience: '#version-web',
    support: '#apoyo',
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
  linuxDownloadUrl: string | null
  macosDownloadUrl: string | null
  webAppUrl: string | null
  maintenanceMode: boolean
  donations: {
    enabled: boolean
    cafe: string
    apoyo: string
    impulso: string
    custom: string
  }
}

export const releaseConfig: ReleaseConfig = __DOBRE_RELEASE_CONFIG__

