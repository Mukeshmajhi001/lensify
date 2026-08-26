const pageLoader = document.querySelector("[data-page-loader]");
const hidePageLoader = () => {
  if (!pageLoader || pageLoader.classList.contains("is-hidden")) return;
  pageLoader.classList.add("is-hidden");
  window.setTimeout(() => pageLoader.remove(), 500);
};

if (document.readyState === "complete") {
  hidePageLoader();
} else {
  window.addEventListener("load", hidePageLoader, { once: true });
}

document.querySelectorAll("[data-flash]").forEach((flash) => {
  window.setTimeout(() => {
    flash.style.transition = "opacity 250ms ease, transform 250ms ease";
    flash.style.opacity = "0";
    flash.style.transform = "translateY(-8px)";
    window.setTimeout(() => flash.remove(), 260);
  }, 3800);
});

document.querySelectorAll("[data-password-toggle]").forEach((toggle) => {
  const input = document.getElementById(toggle.dataset.passwordToggle);
  const icon = toggle.querySelector(".material-symbols-outlined");
  if (!input) return;
  toggle.addEventListener("click", () => {
    const visible = input.type === "text";
    input.type = visible ? "password" : "text";
    toggle.setAttribute(
      "aria-label",
      visible ? "Show password" : "Hide password",
    );
    if (icon) icon.textContent = visible ? "visibility" : "visibility_off";
  });
});

document.querySelectorAll("[data-quantity-input]").forEach((input) => {
  input.addEventListener("change", () => input.closest("form")?.submit());
});

document.querySelectorAll("[data-menu-toggle]").forEach((toggle) => {
  const menu = document.querySelector(
    toggle.dataset.menuTarget || "[data-menu]",
  );
  if (!menu) return;
  toggle.addEventListener("click", () => {
    const open = menu.classList.toggle("hidden") === false;
    toggle.setAttribute("aria-expanded", String(open));
    const icon = toggle.querySelector(".material-symbols-outlined");
    if (icon) icon.textContent = open ? "close" : "menu";
  });
});

const galleryMain = document.querySelector("#product-gallery-main");
document.querySelectorAll("[data-gallery-image]").forEach((thumbnail) => {
  thumbnail.addEventListener("click", () => {
    if (!galleryMain) return;
    galleryMain.src = thumbnail.dataset.galleryImage || galleryMain.src;
    galleryMain.alt = thumbnail.dataset.galleryAlt || galleryMain.alt;
    document.querySelectorAll("[data-gallery-image]").forEach((item) => {
      item.classList.remove("border-2", "border-black");
      item.classList.add("border", "border-zinc-200");
      item.querySelector("img")?.classList.add("opacity-70");
    });
    thumbnail.classList.remove("border", "border-zinc-200");
    thumbnail.classList.add("border-2", "border-black");
    thumbnail.querySelector("img")?.classList.remove("opacity-70");
  });
});

const unavailablePaymentModal = document.querySelector(
  "[data-payment-unavailable-modal]",
);
const checkoutForm = document.querySelector("[data-checkout-form]");
const cashOnDelivery = document.querySelector(
  'input[name="payment_method"][value="cod"]',
);
const showUnavailablePayment = () => {
  if (!unavailablePaymentModal) return;
  unavailablePaymentModal.classList.remove("hidden");
  unavailablePaymentModal.classList.add("flex");
  unavailablePaymentModal.setAttribute("aria-hidden", "false");
};
const hideUnavailablePayment = () => {
  if (!unavailablePaymentModal) return;
  unavailablePaymentModal.classList.add("hidden");
  unavailablePaymentModal.classList.remove("flex");
  unavailablePaymentModal.setAttribute("aria-hidden", "true");
};
document.querySelectorAll("[data-unavailable-payment]").forEach((payment) => {
  payment.addEventListener("change", showUnavailablePayment);
});
checkoutForm?.addEventListener("submit", (event) => {
  if (checkoutForm.querySelector("[data-unavailable-payment]:checked")) {
    event.preventDefault();
    showUnavailablePayment();
  }
});
document.querySelectorAll("[data-payment-modal-close]").forEach((button) => {
  button.addEventListener("click", () => {
    if (cashOnDelivery) cashOnDelivery.checked = true;
    hideUnavailablePayment();
  });
});
unavailablePaymentModal?.addEventListener("click", (event) => {
  if (event.target === unavailablePaymentModal) hideUnavailablePayment();
});
