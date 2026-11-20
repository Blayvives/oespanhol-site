/* ==========================================================================
   O ESPANHOL — Empório Ibérico Gourmet · Brasília, DF
   Interactive Catalog, Sommelier Pairing Studio, DF Delivery & Cart Drawer
   ========================================================================== */

(function () {
  "use strict";

  const ASSETS = window.__OESPANHOL_ASSETS__ || {
    hero: "./assets/hero.jpg",
    jamon: "./assets/jamon.jpg",
    vinhos: "./assets/vinhos.jpg",
    manchego: "./assets/manchego.jpg",
    cestas: "./assets/cestas.jpg",
    conservas: "./assets/conservas.jpg"
  };

  const PRODUCTS = [
    {
      id: "jamon-bellota",
      name: "Jamón Ibérico 100% Bellota",
      category: "jamon",
      categoryLabel: "Jamón & Embutidos",
      dop: "D.O.P. Jabugo",
      weight: "100g · Fatiado na faca",
      price: 248,
      img: ASSETS.jamon,
      shortDesc: "Porco 100% raça ibérica criado em montanera de bolotas, cura natural de 36 meses e gordura oleica untuosa.",
      origin: "Sierra de Aracena, Huelva",
      aging: "36 meses em adega natural",
      serving: "22 °C — retirar da embalagem 25 min antes",
      pairing: "Rioja Gran Reserva, Cava Brut Nature ou Jerez Fino"
    },
    {
      id: "paleta-cebo",
      name: "Paleta Ibérica de Cebo de Campo",
      category: "jamon",
      categoryLabel: "Jamón & Embutidos",
      dop: "Guijuelo · Salamanca",
      weight: "100g · Fatiado na faca",
      price: 138,
      img: ASSETS.jamon,
      shortDesc: "Sabor mais intenso e aromático, corte delicado na faca, ideal para tábuas de aperitivo e pão com tomate.",
      origin: "Guijuelo, Castela e Leão",
      aging: "24 meses em secadouros de altitude",
      serving: "21 °C sobre prato levemente morno",
      pairing: "Ribera del Duero Crianza ou Vermute Rojo"
    },
    {
      id: "rioja-gran-reserva",
      name: "Rioja Gran Reserva 2016",
      category: "vinhos",
      categoryLabel: "Vinhos & Vermute",
      dop: "D.O.Ca. Rioja",
      weight: "750 ml · Tempranillo",
      price: 310,
      img: ASSETS.vinhos,
      shortDesc: "Vinhedos velhos de Rioja Alta com 24 meses em carvalho americano e longo afinamento em garrafa. Taninos de seda.",
      origin: "Haro, Rioja Alta",
      aging: "24 meses em barrica + 36 meses em garrafa",
      serving: "17 °C — decantar 30 minutos",
      pairing: "Jamón 100% Bellota e Queijo Manchego Curado"
    },
    {
      id: "ribera-crianza",
      name: "Ribera del Duero Crianza 2020",
      category: "vinhos",
      categoryLabel: "Vinhos & Vermute",
      dop: "D.O. Ribera del Duero",
      weight: "750 ml · Tinto Fino",
      price: 225,
      img: ASSETS.vinhos,
      shortDesc: "Fruta negra madura, especiarias finas e frescor mineral de vinhedos a 850 metros de altitude.",
      origin: "Pesquera de Duero, Valladolid",
      aging: "14 meses em carvalho francês",
      serving: "16 °C em taça Bordeaux",
      pairing: "Paleta Ibérica, embutidos curados e cordeiro"
    },
    {
      id: "manchego-12m",
      name: "Queijo Manchego Artesano 12 Meses",
      category: "queijos",
      categoryLabel: "Queijos & Azeites",
      dop: "D.O.P. La Mancha",
      weight: "250g · Leite cru de ovelha",
      price: 118,
      img: ASSETS.manchego,
      shortDesc: "Elaborado com leite cru de ovelha Manchega, pasta firme com cristais de maturação e final amanteigado de nozes.",
      origin: "Ciudad Real, Castela-La Mancha",
      aging: "12 meses em tábuas de madeira",
      serving: "20 °C em cunhas finas com fio de AOVE",
      pairing: "Azeite Picual, amêndoas Marcona e Rioja Reserva"
    },
    {
      id: "aove-picual",
      name: "Azeite Virgem Extra Picual Precoce",
      category: "queijos",
      categoryLabel: "Queijos & Azeites",
      dop: "Jaén · Colheita Outubro",
      weight: "500 ml · Acidez 0,14%",
      price: 164,
      img: ASSETS.manchego,
      shortDesc: "Prensado a frio poucas horas após a colheita verde. Aromas vibrantes de folha de tomateiro, alcachofra e picância limpa.",
      origin: "Sierra Mágina, Andaluzia",
      aging: "Lote numerado · Safra atual",
      serving: "Cru, na finalização de pães, queijos e peixes",
      pairing: "Pão de fermentação natural, flor de sal e Manchego"
    },
    {
      id: "dupla-conservas-vermute",
      name: "Conservas da Galícia & Vermute Artesanal",
      category: "conservas",
      categoryLabel: "Conservas & Aperitivo",
      dop: "Rías Baixas & Cantábrico",
      weight: "2 latas + Vermute 750 ml",
      price: 189,
      img: ASSETS.conservas,
      shortDesc: "Mexilhões grandes em escabeche suave, filés de anchova do Cantábrico em azeite e Vermute Rojo de ervas mediterrâneas.",
      origin: "Cambados e Santoña, Norte da Espanha",
      aging: "Conserva manual em lata de safra",
      serving: "Vermute a 8 °C com gelo translúcido e casca de laranja",
      pairing: "Azeitonas Gordal, batatas artesanais e fim de tarde"
    },
    {
      id: "caixa-noite-lago",
      name: "Caixa Degustação “Noite no Lago”",
      category: "cestas",
      categoryLabel: "Caixas Presente",
      dop: "Curadoria Completa",
      weight: "Caixa madeira + 5 itens",
      price: 590,
      img: ASSETS.cestas,
      shortDesc: "Nossa assinatura para presentear em Brasília: Jamón 100% Bellota, Rioja Gran Reserva, Manchego 12m, AOVE Picual e Gordal em caixa de madeira.",
      origin: "Seleção O Espanhol · Brasília",
      aging: "Montada no dia com linho cru e cartão",
      serving: "Serve perfeitamente de 4 a 6 convidados",
      pairing: "Pronta para presentear ou abrir direto à mesa"
    }
  ];

  const EXTRA_ITEMS = {
    "clube-tertulia": {
      id: "clube-tertulia",
      name: "Clube La Mesa — Plano Tertúlia (1º mês)",
      weight: "Assinatura Mensal · Frete incluso",
      price: 390,
      img: ASSETS.cestas
    },
    "clube-gran-reserva": {
      id: "clube-gran-reserva",
      name: "Clube La Mesa — Plano Gran Reserva (1º mês)",
      weight: "Assinatura Mensal · Lotes raros",
      price: 680,
      img: ASSETS.vinhos
    }
  };

  const DF_ZONES = [
    { id: "lago-sul", name: "Lago Sul", eta: "Até 2h30", fee: 24, freeMin: 350, note: "Rota prioritária refrigerada com saída às 11h, 15h e 18h30. Ideal para jantares e recepções à beira-lago." },
    { id: "asa-sul", name: "Asa Sul", eta: "Até 1h45", fee: 16, freeMin: 350, note: "Proximidade imediata do nosso Atelier na CLS 405. Retirada sem taxa disponível no mesmo dia." },
    { id: "asa-norte", name: "Asa Norte", eta: "Até 2h15", fee: 18, freeMin: 350, note: "Entregas climatizadas em todas as superquadras e comerciais da Asa Norte até às 20h." },
    { id: "sudoeste", name: "Sudoeste / Octogonal", eta: "Até 2h00", fee: 18, freeMin: 350, note: "Rota expressa saindo do Plano Piloto com embalagem térmica vedada." },
    { id: "noroeste", name: "Noroeste", eta: "Até 2h15", fee: 20, freeMin: 350, note: "Entrega agendada ou expressa no mesmo dia para pedidos confirmados até 18h." },
    { id: "lago-norte", name: "Lago Norte", eta: "Até 2h45", fee: 26, freeMin: 350, note: "Rota refrigerada cobrindo toda a Península dos Ministros e quadras do Lago Norte." },
    { id: "park-way", name: "Park Way", eta: "Até 3h00", fee: 28, freeMin: 400, note: "Entrega refrigerada programada para condomínios do Park Way com confirmação prévia pelo Concierge." },
    { id: "aguas-claras", name: "Águas Claras", eta: "Até 3h00", fee: 26, freeMin: 400, note: "Duas janelas diárias refrigeradas (tarde e noite) com controle rigoroso de temperatura." }
  ];

  const OCCASIONS = {
    aperitivo: {
      title: "Aperitivo ao Pôr do Sol",
      note: "“Comece pelo vermute bem gelado com casca de laranja acompanhando as conservas da Galícia; quando o sol baixar, abra a Paleta Ibérica e o Manchego com um fio do azeite Picual.”",
      build(guests) {
        const packs = Math.max(1, Math.ceil(guests / 4));
        const wines = Math.max(1, Math.ceil(guests / 4));
        return [
          { productId: "paleta-cebo", qty: packs },
          { productId: "dupla-conservas-vermute", qty: Math.max(1, Math.ceil(guests / 6)) },
          { productId: "manchego-12m", qty: packs },
          { productId: "ribera-crianza", qty: wines }
        ];
      }
    },
    jantar: {
      title: "Jantar Íntimo Ibérico",
      note: "“O protagonismo absoluto é do Jamón 100% Bellota em temperatura ambiente ao lado do Rioja Gran Reserva 2016 decantado por 30 minutos. O azeite precoce finaliza pães rústicos e o Manchego 12 meses.”",
      build(guests) {
        const jamonQty = Math.max(1, Math.ceil(guests / 3));
        const wineQty = Math.max(1, Math.ceil(guests / 3));
        return [
          { productId: "jamon-bellota", qty: jamonQty },
          { productId: "rioja-gran-reserva", qty: wineQty },
          { productId: "manchego-12m", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "aove-picual", qty: 1 }
        ];
      }
    },
    recepcao: {
      title: "Recepção no Lago & Embaixadas",
      note: "“Equilíbrio impecável entre dois perfis de tintos (Rioja e Ribera), abundância de Jamón 100% Bellota cortado na faca e conservas nobres do norte espanhol para impressionar convidados exigentes.”",
      build(guests) {
        const jamonQty = Math.max(2, Math.ceil(guests / 3));
        return [
          { productId: "jamon-bellota", qty: jamonQty },
          { productId: "rioja-gran-reserva", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "ribera-crianza", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "manchego-12m", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "dupla-conservas-vermute", qty: Math.max(1, Math.ceil(guests / 6)) }
        ];
      }
    },
    presente: {
      title: "Presente de Autor em Madeira",
      note: "“Nossa Caixa Noite no Lago é finalizada à mão com linho cru e cartão em papel algodão. Para grupos maiores ou famílias, complementamos com azeite de colheita precoce e vermute artesanal.”",
      build(guests) {
        const boxes = Math.max(1, Math.ceil(guests / 6));
        const items = [{ productId: "caixa-noite-lago", qty: boxes }];
        if (guests >= 6) items.push({ productId: "aove-picual", qty: 1 });
        if (guests >= 10) items.push({ productId: "dupla-conservas-vermute", qty: 1 });
        return items;
      }
    }
  };

  /* State */
  let activeCategory = "todos";
  let activeOccasion = "aperitivo";
  let guestCount = 4;
  let activeZoneId = "lago-sul";
  let cart = [
    { id: "jamon-bellota", qty: 1 }
  ];
  let toastTimer = null;

  /* Helpers */
  const formatBRL = (value) =>
    value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

  const findItem = (id) =>
    PRODUCTS.find((p) => p.id === id) || EXTRA_ITEMS[id] || null;

  const findZone = (id) =>
    DF_ZONES.find((z) => z.id === id) || DF_ZONES[0];

  function showToast(message) {
    const el = document.getElementById("toast");
    el.textContent = message;
    el.classList.add("is-visible");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove("is-visible"), 2800);
  }

  /* ========================================================================
     1. Catalog Rendering & Filtering
     ======================================================================== */

  function renderCatalog() {
    const grid = document.getElementById("product-grid");
    const filtered =
      activeCategory === "todos"
        ? PRODUCTS
        : PRODUCTS.filter((p) => p.category === activeCategory);

    grid.innerHTML = filtered
      .map(
        (p) => `
      <article class="product-card" data-product-id="${p.id}">
        <div class="product-media">
          <img src="${p.img}" alt="${p.name}" loading="lazy" />
          <span class="product-dop">${p.dop}</span>
        </div>
        <div class="product-body">
          <span class="product-category">${p.categoryLabel}</span>
          <h3 class="product-name">${p.name}</h3>
          <p class="product-desc">${p.shortDesc}</p>
          <div class="product-meta-row">
            <span class="product-weight">${p.weight}</span>
            <span class="product-price">${formatBRL(p.price)}</span>
          </div>
          <div class="product-actions">
            <button class="btn btn--secondary btn--sm js-open-detail" type="button" data-id="${p.id}">
              Notas
            </button>
            <button class="btn btn--primary btn--sm js-add-cart" type="button" data-id="${p.id}">
              + Sacola
            </button>
          </div>
        </div>
      </article>`
      )
      .join("");
  }

  /* ========================================================================
     2. Product Tasting Sheet Modal
     ======================================================================== */

  function openProductModal(productId) {
    const p = PRODUCTS.find((item) => item.id === productId);
    if (!p) return;

    const modalBody = document.getElementById("product-modal-body");
    modalBody.innerHTML = `
      <img class="product-modal-img" src="${p.img}" alt="${p.name}" />
      <div class="product-modal-content">
        <span class="kicker">${p.dop}</span>
        <h3 id="modal-product-title" style="font-size: 1.85rem; margin-top: 0.4rem;">${p.name}</h3>
        <p style="color: var(--ink-secondary); font-size: 0.92rem; margin: 0.9rem 0 0;">${p.shortDesc}</p>

        <div class="tasting-specs">
          <div>
            <span class="spec-label">Origem</span>
            <span class="spec-val">${p.origin}</span>
          </div>
          <div>
            <span class="spec-label">Maturação / Safra</span>
            <span class="spec-val">${p.aging}</span>
          </div>
          <div>
            <span class="spec-label">Serviço Ideal</span>
            <span class="spec-val">${p.serving}</span>
          </div>
          <div>
            <span class="spec-label">Harmonização</span>
            <span class="spec-val">${p.pairing}</span>
          </div>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap;">
          <div>
            <div style="font-size: 0.74rem; color: var(--ink-muted);">${p.weight}</div>
            <div style="font-family: var(--font-serif); font-size: 1.65rem;" class="tabular">${formatBRL(p.price)}</div>
          </div>
          <button class="btn btn--primary js-modal-add" type="button" data-id="${p.id}">
            Adicionar à Sacola
          </button>
        </div>
      </div>
    `;

    openModal("product-modal");
  }

  /* ========================================================================
     3. Interactive Sommelier Pairing Studio
     ======================================================================== */

  function renderSommelier() {
    const cfg = OCCASIONS[activeOccasion];
    const selection = cfg.build(guestCount);

    document.getElementById("guest-readout").textContent = `${guestCount} pessoas`;
    document.getElementById("pairing-title").textContent = cfg.title;
    document.getElementById("pairing-serves").textContent = `Para ${guestCount} pessoas`;
    document.getElementById("pairing-note").textContent = cfg.note;

    let rawTotal = 0;
    const listEl = document.getElementById("pairing-list");

    listEl.innerHTML = selection
      .map(({ productId, qty }) => {
        const p = findItem(productId);
        const lineTotal = p.price * qty;
        rawTotal += lineTotal;
        return `
          <li class="pairing-item">
            <div>
              <span class="pairing-item-name">${qty}× ${p.name}</span>
              <span class="pairing-item-detail">${p.dop} · ${p.weight}</span>
            </div>
            <span class="pairing-item-price">${formatBRL(lineTotal)}</span>
          </li>`;
      })
      .join("");

    const discounted = Math.round(rawTotal * 0.92);
    const saving = rawTotal - discounted;

    document.getElementById("pairing-original").textContent = formatBRL(rawTotal);
    document.getElementById("pairing-total").textContent = formatBRL(discounted);
    document.getElementById("pairing-saving").textContent = `Inclui 8% de cortesia de curadoria (economia de ${formatBRL(saving)})`;
  }

  /* ========================================================================
     4. DF Delivery Zone Checker
     ======================================================================== */

  function renderZones() {
    const btnWrap = document.getElementById("zone-buttons");
    const cartSelect = document.getElementById("cart-zone-select");

    btnWrap.innerHTML = DF_ZONES.map(
      (z) => `
      <button class="zone-btn ${z.id === activeZoneId ? "is-active" : ""}" type="button" data-zone="${z.id}">
        ${z.name}
      </button>`
    ).join("");

    cartSelect.innerHTML = DF_ZONES.map(
      (z) => `<option value="${z.id}" ${z.id === activeZoneId ? "selected" : ""}>${z.name}</option>`
    ).join("");

    updateZoneDisplay();
  }

  function updateZoneDisplay() {
    const z = findZone(activeZoneId);
    document.getElementById("delivery-zone-name").textContent = z.name;
    document.getElementById("delivery-eta").textContent = z.eta;
    document.getElementById("delivery-fee").textContent = formatBRL(z.fee);
    document.getElementById("delivery-free-min").textContent = `Acima de ${formatBRL(z.freeMin)}`;
    document.getElementById("delivery-note").textContent = z.note;

    document.querySelectorAll(".zone-btn").forEach((b) => {
      b.classList.toggle("is-active", b.dataset.zone === activeZoneId);
    });
    const cartSelect = document.getElementById("cart-zone-select");
    if (cartSelect) cartSelect.value = activeZoneId;
  }

  /* ========================================================================
     5. Cart Drawer Logic
     ======================================================================== */

  function addToCart(id, qty = 1, silent = false) {
    const item = findItem(id);
    if (!item) return;
    const existing = cart.find((c) => c.id === id);
    if (existing) {
      existing.qty += qty;
    } else {
      cart.push({ id, qty });
    }
    renderCart();
    if (!silent) {
      showToast(`Adicionado à sacola: ${item.name}`);
    }
  }

  function updateCartQty(id, delta) {
    const idx = cart.findIndex((c) => c.id === id);
    if (idx === -1) return;
    cart[idx].qty += delta;
    if (cart[idx].qty <= 0) {
      cart.splice(idx, 1);
    }
    renderCart();
  }

  function removeFromCart(id) {
    cart = cart.filter((c) => c.id !== id);
    renderCart();
  }

  function computeCartTotals() {
    const zone = findZone(activeZoneId);
    let subtotal = 0;
    let totalCount = 0;
    cart.forEach((entry) => {
      const p = findItem(entry.id);
      if (p) {
        subtotal += p.price * entry.qty;
        totalCount += entry.qty;
      }
    });
    const isFree = subtotal >= zone.freeMin || subtotal === 0;
    const shipping = subtotal === 0 ? 0 : isFree ? 0 : zone.fee;
    return {
      subtotal,
      totalCount,
      shipping,
      total: subtotal + shipping,
      freeMin: zone.freeMin,
      remainingForFree: Math.max(0, zone.freeMin - subtotal),
      zone
    };
  }

  function renderCart() {
    const { subtotal, totalCount, shipping, total, freeMin, remainingForFree, zone } =
      computeCartTotals();

    document.getElementById("cart-count").textContent = totalCount;

    const barText = document.getElementById("shipping-bar-text");
    const progress = document.getElementById("shipping-progress");
    const pct = Math.min(100, (subtotal / freeMin) * 100);
    progress.style.width = `${pct}%`;

    if (subtotal === 0) {
      barText.textContent = `Frete refrigerado cortesia para ${zone.name} em pedidos acima de ${formatBRL(freeMin)}.`;
    } else if (remainingForFree > 0) {
      barText.textContent = `Faltam ${formatBRL(remainingForFree)} para frete refrigerado cortesia em ${zone.name}.`;
    } else {
      barText.textContent = `Você garantiu frete refrigerado cortesia para ${zone.name}!`;
    }

    const container = document.getElementById("cart-items-container");
    if (cart.length === 0) {
      container.innerHTML = `
        <div class="cart-empty">
          <strong style="font-family: var(--font-serif); font-size: 1.25rem; color: var(--ink-primary);">Sua sacola está vazia</strong>
          <p>Explore nossa curadoria de jamón, vinhos de guarda e azeites de colheita precoce.</p>
          <button class="btn btn--secondary btn--sm" type="button" id="empty-explore-btn">Ver Curadoria</button>
        </div>`;
    } else {
      container.innerHTML = cart
        .map((entry) => {
          const p = findItem(entry.id);
          return `
            <div class="cart-item">
              <img src="${p.img}" alt="${p.name}" />
              <div>
                <div class="cart-item-title">${p.name}</div>
                <div class="cart-item-meta">${p.weight} · ${formatBRL(p.price)}</div>
                <div class="cart-item-row">
                  <div class="qty-control">
                    <button type="button" class="js-qty-dec" data-id="${p.id}" aria-label="Diminuir quantidade">−</button>
                    <span>${entry.qty}</span>
                    <button type="button" class="js-qty-inc" data-id="${p.id}" aria-label="Aumentar quantidade">+</button>
                  </div>
                  <div style="display:flex; align-items:center; gap:0.75rem;">
                    <strong class="tabular" style="font-size:0.9rem;">${formatBRL(p.price * entry.qty)}</strong>
                    <button type="button" class="remove-btn js-qty-remove" data-id="${p.id}">Remover</button>
                  </div>
                </div>
              </div>
            </div>`;
        })
        .join("");
    }

    document.getElementById("cart-subtotal").textContent = formatBRL(subtotal);
    document.getElementById("cart-shipping").textContent =
      subtotal === 0 ? "—" : shipping === 0 ? "Cortesia" : formatBRL(shipping);
    document.getElementById("cart-total").textContent = formatBRL(total);
  }

  /* ========================================================================
     6. Drawers, Modals & Checkout Summary
     ======================================================================== */

  function openCart() {
    closeAllModals();
    document.getElementById("overlay").classList.add("is-open");
    document.getElementById("cart-drawer").classList.add("is-open");
    document.getElementById("cart-drawer").setAttribute("aria-hidden", "false");
  }

  function closeCart() {
    document.getElementById("cart-drawer").classList.remove("is-open");
    document.getElementById("cart-drawer").setAttribute("aria-hidden", "true");
    if (!document.querySelector(".modal.is-open")) {
      document.getElementById("overlay").classList.remove("is-open");
    }
  }

  function openModal(id) {
    closeCart();
    document.getElementById("overlay").classList.add("is-open");
    const m = document.getElementById(id);
    m.classList.add("is-open");
    m.setAttribute("aria-hidden", "false");
  }

  function closeAllModals() {
    document.querySelectorAll(".modal").forEach((m) => {
      m.classList.remove("is-open");
      m.setAttribute("aria-hidden", "true");
    });
    if (!document.getElementById("cart-drawer").classList.contains("is-open")) {
      document.getElementById("overlay").classList.remove("is-open");
    }
  }

  function buildOrderSummary() {
    const { subtotal, shipping, total, zone } = computeCartTotals();
    const lines = [
      "PEDIDO — O ESPANHOL (oespanhol.com.br)",
      "Empório Ibérico Gourmet · Brasília, DF",
      "----------------------------------------",
      ...cart.map((entry) => {
        const p = findItem(entry.id);
        return `• ${entry.qty}x ${p.name} (${p.weight}) — ${formatBRL(p.price * entry.qty)}`;
      }),
      "----------------------------------------",
      `Região de entrega: ${zone.name} (${zone.eta})`,
      `Subtotal: ${formatBRL(subtotal)}`,
      `Entrega refrigerada: ${shipping === 0 ? "Cortesia" : formatBRL(shipping)}`,
      `TOTAL: ${formatBRL(total)}`
    ];
    return lines.join("\n");
  }

  /* ========================================================================
     7. Event Listeners & Init
     ======================================================================== */

  function bindEvents() {
    // Category tabs
    document.getElementById("catalog-filters").addEventListener("click", (e) => {
      const btn = e.target.closest(".filter-tab");
      if (!btn) return;
      activeCategory = btn.dataset.category;
      document.querySelectorAll(".filter-tab").forEach((t) => {
        const active = t === btn;
        t.classList.toggle("is-active", active);
        t.setAttribute("aria-selected", String(active));
      });
      renderCatalog();
    });

    // Product grid delegation
    document.getElementById("product-grid").addEventListener("click", (e) => {
      const addBtn = e.target.closest(".js-add-cart");
      if (addBtn) {
        addToCart(addBtn.dataset.id);
        return;
      }
      const detailBtn = e.target.closest(".js-open-detail");
      if (detailBtn) {
        openProductModal(detailBtn.dataset.id);
      }
    });

    // Product modal add to cart
    document.getElementById("product-modal-body").addEventListener("click", (e) => {
      const btn = e.target.closest(".js-modal-add");
      if (!btn) return;
      addToCart(btn.dataset.id);
      closeAllModals();
      openCart();
    });

    // Sommelier controls
    document.getElementById("occasion-grid").addEventListener("click", (e) => {
      const btn = e.target.closest(".occasion-btn");
      if (!btn) return;
      activeOccasion = btn.dataset.occasion;
      document.querySelectorAll(".occasion-btn").forEach((b) =>
        b.classList.toggle("is-active", b === btn)
      );
      renderSommelier();
    });

    document.getElementById("guest-slider").addEventListener("input", (e) => {
      guestCount = Number(e.target.value);
      renderSommelier();
    });

    document.getElementById("add-pairing-btn").addEventListener("click", () => {
      const selection = OCCASIONS[activeOccasion].build(guestCount);
      selection.forEach(({ productId, qty }) => addToCart(productId, qty, true));
      showToast(`Seleção "${OCCASIONS[activeOccasion].title}" adicionada à sacola!`);
      openCart();
    });

    // Club plans
    document.querySelectorAll(".club-add-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        addToCart(btn.dataset.planId);
        openCart();
      });
    });

    document.getElementById("corporate-inquiry-btn").addEventListener("click", () => {
      document.getElementById("order-summary-text").textContent = [
        "SOLICITAÇÃO CONCIERGE CORPORATIVO — O ESPANHOL",
        "----------------------------------------",
        "Interesse: Caixas Presente em Madeira / Eventos & Embaixadas em Brasília",
        "Serviços disponíveis:",
        "• Caixas personalizadas a partir de 6 unidades",
        "• Cartão em papel algodão com assinatura institucional",
        "• Maestro cortador de Jamón ao vivo sob reserva",
        "",
        "Contato Concierge: contato@oespanhol.com.br | (61) 99900-1928"
      ].join("\n");
      openModal("checkout-modal");
    });

    // Delivery zones
    document.getElementById("zone-buttons").addEventListener("click", (e) => {
      const btn = e.target.closest(".zone-btn");
      if (!btn) return;
      activeZoneId = btn.dataset.zone;
      updateZoneDisplay();
      renderCart();
    });

    document.getElementById("cart-zone-select").addEventListener("change", (e) => {
      activeZoneId = e.target.value;
      updateZoneDisplay();
      renderCart();
    });

    // Cart drawer controls
    document.getElementById("open-cart-btn").addEventListener("click", openCart);
    document.getElementById("close-cart-btn").addEventListener("click", closeCart);
    document.getElementById("overlay").addEventListener("click", () => {
      closeCart();
      closeAllModals();
    });

    document.getElementById("cart-items-container").addEventListener("click", (e) => {
      const inc = e.target.closest(".js-qty-inc");
      const dec = e.target.closest(".js-qty-dec");
      const rem = e.target.closest(".js-qty-remove");
      const explore = e.target.closest("#empty-explore-btn");
      if (inc) updateCartQty(inc.dataset.id, 1);
      if (dec) updateCartQty(dec.dataset.id, -1);
      if (rem) removeFromCart(rem.dataset.id);
      if (explore) {
        closeCart();
        document.getElementById("curadoria").scrollIntoView({ behavior: "smooth" });
      }
    });

    // Checkout flow
    document.getElementById("checkout-btn").addEventListener("click", () => {
      if (cart.length === 0) {
        showToast("Adicione ao menos um item à sacola para continuar.");
        return;
      }
      document.getElementById("order-summary-text").textContent = buildOrderSummary();
      openModal("checkout-modal");
    });

    document.getElementById("copy-order-btn").addEventListener("click", () => {
      const text = document.getElementById("order-summary-text").textContent;
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(() => {
          showToast("Resumo copiado! Pronto para enviar ao Concierge.");
        });
      } else {
        showToast("Resumo pronto — selecione e copie o texto acima.");
      }
    });

    document.getElementById("clear-and-close-btn").addEventListener("click", () => {
      cart = [];
      renderCart();
      closeAllModals();
      showToast("Pedido registrado no modo demonstrativo. ¡Muchas gracias!");
    });

    // Modal closes & Escape
    document.getElementById("close-product-modal").addEventListener("click", closeAllModals);
    document.getElementById("close-checkout-modal").addEventListener("click", closeAllModals);
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        closeCart();
        closeAllModals();
      }
    });

    // Mobile menu
    const menuBtn = document.getElementById("mobile-menu-btn");
    const mobileNav = document.getElementById("mobile-nav");
    menuBtn.addEventListener("click", () => {
      const open = mobileNav.classList.toggle("is-open");
      menuBtn.setAttribute("aria-expanded", String(open));
    });
    mobileNav.addEventListener("click", (e) => {
      if (e.target.tagName === "A") {
        mobileNav.classList.remove("is-open");
        menuBtn.setAttribute("aria-expanded", "false");
      }
    });
  }

  function initScrollReveal() {
    const items = document.querySelectorAll(".reveal");
    if (!("IntersectionObserver" in window)) {
      items.forEach((el) => el.classList.add("is-visible"));
      return;
    }
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12 }
    );
    items.forEach((el) => io.observe(el));
  }

  /* Boot */
  renderCatalog();
  renderSommelier();
  renderZones();
  renderCart();
  bindEvents();
  initScrollReveal();
})();
