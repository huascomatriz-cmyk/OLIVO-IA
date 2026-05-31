# Experiencia Comercial Final — BRUZZONE IA

**v01 · 2026-05-29.** Recorrido visual completo del MVP, con la identidad oficial aplicada de punta a punta. Objetivo: que BRUZZONE IA se vea y se sienta como una **plataforma agrícola territorial profesional**.

## Recorrido de 10 momentos

| # | Momento | Qué se ve (con branding) | Archivo |
|---|---|---|---|
| 1 | **Landing** | Hero verde-dorado, logo, KPIs, servicios, favicon en pestaña | `web/index.html` |
| 2 | **Centro de Demo** | Portada con tarjetas de acceso, estado del MVP, favicon | `frontend/index.html` |
| 3 | **Dashboard** | Header verde con marca, badge DEMO/LIVE, mapa de 504 olivos, leyenda blanca | `09_.../...DASH_leaflet_LIVE_v03.html` |
| 4 | **Popup árbol** | Ficha con código verde, pill de estado, NDVI, rendimiento, QR | (en dashboard) |
| 5 | **QR** | Ficha móvil premium, header verde, estado, trazabilidad | `frontend/src/components/qr/...` |
| 6 | **Monitoreo** | Formulario móvil, estados oficiales, evidencia | `frontend/monitoring/...` |
| 7 | **Historial** | Línea de eventos con pills de estado | (en dashboard/ficha) |
| 8 | **LIVE** | Badge `● LIVE`, datos reales desde Supabase | (dashboard) |
| 9 | **Branding** | Logo, favicon, paleta y tipografía coherentes en todo | `14_BRANDING/` |
| 10 | **Cierre comercial** | CTA a agendar demo, postventa, roadmap | `web/index.html#contacto` |

## Continuidad visual

- **Misma paleta** (verde olivo / dorado / crema) y **misma tipografía** (serif en titulares) en web, demo, dashboard y QR.
- **Favicon e isotipo** presentes en todas las pestañas y accesos directos (apple-touch-icon en móvil).
- **Semáforo operacional** idéntico en mapa, leyenda, popups, ficha QR y formulario.
- **DEMO vs LIVE** comunicado siempre con el badge de color, sin ambigüedad.

## Guion de reunión (≤ 5 min)

1. Abrir **landing** → "esto es BRUZZONE IA". (20 s)
2. **Centro de Demo** → "todo el sistema en un lugar". (20 s)
3. **Dashboard** → su campo, 504 olivos por estado. (60 s)
4. Clic en un árbol → **popup**; mostrar **QR**. (40 s)
5. **Monitoreo** en vivo → el árbol cambia de color. (40 s)
6. **Historial** y **LIVE** → trazabilidad real. (40 s)
7. Cierre: **postventa + escalabilidad + agendar**. (40 s)

## Reglas de presentación

- Empezar siempre en **DEMO** (no depende de internet). Pasar a **LIVE** solo si la conexión está confirmada.
- Si algo falla → volver a DEMO (placeholders en `window.__ENV__`); la marca y el recorrido siguen intactos.
- Mantener el **mapa como protagonista**; texto mínimo; dejar que el sistema hable.

Sistema visual completo en `2026-05-29_LL_DS_sistema_visual_v01.md`. Implementación en `bruzzone-ds.css`.
