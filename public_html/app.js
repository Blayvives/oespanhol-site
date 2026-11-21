/* ==========================================================================
   O ESPANHOL — Storefront Engine (Fase 3: API PHP/MySQL + Fallback Estático)
   Atlas das 17 Comunidades, Sommelier, Entrega DF, Checkout Real & Corporativo
   ========================================================================== */

(function () {
  "use strict";

  const FALLBACK_DATA = window.__OESPANHOL_DATA__ || { MOTIFS: {}, REGIONS: [], EXTRA_ITEMS: {} };
  const MOTIFS = FALLBACK_DATA.MOTIFS;

  let REGIONS = FALLBACK_DATA.REGIONS.slice();
  let EXTRA_ITEMS = Object.assign({}, FALLBACK_DATA.EXTRA_ITEMS);
  let DISH_INDEX = {};
  let apiConnected = false;

  let DF_ZONES = [
    { id: "lago-sul", name: "Lago Sul", eta: "Até 2h30", fee: 24, freeMin: 350, note: "Rota prioritária refrigerada com saída às 11h, 15h e 18h30. Ideal para jantares e recepções à beira-lago." },
    { id: "asa-sul", name: "Asa Sul", eta: "Até 1h45", fee: 16, freeMin: 350, note: "Proximidade imediata do nosso Atelier na CLS 405. Retirada sem taxa disponível no mesmo dia." },
    { id: "asa-norte", name: "Asa Norte", eta: "Até 2h15", fee: 18, freeMin: 350, note: "Entregas climatizadas em todas as superquadras e comerciais da Asa Norte até às 20h." },
    { id: "sudoeste", name: "Sudoeste / Octogonal", eta: "Até 2h00", fee: 18, freeMin: 350, note: "Rota expressa saindo do Plano Piloto com embalagem térmica vedada." },
    { id: "noroeste", name: "Noroeste", eta: "Até 2h15", fee: 20, freeMin: 350, note: "Entrega agendada ou expressa no mesmo dia para pedidos confirmados até 18h." },
    { id: "lago-norte", name: "Lago Norte", eta: "Até 2h45", fee: 26, freeMin: 350, note: "Rota refrigerada cobrindo toda a Península dos Ministros e quadras do Lago Norte." },
    { id: "park-way", name: "Park Way", eta: "Até 3h00", fee: 28, freeMin: 400, note: "Entrega refrigerada programada para condomínios do Park Way com confirmação prévia pelo Concierge." },
    { id: "aguas-claras", name: "Águas Claras", eta: "Até 3h00", fee: 26, freeMin: 400, note: "Duas janelas diárias refrigeradas (tarde e noite) com controle rigoroso de temperatura." }
  ];

  let SOMMELIER_ROUTES = {
    sul: {
      title: "Rota do Sul & Dehesa",
      note: "“Uma travessia ensolarada entre Andaluzia e Extremadura: comece com Salmorejo Cordobés e Fino de Jerez, siga para o Jamón 100% Bellota de Jabugo e encerre mergulhando pão rústico na cremosa Torta del Casar.”",
      discountBps: 800,
      rules: [
        { sku: "and-jamon-jabugo", per_guests: 3, min_qty: 1 },
        { sku: "and-salmorejo", per_guests: 3, min_qty: 1 },
        { sku: "ext-torta-casar", fixed_qty: 1 },
        { sku: "and-atum-jerez", per_guests: 4, min_qty: 1 }
      ]
    },
    norte: {
      title: "Rota Atlântica — Norte Verde",
      note: "“O frescor oceânico da Galícia, País Basco e Astúrias: abra com Gildas Donostiarras e Txakoli gelado, sirva o Polvo à Feira sobre tábuas de madeira com Albariño e feche com o Idiazabal defumado.”",
      discountBps: 800,
      rules: [
        { sku: "gal-pulpo", per_guests: 3, min_qty: 1 },
        { sku: "eus-gildas", per_guests: 4, min_qty: 1 },
        { sku: "eus-idiazabal", fixed_qty: 1 },
        { sku: "gal-albarino", per_guests: 4, min_qty: 1 },
        { sku: "ast-sidra", per_guests: 6, min_qty: 1 }
      ]
    },
    mediterraneo: {
      title: "Rota Mediterrânea & Ilhas",
      note: "“Almoço luminoso do Levante às Baleares: Escalivada catalã e Sobrassada de Mallorca com Cava Brut Nature enquanto a Paella Valenciana descansa por 5 minutos, fechando com Turrón de Jijona.”",
      discountBps: 800,
      rules: [
        { sku: "val-kit-paella", per_guests: 4, min_qty: 1 },
        { sku: "cat-escalivada", per_guests: 4, min_qty: 1 },
        { sku: "bal-sobrassada", fixed_qty: 1 },
        { sku: "cat-cava", per_guests: 4, min_qty: 1 },
        { sku: "val-turron", fixed_qty: 1 }
      ]
    },
    meseta: {
      title: "Rota da Meseta Real & La Rioja",
      note: "“Clássicos solenes do interior espanhol: Vermute de Madri e azeitonas Campo Real no aperitivo, Queijo Manchego 12 meses, Paleta de Guijuelo e o Rioja Gran Reserva 2016 decantado.”",
      discountBps: 800,
      rules: [
        { sku: "rio-gran-reserva", per_guests: 4, min_qty: 1 },
        { sku: "clm-manchego", per_guests: 4, min_qty: 1 },
        { sku: "cyl-paleta-guijuelo", per_guests: 3, min_qty: 1 },
        { sku: "mad-vermute", fixed_qty: 1 },
        { sku: "rio-patatas", per_guests: 4, min_qty: 1 }
      ]
    }
  };

  /* State */
  let activeMacro = "todas";
  let activeRegionId = "andaluzia";
  let viewMode = "region";
  let searchQuery = "";
  let activeOccasion = "sul";
  let guestCount = 4;
  let activeZoneId = "lago-sul";
  let activeSommelierRouteSlug = null;
  let cart = [{ id: "and-jamon-jabugo", qty: 1 }];
  let serverQuote = null;
  let toastTimer = null;

  /* Helpers */
  const formatBRL = (value) =>
    Number(value).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

  const formatCents = (cents) => formatBRL((Number(cents) || 0) / 100);

  const normalize = (str) =>
    String(str || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");

  function rebuildDishIndex() {
    DISH_INDEX = {};
    REGIONS.forEach((region) => {
      (region.dishes || []).forEach((dish) => {
        const sku = dish.sku || dish.id;
        DISH_INDEX[sku] = Object.assign({}, dish, {
          id: sku,
          sku,
          in_stock: dish.in_stock !== undefined ? dish.in_stock : true,
          is_made_to_order: dish.is_made_to_order !== undefined ? dish.is_made_to_order : sku === "bal-ensaimada",
          availability_note:
            dish.availability_note ||
            (sku === "bal-ensaimada" ? "Sob encomenda — assada fresca nas manhãs de sexta e sábado" : null),
          regionId: region.id,
          regionName: region.name,
          regionCode: region.code,
          regionAccent: region.accent,
          regionAccentSoft: region.accentSoft,
          regionMotifKey: region.motifKey
        });
      });
    });
  }

  const findItem = (sku) => DISH_INDEX[sku] || EXTRA_ITEMS[sku] || null;
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
    toastTimer = setTimeout(() => el.classList.remove("is-visible"), 3000);
  }

  function applyRegionalTheme(region) {
    if (!region) return;
    document.documentElement.style.setProperty("--region-accent", region.accent);
    document.documentElement.style.setProperty("--region-accent-soft", region.accentSoft);
  }

  /* ========================================================================
     0. Live Backend Hydration (Gracefully falls back to static data)
     ======================================================================== */

  async function hydrateFromApi() {
    try {
      const [regRes, zoneRes] = await Promise.all([
        fetch("./api/catalog/regions.php", { headers: { Accept: "application/json" } }),
        fetch("./api/shipping/quote.php", { headers: { Accept: "application/json" } })
      ]);

      if (!regRes.ok || !zoneRes.ok) return;
      const regJson = await regRes.json();
      const zoneJson = await zoneRes.json();

      if (regJson.ok && Array.isArray(regJson.regions) && regJson.regions.length > 0) {
        REGIONS = regJson.regions;
        if (regJson.extra_items) {
          Object.keys(regJson.extra_items).forEach((sku) => {
            const it = regJson.extra_items[sku];
            EXTRA_ITEMS[sku] = Object.assign({}, it, {
              id: sku,
              regionName: it.item_type === "CLUB_PLAN" ? "Clube La Mesa" : "Curadoria Nacional"
            });
          });
        }
        if (Array.isArray(regJson.sommelier_routes) && regJson.sommelier_routes.length > 0) {
          const map = {};
          regJson.sommelier_routes.forEach((rt) => {
            map[rt.slug] = {
              title: rt.title,
              note: rt.note,
              discountBps: rt.discount_bps,
              rules: rt.rules
            };
          });
          SOMMELIER_ROUTES = map;
        }
      }

      if (zoneJson.ok && Array.isArray(zoneJson.zones) && zoneJson.zones.length > 0) {
        DF_ZONES = zoneJson.zones.map((z) => ({
          id: z.slug,
          name: z.name,
          eta: z.eta_label,
          fee: z.fee_cents / 100,
          freeMin: z.free_shipping_min_cents / 100,
          note: z.delivery_note
        }));
      }

      apiConnected = true;
      rebuildDishIndex();
      renderCatalogArea();
      renderSommelier();
      renderZones();
      await syncServerQuote();
    } catch {
      apiConnected = false;
    }
  }

  async function syncServerQuote() {
    if (!apiConnected || cart.length === 0) {
      serverQuote = null;
      renderCart();
      return;
    }
    try {
      const fulfillmentEl = document.querySelector('input[name="fulfillment_type"]:checked');
      const fulfillmentType = fulfillmentEl ? fulfillmentEl.value : "DELIVERY";
      const res = await fetch("./api/shipping/quote.php", {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify({
          delivery_zone_slug: activeZoneId,
          fulfillment_type: fulfillmentType,
          sommelier_route_slug: activeSommelierRouteSlug,
          items: cart.map((c) => ({ sku: c.id, qty: c.qty }))
        })
      });
      if (res.ok) {
        const json = await res.json();
        if (json.ok && json.quote) {
          serverQuote = json.quote;
        }
      }
    } catch {
      serverQuote = null;
    }
    renderCart();
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
    if (active) {
      document.getElementById("map-hover-readout").textContent = `${active.code} · ${active.name} (${active.capital})`;
    }
  }

  /* ========================================================================
     2. 17-Community Directory & Dish Card Renderer
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
            <span class="region-pill-count">${(r.dishes || []).length} pratos</span>
          </button>`;
      })
      .join("");
  }

  function renderDishCard(dish, regionAccent) {
    const sku = dish.sku || dish.id;
    const item = DISH_INDEX[sku] || dish;
    const outOfStock = item.in_stock === false;
    const availHtml = outOfStock
      ? `<span class="product-availability product-availability--out">Temporariamente esgotado</span>`
      : item.is_made_to_order && item.availability_note
        ? `<span class="product-availability">${item.availability_note}</span>`
        : "";

    return `
      <article class="product-card" style="--card-accent:${regionAccent};">
        <div class="product-media">
          <img src="${item.img}" alt="${item.name}" loading="lazy" />
          <span class="product-dop">${item.dop}</span>
        </div>
        <div class="product-body">
          <span class="product-category">${item.type}</span>
          <h4 class="product-name">${item.name}</h4>
          <p class="product-desc">${item.shortDesc}</p>
          ${availHtml}
          <div class="product-meta-row">
            <span class="product-weight">${item.weight}</span>
            <span class="product-price">${formatBRL(item.price)}</span>
          </div>
          <div class="product-actions">
            <button class="btn btn--secondary btn--sm js-open-detail" type="button" data-id="${sku}">
              Notas
            </button>
            <button class="btn btn--sm js-add-cart" type="button" data-id="${sku}" ${outOfStock ? "disabled" : ""}
                    style="background-color:${outOfStock ? "#9C8F87" : regionAccent}; border-color:${outOfStock ? "#9C8F87" : regionAccent}; color:#F7F1E8;">
              ${outOfStock ? "Esgotado" : "+ Sacola"}
            </button>
          </div>
        </div>
      </article>`;
  }

  function renderRegionalDossier() {
    const region = findRegion(activeRegionId);
    if (!region) return;
    applyRegionalTheme(region);

    const motifSvg = MOTIFS[region.motifKey] || MOTIFS.mudejar || "";
    const repeatedMotifs = Array.from({ length: 7 }, () => motifSvg).join("");

    document.getElementById("regional-dossier").innerHTML = `
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
            ${(region.dops || []).map((d) => `<span class="dop-tag">${d}</span>`).join("")}
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
          <span style="font-size:0.78rem; color:var(--ink-muted);">${(region.dishes || []).length} especialidades selecionadas para entrega em Brasília</span>
        </div>
        <div class="product-grid">
          ${(region.dishes || []).map((d) => renderDishCard(d, region.accent)).join("")}
        </div>
      </div>
    `;
  }

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
          : (region.dishes || []).filter(
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
        const motifSvg = MOTIFS[region.motifKey] || MOTIFS.mudejar || "";
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
      if (visible.length > 0 && !visible.some((r) => r.id === activeRegionId)) {
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
    if (reg && activeMacro !== "todas" && reg.macro !== activeMacro) {
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
     3. Tasting Sheet Modal
     ======================================================================== */

  function openProductModal(sku) {
    const p = DISH_INDEX[sku];
    if (!p) return;

    const availBlock = p.availability_note
      ? `<p class="product-availability" style="margin-top:0.85rem;">${p.availability_note}</p>`
      : "";

    document.getElementById("product-modal-body").innerHTML = `
      <img class="product-modal-img" src="${p.img}" alt="${p.name}" />
      <div class="product-modal-content">
        <span class="kicker" style="color:${p.regionAccent};">${p.regionName} · ${p.dop}</span>
        <h3 id="modal-product-title" style="font-size: 1.75rem; margin-top: 0.4rem;">${p.name}</h3>
        <p style="color: var(--ink-secondary); font-size: 0.91rem; margin: 0.85rem 0 0;">${p.shortDesc}</p>
        ${availBlock}
        <div class="tasting-specs">
          <div><span class="spec-label">Origem Regional</span><span class="spec-val">${p.origin || "Espanha"}</span></div>
          <div><span class="spec-label">Preparo / Maturação</span><span class="spec-val">${p.aging || "Artesanal"}</span></div>
          <div><span class="spec-label">Ritual de Serviço</span><span class="spec-val">${p.serving || "Temperatura ambiente"}</span></div>
          <div><span class="spec-label">Harmonização</span><span class="spec-val">${p.pairing || "Vinhos ibéricos"}</span></div>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap;">
          <div>
            <div style="font-size: 0.74rem; color: var(--ink-muted);">${p.weight}</div>
            <div style="font-family: var(--font-serif); font-size: 1.6rem;" class="tabular">${formatBRL(p.price)}</div>
          </div>
          <button class="btn js-modal-add" type="button" data-id="${p.sku}" ${p.in_stock === false ? "disabled" : ""}
                  style="background-color:${p.regionAccent}; border-color:${p.regionAccent}; color:#F7F1E8;">
            ${p.in_stock === false ? "Esgotado" : "Adicionar à Sacola"}
          </button>
        </div>
      </div>
    `;
    openModal("product-modal");
  }

  /* ========================================================================
     4. Sommelier Routes
     ======================================================================== */

  function buildRouteSelection(routeKey, guests) {
    const cfg = SOMMELIER_ROUTES[routeKey];
    if (!cfg || !Array.isArray(cfg.rules)) return [];
    return cfg.rules.map((rule) => {
      const qty = rule.fixed_qty
        ? Number(rule.fixed_qty)
        : Math.max(Number(rule.min_qty || 1), Math.ceil(guests / Number(rule.per_guests || 4)));
      return { productId: rule.sku, qty };
    });
  }

  function renderSommelier() {
    const cfg = SOMMELIER_ROUTES[activeOccasion];
    if (!cfg) return;
    const selection = buildRouteSelection(activeOccasion, guestCount);

    document.getElementById("guest-readout").textContent = `${guestCount} pessoas`;
    document.getElementById("pairing-title").textContent = cfg.title;
    document.getElementById("pairing-serves").textContent = `Para ${guestCount} pessoas`;
    document.getElementById("pairing-note").textContent = cfg.note;

    let rawTotal = 0;
    document.getElementById("pairing-list").innerHTML = selection
      .map(({ productId, qty }) => {
        const p = findItem(productId);
        if (!p) return "";
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

    const discountFactor = 1 - (Number(cfg.discountBps || 800) / 10000);
    const discounted = Math.round(rawTotal * discountFactor);
    const saving = rawTotal - discounted;

    document.getElementById("pairing-original").textContent = formatBRL(rawTotal);
    document.getElementById("pairing-total").textContent = formatBRL(discounted);
    document.getElementById("pairing-saving").textContent =
      `Inclui ${(cfg.discountBps || 800) / 100}% de cortesia na rota completa (economia de ${formatBRL(saving)})`;
  }

  /* ========================================================================
     5. DF Delivery Zones & Cart
     ======================================================================== */

  function renderZones() {
    document.getElementById("zone-buttons").innerHTML = DF_ZONES.map(
      (z) => `<button class="zone-btn ${z.id === activeZoneId ? "is-active" : ""}" type="button" data-zone="${z.id}">${z.name}</button>`
    ).join("");

    const optionsHtml = DF_ZONES.map(
      (z) => `<option value="${z.id}" ${z.id === activeZoneId ? "selected" : ""}>${z.name}</option>`
    ).join("");

    document.getElementById("cart-zone-select").innerHTML = optionsHtml;
    document.getElementById("co-zone").innerHTML = optionsHtml;
    updateZoneDisplay();
  }

  function updateZoneDisplay() {
    const z = findZone(activeZoneId);
    if (!z) return;
    document.getElementById("delivery-zone-name").textContent = z.name;
    document.getElementById("delivery-eta").textContent = z.eta;
    document.getElementById("delivery-fee").textContent = formatBRL(z.fee);
    document.getElementById("delivery-free-min").textContent = `Acima de ${formatBRL(z.freeMin)}`;
    document.getElementById("delivery-note").textContent = z.note;

    document.querySelectorAll(".zone-btn").forEach((b) => {
      b.classList.toggle("is-active", b.dataset.zone === activeZoneId);
    });
    document.getElementById("cart-zone-select").value = activeZoneId;
    document.getElementById("co-zone").value = activeZoneId;
  }

  function addToCart(sku, qty = 1, silent = false) {
    const item = findItem(sku);
    if (!item || item.in_stock === false) {
      showToast("Item temporariamente indisponível em estoque.");
      return;
    }
    const existing = cart.find((c) => c.id === sku);
    if (existing) {
      existing.qty += qty;
    } else {
      cart.push({ id: sku, qty });
    }
    syncServerQuote();
    if (!silent) {
      showToast(`Adicionado (${item.regionName}): ${item.name}`);
    }
  }

  function updateCartQty(sku, delta) {
    const idx = cart.findIndex((c) => c.id === sku);
    if (idx === -1) return;
    cart[idx].qty += delta;
    if (cart[idx].qty <= 0) cart.splice(idx, 1);
    syncServerQuote();
  }

  function removeFromCart(sku) {
    cart = cart.filter((c) => c.id !== sku);
    syncServerQuote();
  }

  function computeCartTotals() {
    const zone = findZone(activeZoneId);
    let totalCount = cart.reduce((acc, c) => acc + c.qty, 0);

    if (serverQuote && cart.length > 0) {
      return {
        subtotal: serverQuote.subtotal_cents / 100,
        discount: serverQuote.discount_cents / 100,
        shipping: serverQuote.shipping_cents / 100,
        total: serverQuote.total_cents / 100,
        freeMin: serverQuote.shipping.free_shipping_min_cents / 100,
        remainingForFree: serverQuote.shipping.remaining_for_free_cents / 100,
        totalCount,
        zone
      };
    }

    let subtotal = 0;
    cart.forEach((entry) => {
      const p = findItem(entry.id);
      if (p) subtotal += p.price * entry.qty;
    });

    const fulfillmentEl = document.querySelector('input[name="fulfillment_type"]:checked');
    const isPickup = fulfillmentEl && fulfillmentEl.value === "PICKUP_ATELIER";
    const discount = 0;
    const afterDiscount = subtotal - discount;
    const isFree = isPickup || afterDiscount >= zone.freeMin || subtotal === 0;
    const shipping = subtotal === 0 || isFree ? 0 : zone.fee;

    return {
      subtotal,
      discount,
      shipping,
      total: afterDiscount + shipping,
      freeMin: zone.freeMin,
      remainingForFree: isPickup ? 0 : Math.max(0, zone.freeMin - afterDiscount),
      totalCount,
      zone
    };
  }

  function renderCart() {
    const { subtotal, discount, shipping, total, freeMin, remainingForFree, totalCount, zone } =
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
          if (!p) return "";
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
    const discRow = document.getElementById("cart-discount-row");
    discRow.hidden = discount <= 0;
    document.getElementById("cart-discount").textContent = `-${formatBRL(discount)}`;
    document.getElementById("cart-shipping").textContent =
      subtotal === 0 ? "—" : shipping === 0 ? "Cortesia" : formatBRL(shipping);
    document.getElementById("cart-total").textContent = formatBRL(total);

    // Sync totals inside checkout modal strip
    const metaEl = document.getElementById("co-summary-meta");
    const totEl = document.getElementById("co-summary-total");
    if (metaEl && totEl) {
      metaEl.textContent = `${totalCount} item(ns) · ${shipping === 0 ? "Frete cortesia / retirada" : "Frete " + formatBRL(shipping)}`;
      totEl.textContent = formatBRL(total);
    }
  }

  /* ========================================================================
     6. Real Checkout & Corporate Inquiry Submissions
     ======================================================================== */

  function openCheckoutModal() {
    if (cart.length === 0) {
      showToast("Adicione ao menos um item à sacola para continuar.");
      return;
    }
    document.getElementById("checkout-form").hidden = false;
    document.getElementById("checkout-receipt").hidden = true;
    document.getElementById("checkout-error").hidden = true;
    document.getElementById("checkout-api-badge").textContent = apiConnected
      ? "Servidor MySQL Conectado"
      : "Modo Demonstração Local";
    syncServerQuote();
    openModal("checkout-modal");
  }

  async function handleCheckoutSubmit(e) {
    e.preventDefault();
    const form = e.currentTarget;
    const errEl = document.getElementById("checkout-error");
    const submitBtn = document.getElementById("submit-order-btn");
    errEl.hidden = true;

    const fd = new FormData(form);
    const fulfillmentType = String(fd.get("fulfillment_type") || "DELIVERY");
    const payload = {
      fulfillment_type: fulfillmentType,
      delivery_zone_slug: String(fd.get("delivery_zone_slug") || activeZoneId),
      delivery_window: String(fd.get("delivery_window") || ""),
      payment_method: String(fd.get("payment_method") || "PIX"),
      sommelier_route_slug: activeSommelierRouteSlug,
      customer_notes: String(fd.get("customer_notes") || ""),
      customer: {
        full_name: String(fd.get("full_name") || ""),
        email: String(fd.get("email") || ""),
        phone: String(fd.get("phone") || ""),
        cpf: String(fd.get("cpf") || "")
      },
      address:
        fulfillmentType === "DELIVERY"
          ? {
              zip_code: String(fd.get("zip_code") || ""),
              street: String(fd.get("street") || ""),
              number_text: String(fd.get("number_text") || ""),
              complement: String(fd.get("complement") || ""),
              district: String(fd.get("district") || ""),
              city: "Brasília",
              state_uf: "DF",
              reference_note: String(fd.get("reference_note") || "")
            }
          : null,
      items: cart.map((c) => ({ sku: c.id, qty: c.qty }))
    };

    submitBtn.disabled = true;
    submitBtn.textContent = "Processando...";

    try {
      if (apiConnected) {
        const res = await fetch("./api/orders/create.php", {
          method: "POST",
          headers: { "Content-Type": "application/json", Accept: "application/json" },
          body: JSON.stringify(payload)
        });
        const json = await res.json();
        if (!res.ok || !json.ok) {
          throw new Error(json.error || "Não foi possível concluir o pedido.");
        }
        renderServerReceipt(json.order, payload.customer.full_name);
      } else {
        // Fallback em hospedagem puramente estática (ex.: GitHub Pages sem PHP)
        renderStaticDemoReceipt(payload);
      }

      cart = [];
      activeSommelierRouteSlug = null;
      serverQuote = null;
      renderCart();
      form.reset();
    } catch (err) {
      errEl.textContent = err.message || "Erro ao enviar pedido.";
      errEl.hidden = false;
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = "Confirmar Pedido";
    }
  }

  function renderServerReceipt(order, customerName) {
    const lines = [
      `PEDIDO CONFIRMADO — ${order.order_code}`,
      "O ESPANHOL · Empório Ibérico Gourmet (Brasília, DF)",
      "----------------------------------------------------",
      `Cliente: ${customerName}`,
      `Status: ${order.status}`,
      `Modalidade: ${order.fulfillment_type === "PICKUP_ATELIER" ? "Retirada CLS 405 (Asa Sul)" : order.zone_name + " (" + order.eta_label + ")"}`,
      `Janela: ${order.delivery_window}`,
      "----------------------------------------------------",
      ...order.items.map(
        (it) => `• ${it.quantity}x ${it.name} [${it.region_name}] — ${formatCents(it.line_total_cents)}`
      ),
      "----------------------------------------------------",
      `Subtotal: ${formatCents(order.subtotal_cents)}`,
      order.discount_cents > 0 ? `Cortesia Sommelier (${order.applied_route}): -${formatCents(order.discount_cents)}` : null,
      `Entrega refrigerada: ${order.shipping_cents === 0 ? "Cortesia" : formatCents(order.shipping_cents)}`,
      `TOTAL: ${formatCents(order.total_cents)}`,
      "----------------------------------------------------",
      `Pagamento (${order.payment.method}): ${order.payment.provider_reference}`
    ].filter(Boolean);

    document.getElementById("checkout-form").hidden = true;
    document.getElementById("checkout-receipt").hidden = false;
    document.getElementById("receipt-subtitle").textContent =
      `Pedido ${order.order_code} gravado no banco de dados com estoque reservado!`;
    document.getElementById("order-summary-text").textContent = lines.join("\n");
    showToast(`Pedido ${order.order_code} registrado com sucesso!`);
  }

  function renderStaticDemoReceipt(payload) {
    const { subtotal, shipping, total, zone } = computeCartTotals();
    const lines = [
      "RESUMO DE PEDIDO (MODO ESTÁTICO) — O ESPANHOL",
      "----------------------------------------------------",
      `Cliente: ${payload.customer.full_name} (${payload.customer.phone})`,
      payload.fulfillment_type === "DELIVERY"
        ? `Entrega: ${payload.address.street}, ${payload.address.number_text} — ${zone.name} (CEP ${payload.address.zip_code})`
        : "Modalidade: Retirada no Atelier CLS 405 (Asa Sul)",
      `Janela: ${payload.delivery_window} | Pagamento: ${payload.payment_method}`,
      "----------------------------------------------------",
      ...cart.map((c) => {
        const p = findItem(c.id);
        return `• ${c.qty}x ${p.name} [${p.regionName}] — ${formatBRL(p.price * c.qty)}`;
      }),
      "----------------------------------------------------",
      `Subtotal: ${formatBRL(subtotal)} | Frete: ${shipping === 0 ? "Cortesia" : formatBRL(shipping)} | TOTAL: ${formatBRL(total)}`
    ];

    document.getElementById("checkout-form").hidden = true;
    document.getElementById("checkout-receipt").hidden = false;
    document.getElementById("receipt-subtitle").textContent =
      "Ambiente sem backend PHP ativo — resumo gerado localmente para envio ao Concierge.";
    document.getElementById("order-summary-text").textContent = lines.join("\n");
  }

  async function handleCorporateSubmit(e) {
    e.preventDefault();
    const form = e.currentTarget;
    const errEl = document.getElementById("corp-error");
    const btn = document.getElementById("submit-corp-btn");
    errEl.hidden = true;

    const fd = new FormData(form);
    const payload = {
      organization_name: String(fd.get("organization_name") || ""),
      contact_name: String(fd.get("contact_name") || ""),
      email: String(fd.get("email") || ""),
      phone: String(fd.get("phone") || ""),
      box_quantity: Number(fd.get("box_quantity") || 6),
      event_date: String(fd.get("event_date") || "") || null,
      preferred_regions: String(fd.get("preferred_regions") || ""),
      needs_jamon_carver: fd.get("needs_jamon_carver") === "on",
      notes: String(fd.get("notes") || "")
    };

    btn.disabled = true;
    btn.textContent = "Enviando...";

    try {
      if (apiConnected) {
        const res = await fetch("./api/inquiries/corporate.php", {
          method: "POST",
          headers: { "Content-Type": "application/json", Accept: "application/json" },
          body: JSON.stringify(payload)
        });
        const json = await res.json();
        if (!res.ok || !json.ok) {
          throw new Error(json.error || "Não foi possível registrar sua solicitação.");
        }
        showToast(`Solicitação #${json.inquiry_id} registrada para o Concierge!`);
      } else {
        showToast("Solicitação preparada (ative o backend PHP/MySQL na KingHost para persistir).");
      }
      form.reset();
      closeAllModals();
    } catch (err) {
      errEl.textContent = err.message || "Erro ao enviar solicitação.";
      errEl.hidden = false;
    } finally {
      btn.disabled = false;
      btn.textContent = "Enviar Solicitação ao Concierge";
    }
  }

  /* ========================================================================
     7. Drawers, Modals & Event Bindings
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

  function bindEvents() {
    document.getElementById("macro-tabs").addEventListener("click", (e) => {
      const btn = e.target.closest(".macro-tab");
      if (!btn) return;
      activeMacro = btn.dataset.macro;
      syncMacroTabs();
      renderCatalogArea();
    });

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

    document.getElementById("menu-search").addEventListener("input", (e) => {
      searchQuery = e.target.value;
      renderCatalogArea();
    });

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

    const pinsLayer = document.getElementById("atlas-map-pins");
    pinsLayer.addEventListener("click", (e) => {
      const pin = e.target.closest(".map-pin");
      if (pin) selectRegion(pin.dataset.regionId, true);
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
      if (r) document.getElementById("map-hover-readout").textContent = `${r.code} · ${r.name} (${r.capital})`;
    });
    pinsLayer.addEventListener("mouseleave", () => {
      const active = findRegion(activeRegionId);
      if (active) document.getElementById("map-hover-readout").textContent = `${active.code} · ${active.name} (${active.capital})`;
    });

    document.getElementById("region-directory").addEventListener("click", (e) => {
      const btn = e.target.closest(".region-pill");
      if (btn) selectRegion(btn.dataset.regionId, false);
    });

    document.getElementById("curadoria").addEventListener("click", (e) => {
      const addBtn = e.target.closest(".js-add-cart");
      if (addBtn) return addToCart(addBtn.dataset.id);
      const detailBtn = e.target.closest(".js-open-detail");
      if (detailBtn) return openProductModal(detailBtn.dataset.id);
      if (e.target.closest("#prev-region-btn")) return stepRegion(-1);
      if (e.target.closest("#next-region-btn")) return stepRegion(1);
      const focusBtn = e.target.closest(".js-focus-region");
      if (focusBtn) return selectRegion(focusBtn.dataset.regionId, true);
      if (e.target.closest("#clear-search-btn")) {
        searchQuery = "";
        document.getElementById("menu-search").value = "";
        renderCatalogArea();
      }
    });

    document.getElementById("product-modal-body").addEventListener("click", (e) => {
      const btn = e.target.closest(".js-modal-add");
      if (!btn) return;
      addToCart(btn.dataset.id);
      closeAllModals();
      openCart();
    });

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
      const selection = buildRouteSelection(activeOccasion, guestCount);
      activeSommelierRouteSlug = activeOccasion;
      selection.forEach(({ productId, qty }) => addToCart(productId, qty, true));
      showToast(`Rota "${SOMMELIER_ROUTES[activeOccasion].title}" adicionada (cortesia 8% aplicada)!`);
      openCart();
    });

    document.querySelectorAll(".club-add-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        addToCart(btn.dataset.planId);
        openCart();
      });
    });

    document.getElementById("corporate-inquiry-btn").addEventListener("click", () => {
      document.getElementById("corp-error").hidden = true;
      openModal("corporate-modal");
    });

    document.getElementById("zone-buttons").addEventListener("click", (e) => {
      const btn = e.target.closest(".zone-btn");
      if (!btn) return;
      activeZoneId = btn.dataset.zone;
      updateZoneDisplay();
      syncServerQuote();
    });

    document.getElementById("cart-zone-select").addEventListener("change", (e) => {
      activeZoneId = e.target.value;
      updateZoneDisplay();
      syncServerQuote();
    });

    document.getElementById("co-zone").addEventListener("change", (e) => {
      activeZoneId = e.target.value;
      updateZoneDisplay();
      syncServerQuote();
    });

    document.querySelectorAll('input[name="fulfillment_type"]').forEach((radio) => {
      radio.addEventListener("change", () => {
        const isDelivery = radio.value === "DELIVERY" && radio.checked;
        document.getElementById("co-address-fields").style.display = isDelivery ? "flex" : "none";
        syncServerQuote();
      });
    });

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

    document.getElementById("checkout-btn").addEventListener("click", openCheckoutModal);
    document.getElementById("checkout-form").addEventListener("submit", handleCheckoutSubmit);
    document.getElementById("corporate-form").addEventListener("submit", handleCorporateSubmit);

    document.getElementById("copy-order-btn").addEventListener("click", () => {
      const text = document.getElementById("order-summary-text").textContent;
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(() => showToast("Comprovante copiado!"));
      }
    });

    document.getElementById("clear-and-close-btn").addEventListener("click", closeAllModals);
    document.getElementById("close-product-modal").addEventListener("click", closeAllModals);
    document.getElementById("close-checkout-modal").addEventListener("click", closeAllModals);
    document.getElementById("close-corporate-modal").addEventListener("click", closeAllModals);
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        closeCart();
        closeAllModals();
      }
    });

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
  rebuildDishIndex();
  renderCatalogArea();
  renderSommelier();
  renderZones();
  renderCart();
  bindEvents();
  initScrollReveal();
  hydrateFromApi();
})();
