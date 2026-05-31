# Estructura Frontend Consolidada — BRUZZONE IA

**v01 · 2026-05-29.** Organización modular del frontend tras la consolidación del sistema de diseño. Todas las páginas heredan de `bruzzone-ds.css` y usan el lockup oficial.

## Carpetas

```
16_DESARROLLO/frontend/
├── assets/         Fuente de marca: bruzzone-ds.css, favicon, apple-touch, logos (svg/png)
├── branding/       Copia compartida de logos/CSS para reutilizar en módulos
├── styles/         Estilos específicos / overrides (sobre el maestro)
├── components/     Componentes UI compartidos (KPI, pills, paneles, tarjetas)
├── layout/         Header (lockup), nav, footer, contenedores
├── maps/           Componentes Leaflet (capa árboles, leyenda, control)
├── monitoring/     Formulario de monitoreo (registrar_monitoreo) — página viva
├── qr/             Ruta /qr/:codigo (ficha en src/components/qr) — página viva
├── auth/           Lógica de autenticación (login/registro viven en pages/)
├── pages/          Páginas/rutas: login, registro
├── lib/            supabaseClient.js, api.js
├── services/       dataService.js, cache.js (orquestación, cache, cola offline)
├── hooks/          useArboles.js, useSesion.js (React, para migración)
├── public/         estáticos
└── src/            estructura previa (components/lib/styles/mobile) + qr/
```

## Principios de consolidación

- **CSS maestro único:** `bruzzone-ds.css` define tokens (variables oficiales `--olive-primary`, `--gold-primary`, `--danger`, `--warning`, `--success`, etc.) y componentes (`.bz-*`). Todas las páginas lo enlazan.
- **Sin estilos aislados nuevos:** los módulos usan las variables y clases del maestro; los estilos propios actuales se mantienen por compatibilidad pero deben migrar a `.bz-*`.
- **Lockup oficial:** `logo-horizontal.svg` (fondos claros) / `logo-dark.svg` (cabeceras verdes) con la clase `.bz-brand-logo`. Sin isotipos/emoji inline en cabeceras.
- **Branding local por módulo:** cada carpeta de página tiene copia de `bruzzone-ds.css` + logos + favicon, para rutas robustas en `file://` y despliegues estáticos.

## Dependencias y reutilización

- `pages/`, `monitoring/`, `qr/` (en `src/components/qr`) → consumen `lib/api.js` y `lib/supabaseClient.js`.
- `services/dataService.js` → orquesta `lib/api.js` + `services/cache.js` (fallback/offline).
- Todos los módulos → `bruzzone-ds.css` (visual) + assets de marca.
- Al migrar a React/Next: `components/`, `layout/`, `hooks/` ya están previstos; el HTML actual sirve de referencia 1:1.

## Estado

Páginas vivas (HTML autocontenido, con branding y CSS maestro integrados): landing, demo, Centro de Demo, dashboard LIVE, login, registro, monitoreo, QR. Carpetas modulares creadas como scaffolding para el crecimiento a componentes.
