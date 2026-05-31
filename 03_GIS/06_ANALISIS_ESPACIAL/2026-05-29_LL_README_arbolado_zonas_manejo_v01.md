# Olivar Los Loros — Arbolado con zonas de manejo (GeoJSON)

**Archivo de datos:** `2026-05-29_LL_GIS_arbolado_zonas_manejo_v01.geojson`
**Fecha de procesamiento:** 2026-05-29 · **Versión:** v01
**Predio:** Olivar Los Loros (comuna de Freirina, Región de Atacama, Chile)
**Sistema de coordenadas:** WGS84 / CRS84 (lon, lat) — listo para Leaflet y Mapbox.

---

## 1. Resumen técnico del procesamiento

Se integraron tres fuentes históricas validadas del ecosistema BRUZZONE IA en un único archivo GeoJSON de puntos, uno por olivo:

1. **Geometría (504 olivos):** parseo del KML `2026-05-29_LL_GIS_georreferenciacion_olivo_v01.kml`. Cada *placemark* aporta el identificador del árbol (`name`) y sus coordenadas (lon, lat).
2. **Vigor (NDVI):** serie multitemporal por árbol `Datos_NDVI_arbol.csv` (8 fechas, 2016–2020). Se calculó el NDVI medio (vigor estable) y el NDVI más reciente (ene-2020).
3. **Zonificación de manejo:** clasificación **K-means oficial** del predio (`DF_puntos_cluster_NDVI.xlsx`), 4 clases de vigor por árbol, mapeadas a 3 zonas de manejo.
4. **Rendimiento:** cosechas por árbol de las temporadas 2018-2019 (`bd_18-19.csv`) y 2020 (`bd20.csv`), en kg/árbol.

**Validación de identidad del predio:** las coordenadas del KML coinciden exactamente con las del dataset científico histórico (árbol 1: −71.09368, −28.49999 en ambas fuentes). Se confirma que Olivar Los Loros **es** el olivar estudiado científicamente; el join por `id_arbol` es plenamente válido.

**Resultado:**

| Indicador | Valor |
|---|---|
| Olivos exportados | **504** (100% del KML) |
| Geometría válida (Point) | 504 / 504 |
| Códigos únicos | 504 / 504 |
| Tamaño del archivo | ~223 KB |
| BBox [W, S, E, N] | −71.09414, −28.50169, −71.09067, −28.49877 |

**Cobertura de atributos:**

| Atributo | Árboles con dato | Cobertura |
|---|---|---|
| NDVI (medio y actual) | 504 | 100% |
| Clase de vigor K-means | 504 | 100% |
| Rendimiento 2020 | 504 | 100% |
| Rendimiento 2019 | 478 | 94.8% |

**Reproducibilidad:** generado con `process_geojson.py` (incluido en la entrega). Reejecutable si se actualizan las fuentes.

---

## 2. Tabla de atributos (esquema de cada `feature.properties`)

| Atributo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `codigo` | texto | Código único del árbol (`LL-OLI-####`) | `LL-OLI-0001` |
| `id_arbol` | entero | Identificador numérico original | `1` |
| `predio` | texto | Nombre del predio | `Olivar Los Loros` |
| `cultivo` | texto | Cultivo | `Olivo` |
| `variedad` | texto/null | Variedad (no documentada en origen) | `null` |
| `lon` | decimal | Longitud WGS84 | `-71.0936754` |
| `lat` | decimal | Latitud WGS84 | `-28.4999914` |
| `zona_manejo` | texto | Zona de manejo: `alto` · `medio` · `bajo` | `alto` |
| `clase_vigor_kmeans` | entero | Clase K-means original (1=menor vigor … 4=mayor) | `4` |
| `ndvi` | decimal | NDVI medio multitemporal (2016–2020) | `0.507` |
| `ndvi_actual` | decimal | NDVI más reciente (ene-2020) | `0.483` |
| `rendimiento_2019` | decimal/null | Cosecha 2018-2019 (kg/árbol) | `14.1` |
| `rendimiento_2020` | decimal/null | Cosecha 2020 (kg/árbol) | `94.4` |
| `estado` | texto | Semáforo operativo del dashboard | `sin_monitoreo` |
| `ultimo_monitoreo` | fecha/null | Fecha del último monitoreo (se llena en operación) | `null` |

La geometría es siempre `Point` con coordenadas `[lon, lat]`. La colección incluye `bbox` y un bloque `metadata` con fuentes y criterios.

---

## 3. Criterios de clasificación de zonas de manejo

La zonificación **no se recalculó arbitrariamente**: se reutilizó la clasificación **K-means oficial** del predio (4 clases de vigor sobre NDVI), que es la referencia metodológica validada del ecosistema. Las 4 clases se mapearon a las 3 zonas de manejo solicitadas:

