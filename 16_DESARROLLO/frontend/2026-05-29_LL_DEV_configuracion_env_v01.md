# Configuración de credenciales (ENV) — BRUZZONE IA

**v01 · 2026-05-29.** Cómo conectar el frontend al proyecto Supabase. Dos formas: HTML demo y app real.

## Dónde obtener las credenciales

En Supabase: **Settings → API**
- `Project URL` → `SUPABASE_URL` (ej. `https://abcd1234.supabase.co`)
- `Project API keys → anon public` → `SUPABASE_ANON_KEY` (cadena larga `eyJ...`)

## A. HTML demo (dashboard y páginas)

Cada HTML que usa Supabase tiene (o admite) un bloque `window.__ENV__`. Edítalo con tus valores:

```js
window.__ENV__ = {
  SUPABASE_URL: "https://TU-PROYECTO.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOi...ANON...",
  ID_PREDIO: "22222222-2222-2222-2222-222222222222"
};
```

Archivos a editar:
- `09_DASHBOARDS_Y_PLATAFORMA/03_Mapas_Interactivos/2026-05-29_LL_DASH_leaflet_LIVE_v03.html` (bloque cerca del final).
- `16_DESARROLLO/frontend/src/components/qr/2026-05-29_LL_QR_live_ficha_publica_v01.html`
- `16_DESARROLLO/frontend/monitoring/2026-05-29_LL_MON_registro_monitoreo_v01.html`
- `16_DESARROLLO/frontend/pages/2026-05-29_LL_AUTH_login_v01.html`
- `16_DESARROLLO/frontend/pages/2026-05-29_LL_AUTH_registro_usuario_v01.html`

> En las páginas QR/monitoreo/login, el `window.__ENV__` se define dentro del `<script>` (variable `ENV`). Pega ahí tus valores. **Con placeholders → modo DEMO; con valores reales → modo LIVE.**

Truco para no editar cada archivo: crear un `env.js` compartido con `window.__ENV__ = {...}` e incluirlo con `<script src="env.js"></script>` antes del script principal de cada página (no lo subas a GitHub).

## B. App real futura (Vite / Next.js)

Copia `.env.example` a `.env` (o `.env.local`) y completa:

```
VITE_SUPABASE_URL=https://TU-PROYECTO.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOi...ANON...
VITE_ID_PREDIO=22222222-2222-2222-2222-222222222222
```

`lib/supabaseClient.js` ya lee estas variables (soporta Vite, Next y `window.__ENV__`).

## Advertencias de seguridad

- ⚠ **Nunca** pongas la `service_role` key en el frontend ni en un HTML. Es omnipotente e ignora RLS.
- ⚠ **Nunca** subas el `.env` real a GitHub. Manténlo en `.gitignore`.
- ✅ Conserva `.env.example` (sin secretos reales) como plantilla.
- ✅ La `anon key` es pública por diseño; la protección real son las políticas RLS.

## Verificación rápida

Abre el dashboard tras configurar: el badge debe pasar de **● DEMO (local)** a **● LIVE**. Si sigue en DEMO, revisa que la URL/clave no tengan el texto `TU-PROYECTO`/`TU_ANON` y que no haya errores en la consola del navegador (F12).
