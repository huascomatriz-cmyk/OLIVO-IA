# Dashboard Operacional Vivo — Arquitectura · Olivar Los Loros

**Versión:** v01 · **Fecha:** 2026-05-29 · **Predio:** Olivar Los Loros (504 olivos)
Evolución del mapa demo (`v01`) hacia un sistema operacional de monitoreo territorial (`v02`).

**Artefacto funcional:** `03_Mapas_Interactivos/2026-05-29_LL_DASH_leaflet_operacional_v02.html`
**Datos de monitoreo simulado:** `03_Mapas_Interactivos/2026-05-29_LL_DATA_monitoreo_simulado_v01.json`

---

## 1. Sistema operacional de estados

Cada árbol tiene en todo momento **un** estado operacional. El estado —no la zona de manejo— pasa a ser el color por defecto del mapa: la zona (vigor NDVI) es la *línea base estructural*, el estado es la *realidad operativa actual*.

| Estado | Color | Ícono | Prioridad | Significado | Transiciones típicas |
|---|---|---|---|---|---|
| **Crítico** | `#C62828` rojo | ✖ | 4 | Urgencia (quintral severo, daño grave) | → intervención → podado |
| **Intervención** | `#EF6C00` naranja | ⚠ | 3 | Requiere acción (foco de quintral, plaga) | → podado / crítico |
| **Vigilar** | `#F9A825` amarillo | 👁 | 2 | Señal temprana, reobservar | → sano / intervención |
| **Recuperándose** | `#26A69A` teal | ↑ | 2 | Evolución favorable post-manejo | → sano / vigilar |
| **Podado** | `#5C6BC0` índigo | ✂ | 1 | Manejo (poda) ya realizado | → recuperándose |
| **Monitoreo pendiente** | `#9E9E9E` gris | ◷ | 1 | Sin visita en el ciclo | → cualquiera al monitorear |
| **Sano** | `#2E7D32` verde | ✓ | 0 | Sin novedades | → vigilar |

**Reglas visuales / semáforo**
- El color del punto = color del estado actual. "Rojo manda": en cualquier vista agregada, prevalece el estado de mayor prioridad.
- La **prioridad** ordena el panel de alertas y permite agrupar (crítico + intervención = "alertas").
- Filtros: por estado (mostrar/ocultar desde la leyenda), por presencia de **quintral**, y conmutador **color por estado / por zona**.
- Estados terminales positivos (sano) en verde; negativos (crítico/intervención) en cálidos; de manejo (podado/recuperándose) en fríos para distinguirlos de las alertas.

**Máquina de estados (resumen)**

```
monitoreo_pendiente ──monitorear──▶ {sano | vigilar | intervencion | critico}
sano ⇄ vigilar ──agrava──▶ intervencion ──agrava──▶ critico
intervencion | critico ──poda sanitaria──▶ podado ──rebrote──▶ recuperandose ──▶ sano
```

---

## 2. Capa de monitoreo operacional

El monitoreo es un **evento fechado** sobre un árbol (o sector). El estado del árbol es siempre el del último evento. El "quintral" es un `tipo` de monitoreo, no una entidad aparte.

**Estructura de datos (alineada con `16_DESARROLLO/03_supabase`)**

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | uuid | Identificador del evento |
| `id_arbol` | uuid | Árbol monitoreado |
| `fecha` | timestamptz | Fecha/hora del evento |
| `tipo` | texto | `vigor` · `quintral` · `fitosanitario` · `poda` · `riego` |
| `severidad` | 0–5 | Escala de severidad |
| `observacion` | texto | Nota del técnico |
| `foto_url` | texto | Evidencia fotográfica |
| `id_usuario` | uuid | Técnico responsable |
| `geom` | point | Hereda la ubicación del árbol |

Al guardar un monitoreo se ejecutan dos efectos: (1) se inserta el evento en `monitoreo`; (2) se actualiza `arbol.estado` y `arbol.ultimo_monitoreo`. El historial se reconstruye consultando los eventos por árbol en orden descendente (vista `v_historial_arbol`).

