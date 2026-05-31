# Checklist Supabase LIVE — BRUZZONE IA (Olivar Los Loros)

**v01 · 2026-05-29.** Verificación de la activación LIVE. Marca cada ítem; todos deben quedar ✓ antes de presentar en modo LIVE.

## 1. Infraestructura
- [ ] Proyecto Supabase creado y activo.
- [ ] **PostGIS activo** (`select postgis_version();` responde).
- [ ] `pgcrypto` disponible (`gen_random_uuid()` funciona).

## 2. Esquema y datos (tras 01 + 02)
- [ ] Tablas creadas: `cliente`, `usuario`, `predio`, `sector`, `arbol`, `monitoreo`, `tarea`, `estado_catalogo`.
- [ ] **Predio creado** (`select * from predio;` = 1 fila, Olivar Los Loros).
- [ ] **504 olivos cargados** (`select count(*) from arbol;` = 504).
- [ ] **Perímetro predial cargado** (`predio.geom` es un polígono).
- [ ] Cobertura: NDVI y rendimiento 2020 al 100%, rendimiento 2019 ~95%.

## 3. RPC y vistas (tras 03)
- [ ] `arbol_geojson('<id_predio>')` devuelve **FeatureCollection con 504 features**.
- [ ] `estado_catalogo` responde con **7 estados** (color/ícono/prioridad).
- [ ] `v_kpi_predio` responde (n_arboles=504, NDVI medio, rendimientos, alertas).
- [ ] `v_zona_manejo` responde (alto/medio/bajo).
- [ ] `v_historial_arbol` existe.

## 4. Seguridad / RLS
- [ ] **RLS activo** en `arbol`, `monitoreo`, `estado_catalogo`, `sector` (test 5b).
- [ ] Política **SELECT pública** en `arbol` y `estado_catalogo` (test 5c).
- [ ] `monitoreo`: insert/select solo `authenticated`.
- [ ] No existe política de UPDATE directo sobre `arbol`.

## 5. Auth
- [ ] Proveedor Email/OTP activo.
- [ ] Usuario operador de prueba creado.
- [ ] (Opcional) usuario agrónomo creado.

## 6. Pruebas funcionales (extremo a extremo)
- [ ] **QR público lee datos:** `...QR...html?codigo=LL-OLI-0001` muestra la ficha sin login.
- [ ] **Login operador funciona:** OTP recibido y verificado, sesión activa.
- [ ] **Usuario autenticado registra monitoreo** desde el formulario.
- [ ] **`registrar_monitoreo` actualiza el estado** del árbol (vía RPC, no UPDATE directo).
- [ ] El **historial** registra el evento (`v_historial_arbol`).
- [ ] **Sin login no se puede registrar** (RLS bloquea / UI oculta el botón).

## 7. Dashboard
- [ ] Con credenciales en `window.__ENV__`, el badge muestra **● LIVE**.
- [ ] El mapa carga los 504 olivos desde Supabase.
- [ ] **El dashboard pasa de DEMO a LIVE** correctamente.
- [ ] Tras registrar un monitoreo, **↻ Recargar** refleja el nuevo estado.

## 8. Fallback (resiliencia)
- [ ] Con placeholders en `window.__ENV__`, vuelve a **DEMO** sin romperse.
- [ ] Con Supabase caído, el dashboard cae a DEMO/CACHÉ y avisa.

**Criterio LIVE aprobado:** secciones 1–8 completas. Ejecuta `04_pruebas_validacion.sql`: todos los tests deben decir **PASA**.
