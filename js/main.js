const rupiah = value => new Intl.NumberFormat("id-ID",{style:"currency",currency:"IDR",maximumFractionDigits:0}).format(value);
const grid = document.getElementById("serviceGrid");
const dialog = document.getElementById("serviceDialog");
const dialogContent = document.getElementById("dialogContent");
let selectedService = null;

function renderServices(){
  grid.innerHTML = SERVICES.map((service,index)=>`
    <article class="service-card">
      <div class="service-top"><span class="service-icon">${service.icon}</span><span class="service-number">SERVICE 0${index+1}</span></div>
      <h3>${service.name}</h3><p>${service.short}</p>
      <div class="service-bottom"><span class="service-price"><small>Mulai dari</small>${rupiah(service.price)}</span>
      <button class="service-detail-link" data-service="${service.id}">Detail layanan ↗</button></div>
    </article>`).join("");
}
function openService(id){
  selectedService = SERVICES.find(item=>item.id===id);
  if(!selectedService) return;
  dialogContent.innerHTML = `<h2>${selectedService.name}</h2><p>${selectedService.description}</p><ul>${selectedService.features.map(feature=>`<li>${feature}</li>`).join("")}</ul><p><b>Estimasi:</b> ${selectedService.duration}</p><div class="dialog-price">${rupiah(selectedService.price)}</div>`;
  dialog.showModal();
}
grid.addEventListener("click",event=>{
  const button=event.target.closest("[data-service]");
  if(button) openService(button.dataset.service);
});
document.getElementById("dialogClose").addEventListener("click",()=>dialog.close());
document.getElementById("orderButton").addEventListener("click",()=>{
  if(!selectedService) return;
  const params=new URLSearchParams({service:selectedService.id});
  window.location.href=`checkout.html?${params.toString()}`;
});
const menuToggle=document.getElementById("menuToggle");
const mainNav=document.getElementById("mainNav");
menuToggle.addEventListener("click",()=>{
  const open=mainNav.classList.toggle("open");
  menuToggle.setAttribute("aria-expanded",String(open));
});
mainNav.addEventListener("click",event=>{
  if(event.target.closest("a")){mainNav.classList.remove("open");menuToggle.setAttribute("aria-expanded","false");}
});
document.getElementById("year").textContent=new Date().getFullYear();
renderServices();
