// =====================================================================
// BRUZZONE IA · MVP · API wrapper (Supabase RPC + vistas)
// 16_DESARROLLO/frontend/lib/api.js
// Una función por endpoint. El frontend SOLO usa estas funciones.
// Regla de oro: el estado del árbol se cambia EXCLUSIVAMENTE vía registrar_monitoreo.
// =====================================================================
import { supabase, supabaseListo, ID_PREDIO } from "./supabaseClient.js";

/** Árboles de un predio como FeatureCollection GeoJSON (mismo formato que el demo embebido). */
export async function getArboles(idPredio = ID_PREDIO) {
  if (!supabaseListo()) throw new Error("Supabase no configurado");
  const { data, error } = await supabase.rpc("arbol_geojson", { p_predio: idPredio });
  if (error) throw error;
  // data es el FeatureCollection. Validación mínima:
  if (!data || data.type !== "FeatureCollection" || !Array.isArray(data.features)) {
    throw new Error("Respuesta inválida de arbol_geojson");
  }
  return data;
}

/**
 * Registra un monitoreo y actualiza el estado del árbol (vía RPC security definer).
 * payload: { codigo, estado, tipo, severidad, observacion, fotoUrl? }
 * Requiere usuario autenticado.
 */
export async function registrarMonitoreo(payload) {
  if (!supabaseListo()) throw new Error("Supabase no configurado");
  const { data, error } = await supabase.rpc("registrar_monitoreo", {
    p_codigo: payload.codigo,
    p_estado: payload.estado,
    p_tipo: payload.tipo,
    p_severidad: payload.severidad ?? 0,
    p_observacion: payload.observacion ?? "",
    p_foto_url: payload.fotoUrl ?? null,
  });
  if (error) throw error;
  return data; // uuid del monitoreo creado
}

/** Catálogo de estados (etiqueta/color/ícono/prioridad). Cachear en cliente. */
export async function getEstadosCatalogo() {
  if (!supabaseListo()) throw new Error("Supabase no configurado");
  const { data, error } = await supabase
    .from("estado_catalogo")
    .select("estado,etiqueta,color,icono,prioridad")
    .order("prioridad", { ascending: false });
  if (error) throw error;
  return data;
}

/** Historial de monitoreos de un árbol (requiere autenticación). */
export async function getHistorialArbol(codigo) {
  if (!supabaseListo()) throw new Error("Supabase no configurado");
  const { data, error } = await supabase
    .from("v_historial_arbol")
    .select("*")
    .eq("codigo", codigo)
    .order("fecha", { ascending: false });
  if (error) throw error;
  return data;
}

/** KPIs agregados de un predio. */
export async function getKpisPredio(idPredio = ID_PREDIO) {
  if (!supabaseListo()) throw new Error("Supabase no configurado");
  const { data, error } = await supabase
    .from("v_kpi_predio")
    .select("*")
    .eq("id_predio", idPredio)
    .single();
  if (error) throw error;
  return data;
}

/** Sesión actual (para distinguir operador autenticado vs cliente anónimo). */
export async function getSesion() {
  if (!supabaseListo()) return null;
  const { data } = await supabase.auth.getSession();
  return data?.session ?? null;
}
