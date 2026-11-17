(function () {
  const loader = document.getElementById("dapzLoader");
  if (!loader) return;

  let hidden = false;
  const hideLoader = () => {
    if (hidden) return;
    hidden = true;
    loader.classList.add("is-hidden");
    window.setTimeout(() => loader.remove(), 650);
  };

  const startedAt = Date.now();
  const finish = () => {
    const remaining = Math.max(0, 520 - (Date.now() - startedAt));
    window.setTimeout(hideLoader, remaining);
  };

  if (document.readyState === "complete") finish();
  else window.addEventListener("load", finish, { once: true });

  // Prevent a broken external resource from leaving the loader on screen.
  window.setTimeout(hideLoader, 2200);
})();
