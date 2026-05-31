# Integración de IA Futura — BRUZZONE IA

**v01 · 2026-05-29.** Cómo se incorporará la inteligencia artificial al ecosistema territorial, con prioridades realistas. La IA **organiza y acelera**; el criterio profesional **valida**. Nada crítico se automatiza sin validación humana.

## Componentes y cómo se integran

| Componente | Qué hará | Datasets necesarios | Madurez |
|---|---|---|---|
| **Claude (API/agentes)** | Estructurar observaciones, redactar reportes, orquestar flujos | Datos de monitoreo + plantillas | Disponible hoy (asistido) |
| **Visión computacional (YOLO)** | Detectar quintral y contar objetos en imágenes | Fotos etiquetadas (quintral/copa/daño) | Requiere dataset etiquetado |
| **Predicción NDVI → rendimiento** | Estimar producción desde índices + terreno | Series NDVI + rendimiento histórico (ya existe, R²=0,74) | Validado; falta productizar |
| **Alertas IA** | Avisar focos/caídas de vigor automáticamente | Series temporales + umbrales | Tras volumen de datos |
| **Recomendaciones** | Sugerir manejo diferencial por zona | Histórico + reglas agronómicas | Media; siempre con validación |
| **Automatización agrícola** | Disparar tareas/reportes sin intervención | Flujos definidos (n8n/Make) | Incremental |
| **Agentes IA** | Asistentes que consultan datos y responden | Acceso a BD + contexto del predio | Futuro |
| **Análisis territorial** | Patrones espaciales, zonas de riesgo | GIS + monitoreo acumulado | Media |

## Arquitectura futura

- **Captura** (app/QR/dron) → **Supabase/PostGIS** (datos) → **capa IA** (Colab/servicio para YOLO; Claude API para texto y orquestación) → **dashboard** (resultados) → **alertas** (WhatsApp/correo).
- Los resultados de IA se escriben como **monitoreos o atributos derivados** (nunca UPDATE directo a `arbol`); el agrónomo valida antes de publicar lo crítico.
- Datasets se versionan en `06_DATASETS` (raw → procesado → etiquetado → exportes) y `04_IA`.

## Prioridades reales (orden)

1. **Reportes automáticos con Claude** (alto valor, bajo riesgo) — ya viable.
2. **Sincronización captura→dashboard y alertas** — núcleo operativo.
3. **Acumular fotos etiquetadas** durante el monitoreo manual — habilita YOLO.
4. **YOLO de quintral** cuando haya dataset suficiente y validado.
5. **Predicción de rendimiento en producción** como capa premium.
6. **Recomendaciones y agentes** al final, sobre datos maduros.

**No construir todavía:** detección automática sin dataset, recomendaciones de riego automáticas, o cualquier automatización de decisiones agronómicas críticas sin validación. Primero datos y validación; luego automatización.
