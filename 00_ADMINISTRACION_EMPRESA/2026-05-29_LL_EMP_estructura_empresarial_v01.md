# Estructura Empresarial Oficial — BRUZZONE IA

**v01 · 2026-05-29.** Unidades de la empresa ecosistémica de servicios territoriales inteligentes, qué hace cada una, qué datos maneja, qué genera y cómo se conecta. Incluye el mapeo a las carpetas de trabajo ya existentes (para no romper el sistema vivo).

## Las 15 unidades

| # | Unidad | Qué hace | Datos que maneja | Qué genera | Se conecta con |
|---|---|---|---|---|---|
| 00 | **Administración empresa** | Finanzas, legal, contratos, modelo de negocio | Contratos, facturación, costos | Modelo SaaS, planes, reportes financieros | Dirección, Clientes |
| 01 | **Dirección estratégica** | Visión, metodología, escalamiento, alianzas | KPIs de negocio, roadmap | Modelo operacional, metodología, estrategia | Todas |
| 02 | **Olivicultura de precisión** | Criterio agronómico, manejo diferencial | NDVI, rendimiento, zonas de manejo | Diagnósticos, recomendaciones validadas | GIS, Monitoreo, IA |
| 03 | **Monitoreo de quintral** | Detección, seguimiento y control del quintral | Monitoreos, severidad, evidencia | Estados de árbol, alertas | Dashboard, Operadores |
| 04 | **GIS territorial** | Capa espacial: predios, cuarteles, árboles | Geometrías, KML/GeoJSON, capas | Mapas, GeoJSON operacional | Dashboard, Dron, IA |
| 05 | **Dron y teledetección** | Levantamiento aéreo, ortomosaicos, índices | Vuelos, ortos, NDVI/Kc/LAI | Capas raster, línea base | GIS, IA |
| 06 | **Inventario y gestión** | Activos, insumos, herramientas, tareas | Stock, tareas, equipos | Estado operativo, planificación | Operadores, Dashboard |
| 07 | **Inteligencia artificial** | Modelos, prompts, pipelines, análisis | Datasets, modelos, inferencias | Predicciones, clasificaciones, reportes IA | Visión, GIS, Dashboard |
| 08 | **Visión computacional (YOLO)** | Detección automática (quintral, conteo) | Imágenes etiquetadas, pesos | Detecciones automáticas | IA, Monitoreo, Dron |
| 09 | **Dashboards y plataforma** | Frontend, dashboard, QR, web, app | Vistas, GeoJSON live, sesiones | Dashboard LIVE/DEMO, QR, web | Supabase, GIS, Clientes |
| 10 | **Laboratorio vivo** | Experimentación y validación de métodos | Ensayos, bitácoras, resultados | Métodos validados, evidencia científica | Olivicultura, IA |
| 11 | **Transferencia tecnológica** | Capacitación y traspaso metodológico | Material, cursos, certificaciones | Equipos formados, clientes capacitados | Clientes, Dirección |
| 12 | **Marketing, branding y RRSS** | Marca, contenido, captación | Branding, calendario, leads | Landing, RRSS, material comercial | Comercial, Clientes |
| 13 | **Clientes y proyectos** | CRM, contratos, postventa, pilotos | Fichas, contratos, tickets | Pipeline, postventa, recurrencia | Administración, Dashboard |
| 14 | **Master data** | Gobernanza y diccionario de datos único | Esquemas, diccionario, IDs | Estándares, calidad de datos | Todas |

## Mapeo a carpetas de trabajo existentes

La organización física actual ya cubre la mayoría de unidades; **no se renombran** para no romper rutas del sistema vivo. Equivalencias:

| Unidad empresarial | Carpeta(s) de trabajo actual |
|---|---|
| 00 Administración | `00_ADMINISTRACION_EMPRESA/` (nueva) · `18_ADMINISTRACION/` |
| 01 Dirección estratégica | `01_DIRECCION_ESTRATEGICA/` (nueva) · `01_METODOLOGIA/` |
| 02 Olivicultura precisión | `01_METODOLOGIA/05_metodologia_referencias_cientificas` · `07_MONITOREO/01_olivos` |
| 03 Monitoreo quintral | `08_QUINTRAL/` · `07_MONITOREO/02_fitosanitario` |
| 04 GIS territorial | `03_GIS/` |
| 05 Dron y teledetección | `09_DRONES/` · rasters NDVI/Kc/LAI en metodología |
| 06 Inventario y gestión | `06_DATASETS/` · tablas `tarea`/`activo` |
| 07 IA | `04_IA/` |
| 08 Visión YOLO | `04_IA/02_modelos_vision_yolo` |
| 09 Dashboards y plataforma | `09_DASHBOARDS_Y_PLATAFORMA/` · `16_DESARROLLO/` |
| 10 Laboratorio vivo | `15_LABORATORIO_VIVO/` |
| 11 Transferencia | `17_CAPACITACION/` |
| 12 Marketing/branding | `14_BRANDING/` · `13_RRSS/` |
| 13 Clientes y proyectos | `13_CLIENTES_Y_PROYECTOS/` (nueva) · `11_CLIENTES/` · `02_PROYECTOS/` |
| 14 Master data | `06_DATASETS/05_diccionario_datos` · esquema Supabase |

> Recomendación: tratar la tabla de 15 unidades como el **organigrama lógico** de la empresa, y las carpetas como su implementación física. Al escalar, consolidar gradualmente hacia la numeración canónica.

## Roadmap empresarial (6 etapas)

| Etapa | Nombre | Foco | Hito de salida |
|---|---|---|---|
| **1** | Los Loros MVP | Sistema territorial funcional | Dashboard + QR + monitoreo operativos (✔ logrado) |
| **2** | Pilotos agrícolas | 2–3 olivares reales | Implementación + suscripción cobradas |
| **3** | Asociaciones agrícolas | Grupos de productores | Contrato con una asociación; varios predios |
| **4** | Plataforma multicliente | SaaS con RLS por cliente | Login por cliente, paneles separados, facturación recurrente |
| **5** | IA territorial predictiva | Predicción y automatización | Modelo NDVI→rendimiento + detección quintral en producción |
| **6** | Escalamiento regional | Multirubro y territorio | Red de operadores; expansión a otras zonas/cultivos |

Detalle de modelo operacional, metodología y roles en `../01_DIRECCION_ESTRATEGICA/`. SaaS y multicliente en `2026-05-29_LL_EMP_modelo_saas_multicliente_v01.md`.