| Zona de manejo | Clase K-means | NDVI medio (rango) | N.º olivos | Interpretación |
|---|---|---|---|---|
| **bajo** vigor | Clase 1 | 0.416 (0.357–0.438) | 14 | Árboles rezagados; prioridad de diagnóstico/intervención |
| **medio** vigor | Clases 2–3 | 0.498 (0.397–0.550) | 222 | Comportamiento intermedio; manejo estándar |
| **alto** vigor | Clase 4 | 0.549 (0.507–0.582) | 268 | Mayor vigor; sostener y monitorear |

**Regla de respaldo (fallback):** si un árbol no tuviese clase K-means, se clasifica por terciles del NDVI medio (puntos de corte: bajo < 0.514, medio < 0.544, alto ≥ 0.544). En esta versión **no fue necesario**: el 100% de los olivos tiene clase oficial.

**Por qué esta lógica:** la clasificación por vigor permite el *manejo diferencial* — tratar distinto lo que es distinto— que es el núcleo de la propuesta de valor. La clase queda guardada también de forma cruda (`clase_vigor_kmeans`) para poder volver a 4 niveles si el dashboard lo requiere.

---

## 4. Observaciones de calidad de datos

- **Coincidencia geográfica perfecta:** KML e histórico científico refieren al mismo predio y a la misma numeración de árboles. No hubo necesidad de geomatching aproximado.
- **Cobertura alta:** NDVI, clase de vigor y rendimiento 2020 cubren el 100% de los olivos; rendimiento 2019 cubre el 94.8% (26 árboles sin dato → `null`, no se inventó valor).
- **Duplicados en origen depurados:** la tabla de rendimiento 2018-2019 contenía múltiples filas por árbol (777 filas, 479 IDs únicos). Se consolidó promediando por árbol para evitar duplicación de puntos. La tabla NDVI tenía 1 ID duplicado, también depurado.
- **Relación vigor–rendimiento a nivel de zona (señal real):** la zona de **bajo vigor rinde menos** que las demás —2019: 66.4 vs ~79 kg/árbol; 2020: 79.2 vs ~89 kg/árbol—, lo que respalda el uso de la zonificación para decisiones.
- **Correlación cruda NDVI–rendimiento débil a nivel de árbol individual** (r ≈ 0.13 en 2020; ≈ 0.02 en 2019). Esto es esperable y **no contradice** el modelo histórico de alta precisión (R² = 0.74): ese modelo usa NDVI **combinado con variables de terreno y derivadas** (pendiente, exposición, grados-día, etc.), no NDVI crudo aislado. Conclusión operativa: para predecir rendimiento se requiere el modelo completo, no solo NDVI; para zonificar el manejo, el vigor NDVI es suficiente y útil.
- **Variedad no disponible** en las fuentes; queda como `null` para completarse en terreno.
- **Temporalidad:** NDVI y rendimientos son históricos (2016–2020). Sirven como **línea base**; el monitoreo actual los actualizará (`estado`, `ultimo_monitoreo`).

---

## 5. Recomendaciones para el dashboard MVP

1. **Capa base de puntos coloreada por `zona_manejo`** sobre el perímetro predial: verde = alto, amarillo = medio, rojo = bajo. Es el "momento ajá" del cliente.
2. **Popup por árbol** al hacer clic: mostrar `codigo`, `zona_manejo`, `ndvi`, `rendimiento_2020` y `estado`. Mantenerlo a 4–5 campos para legibilidad.
3. **Semáforo operativo con `estado`** (hoy `sin_monitoreo`): a medida que entren monitoreos, sobreescribir el color por estado sanitario/quintral, dejando `zona_manejo` como filtro.
4. **Filtros simples:** por zona de manejo y por presencia de rendimiento. Evitar filtros avanzados en el MVP.
5. **KPIs del predio derivables directamente del GeoJSON:** n.º de olivos (504), distribución por zona (268/222/14), NDVI medio por zona, rendimiento medio por zona y por temporada. No requieren backend para una demo.
6. **Comparación de temporadas** (`rendimiento_2019` vs `rendimiento_2020`) como gráfico de barras: comunica evolución y valida la trazabilidad histórica.
7. **Rendimiento:** mostrarlo como *dato histórico de línea base*, no como predicción. La capa predictiva (modelo R² = 0.74) se reserva para una fase posterior/premium.
8. **Rendimiento como mapa de calor opcional** (`rendimiento_2020`) como segunda capa, para contrastar visualmente vigor vs producción y abrir la conversación de manejo diferencial.
9. **Carga directa:** Leaflet (`L.geoJSON`) o Mapbox (`addSource` tipo `geojson`) consumen este archivo sin transformación. Para producción, cargar a PostGIS con el esquema SQL incluido (`16_DESARROLLO/03_supabase`).

---

*Generado por BRUZZONE IA · Fase Operacional MVP · Script reproducible: `process_geojson.py`.*
