// Ganti dengan nomor WhatsApp bisnis setelah nomor final ditentukan.
// Format: kode negara + nomor, tanpa tanda +, spasi, atau strip. Contoh format Indonesia: 6281234567890
const BUSINESS_WHATSAPP = "6281996319627";
const money = value => new Intl.NumberFormat("id-ID",{style:"currency",currency:"IDR",maximumFractionDigits:0}).format(value);
const selectedId = new URLSearchParams(window.location.search).get("service");
const service = SERVICES.find(item=>item.id===selectedId);
const summary = document.getElementById("serviceSummary");
const result = document.getElementById("formResult");
if(!service){
  summary.innerHTML="<p>Layanan tidak ditemukan. Silakan kembali ke halaman layanan.</p>";
  document.getElementById("totalPrice").textContent="-";
  document.querySelector("#checkoutForm button[type=submit]").disabled=true;
}else{
  summary.innerHTML=`<div class="summary-row"><span>${service.name}</span><strong>${money(service.price)}</strong></div><div class="summary-row"><span>Kategori</span><span>${service.category}</span></div>`;
  document.getElementById("totalPrice").textContent=money(service.price);
}
document.getElementById("checkoutForm").addEventListener("submit",event=>{
  event.preventDefault();
  if(!service) return;
  const name=document.getElementById("customerName").value.trim();
  const whatsapp=document.getElementById("customerWhatsapp").value.trim();
  const note=document.getElementById("customerNote").value.trim();
  if(!name || !whatsapp){result.textContent="Lengkapi nama dan nomor WhatsApp terlebih dahulu.";return;}
  const message=[
    "Halo DAPZ DIGITAL, saya ingin memesan layanan.",
    "",
    `Layanan: ${service.name}`,
    `Harga awal: ${money(service.price)}`,
    `Nama: ${name}`,
    `WhatsApp: ${whatsapp}`,
    `Metode pembayaran: Cash (perlu konfirmasi)`,
    `Detail kebutuhan: ${note || "-"}`,
    "",
    "Mohon konfirmasi ketersediaan layanan dan total harga. Terima kasih."
  ].join("\n");
  if(BUSINESS_WHATSAPP==="6280000000000"){
    result.textContent="Nomor WhatsApp bisnis belum diatur. Ganti BUSINESS_WHATSAPP di js/checkout.js sebelum website dipublikasikan.";
    return;
  }
  const url=`https://wa.me/${BUSINESS_WHATSAPP}?text=${encodeURIComponent(message)}`;
  window.open(url,"_blank","noopener,noreferrer");
});
