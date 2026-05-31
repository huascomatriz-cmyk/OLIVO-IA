# Frontend territorial vivo — BRUZZONE IA (Olivar Los Loros)

Primer frontend operacional conectado a Supabase, con fallback a datos embebidos. Mantiene el mapa Leaflet, el QR y el monitoreo, listo para expandirse a React/Next.

> 🚪 **Punto de entrada para demos:** abre `index.html` (centro de demo) — enlaza dashboard, QR, monitoreo, login y documentación en una sola pantalla. Ver `README_DEMO_CENTER.md`.

## Estado actual

El dashboard funcional vive como HTML autocontenido (con fallback) y, al configurar Supabase, opera en vivo:

- **Dashboard LIVE:** `../../09_DASHBOARDS_Y_PLATAFORMA/03_Mapas_Interactivos/2026-05-29_LL_DASH_leaflet_LIVE_v03.html`
- **Ficha QR pública:** `src/components/qr/2026-05-29_LL_QR_live_ficha_publica_v01.html`
- **Registro de monitoreo:** `monitoring/2026-05-29_LL_MON_registro_monitoreo_v01.html`
- **Login / Registro operador:** `pages/2026-05-29_LL_AUTH_login_v01.html` · `pages/2026-05-29_LL_AUTH_registro_usuario_v01.html`

## Estructura

```
16_DESARROLLO/frontend/
├── assets/        bruzzone-ds.css · favicon · apple-touch · logos (svg/png)
├── branding/      copia compartida de logos/CSS
├── styles/        estilos/overrides sobre el maestro
├── components/    UI compartida (KPI, pills, paneles)
├── layout/        header (lockup), nav, footer
├── maps/          componentes Leaflet
├── monitoring/    formulario de monitoreo (registrar_monitoreo)
├── qr/            ruta /qr/:codigo (ficha en src/components/qr)
├── auth/          autenticación (login/registro en pages/)
├── pages/         login, registro
├── lib/           supabaseClient.js · api.js
├── services/      dataService.js · cache.js (cache/cola offline)
├── hooks/         useArboles.js · useSesion.js (React)
├── public/        estáticos
└── src/           estructura previa
```

Detalle en `2026-05-29_LL_DEV_estructura_frontend_v01.md`.

## Documentación (esta carpeta)

| Archivo | Contenido |
|---|---|
| `..._corte_a_vivo_README_v01.md` | Plan de corte, configuración Supabase, checklist, rollback |
| `..._contrato_api_v01.md` | Contrato de los 5 endpoints |
| `..._migracion_mapa_v01.md` | Migrar el mapa a `getArboles` (código) |
| `..._qr_live_v01.md` | Ruta `/qr/:codigo` y registro |
| `..._seguridad_rls_v01.md` | RLS, roles, checklist de seguridad |
| `..._fallback_estrategia_v01.md` | Modos DEMO/CACHÉ/LIVE y offline |
| `..._checklist_mvp_funcional_v01.md` | Validación de extremo a extremo |
| `..._configuracion_env_v01.md` | Conectar credenciales Supabase |
| `..._pruebas_centro_demo_live_v01.md` | Pruebas del centro de demo en LIVE |
| `..._estructura_frontend_v01.md` | Estructura modular del frontend |
| `..._roadmap_inmediato_v01.md` | Qué construir/estabilizar/aplazar |
| `.env.example` | Variables de entorno |

SQL en `../03_supabase/` (`01_schema` · `02_seed` · `03_monitoreo_rpc_rls` · `04_pruebas_validacion`).

**Activar LIVE:** guía paso a paso en `../03_supabase/2026-05-29_LL_DEV_guia_supabase_live_v01.md` + checklist `..._checklist_supabase_live_v01.md`.

## Puesta en marcha (resumen)

1. Crear proyecto Supabase + activar PostGIS; ejecutar los 4 SQL en orden.
2. Completar credenciales en `.env` (app real) o en el bloque `window.__ENV__` del HTML del dashboard.
3. Abrir el dashboard: con credenciales válidas arranca en **LIVE**; sin ellas, en **DEMO** con los 504 olivos embebidos.
4. Activar Auth de operadores; el QR queda público de solo-lectura.

**Regla de oro:** el estado del árbol se cambia **exclusivamente** vía la RPC `registrar_monitoreo`. El frontend nunca hace `UPDATE` directo sobre `arbol`.

## Identidad visual

Sistema de diseño oficial en `assets/bruzzone-ds.css` (tokens, variables oficiales `--olive-primary`/`--gold-primary`/`--danger`/`--warning`/`--success`, componentes `.bz-*`, semáforos, estilos de dashboard/QR/DEMO-LIVE). Branding (logo, favicon, apple-touch-icon) en `assets/` e integrado en todas las páginas.

**Consolidación v01:** todas las páginas heredan de `bruzzone-ds.css` y usan el **lockup oficial** (`logo-horizontal.svg` en fondos claros / `logo-dark.svg` en cabeceras verdes) en vez de isotipos inline. Guías de identidad en `14_BRANDING/assets/`: sistema visual, experiencia comercial y **checklist visual** (`2026-05-29_LL_DS_checklist_visual_v01.md`). Manual de marca y kit de logo en `14_BRANDING/`.
