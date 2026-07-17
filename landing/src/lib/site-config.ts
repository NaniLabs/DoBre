export const siteConfig = {
  name: 'DoBre',
  description:
    'Indicá cuánto querés recibir y DoBre calcula el precio sugerido para tu publicación de Mercado Libre.',
  links: {
    download: '#descargar',
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
  version: 'Próximamente',
  changelogUrl: null,
  androidDownloadUrl: null,
  windowsDownloadUrl: null,
  maintenanceMode: false,
}

export function getPrimaryDownloadUrl(): string {
  return releaseConfig.androidDownloadUrl ?? siteConfig.links.download
}