**Capacidades** (ya operativas en el dashboard, en memoria): registrar monitoreo, cambiar estado, ingresar observación, asociar fotografía, guardar historial, registrar técnico y fecha.

**Flujo UX de registro**
1. Seleccionar árbol (mapa o QR) → se abre la ficha.
2. Botón **＋ Registrar monitoreo** → formulario.
3. Elegir estado, tipo, severidad, observación, técnico, fecha, foto.
4. Guardar → el mapa **recolorea el árbol al instante**, se actualizan KPIs, leyenda y alertas, y el evento entra al historial.

**Experiencia móvil:** formulario de una columna, campos grandes, estado por botones, cámara nativa para la foto, fecha por defecto = hoy. Pensado para usarse con una mano en terreno.

---

## 3. Simulación operacional realista

Para demostrar el comportamiento real se generó una capa de monitoreo simulada sobre los 504 olivos (`...DATA_monitoreo_simulado_v01.json`), con distribución verosímil y un **sector problemático concentrado** (esquina NE, coincidente con la zona de bajo vigor):

| Estado | N.º olivos |
|---|---|
| Crítico | 10 |
| Intervención (quintral) | 24 |
| Vigilar | 18 |
| Podado | 26 |
| Recuperándose | 16 |
| Monitoreo pendiente | 58 |
| Sano | 352 |

39 árboles con **quintral**, agrupados en el sector NE para mostrar un foco real. Cada árbol monitoreado tiene 1–3 eventos de historial con fecha, técnico, tipo, severidad y observación. Esto permite ver el dashboard "como se verá en operación" sin datos reales aún.

---

## 4. Evolución del mapa Leaflet (v01 → v02)

| Capacidad | v01 (demo) | v02 (operacional) |
|---|---|---|
| Color de puntos | Por zona de manejo | **Dinámico por estado** (conmutable a zona) |
| Filtros | — | Por estado (leyenda), por quintral, reset |
| Leyenda | Estática por zona | **Operacional**: estados + conteo + clic para ocultar |
| Popup | Atributos básicos | Enlace a **ficha operacional** completa |
| Panel lateral | — | **Contextual**: resumen / ficha / formulario |
| Tarjetas KPI | Fijas | **Dinámicas** (se recalculan al monitorear) |
| Historial | — | Resumido en la ficha |
| QR | — | **Generado en vivo** por árbol |
| Registro | — | **Formulario funcional** (en memoria) |
| Alertas | — | Lista priorizada, clic → vuela al árbol |

**Wireframe textual**

```
┌───────────────────────────────────────────────────────────┐
│ 🌿 BRUZZONE IA · Dashboard Operacional · Los Loros   [badge]│
├───────────────────────────────────────────────────────────┤
│ [Olivos][Monitoreados][Alertas][Críticos][Interv.][Pend.]  │  KPIs dinámicos
├───────────────────────────────────────────────────────────┤
│ Color: (Por estado)(Por zona)   ·   [Solo quintral][Ver todo]│ toolbar
├──────────────────────────────────────────┬────────────────┤
│                                            │ 📋 Resumen      │
│              MAPA LEAFLET                  │  Alertas (34)   │
│   · 504 olivos coloreados por estado       │  ▸ LL-OLI-0123  │
│   · perímetro predial                      │  ▸ LL-OLI-0048  │
│   · control de capas (sat/osm/perímetro)   │   …             │
│                              [Leyenda ▥]   │ (o ficha árbol) │
└──────────────────────────────────────────┴────────────────┘
```

---

## 5. Popup / ficha operacional del árbol

Dos niveles: **popup rápido** (en el mapa) y **ficha completa** (panel lateral).

**Popup rápido:** código, estado (pill), zona, NDVI, rend. 2020, última visita, técnico, enlace "Ver ficha operacional →".

**Ficha operacional (panel):**
- Encabezado: código + pill de estado.
- Atributos: zona y clase de vigor, NDVI medio/actual, rendimiento 2019/2020, última visita, técnico, quintral sí/no.
- **QR del árbol** (imagen + URL `app.bruzzoneia.cl/qr/LL-OLI-####`).
- **Fotografías** (placeholder en demo; en operación, las del monitoreo).
- **Historial** cronológico con pill de estado, observación y técnico.
- Botones: **＋ Registrar monitoreo** y **← Volver al resumen**.

