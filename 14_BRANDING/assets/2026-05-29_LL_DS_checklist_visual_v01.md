# Checklist Visual Operacional — BRUZZONE IA

**v01 · 2026-05-29.** Validación de consistencia visual tras la consolidación del sistema de diseño. Verificar en cada módulo.

## Branding e identidad
- [x] **Favicon visible** en pestaña (favicon.ico) y `apple-touch-icon` en móvil — en las 8 páginas.
- [x] **Lockup correcto:** logo horizontal en fondos claros; logo fondo-oscuro (blanco) en cabeceras verdes.
- [x] **Logo integrado** en landing, demo, Centro de Demo, dashboard, login, registro, monitoreo y QR.
- [x] **Colores coherentes:** misma paleta olivo/dorado/crema en todos los módulos.
- [x] **CSS maestro** (`bruzzone-ds.css`) enlazado en las 8 páginas; variables oficiales disponibles.

## Componentes
- [x] **KPI cards** con valor serif verde + etiqueta xs.
- [x] **Badges DEMO/LIVE/CACHÉ** con color y punto (●).
- [x] **Botones** dorado (comercial) / verde (sistema) / fantasma (secundario).
- [x] **Semáforo de estados** idéntico en mapa, leyenda, popup, ficha QR y formulario.
- [x] **Popup Leaflet** legible (≤5 campos), código verde + pill de estado.

## Estados del árbol (regla visual)
- [x] Sano = verde ✓ · Vigilar = amarillo 👁 · Intervención = naranja ⚠ · Crítico = rojo ✖.
- [x] Podado = índigo ✂ · Recuperándose = teal ↑ · Pendiente = gris ◷.
- [x] Quintral resaltable con filtro "solo quintral"; severidad 0–5 mapeada a estado.

## DEMO vs LIVE
- [x] Badge de modo siempre visible en el dashboard.
- [x] DEMO = ámbar "datos locales"; LIVE = verde; CACHÉ = azul.
- [x] Fallback automático con aviso; nunca pantalla en blanco.

## Responsive (verificación recomendada en dispositivo)
- [ ] **Móvil terreno:** dashboard navegable, controles grandes, lockup legible (~26px).
- [ ] **Tablet:** panel/filtros se reordenan sin solape.
- [ ] **Escritorio:** mapa + panel lateral + KPIs en fila.
- [ ] **Popup Leaflet móvil:** ancho contenido, texto legible.
- [ ] **QR móvil:** ficha a una columna, header con lockup.
- [ ] **Formulario monitoreo:** campos grandes, cámara nativa.

## Uniformidad entre módulos
- [x] Headers verdes coherentes (lockup blanco + subtítulo).
- [x] Tipografía: titulares serif, cuerpo sans, en todos los módulos.
- [x] Iconografía y espaciado consistentes.

**Leyenda:** [x] verificado estáticamente (estructura, enlaces, assets) · [ ] pendiente de verificación visual en navegador/dispositivo real.
