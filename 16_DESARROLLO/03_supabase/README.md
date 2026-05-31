# Supabase / PostGIS — Esquema MVP BRUZZONE IA

Base de datos del MVP: modelo mínimo `cliente · predio · sector · arbol · monitoreo · tarea · usuario` con soporte espacial PostGIS.

## Archivos

| Archivo | Qué hace |
|---|---|
| `01_schema_mvp.sql` | Extensiones, tipos enum, 7 tablas, índices espaciales (GIST), vistas de dashboard y RLS base. Idempotente. |
| `02_seed_los_loros.sql` | Carga el caso real: cliente demo, predio Olivar Los Loros (con perímetro) y los **504 olivos** con zona de manejo, NDVI y rendimiento histórico. |

## Orden de ejecución

1. En Supabase → **SQL Editor**, ejecutar `01_schema_mvp.sql`.
2. Ejecutar `02_seed_los_loros.sql`.
3. Verificar:

   ```sql
   select zona_manejo, count(*), round(avg(ndvi),3), round(avg(rendimiento_2020),1)
   from arbol group by zona_manejo;
   select * from v_kpi_predio;
   ```

## Cómo alimenta al dashboard

- `v_kpi_predio` → tarjetas de KPI del predio (n.º árboles, NDVI medio, rendimiento medio, árboles en alerta).
- `v_zona_manejo` → resumen por zona (alto/medio/bajo).
- `v_arbol_geojson` → devuelve **un FeatureCollection GeoJSON listo para el mapa** directamente desde la base:

  ```sql
  select geojson from v_arbol_geojson where id_predio = '22222222-2222-2222-2222-222222222222';
  ```

  Leaflet (`L.geoJSON(data)`) o Mapbox (`map.addSource({type:'geojson', data})`) lo consumen sin transformación.

## Notas

- **QR sin login:** `arbol` y `sector` tienen lectura pública (RLS) para que el escaneo del QR abra la ficha sin autenticación. Refinar por cliente al escalar.
- **Carga alternativa del GeoJSON** (en vez del seed) con GDAL:

  ```bash
  ogr2ogr -f PostgreSQL "PG:host=... dbname=postgres user=..." \
    2026-05-29_LL_GIS_arbolado_zonas_manejo_v01.geojson -nln arbol_staging
  ```

  y luego un `insert into arbol (...) select ... from arbol_staging`.
- El seed usa UUIDs fijos para cliente/predio, de modo que reejecutarlo limpia y recarga sin duplicar.
