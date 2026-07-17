# DoBre Cloudflare Worker

Worker listo para exponer la configuracion remota de DoBre en Cloudflare Workers.

## Endpoint principal

- `GET /config`

Ese endpoint devuelve un JSON **100% compatible** con el modelo `AppConfig` que ya existe en Flutter:

- `version`
- `lastUpdate`
- `message`
- `maintenanceMode`
- `minimumSupportedVersion`
- `tariffs`
- `percentages`
- `shipping`
- `installments`
- `categories`
- `advancedMode`
- `input`

## Archivos importantes

- `src/app-config.ts`
  Tipos TypeScript equivalentes al modelo de Flutter.

- `src/config.ts`
  Configuracion real servida por el Worker.

- `src/index.ts`
  Router HTTP del Worker.

- `wrangler.toml`
  Configuracion de despliegue.

## Despliegue

```bash
cd cloudflare-worker
npm install
npx wrangler login
npm run deploy
```

## URL para Flutter

Una vez desplegado, usa la URL real del Worker:

```bash
flutter run --dart-define=DOBRE_REMOTE_CONFIG_URL=https://<tu-worker>.<tu-subdominio>.workers.dev/config
```

## Produccion

Antes de publicar:

1. Cambia el `name` del worker en `wrangler.toml`.
2. Revisa los valores de `src/config.ts`.
3. Incrementa `version` y `lastUpdate` cada vez que cambies configuracion.
4. Si subis una config incompatible, la app Flutter puede parsear mal o ignorar campos.
