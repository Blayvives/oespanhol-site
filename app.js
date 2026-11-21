/* ==========================================================================
   O ESPANHOL — Interactive Engine for 17 Spanish Autonomous Communities
   Interactive SVG Atlas, Dynamic Regional Design Motifs, Search, Sommelier & Cart
   ========================================================================== */

(function () {
  "use strict";

  const { MOTIFS, REGIONS, EXTRA_ITEMS } = window.__OESPANHOL_DATA__;

  /* Flatten all 56 regional dishes into a fast lookup map with parent region metadata */
  const DISH_INDEX = {};
  REGIONS.forEach((region) => {
    region.dishes.forEach((dish) => {
      DISH_INDEX[dish.id] = Object.assign({}, dish, {
        regionId: region.id,
        regionName: region.name,
        regionCode: region.code,
        regionAccent: region.accent,
        regionAccentSoft: region.accentSoft,
        regionMotifKey: region.motifKey
      });
    });
  });

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

  const SOMMELIER_ROUTES = {
    sul: {
      title: "Rota do Sul & Dehesa",
      note: "“Uma travessia ensolarada entre Andaluzia e Extremadura: comece com Salmorejo Cordobés e Fino de Jerez, siga para o Jamón 100% Bellota de Jabugo e encerre mergulhando pão rústico na cremosa Torta del Casar.”",
      build(guests) {
        const packs = Math.max(1, Math.ceil(guests / 3));
        return [
          { productId: "and-jamon-jabugo", qty: packs },
          { productId: "and-salmorejo", qty: Math.max(1, Math.ceil(guests / 3)) },
          { productId: "ext-torta-casar", qty: 1 },
          { productId: "and-atum-jerez", qty: Math.max(1, Math.ceil(guests / 4)) }
        ];
      }
    },
    norte: {
      title: "Rota Atlântica — Norte Verde",
      note: "“O frescor oceânico da Galícia, País Basco e Astúrias: abra com Gildas Donostiarras e Txakoli gelado, sirva o Polvo à Feira sobre tábuas de madeira com Albariño e feche com o Idiazabal defumado.”",
      build(guests) {
        return [
          { productId: "gal-pulpo", qty: Math.max(1, Math.ceil(guests / 3)) },
          { productId: "eus-gildas", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "eus-idiazabal", qty: 1 },
          { productId: "gal-albarino", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "ast-sidra", qty: Math.max(1, Math.ceil(guests / 6)) }
        ];
      }
    },
    mediterraneo: {
      title: "Rota Mediterrânea & Ilhas",
      note: "“Almoço luminoso do Levante às Baleares: Escalivada catalã e Sobrassada de Mallorca com Cava Brut Nature enquanto a Paella Valenciana descansa por 5 minutos, fechando com Turrón de Jijona.”",
      build(guests) {
        return [
          { productId: "val-kit-paella", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "cat-escalivada", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "bal-sobrassada", qty: 1 },
          { productId: "cat-cava", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "val-turron", qty: 1 }
        ];
      }
    },
    meseta: {
      title: "Rota da Meseta Real & La Rioja",
      note: "“Clássicos solenes do interior espanhol: Vermute de Madri e azeitonas Campo Real no aperitivo, Queijo Manchego 12 meses, Paleta de Guijuelo e o Rioja Gran Reserva 2016 decantado.”",
      build(guests) {
        return [
          { productId: "rio-gran-reserva", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "clm-manchego", qty: Math.max(1, Math.ceil(guests / 4)) },
          { productId: "cyl-paleta-guijuelo", qty: Math.max(1, Math.ceil(guests / 3)) },
          { productId: "mad-vermute", qty: 1 },
          { productId: "rio-patatas", qty: Math.max(1, Math.ceil(guests / 4)) }
        ];
      }
    }
  };

  /* State */
  let activeMacro = "todas";
  let activeRegionId = "andaluzia";
  let viewMode = "region"; // "region" | "all"
  let searchQuery = "";
  let activeOccasion = "sul";
  let guestCount = 4;
  let activeZoneId = "lago-sul";
  let cart = [{ id: "and-jamon-jabugo", qty: 1 }];
  let toastTimer = null;

  /* Helpers */
  const formatBRL = (value) =>
    value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

  const normalize = (str) =>
    str
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");

  const findItem = (id) => DISH_INDEX[id] || EXTRA_ITEMS[id] || null;
  const findRegion = (id) => REGIONS.find((r) => r.id === id) || REGIONS[0];
  const findZone = (id) => DF_ZONES.find((z) => z.id === id) || DF_ZONES[0];

  function getFilteredRegions() {
    return activeMacro === "todas"
      ? REGIONS
      : REGIONS.filter((r) => r.macro === activeMacro);
  }

  function showToast(message) {
    const el = document.getElementById("toast");
    el.textContent = message;
    el.classList.add("is-visible");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove("is-visible"), 2800);
  }

  function applyRegionalTheme(region) {
    document.documentElement.style.setProperty("--region-accent", region.accent);
    document.documentElement.style.setProperty("--region-accent-soft", region.accentSoft);
  }

  /* ========================================================================
     1. Interactive Stylized Iberian SVG Map (17 Pins)
     ======================================================================== */

  function renderMapPins() {
    const pinsLayer = document.getElementById("atlas-map-pins");
    const visibleIds = new Set(getFilteredRegions().map((r) => r.id));

    pinsLayer.innerHTML = REGIONS.map((r) => {
      const isActive = r.id === activeRegionId;
      const isDimmed = !visibleIds.has(r.id);
      const radius = isActive ? 12 : 9.2;
      return `
        <g class="map-pin ${isActive ? "is-active" : ""} ${isDimmed ? "is-dimmed" : ""}"
           data-region-id="${r.id}"
           role="button"
           tabindex="0"
           aria-label="${r.code} ${r.name} — ${r.capital}">
          <circle class="map-pin-ring" cx="${r.mapPos.x}" cy="${r.mapPos.y}" r="${radius + 5}"
                  fill="none" stroke="${r.accent}" stroke-width="1.5" stroke-dasharray="2 2"/>
          <circle class="map-pin-dot" cx="${r.mapPos.x}" cy="${r.mapPos.y}" r="${radius}"
                  fill="${r.accent}" stroke="#FFFDF9" stroke-width="${isActive ? 2.2 : 1.4}"/>
          <text class="map-pin-code" x="${r.mapPos.x}" y="${r.mapPos.y}">${r.code}</text>
        </g>`;
    }).join("");

    const active = findRegion(activeRegionId);
    document.getElementById("map-hover-readout").textContent = `${active.code} · ${active.name} (${active.capital})`;
  }

  /* ========================================================================
     2. 17-Community Directory Index
     ======================================================================== */

  function renderDirectory() {
    const dir = document.getElementById("region-directory");
    const list = getFilteredRegions();

    dir.innerHTML = list
      .map((r) => {
        const isActive = r.id === activeRegionId;
        return `
          <button class="region-pill ${isActive ? "is-active" : ""}" type="button" data-region-id="${r.id}">
            <span class="region-pill-left">
              <span class="region-dot" style="background-color:${r.accent};"></span>
              <span class="region-pill-text">
                <span class="region-pill-name">${r.code} · ${r.name}</span>
                <span class="region-pill-cap">${r.capital} · ${r.macroLabel}</span>
              </span>
            </span>
            <span class="region-pill-count">${r.dishes.length} pratos</span>
          </button>`;
      })
      .join("");
  }

  /* ========================================================================
     3. Dish Card Renderer (Shared across Regional Dossier & Full Menu)
     ======================================================================== */

  function renderDishCard(dish, regionAccent) {
    return `
      <article class="product-card" style="--card-accent:${regionAccent};">
        <div class="product-media">
          <img src="${dish.img}" alt="${dish.name}" loading="lazy" />
          <span class="product-dop">${dish.dop}</span>
        </div>
        <div class="product-body">
          <span class="product-category">${dish.type}</span>
          <h4 class="product-name">${dish.name}</h4>
          <p class="product-desc">${dish.shortDesc}</p>
          <div class="product-meta-row">
            <span class="product-weight">${dish.weight}</span>
            <span class="product-price">${formatBRL(dish.price)}</span>
          </div>
          <div class="product-actions">
            <button class="btn btn--secondary btn--sm js-open-detail" type="button" data-id="${dish.id}">
              Notas
            </button>
            <button class="btn btn--sm js-add-cart" type="button" data-id="${dish.id}"
                    style="background-color:${regionAccent}; border-color:${regionAccent}; color:#F7F1E8;">
              + Sacola
            </button>
          </div>
        </div>
      </article>`;
  }

  /* ========================================================================
     4. Single-Region Editorial Dossier
     ======================================================================== */

  function renderRegionalDossier() {
    const region = findRegion(activeRegionId);
    applyRegionalTheme(region);

    const motifSvg = MOTIFS[region.motifKey] || MOTIFS.mudejar;
    const repeatedMotifs = Array.from({ length: 7 }, () => motifSvg).join("");

    const dossier = document.getElementById("regional-dossier");
    dossier.innerHTML = `
      <div class="regional-frieze">
        <div class="frieze-motifs" aria-hidden="true">${repeatedMotifs}</div>
        <span class="frieze-caption">${region.motifLabel}</span>
      </div>

      <div class="dossier-header">
        <div>
          <div class="dossier-meta-line">
            <span class="dossier-code">Comunidade ${region.code} / 17</span>
            <span class="kicker kicker--region">${region.macroLabel}</span>
          </div>

          <h3 class="dossier-title">
            ${region.name}
            <span class="dossier-endonym">${region.spanishName}</span>
          </h3>

          <p class="dossier-tagline">${region.tagline}</p>
          <p class="dossier-story">${region.story}</p>

          <div class="dossier-dops">
            ${region.dops.map((d) => `<span class="dop-tag">${d}</span>`).join("")}
          </div>

          <p class="dossier-ritual">${region.ritual}</p>
        </div>

        <aside class="dossier-emblem-box">
          <div class="dossier-emblem-svg">${motifSvg}</div>
          <span class="dossier-capital">Capital: ${region.capital}</span>
          <span class="dossier-motif-name">${region.motifLabel}</span>
          <div class="dossier-nav-btns">
            <button type="button" id="prev-region-btn">← Anterior</button>
            <button type="button" id="next-region-btn">Próxima →</button>
          </div>
        </aside>
      </div>

      <div class="dossier-dishes-wrap">
        <div class="dossier-dishes-head">
          <h4 class="dossier-dishes-title">Cardápio Tradicional — ${region.name}</h4>
          <span style="font-size:0.78rem; color:var(--ink-muted);">${region.dishes.length} especialidades selecionadas para entrega em Brasília</span>
        </div>
        <div class="product-grid">
          ${region.dishes.map((d) => renderDishCard(d, region.accent)).join("")}
        </div>
      </div>
    `;
  }

  /* ========================================================================
     5. Full Menu / Live Search View (Across All 17 Regions)
     ======================================================================== */

  function renderFullMenu() {
    const container = document.getElementById("full-menu-container");
    const q = normalize(searchQuery.trim());
    const regionsPool = getFilteredRegions();

    const chapters = regionsPool
      .map((region) => {
        const regionMatch =
          !q ||
          normalize(region.name).includes(q) ||
          normalize(region.spanishName).includes(q) ||
          normalize(region.capital).includes(q) ||
          normalize(region.tagline).includes(q);

        const dishes = regionMatch
          ? region.dishes
          : region.dishes.filter(
              (d) =>
                normalize(d.name).includes(q) ||
                normalize(d.shortDesc).includes(q) ||
                normalize(d.dop).includes(q) ||
                normalize(d.type).includes(q)
            );

        return { region, dishes };
      })
      .filter((c) => c.dishes.length > 0);

    if (chapters.length === 0) {
      container.innerHTML = `
        <div class="empty-search-state">
          <strong style="font-family:var(--font-serif); font-size:1.35rem; color:var(--ink-primary);">Nenhum prato encontrado para “${searchQuery}”</strong>
          <p style="margin:0.5rem 0 1.25rem; font-size:0.9rem;">Experimente buscar por “paella”, “polvo”, “jamón”, “queijo”, “rioja” ou “gilda”.</p>
          <button type="button" class="btn btn--secondary btn--sm" id="clear-search-btn">Limpar busca</button>
        </div>`;
      return;
    }

    container.innerHTML = chapters
      .map(({ region, dishes }) => {
        const motifSvg = MOTIFS[region.motifKey] || MOTIFS.mudejar;
        return `
          <section class="region-chapter" style="--chapter-accent:${region.accent};">
            <div class="region-chapter-head">
              <div class="region-chapter-id">
                <div class="region-chapter-motif">${motifSvg}</div>
                <div>
                  <h3 class="region-chapter-title">${region.code} · ${region.name}</h3>
                  <div class="region-chapter-sub">${region.capital} · ${region.tagline}</div>
                </div>
              </div>
              <button type="button" class="btn btn--secondary btn--sm js-focus-region" data-region-id="${region.id}">
                Ver Dossiê Regional
              </button>
            </div>
            <div class="product-grid">
              ${dishes.map((d) => renderDishCard(d, region.accent)).join("")}
            </div>
          </section>`;
      })
      .join("");
  }

  /* Master Catalog View Sync */
  function renderCatalogArea() {
    const hasSearch = searchQuery.trim().length > 0;
    const showFull = viewMode === "all" || hasSearch;

    document.getElementById("atlas-navigator").hidden = showFull;
    document.getElementById("regional-dossier").hidden = showFull;
    document.getElementById("full-menu-container").hidden = !showFull;

    document.getElementById("view-by-region-btn").classList.toggle("is-active", !showFull);
    document.getElementById("view-all-btn").classList.toggle("is-active", showFull);

    if (showFull) {
      renderFullMenu();
    } else {
      const visible = getFilteredRegions();
      if (!visible.some((r) => r.id === activeRegionId)) {
        activeRegionId = visible[0].id;
      }
      renderMapPins();
      renderDirectory();
      renderRegionalDossier();
    }
  }

  function selectRegion(regionId, scrollToDossier = false) {
    activeRegionId = regionId;
    searchQuery = "";
    document.getElementById("menu-search").value = "";
    viewMode = "region";
    const reg = findRegion(regionId);
    if (activeMacro !== "todas" && reg.macro !== activeMacro) {
      activeMacro = "todas";
      syncMacroTabs();
    }
    renderCatalogArea();
    if (scrollToDossier) {
      document.getElementById("regional-dossier").scrollIntoView({ behavior: "smooth", block: "nearest" });
    }
  }

  function stepRegion(delta) {
    const list = getFilteredRegions();
    const idx = list.findIndex((r) => r.id === activeRegionId);
    const nextIdx = (idx + delta + list.length) % list.length;
    selectRegion(list[nextIdx].id, false);
  }

  function syncMacroTabs() {
    document.querySelectorAll(".macro-tab").forEach((t) => {
      const active = t.dataset.macro === activeMacro;
      t.classList.toggle("is-active", active);
      t.setAttribute("aria-selected", String(active));
    });
  }

  /* ========================================================================
     6. Product Tasting Sheet Modal
     ======================================================================== */

  function openProductModal(productId) {
    const p = DISH_INDEX[productId];
    if (!p) return;

    const modalBody = document.getElementById("product-modal-body");
    modalBody.innerHTML = `
      <img class="product-modal-img" src="${p.img}" alt="${p.name}" />
      <div class="product-modal-content">
        <span class="kicker" style="color:${p.regionAccent};">${p.regionName} · ${p.dop}</span>
        <h3 id="modal-product-title" style="font-size: 1.75rem; margin-top: 0.4rem;">${p.name}</h3>
        <p style="color: var(--ink-secondary); font-size: 0.91rem; margin: 0.85rem 0 0;">${p.shortDesc}</p>

        <div class="tasting-specs">
          <div>
            <span class="spec-label">Origem Regional</span>
            <span class="spec-val">${p.origin}</span>
          </div>
          <div>
            <span class="spec-label">Preparo / Maturação</span>
            <span class="spec-val">${p.aging}</span>
          </div>
          <div>
            <span class="spec-label">Ritual de Serviço</span>
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
            <div style="font-family: var(--font-serif); font-size: 1.6rem;" class="tabular">${formatBRL(p.price)}</div>
          </div>
          <button class="btn js-modal-add" type="button" data-id="${p.id}"
                  style="background-color:${p.regionAccent}; border-color:${p.regionAccent}; color:#F7F1E8;">
            Adicionar à Sacola
          </button>
        </div>
      </div>
    `;

    openModal("product-modal");
  }

  /* ========================================================================
     7. Regional Sommelier Pairing Studio
     ======================================================================== */

  function renderSommelier() {
    const cfg = SOMMELIER_ROUTES[activeOccasion];
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
              <span class="pairing-item-detail">${p.regionName} · ${p.dop} · ${p.weight}</span>
            </div>
            <span class="pairing-item-price">${formatBRL(lineTotal)}</span>
          </li>`;
      })
      .join("");

    const discounted = Math.round(rawTotal * 0.92);
    const saving = rawTotal - discounted;

    document.getElementById("pairing-original").textContent = formatBRL(rawTotal);
    document.getElementById("pairing-total").textContent = formatBRL(discounted);
    document.getElementById("pairing-saving").textContent = `Inclui 8% de cortesia na rota completa (economia de ${formatBRL(saving)})`;
  }

  /* ========================================================================
     8. DF Delivery Zone Checker
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
     9. Cart Drawer Logic
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
      showToast(`Adicionado (${item.regionName}): ${item.name}`);
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
          <p>Explore o mapa das 17 Comunidades Autônomas e monte sua mesa ibérica.</p>
          <button class="btn btn--secondary btn--sm" type="button" id="empty-explore-btn">Explorar 17 Regiões</button>
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
                <div class="cart-item-meta">${p.regionName} · ${p.weight} · ${formatBRL(p.price)}</div>
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
     10. Drawers, Modals & Checkout Summary
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
      "Atlas Gastronômico das 17 Comunidades · Brasília, DF",
      "----------------------------------------",
      ...cart.map((entry) => {
        const p = findItem(entry.id);
        return `• ${entry.qty}x ${p.name} [${p.regionName}] — ${formatBRL(p.price * entry.qty)}`;
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
     11. Event Bindings
     ======================================================================== */

  function bindEvents() {
    // Macro-region tabs
    document.getElementById("macro-tabs").addEventListener("click", (e) => {
      const btn = e.target.closest(".macro-tab");
      if (!btn) return;
      activeMacro = btn.dataset.macro;
      syncMacroTabs();
      renderCatalogArea();
    });

    // Footer macro shortcuts
    document.querySelectorAll(".js-footer-macro").forEach((link) => {
      link.addEventListener("click", () => {
        activeMacro = link.dataset.macro;
        viewMode = "region";
        searchQuery = "";
        document.getElementById("menu-search").value = "";
        syncMacroTabs();
        renderCatalogArea();
      });
    });

    // Search input
    document.getElementById("menu-search").addEventListener("input", (e) => {
      searchQuery = e.target.value;
      renderCatalogArea();
    });

    // View mode switch
    document.getElementById("view-by-region-btn").addEventListener("click", () => {
      viewMode = "region";
      searchQuery = "";
      document.getElementById("menu-search").value = "";
      renderCatalogArea();
    });

    document.getElementById("view-all-btn").addEventListener("click", () => {
      viewMode = "all";
      renderCatalogArea();
    });

    // SVG Map pins click & hover
    const pinsLayer = document.getElementById("atlas-map-pins");
    pinsLayer.addEventListener("click", (e) => {
      const pin = e.target.closest(".map-pin");
      if (!pin) return;
      selectRegion(pin.dataset.regionId, true);
    });
    pinsLayer.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        const pin = e.target.closest(".map-pin");
        if (pin) {
          e.preventDefault();
          selectRegion(pin.dataset.regionId, true);
        }
      }
    });
    pinsLayer.addEventListener("mouseover", (e) => {
      const pin = e.target.closest(".map-pin");
      if (!pin) return;
      const r = findRegion(pin.dataset.regionId);
      document.getElementById("map-hover-readout").textContent = `${r.code} · ${r.name} (${r.capital})`;
    });
    pinsLayer.addEventListener("mouseleave", () => {
      const active = findRegion(activeRegionId);
      document.getElementById("map-hover-readout").textContent = `${active.code} · ${active.name} (${active.capital})`;
    });

    // 17-Community directory clicks
    document.getElementById("region-directory").addEventListener("click", (e) => {
      const btn = e.target.closest(".region-pill");
      if (!btn) return;
      selectRegion(btn.dataset.regionId, false);
    });

    // Delegated clicks inside Dossier & Full Menu (add to cart, tasting notes, prev/next, focus region, clear search)
    const curadoriaSection = document.getElementById("curadoria");
    curadoriaSection.addEventListener("click", (e) => {
      const addBtn = e.target.closest(".js-add-cart");
      if (addBtn) {
        addToCart(addBtn.dataset.id);
        return;
      }
      const detailBtn = e.target.closest(".js-open-detail");
      if (detailBtn) {
        openProductModal(detailBtn.dataset.id);
        return;
      }
      if (e.target.closest("#prev-region-btn")) {
        stepRegion(-1);
        return;
      }
      if (e.target.closest("#next-region-btn")) {
        stepRegion(1);
        return;
      }
      const focusBtn = e.target.closest(".js-focus-region");
      if (focusBtn) {
        selectRegion(focusBtn.dataset.regionId, true);
        return;
      }
      if (e.target.closest("#clear-search-btn")) {
        searchQuery = "";
        document.getElementById("menu-search").value = "";
        renderCatalogArea();
      }
    });

    // Product modal add
    document.getElementById("product-modal-body").addEventListener("click", (e) => {
      const btn = e.target.closest(".js-modal-add");
      if (!btn) return;
      addToCart(btn.dataset.id);
      closeAllModals();
      openCart();
    });

    // Sommelier routes
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
      const selection = SOMMELIER_ROUTES[activeOccasion].build(guestCount);
      selection.forEach(({ productId, qty }) => addToCart(productId, qty, true));
      showToast(`Rota "${SOMMELIER_ROUTES[activeOccasion].title}" adicionada à sacola!`);
      openCart();
    });

    // Club plans & corporate
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
        "Interesse: Caixas Presente Temáticas por Comunidade Autônoma / Eventos em Brasília",
        "Serviços disponíveis:",
        "• Caixas em madeira natural (a partir de 6 unidades)",
        "• Cartão em papel algodão com motivo regional impresso",
        "• Maestro cortador de Jamón ao vivo sob reserva no Lago Sul",
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

    // Cart drawer
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

    document.getElementById("close-product-modal").addEventListener("click", closeAllModals);
    document.getElementById("close-checkout-modal").addEventListener("click", closeAllModals);
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        closeCart();
        closeAllModals();
      }
    });

    // Mobile nav
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
  renderCatalogArea();
  renderSommelier();
  renderZones();
  renderCart();
  bindEvents();
  initScrollReveal();
})();
