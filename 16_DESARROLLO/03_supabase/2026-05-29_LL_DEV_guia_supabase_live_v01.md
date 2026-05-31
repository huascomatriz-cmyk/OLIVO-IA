# Guía Supabase LIVE — BRUZZONE IA (Olivar Los Loros)

**v01 · 2026-05-29.** Pasar el MVP territorial de **DEMO** a **LIVE** de forma segura, ordenada y verificable. Pensada para una persona técnica principiante/intermedia. Tiempo estimado: 30–45 min.

> **Regla inviolable:** ningún componente modifica directamente la tabla `arbol`. Todo cambio de estado ocurre vía la RPC `registrar_monitoreo`.

---

## 0. Antes de empezar

Necesitas: una cuenta en [supabase.com](https://supabase.com) (gratis), los archivos SQL de `16_DESARROLLO/03_supabase/` y el frontend de `16_DESARROLLO/frontend/`. No necesitas instalar nada local: todo se hace en el navegador.

---

## 1. Guía paso a paso

### Paso 1 — Crear el proyecto Supabase
1. Entra a supabase.com → **New project**.
2. Nombre: `bruzzone-ia-los-loros`. Define una contraseña de base de datos (guárdala).
3. Región: la más cercana (ej. *South America (São Paulo)*).
4. Espera ~2 min a que el proyecto quede listo.

### Paso 2 — Activar PostGIS
- Lo activa automáticamente la primera línea de `01_schema_mvp.sql` (`create extension if not exists postgis;`).
- Alternativa por interfaz: **Database → Extensions** → buscar `postgis` → habilitar.

### Paso 3 — Ejecutar los SQL en orden
En **SQL Editor** (menú izquierdo) → **New query**, pegar y ejecutar cada archivo **en este orden** (ver sección 2 para detalle):
1. `01_schema_mvp.sql`
2. `02_seed_los_loros.sql`
3. `03_monitoreo_rpc_rls.sql`
4. `04_pruebas_validacion.sql`

### Paso 4 — Cargar los 504 olivos
Lo hace `02_seed_los_loros.sql` (incluye cliente demo, predio con perímetro y los 504 olivos con NDVI, rendimiento y zona). Es **idempotente**: si lo corres dos veces, limpia y recarga sin duplicar.

### Paso 5 — Verificar tablas
En **Table Editor** deben aparecer: `cliente`, `usuario`, `predio`, `sector`, `arbol` (504 filas), `monitoreo`, `tarea`, `estado_catalogo` (7 filas).

### Paso 6 — Verificar las RPC
En SQL Editor:
```sql
select arbol_geojson('22222222-2222-2222-2222-222222222222');  -- FeatureCollection(504)
```
(La RPC `registrar_monitoreo` se prueba en el paso 10.)

### Paso 7 — Verificar RLS
`04_pruebas_validacion.sql` (tests 5b/5c) confirma que RLS está activo y lista las políticas. Debe haber SELECT público en `arbol` y `estado_catalogo`.

### Paso 8 — Configurar Auth (ver sección 6)
**Authentication → Providers → Email**: activar, con OTP/Magic Link. Crear un operador de prueba.

### Paso 9 — Conectar credenciales al frontend (ver sección 3 y guía de env)
Copiar `Project URL` y `anon key` (**Settings → API**) al bloque `window.__ENV__` del dashboard y de las páginas QR/monitoreo/login.

### Paso 10 — Probar dashboard, QR, monitoreo y login
- Abrir el dashboard → el badge debe pasar a **● LIVE** y cargar 504 olivos.
- Abrir el QR de ejemplo → ficha pública sin login.
- Iniciar sesión (OTP) → registrar un monitoreo → el árbol cambia de estado y el mapa lo refleja.

---

## 2. Orden oficial de ejecución SQL

| Archivo | Qué hace | Cuándo | Cómo verificar | Error común | Corrección |
|---|---|---|---|---|---|
| `01_schema_mvp.sql` | Extensiones, tipos (enum), 7 tablas, índices GIST, vistas, RLS base | **Primero** | Aparecen las tablas en Table Editor | "type already exists" al reejecutar | Es inofensivo (usa `if not exists` / manejo de duplicados); continuar |
| `02_seed_los_loros.sql` | Cliente demo, predio (perímetro) y **504 olivos** | Tras `01` | `select count(*) from arbol;` = 504 | "relation arbol does not exist" | Ejecutar `01` primero |
| `03_monitoreo_rpc_rls.sql` | Catálogo de estados, RPC `arbol_geojson` + `registrar_monitoreo`, RLS live | Tras `02` | `select * from estado_catalogo;` = 7 | "function gen_random_uuid() does not exist" | Habilitar extensión `pgcrypto` (la incluye `01`) |
| `04_pruebas_validacion.sql` | Verificación automática (PASA/FALLA) | **Último** | Todos los tests "PASA" | Algún test "FALLA" | Releer el test, revisar orden 01→02→03 |

> **Importante:** el enum de estados se define **completo** en `01` (7 estados). No se usa `ALTER TYPE ADD VALUE` (que falla dentro de transacciones). Si modificaste el `03` para agregar valores con ALTER TYPE, no lo hagas: ya están en `01`.

---

## 3. Configuración de credenciales

Ubicación en Supabase: **Settings → API** → `Project URL` y `Project API keys → anon public`.

### A. HTML demo (dashboard y páginas)
Editar el bloque `window.__ENV__` (está cerca del final del HTML del dashboard `...LIVE_v03.html`, y al inicio del `<script>` en QR / monitoreo / login):
```js
window.__ENV__ = {
  SUPABASE_URL: "https://TU-PROYECTO.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOi...ANON...",
  ID_PREDIO: "22222222-2222-2222-2222-222222222222"
};
```
Con valores reales, el dashboard arranca en **LIVE**; con los placeholders, en **DEMO**.

### B. App real futura (Vite/Next)
Archivo `.env` (copiado de `.env.example`):
```
VITE_SUPABASE_URL=https://TU-PROYECTO.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOi...ANON...
```

**Advertencias de seguridad**
- ⚠ **Nunca** uses ni publiques la `service_role` key en el frontend (omnipotente, ignora RLS).
- ⚠ **Nunca** subas el `.env` real a GitHub; manténlo en `.gitignore`.
- ✅ Conserva `.env.example` (sin secretos) como plantilla.
- La `anon key` es pública por diseño; la seguridad real la dan las políticas RLS.

---

## 6. Configuración de Auth (operadores)

1. **Authentication → Providers → Email:** activar. Recomendado: **OTP / Magic Link** (sin contraseñas).
2. **Crear operador:** Authentication → Users → *Add user* (email del operador), o que se registre desde `pages/...AUTH_registro_usuario...` (envía OTP con `shouldCreateUser`).
3. **Crear agrónomo:** igual; el rol se guarda como metadata (`rol: agronomo`).
4. **Asignar roles (MVP):** simple, vía metadata del usuario. La tabla `usuario.rol` se completa al escalar; por ahora basta con "autenticado = puede registrar".
5. **Probar login:** abrir `login`, pedir código, verificar OTP → sesión activa.
6. **Probar registro de monitoreo:** con sesión, el formulario llama `registrar_monitoreo` → estado cambia.
7. **Bloqueo sin login:** sin sesión, el QR queda en solo-lectura y el formulario redirige a login. (Garantizado por RLS: `insert` en `monitoreo` solo para `authenticated`.)

> Mantener simple: email OTP/Magic Link, sin sistema complejo de permisos todavía.

---

## 7. Configuración QR LIVE

La ruta `/qr/:codigo` (página `src/components/qr/...QR_live_ficha_publica...`) debe:
- Abrir la ficha pública leyendo `arbol` por `codigo` (RLS: SELECT público).
- Mostrar estado actual, zona, NDVI, rendimiento y última visita.
- Mostrar solo lo permitido en público (historial completo = autenticado).
- Bloquear edición sin login (botón de registro oculto; ofrece iniciar sesión).
- Mantener lectura anónima (sin login).

**Prueba:** abrir `...QR...html?codigo=LL-OLI-0001`. Debe mostrar la ficha. En producción, el QR físico codifica `https://app.bruzzoneia.cl/qr/LL-OLI-0001`.

---

## 9. Plan de rollback (volver a DEMO sin perder la presentación)

| Si falla… | Síntoma | Acción inmediata |
|---|---|---|
| Supabase no responde | Badge no pasa a LIVE / timeout | El dashboard **cae solo a DEMO**; sigue la presentación con datos embebidos |
| El SQL falla | Error en SQL Editor | Releer el mensaje; reejecutar en orden 01→02→03; los scripts son idempotentes |
| El seed duplica datos | >504 árboles | Reejecutar `02` (limpia por UUID fijo antes de insertar) |
| La RPC no responde | `arbol_geojson` error | Verificar que `03` se ejecutó; revisar nombre del predio/UUID |
| RLS bloquea todo | Mapa vacío / 401 | Revisar políticas (test 5c); confirmar SELECT público en `arbol` |
| El dashboard no carga datos | Mapa sin puntos | **Quitar credenciales** de `window.__ENV__` (volver a placeholders) → vuelve a DEMO |
| El QR no encuentra el árbol | "Árbol no encontrado" | Verificar que el `codigo` existe (`LL-OLI-0001`) y que `02` cargó los 504 |

**Garantía:** poner los placeholders de vuelta en `window.__ENV__` devuelve el sistema a **DEMO** al instante. La demo comercial nunca depende de que Supabase funcione.

---

## Resumen

Sigue secciones 1→2→3→6→7, valida con la **sección 4** (checklist) y el `04_pruebas_validacion.sql` (**sección 5**), prueba desde el **Centro de Demo** (guía de pruebas LIVE) y ten a mano la **sección 9** por si algo falla. Documentos relacionados: `..._checklist_supabase_live_v01.md`, `../frontend/2026-05-29_LL_DEV_configuracion_env_v01.md`, `../frontend/2026-05-29_LL_DEV_pruebas_centro_demo_live_v01.md`.
