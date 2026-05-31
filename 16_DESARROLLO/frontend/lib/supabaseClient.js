// =====================================================================
// BRUZZONE IA · MVP · Cliente Supabase
// 16_DESARROLLO/frontend/lib/supabaseClient.js
// Funciona en dos modos:
//   (a) bundler (Vite/Next): import { createClient } from '@supabase/supabase-js'
//   (b) HTML simple: cargar el UMD por CDN y usar window.supabase
// Las credenciales se leen de variables de entorno; nunca se hardcodean.
// =====================================================================

// ID del predio Olivar Los Loros (definido en el seed 02_seed_los_loros.sql)
export const ID_PREDIO = "22222222-2222-2222-2222-222222222222";

// --- Lectura de variables de entorno (tolerante a distintos entornos) ---
function envVar(...names) {
  // Vite (import.meta.env), Next/Node (process.env) o window.__ENV__ para HTML plano
  for (const n of names) {
    try { if (typeof import.meta !== "undefined" && import.meta.env && import.meta.env[n]) return import.meta.env[n]; } catch (_) {}
    try { if (typeof process !== "undefined" && process.env && process.env[n]) return process.env[n]; } catch (_) {}
    try { if (typeof window !== "undefined" && window.__ENV__ && window.__ENV__[n]) return window.__ENV__[n]; } catch (_) {}
  }
  return undefined;
}

export const SUPABASE_URL =
  envVar("VITE_SUPABASE_URL", "NEXT_PUBLIC_SUPABASE_URL", "SUPABASE_URL");
export const SUPABASE_ANON_KEY =
  envVar("VITE_SUPABASE_ANON_KEY", "NEXT_PUBLIC_SUPABASE_ANON_KEY", "SUPABASE_ANON_KEY");

// --- Resolver createClient en bundler o CDN ---
let _createClient;
try {
  // entorno con bundler
  ({ createClient: _createClient } = await import("@supabase/supabase-js"));
} catch (_) {
  // entorno HTML: se asume <script src=".../supabase-js@2"></script> cargado antes
  if (typeof window !== "undefined" && window.supabase) {
    _createClient = window.supabase.createClient;
  }
}

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.warn("[BRUZZONE IA] Falta SUPABASE_URL o SUPABASE_ANON_KEY. Revisa tus variables de entorno (.env).");
}

export const supabase =
  _createClient && SUPABASE_URL && SUPABASE_ANON_KEY
    ? _createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        auth: { persistSession: true, autoRefreshToken: true },
      })
    : null;

export const supabaseListo = () => !!supabase;
