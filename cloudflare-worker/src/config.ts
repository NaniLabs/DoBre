import localConfig from '../../assets/config/default_config.json';
import type { AppConfig } from './app-config';

// El Worker reexporta exactamente el mismo JSON que usa Flutter como fallback local.
// De esta forma, assets/config/default_config.json es la unica fuente de verdad.
export const appConfig = localConfig satisfies AppConfig;
