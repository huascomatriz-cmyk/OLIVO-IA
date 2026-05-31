# Modelo SaaS Agrícola y Arquitectura Multicliente — BRUZZONE IA

**v01 · 2026-05-29.** Cómo se cobra y cómo escala técnicamente de un predio a una plataforma territorial.

## 1. Estructura de ingresos

| Concepto | Tipo de cobro | Escala por | Notas |
|---|---|---|---|
| **Implementación inicial** | Único (one-time) | predio / hectárea | Levantamiento GIS, carga de árboles, zonificación, instalación QR |
| **Suscripción plataforma** | Mensual / anual | n.º de árboles o hectáreas | Acceso a dashboard, mapa, QR y trazabilidad |
| **Monitoreo periódico** | Mensual / por visita | n.º de visitas / superficie | Recorridos, detección de quintral, reportes |
| **Almacenamiento histórico** | Anual | volumen de datos / años | Conservación de la trazabilidad y series temporales |
| **Mantenimiento dashboard** | Anual | incluido / por plan | Soporte, actualizaciones, disponibilidad |
| **Análisis IA a demanda** | Por servicio | por lote / por análisis | Conteos, detección, diagnósticos puntuales |
| **Capacitación / transferencia** | Por servicio | por jornada | Formación de equipos del cliente |

**Regla:** lo que da valor recurrente (dashboard, monitoreo, trazabilidad) se cobra como **suscripción**; lo que se hace una vez (levantamiento) es **one-time**; lo que crece con el predio escala por **árboles/hectáreas**.

## 2. Planes

| Plan | Para quién | Incluye | Modelo |
|---|---|---|---|
| **Trazabilidad** (base) | Productor pequeño | Implementación + dashboard + mapa + QR + 1 monitoreo/temporada + reporte | One-time + suscripción anual |
| **Pro** (recomendado) | Productor mediano | Trazabilidad + monitoreos periódicos de quintral/vigor + alertas + reportes | One-time + suscripción mensual |
| **Territorial** | Asociación / gran predio | Pro multipredio + paneles por predio + IA a demanda + soporte prioritario | One-time + suscripción por superficie |

Precios iniciales sugeridos: fee de implementación por predio + suscripción escalonada por tramos de n.º de árboles (p. ej. 0–500, 501–2.000, 2.000+). Empezar con un valor de entrada accesible para validar disposición a pagar en pilotos.

## 3. Arquitectura multicliente

Transición: **Los Loros → múltiples predios → múltiples agricultores → asociaciones → territorios completos.**

| Dimensión | MVP (hoy) | Multicliente (objetivo) |
|---|---|---|
| Datos | 1 predio (UUID fijo) | N predios por cliente; filtrado por `id_cliente` |
| Acceso | operador único / demo | login por cliente; cada cliente ve solo sus predios |
| Paneles | 1 dashboard | panel por cliente/predio + panel interno BRUZZONE |
| Permisos | RLS lectura pública + escritura autenticada | RLS por `id_cliente` (aislamiento entre clientes) |
| Infra | Supabase free | Supabase escalado + CDN (Vercel/Cloudflare) |

**Separación de clientes (cómo):**
- Toda fila relevante (`predio`, `arbol`, `monitoreo`, `tarea`) cuelga de `cliente` vía `id_cliente`/`id_predio`.
- Políticas RLS por cliente: `using (id_cliente = auth.jwt()->>'cliente_id')` (o tabla puente usuario→cliente). Un usuario solo ve y escribe lo de su cliente.
- El frontend agrega un **selector de predio**; las RPC ya son parametrizadas por predio (`arbol_geojson(p_predio)`), así que la UI no cambia, solo el alcance de datos.
- La asociación agrícola = un "cliente" con varios predios y varios usuarios.

**Costos de infraestructura (orden de magnitud):**
- **Fase pilotos:** Supabase free / Pro bajo, Vercel/Cloudflare free → costo casi nulo.
- **Multicliente:** Supabase Pro (BD + storage de fotos), dominio, posible CDN de imágenes → costo mensual moderado que se cubre con las suscripciones.
- **Escala regional:** dimensionar BD (conexiones, storage histórico) y mover medios a almacenamiento por uso. El costo por cliente baja al crecer (costo marginal decreciente).

**Seguridad:** la regla inviolable se mantiene multicliente — el estado del árbol cambia solo vía `registrar_monitoreo` (security definer); RLS aísla clientes; la `service_role` jamás se expone.

Ver flujos y metodología en `../01_DIRECCION_ESTRATEGICA/2026-05-29_LL_EMP_modelo_operacional_v01.md`.
