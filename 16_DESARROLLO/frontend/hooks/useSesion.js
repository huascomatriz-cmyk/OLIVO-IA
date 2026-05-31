// hooks/useSesion.js — expone la sesión Supabase (operador autenticado) para la UI.
import { useEffect, useState } from "react";
import { getSesion } from "../lib/api.js";
export function useSesion(){
  const [sesion,setSesion]=useState(null);
  useEffect(()=>{ getSesion().then(setSesion); },[]);
  return sesion;
}
