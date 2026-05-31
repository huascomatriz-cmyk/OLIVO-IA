# Plantilla de proyecto cliente — BRUZZONE IA

Copiar esta carpeta y renombrar a `AAAA_cliente_predio` por cada nuevo cliente. Sigue la metodología de 6 fases.

```
_plantilla_proyecto_cliente/
├── 01_diagnostico/   Fase 1: línea base, objetivos, KPIs acordados
├── 02_gis/           Fase 2: perímetro, árboles, zonificación NDVI (KML/GeoJSON)
├── 03_monitoreo/     Fase 3: ciclos de monitoreo, evidencia
├── 04_dashboard/     Fase 4: enlaces/config del dashboard del cliente
├── 05_reportes/      Fases 4–6: reportes técnicos/ejecutivos/postventa
└── 06_contrato/      Administración: contrato, plan, facturación
```

Nomenclatura de archivos: `AAAA-MM-DD_<cliente>_<predio>_<tipo>_v01.ext`.
Datos del predio viven en Supabase (un `cliente` + sus `predio`/`arbol`); esta carpeta guarda documentos y entregables.
