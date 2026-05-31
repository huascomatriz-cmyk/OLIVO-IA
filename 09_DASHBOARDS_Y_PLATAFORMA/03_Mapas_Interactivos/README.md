# Mapa interactivo — Olivar Los Loros (demo MVP)

**Archivo:** `2026-05-29_LL_DASH_leaflet_demo_mapa_olivos_v01.html`
Primera demo navegable del dashboard MVP de BRUZZONE IA. Mapa Leaflet autocontenido.

## 1. Qué muestra el mapa

- **Perímetro predial** del Olivar Los Loros (línea dorada punteada).
- **504 olivos georreferenciados**, cada uno coloreado por su **zona de manejo**: verde = alto vigor, amarillo = medio, rojo = bajo (clasificación K-means oficial sobre NDVI).
- **Panel de KPIs** superior: total de olivos, NDVI medio, rendimiento medio 2019/2020 y distribución por zona.
- **Leyenda** (abajo a la derecha) con el conteo por zona.
- **Popup por árbol** al hacer clic: código, zona de manejo, clase de vigor K-means, NDVI medio y actual, rendimiento 2019 y 2020, y estado operativo.
- **Control de capas** (arriba a la derecha): alternar mapa base (satélite Esri / OpenStreetMap), el perímetro y cada zona de vigor por separado.
- **Zoom automático** al predio al abrir.

## 2. Cómo abrirlo

Doble clic en el archivo `.html` — se abre en cualquier navegador (Chrome, Edge, Firefox). No requiere instalar nada ni servidor.

> Necesita conexión a internet la primera vez, porque carga la librería Leaflet y las imágenes de los mapas base desde la web. Los datos de los olivos van **dentro del archivo**, así que el mapa de árboles funciona aunque el resto sea lento.

## 3. Qué datos utiliza

Los datos están **embebidos** en el HTML (no usa `fetch`, por eso funciona con doble clic sin errores de seguridad del navegador). Provienen de:

- `03_GIS/06_ANALISIS_ESPACIAL/2026-05-29_LL_GIS_arbolado_zonas_manejo_v01.geojson` (504 olivos con atributos).
- `03_GIS/02_capas_base/...perimetro_predial...kml` (perímetro del predio).

Esos atributos son exactamente los que entrega la vista `v_arbol_geojson` de la base de datos, por lo que el formato ya es compatible con la fase siguiente.

## 4. Cómo se conectará después a Supabase

Hoy los datos están embebidos (modo demo). Para datos en vivo, se reemplaza el bloque `const ARBOLES = {...}` por una consulta a Supabase:

```js
const url = "https://<proyecto>.supabase.co/rest/v1/rpc/arbol_geojson?id_predio=...";
const ARBOLES = await fetch(url, { headers:{ apikey:"<anon-key>" }}).then(r=>r.json());
```

La vista `v_arbol_geojson` (en `16_DESARROLLO/03_supabase/01_schema_mvp.sql`) ya devuelve un FeatureCollection listo, así que el resto del código del mapa no cambia. Al servirse desde una web (no `file://`), `fetch` funciona sin problemas de CORS.

## 5. Próximos pasos para convertirlo en dashboard real

1. **Conectar a Supabase** en vivo (paso 4) para que el mapa refleje el estado actual.
2. **Capa de monitoreo:** recolorear los olivos por `estado` (sano / vigilar / intervención) a medida que entren monitoreos, dejando la zona de manejo como filtro.
3. **Registro desde el mapa / QR:** botón para crear un monitoreo (estado + foto) sobre el árbol seleccionado.
4. **Capa de rendimiento:** mapa de calor opcional con `rendimiento_2020` para contrastar vigor vs producción.
5. **Filtros y comparación temporal:** filtrar por zona y comparar NDVI/rendimiento entre temporadas.
6. **Integrarlo en la web Next.js/Vercel** como sección "Ver demo en vivo" del portal del cliente.

---
*BRUZZONE IA · Fase Operacional MVP · Demo de dashboard territorial.*
