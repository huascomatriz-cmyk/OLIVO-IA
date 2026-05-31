# Corte a Supabase Live — Plan técnico · BRUZZONE IA (Olivar Los Loros)

**v01 · 2026-05-29.** Guía maestra para pasar del dashboard autocontenido (datos embebidos) a **datos en vivo desde Supabase**, con el menor cambio posible y sin romper la demo.

> **Principio:** la RPC `arbol_geojson` devuelve **exactamente** el mismo FeatureCollection que hoy está embebido. El corte se reduce a reemplazar `const ARBOLES = {…}` por `const ARBOLES = await getArboles(ID_PREDIO)`.

## Documentos de esta serie

| Archivo | Contenido |
|---|---|
| `..._corte_a_vivo_README_v01.md` (este) | Plan, configuración Supabase, checklist, rollback |
| `..._contrato_api_v01.md` | Contrato definitivo de los 5 endpoints |
| `..._migracion_mapa_v01.md` | Cómo migrar el HTML del mapa (con código) |
| `..._qr_live_v01.md` + `qr.html` | Ruta `/qr/:codigo` y página pública |
| `..._seguridad_rls_v01.md` | RLS, roles y checklist de seguridad |
| `.env.example` | Variables de entorno |
| `lib/supabaseClient.js`, `lib/api.js` | Cliente + API wrapper |
| `../03_supabase/0X_*.sql` | Esquema, seed, RPC/RLS y pruebas |

---

## 1. Plan de corte (paso a paso)

| # | Paso | Dependencia | Validación | Rollback |
|---|---|---|---|---|
| 1 | Crear proyecto Supabase + activar PostGIS | — | Proyecto activo | Borrar proyecto (no afecta la demo) |
| 2 | Ejecutar `01_schema_mvp.sql` | 1 | Tablas y tipos creados | `drop schema` / recrear proyecto |
| 3 | Ejecutar `02_seed_los_loros.sql` | 2 | 504 árboles + perímetro | Reejecutar (es idempotente) |
| 4 | Ejecutar `03_monitoreo_rpc_rls.sql` | 2 | Catálogo, RPC y RLS | Reejecutar |
| 5 | Ejecutar `04_pruebas_validacion.sql` | 2-4 | Todos los tests "PASA" | Corregir y repetir |
| 6 | Configurar `.env` (URL + anon key) | 1 | Variables presentes | — |
| 7 | Migrar el mapa a `getArboles` | 2-6 | Mapa carga 504 olivos vivos | **Fallback a datos embebidos** |
| 8 | Conectar formulario a `registrarMonitoreo` | 4,6 | Estado cambia y mapa refresca | Deshabilitar registro |
| 9 | Publicar ruta `/qr/:codigo` | 2-6 | QR abre ficha pública | Servir QR estático |
| 10 | Activar Auth de operadores | 1 | Login funciona; cliente solo-lectura | Mantener solo lectura |

**Riesgos y mitigaciones**
- *Supabase no responde / sin red* → el mapa usa **fallback** a datos embebidos (ver guía de migración). La demo nunca se rompe.
- *Formato de RPC distinto* → mitigado: `arbol_geojson` replica el formato; `getArboles` valida el FeatureCollection.
- *Orden de scripts incorrecto* → ejecutar siempre 01 → 02 → 03 → 04; PostGIS antes de todo.
- *Enum de estados* → ya se define completo en `01` (no se usa `ALTER TYPE`).

**Rollback global:** como la versión embebida (`v02`) sigue existiendo intacta, ante cualquier problema se vuelve a ese archivo. El corte a vivo es aditivo, no destructivo.

---

## 2. Configuración de Supabase

1. **Crear proyecto** en supabase.com → anotar *Project URL* y *anon key* (Settings → API).
2. **Activar PostGIS:** lo hace `create extension if not exists postgis;` (primera línea de `01_schema_mvp.sql`). Alternativa UI: Database → Extensions → habilitar `postgis`.
3. **Ejecutar SQL** en el SQL Editor, en orden:

   ```
   01_schema_mvp.sql        -- extensiones, tipos, tablas, índices GIST, vistas, RLS base
   02_seed_los_loros.sql    -- cliente demo, predio (perímetro) y 504 olivos reales
   03_monitoreo_rpc_rls.sql -- catálogo de estados, RPC arbol_geojson + registrar_monitoreo, RLS live
   04_pruebas_validacion.sql-- verificación automática (debe dar todo "PASA")
   ```

4. **Validaciones rápidas** (incluidas en `04`):
   - Árboles = 504 · perímetro = polígono · `arbol_geojson` = FeatureCollection(504).
   - `v_kpi_predio`, `estado_catalogo` (7 estados), `registrar_monitoreo` cambia el estado, `v_historial_arbol` registra el evento.

---

## 10. Checklist de corte a vivo

- [ ] 1. Crear proyecto Supabase y activar PostGIS.
- [ ] 2. Ejecutar `01`, `02`, `03` en orden.
- [ ] 3. Ejecutar `04_pruebas_validacion.sql` → todos "PASA".
- [ ] 4. Configurar `.env` con URL + anon key.
- [ ] 5. Probar RPC desde el SQL editor y desde `lib/api.js`.
- [ ] 6. Migrar el mapa a `getArboles(ID_PREDIO)` (con fallback).
- [ ] 7. Probar el mapa vivo: 504 olivos, colores por estado, leyenda, KPIs.
- [ ] 8. Probar `/qr/:codigo` (lectura pública sin login).
- [ ] 9. Probar login de operador y registro de monitoreo (estado cambia, mapa refresca).
- [ ] 10. Documentar errores y correcciones en este README.

**Estado del entregable:** scripts SQL, cliente, API wrapper, pruebas y guías listos. Falta únicamente crear el proyecto Supabase real y completar `.env` para ejecutar el corte.
