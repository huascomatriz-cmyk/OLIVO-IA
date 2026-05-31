# 🌿 BRUZZONE IA — Repositorio Maestro del Ecosistema

Ecosistema metodológico de servicios inteligentes que integra **trabajo humano + inteligencia artificial + plataformas territoriales** para transformar procesos agrícolas y operacionales en sistemas **trazables, visuales, automatizados y escalables**.

> Principio operativo: **el humano ejecuta · la IA organiza · la metodología estandariza · el dashboard controla · el ecosistema aprende y escala.**

## Empresa y modelo operacional

BRUZZONE IA opera como **empresa ecosistémica de servicios territoriales inteligentes**. Documentación empresarial:

- `00_ADMINISTRACION_EMPRESA/` — estructura empresarial (15 unidades + mapeo), modelo SaaS y multicliente, roadmap de 6 etapas.
- `01_DIRECCION_ESTRATEGICA/` — modelo operacional (flujos), metodología de 6 fases, roles e integración de IA futura.
- `13_CLIENTES_Y_PROYECTOS/` — estrategia comercial, postventa inteligente y plantilla de proyecto cliente.

Estado: **MVP territorial LIVE del Olivar Los Loros** (504 olivos) operativo — dashboard, QR, monitoreo, Supabase, branding y sistema visual consolidados.

## Estructura oficial de carpetas

| Carpeta | Propósito |
|---|---|
| `00_ADMINISTRACION_EMPRESA` | Administración, modelo SaaS, estructura empresarial, roadmap |
| `01_DIRECCION_ESTRATEGICA` | Modelo operacional, metodología, roles, IA futura |
| `01_METODOLOGIA` | Manual maestro, SOPs, plantillas, gobernanza y referencias científicas |
| `02_PROYECTOS` | Un directorio por proyecto/predio (usar `_plantilla_proyecto`) |
| `03_GIS` | Proyectos QGIS, capas base, GeoJSON, ortomosaicos, análisis espacial |
| `04_IA` | Prompts, modelos de visión (YOLO), notebooks, pipelines, inferencias |
| `05_DASHBOARDS` | Power BI, Looker Studio, app web, mapas interactivos |
| `06_DATASETS` | Datos raw → procesado → etiquetado → exportes + diccionario de datos |
| `07_MONITOREO` | Olivos, fitosanitario, riego/suelo, registros de campo |
| `08_QUINTRAL` | Detección, seguimiento, tratamientos y evidencia del quintral |
| `09_DASHBOARDS_Y_PLATAFORMA` | Dashboard LIVE/DEMO, mapas interactivos, documentación operacional |
| `09_DRONES` | Planes de vuelo, capturas RAW, proyectos Pix4D, productos derivados |
| `10_REPORTES` | Técnicos, ejecutivos, postventa + plantillas |
| `11_CLIENTES` | Fichas (CRM), contratos, seguimiento postventa |
| `12_AUTOMATIZACIONES` | n8n/Make, scripts, WhatsApp API, agentes Claude |
| `13_CLIENTES_Y_PROYECTOS` | CRM, comercial, postventa, plantilla de proyecto cliente |
| `13_RRSS` | Calendario, contenido y publicado |
| `14_BRANDING` | Logos, favicon, sistema de diseño (`assets/bruzzone-ds.css`), manual de marca |
| `15_LABORATORIO_VIVO` | Experimentos, bitácoras, resultados, transferencia tecnológica |
| `16_DESARROLLO` | Frontend operacional, web, Supabase, infra/DevOps |
| `17_CAPACITACION` | Cursos, material, certificaciones |
| `18_ADMINISTRACION` | Finanzas, legal, modelo de negocio |

> El organigrama lógico de 15 unidades empresariales y su mapeo a estas carpetas está en `00_ADMINISTRACION_EMPRESA/2026-05-29_LL_EMP_estructura_empresarial_v01.md`.

## Accesos rápidos

- **Centro de Demo:** `16_DESARROLLO/frontend/index.html`
- **Dashboard LIVE/DEMO:** `09_DASHBOARDS_Y_PLATAFORMA/03_Mapas_Interactivos/2026-05-29_LL_DASH_leaflet_LIVE_v03.html`
- **Web comercial:** `16_DESARROLLO/web/index.html`
- **Activar Supabase LIVE:** `16_DESARROLLO/03_supabase/2026-05-29_LL_DEV_guia_supabase_live_v01.md`

## Convención de nombres
`AAAA-MM-DD_cliente_predio_tipo_v01.ext` — fechas ISO, sin espacios, versionado explícito.

📄 Documento maestro del ecosistema: `01_METODOLOGIA/01_manual_maestro/`.
**Regla inviolable:** el estado de un árbol cambia solo vía la RPC `registrar_monitoreo`; nunca por UPDATE directo.
