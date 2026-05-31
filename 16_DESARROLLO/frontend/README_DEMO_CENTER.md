# Centro de Demo — BRUZZONE IA (Olivar Los Loros)

Punto de entrada único para presentar el MVP territorial sin tener que explicar carpetas ni rutas.

## ¿Qué es?

`index.html` es un portal visual que reúne en una sola pantalla todas las piezas del MVP: dashboard, QR, monitoreo, login, estado del sistema y documentación. Pensado para abrir en una reunión y demostrar el ecosistema en minutos.

> 🌐 **Web pública (comercial):** existe además un sitio empresarial en `../web/` — landing oficial (`../web/index.html`) y demo comercial (`../web/demo/index.html`) — que enlaza a este Centro de Demo. Este centro es la cara **técnica/interna**; la web es la cara **comercial**.

> 🎨 **Sistema de diseño consolidado:** lockup oficial y `bruzzone-ds.css` integrados en todas las páginas (favicon, variables y componentes compartidos). Guías en `14_BRANDING/assets/`; checklist visual `2026-05-29_LL_DS_checklist_visual_v01.md`; kit de logo en `14_BRANDING/logo/`.

## Cómo abrirlo

Doble clic en `16_DESARROLLO/frontend/index.html`. Se abre en cualquier navegador. No requiere instalar nada.

- El **dashboard** funciona de inmediato en modo **DEMO** (datos embebidos), con o sin internet.
- Las piezas marcadas **LIVE** (QR, monitoreo, login) requieren un proyecto Supabase configurado para mostrar datos reales.

## Qué archivos conecta

| Tarjeta | Archivo | Modo |
|---|---|---|
| Dashboard territorial | `../../09_DASHBOARDS_Y_PLATAFORMA/03_Mapas_Interactivos/2026-05-29_LL_DASH_leaflet_LIVE_v03.html` | DEMO + LIVE |
| QR de ejemplo | `src/components/qr/2026-05-29_LL_QR_live_ficha_publica_v01.html?codigo=LL-OLI-0001` | LIVE |
| Registro de monitoreo | `monitoring/2026-05-29_LL_MON_registro_monitoreo_v01.html?codigo=LL-OLI-0001` | LIVE |
| Login operador | `pages/2026-05-29_LL_AUTH_login_v01.html` | LIVE |
| Registro operador | `pages/2026-05-29_LL_AUTH_registro_usuario_v01.html` | LIVE |
| Documentación | `README.md` y guías `..._DEV_*.md` | DOCS |

> Las rutas relativas asumen que `index.html` está en `16_DESARROLLO/frontend/`. Hay un comentario dentro del HTML indicando cómo ajustar los prefijos si se mueve.

## Modo DEMO vs LIVE

- **DEMO:** sin Supabase, datos embebidos. El dashboard abre y se navega completo. Ideal para presentar.
- **LIVE:** con Supabase. El mapa carga vía RPC `arbol_geojson` y los monitoreos se registran vía RPC `registrar_monitoreo`.
- **Regla inviolable:** ningún componente modifica directamente la tabla `arbol`. Todo cambio de estado pasa por `registrar_monitoreo`.

## Qué falta para Supabase Live

1. Crear el proyecto Supabase y activar PostGIS.
2. Ejecutar en orden los SQL de `../03_supabase/`: `01_schema` → `02_seed` → `03_monitoreo_rpc_rls` → `04_pruebas_validacion`.
3. Completar las credenciales (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) en `window.__ENV__` del dashboard y de las páginas QR/monitoreo/login (o en `.env`).
4. Verificar con `2026-05-29_LL_DEV_checklist_mvp_funcional_v01.md`.

Mientras no se complete, las tarjetas LIVE muestran "sin conexión" — esperado en modo DEMO.

## Cómo se usará en presentación comercial (3 minutos)

1. **Abrir el centro de demo** (`index.html`): "Este es el sistema de Los Loros."
2. **Entrar al dashboard:** el predio completo, 504 olivos coloreados por estado.
3. **Mostrar el mapa:** zonas de manejo, KPIs, foco de quintral filtrando "solo quintral".
4. **Abrir el popup de un árbol:** NDVI, rendimiento histórico, estado, su QR.
5. **Abrir el QR de ejemplo:** "Su operador escanea esto en terreno y ve la ficha al instante."
6. **Registrar un monitoreo:** el árbol cambia de estado y el mapa se actualiza.
7. **Cerrar con trazabilidad y postventa:** historial por árbol y reportes periódicos.

## Próximos pasos

- **Activar Supabase LIVE** con la guía paso a paso:
  - `../03_supabase/2026-05-29_LL_DEV_guia_supabase_live_v01.md` — guía completa.
  - `../03_supabase/2026-05-29_LL_DEV_checklist_supabase_live_v01.md` — checklist.
  - `2026-05-29_LL_DEV_configuracion_env_v01.md` — conectar credenciales.
  - `2026-05-29_LL_DEV_pruebas_centro_demo_live_v01.md` — pruebas tras activar LIVE.
