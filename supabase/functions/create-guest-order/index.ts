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
    if (!supabaseUrl || !serviceRoleKey) {
      return json({ error: "Server configuration is incomplete" }, 500);
    }

    const body = await req.json();
    const serviceSlug = String(body.service_slug ?? "").trim();
    const customerName = String(body.customer_name ?? "").trim();
    const customerWhatsapp = String(body.customer_whatsapp ?? "").trim();
    const customerNote = String(body.customer_note ?? "").trim();

    if (!/^[a-z0-9-]{2,80}$/.test(serviceSlug)) return json({ error: "Layanan tidak valid" }, 400);
    if (customerName.length < 1 || customerName.length > 100) return json({ error: "Nama wajib diisi (maksimal 100 karakter)" }, 400);
    if (customerWhatsapp.replace(/[^0-9]/g, "").length < 9 || customerWhatsapp.length > 25) return json({ error: "Nomor WhatsApp tidak valid" }, 400);
    if (customerNote.length > 1000) return json({ error: "Catatan maksimal 1000 karakter" }, 400);

    // Guest checkout currently accepts cash / WhatsApp confirmation only.
    // QRIS remains disabled until official DANA Bisnis integration is configured.
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: service, error: serviceError } = await supabase
      .from("services")
      .select("id")
      .eq("slug", serviceSlug)
      .eq("is_active", true)
      .maybeSingle();

    if (serviceError || !service) return json({ error: "Layanan tidak tersedia" }, 404);

    const { data: order, error: orderError } = await supabase
      .from("guest_orders")
      .insert({
        service_id: service.id,
        customer_name: customerName,
        customer_whatsapp: customerWhatsapp,
        customer_note: customerNote,
        payment_method: "cash",
      })
      .select("order_code, service_name_snapshot, total_amount_idr, payment_method, payment_status, status, created_at")
      .single();

    if (orderError || !order) {
      console.error("Guest order insert failed", orderError?.message);
      return json({ error: "Pesanan belum dapat dibuat. Silakan coba kembali." }, 500);
    }

    return json({ order });
  } catch (_error) {
    return json({ error: "Permintaan tidak dapat diproses" }, 400);
  }
});
