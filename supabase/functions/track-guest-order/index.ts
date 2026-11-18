import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) return json({ error: "Server configuration is incomplete" }, 500);

    const body = await req.json();
    const orderCode = String(body.order_code ?? "").trim().toUpperCase();
    if (!/^DPZ-[0-9]{6}-[A-F0-9]{16}$/.test(orderCode)) {
      return json({ error: "Format ID pesanan tidak valid" }, 400);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: order, error } = await supabase
      .from("guest_orders")
      .select("order_code, service_name_snapshot, total_amount_idr, payment_method, payment_status, status, created_at, updated_at")
      .eq("order_code", orderCode)
      .maybeSingle();

    if (error) {
      console.error("Guest order lookup failed", error.message);
      return json({ error: "Status pesanan belum dapat diperiksa" }, 500);
    }
    if (!order) return json({ error: "Pesanan tidak ditemukan. Periksa kembali ID pesanan." }, 404);

    return json({ order });
  } catch (_error) {
    return json({ error: "Permintaan tidak dapat diproses" }, 400);
  }
});
