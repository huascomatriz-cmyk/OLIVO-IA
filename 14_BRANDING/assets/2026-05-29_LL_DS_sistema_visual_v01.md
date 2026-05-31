# Sistema Visual Operacional — BRUZZONE IA

**v01 · 2026-05-29.** Identidad visual oficial de todo el ecosistema (landing, Centro de Demo, dashboard, QR, login, monitoreo). Implementación viva en `bruzzone-ds.css`.

Inspiración: **mediterráneo moderno · premium agrícola · territorial · GIS · dashboard SaaS · olivar tecnológico.**

---

## 1. Paleta oficial

| Rol | Token | HEX |
|---|---|---|
| Verde olivo (principal) | `--bz-green` | `#2E5E3A` |
| Verde profundo | `--bz-green-d` | `#234A2D` |
| Verde hoja (acento) | `--bz-leaf` | `#9CC962` |
| Dorado (acento/CTA) | `--bz-gold` | `#B7873B` |
| Dorado claro (sobre oscuro) | `--bz-gold-l` | `#EBC987` |
| Crema mediterránea | `--bz-cream` | `#F7F4EC` |
| Fondo app | `--bz-bg` | `#F5F8F5` |
| Tinta / texto | `--bz-ink` | `#1F2A22` |
| Gris secundario | `--bz-grey` | `#6B756E` |

**Semáforo operacional:** sano `#2E7D32` · vigilar `#F9A825` · recuperándose `#26A69A` · podado `#5C6BC0` · intervención `#EF6C00` · crítico `#C62828` · pendiente `#9E9E9E`.
**Zonas de manejo (NDVI):** alto `#2E7D32` · medio `#F9A825` · bajo `#C62828`.
**Modo de datos:** LIVE `#1F7A3D` · DEMO `#9A6B16` · CACHÉ `#3A6EA5`.

## 2. Tipografía oficial

- **Titulares:** serif (`Georgia, "Times New Roman", serif`) — carácter premium/mediterráneo.
- **Cuerpo / UI:** sans del sistema. **Datos/código:** monoespaciada.
- Escala: display 42 · h1 30 · h2 22 · h3 16 · cuerpo 15 · sm 13 · xs 11.5. Interlineado 1.55.
- Titulares en verde olivo; acentos y CTA en dorado.

## 3. Espaciado, sombras, bordes

- **Espaciado** en escala de 4px (`--bz-s1..s8`: 4,8,12,16,24,32,48,64).
- **Radios:** tarjetas 14px, controles 9px, pills 22px.
- **Bordes:** `1px solid #E2E8E2`.
- **Sombras:** suave `0 1px 6px rgba(46,94,58,.12)`; elevada `0 8px 26px rgba(46,94,58,.13)`.

## 4. Componentes

- **Botones:** `.bz-btn` + `--gold` (acción comercial), `--green` (acción de sistema), `--ghost` (secundaria), `--outline` (sobre oscuro).
- **Tarjetas:** `.bz-card` (+`--hover` con elevación).
- **KPI:** `.bz-kpi` con valor serif verde + etiqueta xs gris.
- **Pills/dots de estado:** `.bz-pill .is-{estado}` y `.bz-dot .is-{estado}`.
- **Badges DEMO/LIVE:** `.bz-modo--{live|demo|cache}`.

## 5. Iconografía

- Set temático consistente por servicio y estado: 🛰️ monitoreo · 🫒 olivicultura · 📊 dashboard · 📱 QR · ⚠️ quintral/intervención · 🔗 trazabilidad · 🧠 IA · 🧪 laboratorio · ✓ sano · ✖ crítico · 👁 vigilar · ✂ podado · ↑ recuperándose · ◷ pendiente.
- Estilo simple y plano; no mezclar estilos de íconos.

## 6. Estilo de mapas (Leaflet)

- Base satelital (Esri) por defecto; alternativa OSM.
- **Perímetro predial:** línea dorada punteada (`#FFD24A`, dash 6 4, weight 3).
- **Olivos:** `circleMarker` radio 5, relleno por estado/zona, borde blanco 1px, opacidad .95.
- **Leyenda** blanca flotante (`.bz-legend`), abajo-derecha, con conteos y toggle por estado.

## 7. Estilo KPI y popup

- **KPI strip:** tarjetas `.bz-kpi` en fila sobre fondo claro.
- **Popup Leaflet (`.bz-pp`):** código en verde, pill de estado, tabla clave/valor xs. Máx. 5 campos para legibilidad.

## 8. Cómo se ve cada estado (regla visual)

- **Árbol sano:** punto verde `#2E7D32`, ícono ✓. Sin alerta.
- **Vigilar:** amarillo `#F9A825`, 👁 — señal temprana.
- **Intervención (quintral):** naranja `#EF6C00`, ⚠ — acción requerida; en filtro "solo quintral" resaltan.
- **Crítico:** rojo `#C62828`, ✖ — urgencia, prioridad máxima en panel de alertas.
- **Podado / recuperándose:** índigo / teal — estados de manejo, fríos para distinguirlos de las alertas.
- **Severidad (0–5):** se mapea a estado (0 sano → 5 crítico); el filtro "severidad ≥" usa esa escala.
- **Quintral:** se marca con el estado (intervención/crítico) + bandera de quintral; visualmente, cálidos concentrados = foco.

## 9. DEMO vs LIVE (visual)

- **Badge de modo** siempre visible en el header del dashboard: `● LIVE` (verde), `● CACHÉ` (azul), `● DEMO (local)` (ámbar).
- **DEMO:** datos embebidos; mensaje "modo DEMO (datos locales)" en flash; el usuario sabe que no son datos reales.
- **LIVE:** datos desde Supabase; tras registrar, refresco visible.
- **Fallback:** si LIVE falla, transición automática a CACHÉ/DEMO con aviso; nunca pantalla en blanco.

## 10. Responsive

- **Escritorio:** mapa + panel lateral (360px) + KPIs en fila.
- **Tablet:** panel se reduce / se apila; filtros en dos filas.
- **Móvil:** una columna; panel pasa a bloque inferior; tipografía mayor; controles grandes (operador en terreno, con una mano). Utilidades `.bz-hide-mobile` / `.bz-hide-tablet` y grids que colapsan a 1 columna.

## 11. Branding integrado

- **Favicon / apple-touch-icon** en todas las páginas (assets en `frontend/assets/` y `web/assets/`).
- **Lockup horizontal** en cabeceras claras; **fondo oscuro** sobre verde; **isotipo** para favicon/avatars; **monocromático** para una tinta.
- Tokens y componentes centralizados en `bruzzone-ds.css` (copiado a `14_BRANDING/assets`, `16_DESARROLLO/frontend/assets`, `16_DESARROLLO/web/assets`).

Manual de marca: `../04_manual_marca/2026-05-29_LL_BRAND_manual_marca_v01.md`. Kit de logo: `../logo/`.
