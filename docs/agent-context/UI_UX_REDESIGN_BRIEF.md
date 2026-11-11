# UI/UX Redesign Brief — DoBre (`landing` + `app`)

## 1. Propósito y Funcionalidad Real
- **Qué es DoBre**: Calculadora inversa y directa de comisiones, cuotas, impuestos y costos de envío para vendedores de Mercado Libre Argentina.
- **Superficies**:
  - `landing/` (`dobre.nanilabs.lat`): Landing interactiva con simulador en vivo de cálculo inverso ("¿Cuánto querés recibir limpio?" -> Precio exacto a publicar en Clásica vs. Premium).
  - `app/` (`dobre-app.nanilabs.lat`, Android y Windows en Flutter): Aplicación calculadora completa con búsqueda binaria de precio objetivo, desglose de cargo por venta, costo fijo, financiación en cuotas, envío e impuestos.

## 2. Objetivos de Diseño e Interactividad
1. **Modo Oscuro y Claro trabajados en `landing/` y `app/`**:
   - Modo oscuro financiero de alta legibilidad (`#0c0f12`, superficie `#14191f`, verde ganancia `#2dd4bf`/`#34d399`, ámbar cargo ML `#f59e0b`) y modo claro contable cálido (`#f6f5f0`, tinta `#121619`).
   - En `landing/index.html`: script anti-FOUC (`localStorage.getItem('dobre-theme')`), conmutador de tema accesible en el header, barra proporcional animada del desglose (Neto vs. Comisión ML vs. Financiación/Costo fijo) y transiciones numéricas suaves cuando cambian el monto neto o el tipo de publicación.
   - En `app/` (Flutter): conmutador de tema claro/oscuro accesible en la cabecera de la calculadora, jerarquía tipográfica tabular (`FontFeature.tabularFigures()`) para lectura instantánea de importes, barra visual comparativa animada (`TweenAnimationBuilder` / `AnimatedContainer`) y transiciones `AnimatedSwitcher` al alternar modo inverso/directo o cambiar parámetros.
2. **Reducción de Texto**:
   - Eliminar textos promocionales largos; ir directo al cálculo, comparativa Clásica vs. Premium y acceso inmediato a la app web (`https://dobre-app.nanilabs.lat`) y repositorio.
3. **Regla UTF-8 y Verificación**:
   - Escribir siempre en **UTF-8 sin BOM**.
   - Ejecutar `flutter analyze` y `flutter test` en `app/` sin errores.
