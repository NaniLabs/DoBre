# DoBre

> **Calculadora y motor de cálculo inverso de precios para vendedores de Mercado Libre.**

DoBre resuelve una necesidad clave para los vendedores: **partir del dinero neto real que desean recibir en mano** por una venta (ej. *"$35.000 netos"*) y calcular automáticamente **qué precio de publicación deben fijar** para cubrir comisiones, financiamiento en cuotas, cargos fijos y costos de envío oficiales de Mercado Libre.

---

## 📑 Tabla de Contenidos
- [1. ¿Qué es DoBre y por qué es diferente?](#1-qué-es-dobre-y-por-qué-es-diferente)
- [2. El Motor de Cálculo Inverso](#2-el-motor-de-cálculo-inverso)
- [3. Arquitectura del Proyecto](#3-arquitectura-del-proyecto)
- [4. Configuración Remota y Resiliencia](#4-configuración-remota-y-resiliencia)
- [5. Plataformas Soportadas](#5-plataformas-soportadas)
- [6. Landing Page](#6-landing-page)
- [7. Publicación y Distribución Automatizada (Release v1.0.0+)](#7-publicación-y-distribución-automatizada-release-v100)
- [8. Comandos Manuales de Referencia](#8-comandos-manuales-de-referencia)
- [9. Pruebas y Calidad de Código](#9-pruebas-y-calidad-de-código)
- [10. Visión a Futuro y Potencial de Integración](#10-visión-a-futuro-y-potencial-de-integración)
- [11. Herramientas de IA y Desarrollo](#11-herramientas-de-ia-y-desarrollo)
- [12. Aviso Legal / Disclaimer](#12-aviso-legal--disclaimer)

---

## 1. ¿Qué es DoBre y por qué es diferente?

En las calculadoras tradicionales de costos para e-commerce, el flujo es directo:

$$\text{Precio de Publicación} \longrightarrow \text{Deducciones (Comisiones, Envíos, Cuotas, Impuestos)} \longrightarrow \text{Dinero Neto}$$

Sin embargo, el vendedor piensa en sentido inverso:
*"Sé cuánto me costó el producto y cuánto margen quiero ganar en el bolsillo. ¿A cuánto lo tengo que publicar para no perder plata?"*

**DoBre invierte el cálculo:**

$$\text{Dinero Neto Objetivo} \longrightarrow \text{Motor Inverso de Optimización} \longrightarrow \text{Precio de Publicación Necesario}$$

Además, DoBre ofrece un **desglose transparente** de cada deducción estimada (comisión por categoría, costo de financiación, costo de envío según tabla de peso y cargo fijo).

---

## 2. El Motor de Cálculo Inverso

El motor (`PricingCalculator`) implementa:
1. **Deducción de comisiones por categoría y tipo de publicación**:
   - Soporte para publicaciones *Clásica* y *Premium*.
   - Tasas porcentuales específicas por categoría (ej. Electrónica, Computación, Indumentaria, Alimentos, etc.).
2. **Opciones de financiación / Cuotas**:
   - Sin cuotas, 3 cuotas, 6 cuotas, 9 cuotas, 12 cuotas con interés o sin interés (cuotas fijas para el comprador con costo asumido por el vendedor).
3. **Esquema de envíos oficiales (Mercado Envíos)**:
   - Umbral de envío gratis oficial (ej. \$33.000 en Argentina).
   - Tabla de costos de envío segmentada por peso (de 0,3 kg hasta +180 kg) y por rango de precio de publicación.
   - Sincronización automática: si el precio calculado supera el umbral, el envío obligatorio se incorpora automáticamente en una sola pasada.
4. **Cargos fijos y costo unitario**:
   - Escalas de costo fijo para publicaciones de bajo precio.
5. **Algoritmo de Búsqueda Binaria de Alta Precisión**:
   - Expansión dinámica de cotas para garantizar convergencia exacta (error menor a \$0.05) incluso en montos bajos donde los costos fijos superan el neto objetivo.

---

## 3. Arquitectura del Proyecto

El repositorio está estructurado en módulos desacoplados:

```text
DoBre/
├── dobre/
│   ├── lib/
│   │   ├── models/            # Modelos de datos (AppConfig, CalculationOptions, CalculationBreakdown, etc.)
│   │   ├── providers/         # Estado de la aplicación (AppConfigProvider, AdvancedModeProvider, ThemeProvider)
│   │   ├── repositories/      # Repositorios con caché local y resolución de configuración
│   │   ├── screens/           # Pantallas (MyHomePage, AdvancedModeScreen, CreditsScreen)
│   │   ├── services/          # Motor de cálculo (PricingCalculator) y red (RemoteConfigService)
│   │   ├── theme/             # Sistema de diseño, temas claro/oscuro
│   │   └── widgets/           # Widgets reutilizables (Resultado, PrecioTextField, EnvioSwitch, etc.)
│   ├── assets/config/         # default_config.json (Fuente de verdad y fallback empaquetado)
│   ├── test/                  # Suite completa de tests unitarios y de widgets
│   ├── cloudflare-worker/     # API en Cloudflare Workers para actualización remota de tarifas
│   ├── landing/               # Landing page web (React + Vite + TypeScript + Tailwind CSS)
│   ├── android/               # Proyecto nativo Android
│   ├── windows/               # Proyecto nativo Windows Desktop
│   ├── web/                   # Configuración web Flutter
│   └── pubspec.yaml           # Metadatos, dependencias y versión de release centralizada
```

---

## 4. Configuración Remota y Resiliencia

DoBre no requiere republicar la aplicación en tiendas para actualizar comisiones o tarifas de Mercado Libre.

### Flujo de Configuración en 3 Niveles:
1. **Endpoint Remoto HTTPS (Cloudflare Worker)**: Intenta descargar el JSON actualizado con un timeout de 7 segundos.
2. **Caché Local (`SharedPreferences`)**: Si no hay conexión o el servidor no responde, utiliza la última configuración válida descargada.
3. **Configuración Empaquetada (`assets/config/default_config.json`)**: Si la app se abre por primera vez sin conexión, utiliza el JSON compilado en el binario.

El Worker en `cloudflare-worker/` reexporta directamente la estructura de `default_config.json`, manteniendo compatibilidad total garantizada por TypeScript.

---

## 5. Plataformas Soportadas

- **Windows**: Aplicación de escritorio moderna, soporte de teclado (Enter para calcular, shortcuts de copiado), layout responsivo de dos columnas.
- **Android**: Aplicación móvil fluida, optimizada para uso con una sola mano, teclado numérico directo y persistencia de preferencias.
- **Web**: Versión web accesible desde cualquier navegador moderno para demostraciones rápidas.

---

## 6. Landing Page

Ubicada en `dobre/landing/`, construida con **React, Vite, TypeScript y Tailwind CSS**:
- Explicación concisa y honesta del valor de DoBre.
- Comparativa visual entre la versión Web y la aplicación instalada.
- Soporte multilingüe (**Español** e **Inglés**).
- Modos claro y oscuro.
- Enlaces de descarga directa para Android (`.apk`) y Windows (`.exe`) sincronizados desde `pubspec.yaml`.

---

## 7. Publicación y Distribución Automatizada (Release v1.0.0+)

DoBre cuenta con un pipeline completamente automatizado para generar instaladores, paquetes de distribución, verificación de calidad y despliegue.

---

### 🚀 ¿Cómo publicar una nueva versión de DoBre? (Paso a Paso)

```text
1. Editar pubspec.yaml (cambiar versión a 1.0.0)
         ↓
2. Ejecutar .\scripts\build-release.ps1
         ↓
3. Revisar artefactos en dist/releases/
         ↓
4. git add . && git commit -m "Release v1.0.0"
         ↓
5. git tag v1.0.0 && git push origin main --tags
         ↓
6. GitHub Actions compila y publica la release automáticamente
7. Cloudflare Pages actualiza la Landing automáticamente
```

---

### 🛠️ Scripts de Automatización Disponibles

#### 1. Generación de Release Completa (Local)
Ejecuta análisis estático, suite de tests, typecheck del Worker, build de la Landing, genera el APK de Android, la versión portable de Windows en `.zip`, el instalador ejecutable `.exe` con Inno Setup y las sumas de verificación SHA256:

```powershell
# Compilar todo en un solo comando
.\scripts\build-release.ps1

# O compilar solo plataformas específicas
.\scripts\build-release.ps1 -Platforms @("android", "windows", "installer")
```

**Artefactos generados en `dobre/dist/releases/`:**
- `DoBre-v1.0.0.apk` / `DoBre-Android-v1.0.0.apk` (Instalador Android)
- `DoBre-Windows-v1.0.0.zip` (Versión portable de Windows)
- `DoBreSetup-v1.0.0.exe` (Instalador ejecutable de Windows generado con Inno Setup)
- `SHA256SUMS.txt` (Sumas de verificación para integridad de descarga)

#### 2. Despliegue de Configuración Remota (Cloudflare Worker)
Valida el esquema del JSON `default_config.json`, realiza typecheck en TypeScript y publica al Worker:

```powershell
.\scripts\deploy-worker.ps1
```

---

### 🤖 Flujo CI/CD en GitHub Actions

El repositorio incluye 3 workflows automatizados en `.github/workflows/`:

1. **`ci.yml`**: Se dispara en cada `push` o `pull_request` a `main`. Ejecuta `flutter analyze`, `flutter test`, comprobación de TypeScript en el Worker y build de la Landing.
2. **`release.yml`**: Se dispara automáticamente al crear y pushear un tag de versión (ej. `v1.0.0`) o mediante ejecución manual (`workflow_dispatch`). Compila el APK de Android, el release de Windows, el instalador con Inno Setup y publica el GitHub Release adjuntando todos los binarios y sus checksums.
3. **`deploy-worker.yml`**: Se dispara al modificar archivos del Worker o de configuración remota, desplegando a Cloudflare Workers mediante secrets configurados (`CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID`).

---

### 📊 Matriz de Automatización

| Componente | Estado de Automatización | Cómo se actualiza |
| :--- | :--- | :--- |
| **Android APK** | 🟢 **100% Automático** | `.\scripts\build-release.ps1` o Tag de GitHub Release |
| **Windows Portable (.zip)** | 🟢 **100% Automático** | `.\scripts\build-release.ps1` o Tag de GitHub Release |
| **Windows Setup (.exe)** | 🟢 **100% Automático** | Inno Setup vía `.\scripts\build-release.ps1` o GitHub Actions |
| **Landing Page** | 🟢 **100% Automático** | Conectada a Cloudflare Pages (se despliega en cada push a `main`) |
| **Cloudflare Worker** | 🟢 **Automatizado** | `.\scripts\deploy-worker.ps1` o GitHub Actions |
| **Web App Flutter** | 🟡 **Manual asistido** | `flutter build web --release` |

---

## 8. Comandos Manuales de Referencia

### Aplicación Flutter
```bash
flutter pub get
flutter test
flutter analyze
flutter build apk --release
flutter build windows --release
flutter build web --release
```

### Cloudflare Worker
```bash
cd cloudflare-worker
npm install
npm run check
npx wrangler deploy
```

### Landing Page
```bash
cd landing
npm install
npm run build
```


---

## 9. Pruebas y Calidad de Código

El proyecto cuenta con una suite completa de pruebas automatizadas y análisis estático estricto:

```bash
cd dobre

# Ejecutar análisis estático (0 issues)
flutter analyze

# Ejecutar suite de pruebas unitarias y de widgets
flutter test
```

### Cobertura de Tests:
- `test/pricing_calculator_test.dart`: Pruebas de reversibilidad matemática ($|Received - Target| < 0.05$), casos con costos fijos altos y montos bajos, cuotas, envío gratis obligatorio y desglose.
- `test/app_config_test.dart`: Parsing del JSON, serialización, resolución de tablas de peso, cargos fijos y categorías.
- `test/currency_utils_test.dart`: Formateo de moneda según convención argentina y parsing tolerante de múltiples formatos.
- `test/remote_config_test.dart`: Mocks de red HTTP, control de errores 500, timeouts y fallback a caché.
- `test/widget_test.dart`: Verificación de renderizado de la UI, ingreso de datos, interacción y presentación de resultados.

---

## 10. Visión a Futuro y Potencial de Integración

DoBre está diseñado modularmente para permitir evoluciones futuras:
- **Motor desacoplado como módulo / microservicio**: El motor `PricingCalculator` puede ser empaquetado como biblioteca Dart/TS o consumido como API por plataformas de terceros (como MercadoData).
- **Multipaís / Multimoneda**: La arquitectura de `AppConfig` permite agregar nuevos esquemas de países (Mercado Libre Brasil, México, Chile, Colombia, etc.) manteniendo el mismo motor central.
- **Modo Avanzado Extensible**: Soporte para simular múltiples condiciones de publicación, peso volumétrico y cargos impositivos adicionales.

---

## 11. Herramientas de IA y Desarrollo

Este proyecto contó con asistencia de herramientas avanzadas durante su concepción y desarrollo:
- **Codex & Asistentes de Código**: Refactorización de código Dart/Flutter y React, organización de arquitectura e integración de pipelines de CI/CD.
- **Modelos de Razonamiento (GPT-5.6 / DeepMind)**: Revisión de decisiones técnicas, auditoría de casos límite matemáticos, optimización de copy multilingüe y preparación de documentación.

La arquitectura final, implementación, auditoría matemática, pruebas unitarias y empaquetado fueron completados y validados por el autor del proyecto.

---

## 12. Aviso Legal / Disclaimer

DoBre es un proyecto independiente y no está afiliado, asociado ni respaldado por Mercado Libre. Utiliza información pública y las opciones configuradas por cada usuario para generar estimaciones. Mercado Libre® es una marca registrada de su respectivo titular. Verifique siempre las condiciones y tarifas oficiales vigentes antes de publicar.


