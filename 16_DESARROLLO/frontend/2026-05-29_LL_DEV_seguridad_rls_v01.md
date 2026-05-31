# Seguridad y RLS — BRUZZONE IA (corte a vivo)

**v01 · 2026-05-29.** Modelo de permisos del MVP. La defensa real son las políticas RLS; la `anon key` es pública por diseño.

## Roles y accesos

| Recurso | `anon` (público) | `authenticated` (operador/agrónomo) | Cerrado |
|---|:--:|:--:|:--:|
| `arbol` (lectura) | ✅ select | ✅ select | — |
| `arbol` (escritura) | ❌ | ❌ directa | Solo vía RPC `registrar_monitoreo` |
| `estado_catalogo` | ✅ select | ✅ select | — |
| `v_kpi_predio` | ✅ select | ✅ select | — |
| `monitoreo` | ❌ | ✅ select / insert | — |
| `v_historial_arbol` | ❌ | ✅ select | — |
| `cliente`, `predio`, `usuario` | ❌ | ❌ (salvo políticas por cliente) | `service_role` |

## Qué puede leer `anon`
- Árboles del predio (`arbol_geojson`, tabla `arbol`), catálogo de estados y KPIs. Suficiente para el **mapa público** y la **ficha QR sin login**. No expone datos sensibles de clientes ni usuarios.

## Qué puede leer/escribir `authenticated`
- Lee historial y monitoreos; **registra** monitoreos vía RPC. No puede modificar árboles, predios ni clientes directamente.

## Qué queda cerrado
- `cliente`, `predio`, `usuario`: sin políticas públicas. Acceso solo por `service_role` (backend) o políticas por cliente que se definirán al escalar a multicliente.

## Cómo se protege la tabla `arbol`
- RLS activado. Solo política de **SELECT** público. **No existe** política de `UPDATE`/`INSERT`/`DELETE` para `anon` ni `authenticated`.
- El estado se cambia únicamente desde `registrar_monitoreo` (ver abajo). Un cliente malicioso con la anon key **no puede** alterar un árbol.

## Cómo se protege `monitoreo`
- RLS activado. `select` e `insert` solo para `authenticated`. Sin `update`/`delete` para roles de cliente.
- La inserción real ocurre dentro de la RPC, que valida la existencia del árbol y la severidad.

## Cómo funciona `security definer`
- `registrar_monitoreo` y `arbol_geojson` se ejecutan con los privilegios del **dueño** de la función, no del usuario que llama. Así la RPC puede insertar el monitoreo y actualizar `arbol.estado` **aunque el rol del usuario no tenga permiso directo** sobre esas tablas. El usuario solo puede hacer lo que la función permite, y nada más. Es el patrón correcto para exponer una operación controlada sin abrir las tablas.

## Qué JAMÁS debe exponerse en el frontend
- La **`service_role` key** (omnipotente, ignora RLS). Solo en backend/admin.
- Credenciales de la base, cadenas de conexión `postgres://`, secretos de Storage.
- Datos de otros clientes/predios fuera del alcance del usuario.

## Checklist de seguridad mínima
- [ ] RLS **activado** en `arbol`, `monitoreo`, `estado_catalogo` (y en `cliente`/`predio`/`usuario`).
- [ ] Solo políticas de **SELECT** público donde corresponde; ninguna de escritura directa sobre `arbol`.
- [ ] Cambios de estado **solo** vía RPC `security definer`.
- [ ] `service_role` key fuera del frontend y del repositorio.
- [ ] `.env` en `.gitignore`; nunca commitear claves reales.
- [ ] Validación de entrada en la RPC (árbol existe, severidad 0–5).
- [ ] Auth de operadores activada; rol `cliente` en modo solo-lectura.
- [ ] Storage de evidencias con políticas de subida solo para autenticados.
