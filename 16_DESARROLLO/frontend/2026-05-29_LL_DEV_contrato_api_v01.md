# Contrato API definitivo — BRUZZONE IA (Olivar Los Loros)

**v01 · 2026-05-29.** Endpoints expuestos por Supabase (PostgREST) y su uso en el frontend (`lib/api.js`). Base URL: `https://<proyecto>.supabase.co/rest/v1`. Todas las peticiones incluyen los headers `apikey: <anon_key>` y, si hay sesión, `Authorization: Bearer <access_token>`.

---

## 1. `arbol_geojson` — árboles del predio (mapa)

- **Propósito:** entregar los árboles como FeatureCollection GeoJSON, en el formato exacto que ya consume el dashboard.
- **Método:** `POST /rpc/arbol_geojson` (RPC).
- **Payload:** `{ "p_predio": "22222222-2222-2222-2222-222222222222" }`
- **Respuesta:**
  ```json
  { "type":"FeatureCollection",
    "features":[ { "type":"Feature",
      "geometry":{"type":"Point","coordinates":[-71.0936754,-28.4999914]},
      "properties":{"codigo":"LL-OLI-0001","zona_manejo":"alto","clase_vigor_kmeans":4,
        "ndvi":0.507,"ndvi_actual":0.483,"rendimiento_2019":14.1,"rendimiento_2020":94.4,
        "estado":"sano","ultimo_monitoreo":null,"lat":-28.4999914,"lon":-71.0936754} } ] }
  ```
- **Auth:** `anon` (lectura pública).
- **Errores:** `404` predio inexistente → `features: []`; red caída → manejar con fallback.
- **Frontend:** `getArboles(idPredio)` → se asigna a `ARBOLES`.

## 2. `registrar_monitoreo` — registrar evento y cambiar estado

- **Propósito:** insertar un monitoreo y actualizar `arbol.estado` + `ultimo_monitoreo`. **Única vía** para cambiar el estado.
- **Método:** `POST /rpc/registrar_monitoreo` (RPC, `security definer`).
- **Payload:**
  ```json
  { "p_codigo":"LL-OLI-0001", "p_estado":"intervencion", "p_tipo":"quintral",
    "p_severidad":4, "p_observacion":"Foco detectado", "p_foto_url":null }
  ```
- **Respuesta:** `"<uuid del monitoreo>"`.
- **Auth:** `authenticated` (operador/agrónomo). `auth.uid()` queda como técnico.
- **Errores:** `Árbol X no existe`; `401/403` si no autenticado; severidad fuera de 0–5.
- **Frontend:** `registrarMonitoreo(payload)`; tras éxito, refrescar el mapa.

## 3. `estado_catalogo` — catálogo de estados

- **Propósito:** fuente única de etiqueta/color/ícono/prioridad de cada estado.
- **Método:** `GET /estado_catalogo?select=estado,etiqueta,color,icono,prioridad&order=prioridad.desc`
- **Respuesta:** `[{ "estado":"critico","etiqueta":"Crítico","color":"#C62828","icono":"✖","prioridad":4 }, …]`
- **Auth:** `anon`.
- **Frontend:** `getEstadosCatalogo()` (cachear; cambia rara vez).

## 4. `v_historial_arbol` — historial de un árbol

- **Propósito:** eventos de monitoreo de un árbol, más reciente primero.
- **Método:** `GET /v_historial_arbol?codigo=eq.LL-OLI-0001&order=fecha.desc`
- **Respuesta:** `[{ "codigo","fecha","tipo","severidad","observacion","foto_url","tecnico","id_usuario" }, …]`
- **Auth:** `authenticated` (el cliente público ve solo lo permitido; ver guía RLS).
- **Frontend:** `getHistorialArbol(codigo)`.

## 5. `v_kpi_predio` — KPIs del predio

- **Propósito:** indicadores agregados (n.º árboles, NDVI medio, rendimientos, árboles en alerta).
- **Método:** `GET /v_kpi_predio?id_predio=eq.<uuid>`
- **Respuesta:** `{ "id_predio","predio","n_arboles":504,"ndvi_medio":0.5,"rend_2020_medio":88.6,"rend_2019_medio":78.9,"arboles_en_alerta":34 }`
- **Auth:** `anon`.
- **Frontend:** `getKpisPredio(idPredio)`.

---

**Resumen de autenticación**

| Endpoint | anon (lectura) | authenticated (escritura) |
|---|:--:|:--:|
| `arbol_geojson` | ✅ | — |
| `estado_catalogo` | ✅ | — |
| `v_kpi_predio` | ✅ | — |
| `v_historial_arbol` | — | ✅ |
| `registrar_monitoreo` | — | ✅ |
