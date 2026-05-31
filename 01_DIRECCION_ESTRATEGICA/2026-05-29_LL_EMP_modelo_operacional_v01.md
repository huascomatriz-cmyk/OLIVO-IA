# Modelo Operacional y Metodología — BRUZZONE IA

**v01 · 2026-05-29.** Cómo opera BRUZZONE IA en terreno: flujos, metodología de servicio y roles. El principio rector: **el humano ejecuta, la IA organiza, la metodología estandariza, el dashboard controla, el ecosistema aprende y escala.**

## 1. Modelo operacional (flujos)

Cómo **entra** un cliente y cómo **permanece** dentro del ecosistema.

| Flujo | Recorrido | Resultado |
|---|---|---|
| **Cliente** | Contacto → demo → diagnóstico → propuesta → contrato (implementación + suscripción) | Cliente activo en el ecosistema |
| **Predial** | Levantamiento del predio → perímetro + árboles en GIS → zonificación por vigor | Predio digitalizado (base de datos) |
| **Monitoreo** | Operador recorre sectores → registra estado/quintral/foto en terreno | Eventos fechados por árbol |
| **Dashboard** | Datos → mapa + KPIs + semáforo se actualizan | Control visual del predio |
| **QR** | Escanear placa → ficha del árbol/sector → consultar o registrar | Trazabilidad en terreno |
| **Postventa** | Reportes periódicos + alertas + seguimiento | Hábito y recurrencia |
| **Reportes** | IA redacta borrador → agrónomo valida → se envía | Entregable periódico al cliente |
| **Soporte** | Ticket territorial → diagnóstico → resolución | Confianza y continuidad |
| **Capacitación** | Formación del equipo del cliente en la metodología | Adopción y autonomía parcial |

**Cómo entra y permanece:** entra por una **demo** que muestra valor en 3 minutos y un **piloto** de bajo riesgo; permanece porque el **dashboard, la trazabilidad y los reportes periódicos** se vuelven indispensables (el histórico hace costoso salir). La permanencia es el objetivo del negocio, no la venta puntual.

## 2. Metodología oficial de servicios (6 fases)

| Fase | Nombre | Entregables | Tiempo | Responsable | Tecnologías | Valor generado |
|---|---|---|---|---|---|---|
| **1** | Diagnóstico territorial | Informe de línea base, objetivos y KPIs | 1–2 sem | Director + Agrónomo | Reunión, datos previos, GIS | Claridad y alcance acordado |
| **2** | Georreferenciación | Predio + árboles en GIS, zonificación NDVI | 2–3 sem | Especialista GIS/Dron | QGIS, dron+Pix4D, KML/GeoJSON | Activo digital del predio |
| **3** | Monitoreo territorial | Primer ciclo de monitoreo, estados, evidencia | 1–2 sem | Operador + Agrónomo | App/QR, Supabase | Datos reales de terreno |
| **4** | Dashboard operacional | Dashboard + mapa + QR + reporte | 1–2 sem | Desarrollador + GIS | Leaflet, Looker, Supabase | Control y trazabilidad visibles |
| **5** | Automatización + IA | Alertas, reportes automáticos, detección | continuo | Especialista IA | Claude API, YOLO, n8n | Eficiencia y escalamiento |
| **6** | Postventa territorial | Reportes periódicos, alertas, seguimiento | recurrente | Coordinador + Agrónomo | Dashboard, WhatsApp | Recurrencia y fidelización |

Cada fase valida antes de avanzar; las fases 1–4 forman la **implementación** (one-time) y las fases 5–6 la **recurrencia** (suscripción).

## 5. Roles operacionales

| Rol | Responsabilidad | Herramientas | Acceso al sistema | En el flujo |
|---|---|---|---|---|
| **A. Director territorial** | Estrategia, clientes, escalamiento | Dirección, CRM | Admin | Cliente, contrato |
| **B. Agrónomo de precisión** | Criterio agronómico, valida diagnósticos y reportes | Dashboard, reportes | Validador | Monitoreo, reportes |
| **C. Operador de monitoreo** | Captura en terreno, ejecuta tareas | App/QR móvil | Autenticado (escribe vía RPC) | Monitoreo, QR |
| **D. Especialista GIS** | Levantamiento y procesamiento espacial | QGIS, dron, Pix4D | Edición de capas | Georreferenciación |
| **E. Especialista IA** | Modelos, pipelines, automatizaciones | Colab, YOLO, Claude API | Backend / datos | Automatización + IA |
| **F. Cliente agrícola** | Consulta su predio, decide manejo | Dashboard, QR (lectura) | Cliente (solo lectura) | Dashboard, postventa |
| **G. Asociación agrícola** | Agrupa productores, negocia condiciones | Panel multipredio | Cliente multi-predio | Multicliente |

**Regla de acceso:** solo roles autenticados (operador/agrónomo) registran monitoreos, y siempre vía la RPC `registrar_monitoreo`. El cliente ve; no edita el estado de los árboles.

Integración de IA futura en `2026-05-29_LL_EMP_integracion_ia_futura_v01.md`. Comercial y postventa en `../13_CLIENTES_Y_PROYECTOS/`.