---

## 6. Arquitectura QR operacional

Flujo completo: **ESCANEAR → IDENTIFICAR → VISUALIZAR → MONITOREAR → GUARDAR → ACTUALIZAR MAPA.**

| Paso | Qué ocurre | Detalle técnico |
|---|---|---|
| Escanear | Cámara del teléfono lee el QR del árbol/sector | QR codifica `app.bruzzoneia.cl/qr/{codigo}` |
| Identificar | La URL resuelve el árbol por su código | Ruta `/qr/:codigo` → consulta por `codigo` |
| Visualizar | Se abre la ficha operacional móvil | Lectura pública (RLS `select using(true)`) |
| Monitorear | Operador registra estado + foto + nota | Formulario móvil |
| Guardar | Se inserta el evento y se actualiza el estado | RPC `registrar_monitoreo` (security definer) |
| Actualizar mapa | El dashboard refleja el nuevo estado | Refetch / realtime de `arbol_geojson` |

**Permisos y experiencias**
- **Operador (autenticado):** ve la ficha y **puede registrar** monitoreo. Botón de registro visible.
- **Cliente (sin login o rol cliente):** ve la ficha en modo **solo lectura** (estado, historial, trazabilidad). Sin botón de registro.
- **Sincronización futura:** registro offline en cola local y envío al recuperar señal; al guardar en servidor, el mapa se actualiza por *refetch* o Supabase Realtime.

---

## 9. Demo comercial operacional (≤ 3 minutos)

Objetivo: que un agricultor entienda el valor en menos de 3 minutos.

1. **El mapa (0:20).** "Este es su campo: 504 olivos, cada uno georreferenciado." Mostrar el predio completo coloreado por estado.
2. **Un árbol (0:40).** Clic en un olivo → ficha: NDVI, rendimiento histórico, estado, técnico, última visita. "Cada árbol tiene su historia."
3. **El QR (0:30).** Mostrar el QR de la ficha. "En terreno, su operador escanea esto y ve y registra todo desde el teléfono."
4. **El monitoreo (0:40).** Registrar un monitoreo en vivo (ej. cambiar a *intervención* por quintral) → el árbol se pone naranja al instante. "Lo que pasa en el campo se ve aquí al segundo."
5. **Los estados y alertas (0:30).** Filtrar "solo con quintral" y mostrar el foco NE. "El sistema le dice dónde está el problema y lo prioriza."
6. **Cierre (0:20).** "Vea, ubique y demuestre el estado de cada árbol. Eso es BRUZZONE IA."

Guion respaldado por el dashboard `v02`, que ya permite ejecutar los pasos 1–5 en vivo.

---

## 10. Roadmap operacional inmediato

**Construir ahora (esta iteración, ya hecho o inmediato)**
- Dashboard operacional con estados dinámicos, filtros, ficha, historial, QR y registro en memoria. ✔
- Catálogo de estados, RPC `arbol_geojson` y `registrar_monitoreo`, RLS base. ✔ (SQL listo)
- Capa de monitoreo simulada para demo. ✔

**Siguiente (corto plazo)**
- Conectar el dashboard a Supabase en vivo (reemplazar datos embebidos por `fetch`/RPC).
- Autenticación de operadores; modo cliente solo-lectura.
- Captura de fotografía real en el formulario (subida a storage).
- Ruta `/qr/:codigo` servida desde la web.

**Dejar para después**
- Supabase Realtime (actualización push del mapa).
- Modo offline con cola de sincronización.
- App móvil dedicada / PWA instalable.

**NO construir todavía**
- IA de detección automática de quintral (YOLO): primero acumular fotos etiquetadas del monitoreo manual.
- Modelo predictivo de rendimiento en producción.
- Multipredio masivo y panel multicliente complejo.

**Criterio:** priorizar experiencia operacional, velocidad y capacidad de demostración real sobre completitud técnica.

---
*BRUZZONE IA · Fase Operacional MVP · Dashboard territorial vivo.*
