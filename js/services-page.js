const formatPrice=value=>new Intl.NumberFormat("id-ID",{style:"currency",currency:"IDR",maximumFractionDigits:0}).format(value);
const grid=document.getElementById("serviceGrid"), dialog=document.getElementById("serviceDialog");
const content=document.getElementById("dialogContent");let chosen=null;
grid.innerHTML=SERVICES.map((s,i)=>`<article class="service-card"><div class="service-top"><span class="service-icon">${s.icon}</span><span class="service-number">SERVICE 0${i+1}</span></div><h3>${s.name}</h3><p>${s.short}</p><div class="service-bottom"><span class="service-price"><small>Mulai dari</small>${formatPrice(s.price)}</span><button class="service-detail-link" data-id="${s.id}">Detail layanan ↗</button></div></article>`).join("");
grid.addEventListener("click",e=>{const btn=e.target.closest("[data-id]");if(!btn)return;chosen=SERVICES.find(s=>s.id===btn.dataset.id);if(!chosen)return;content.innerHTML=`<h2>${chosen.name}</h2><p>${chosen.description}</p><ul>${chosen.features.map(x=>`<li>${x}</li>`).join("")}</ul><p><b>Estimasi:</b> ${chosen.duration}</p><div class="dialog-price">${formatPrice(chosen.price)}</div>`;dialog.showModal();});
document.getElementById("dialogClose").addEventListener("click",()=>dialog.close());
document.getElementById("orderButton").addEventListener("click",()=>{if(chosen)location.href=`checkout.html?service=${encodeURIComponent(chosen.id)}`;});
