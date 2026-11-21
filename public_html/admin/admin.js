/* ==========================================================================
   O ESPANHOL — Backoffice Operacional Client (RBAC + CSRF)
   ========================================================================== */

(function () {
  "use strict";

  let currentUser = null;
  let csrfToken = "";
  let activeTab = "orders";
  let toastTimer = null;

  const TRANSITIONS_BY_ROLE = {
    COZINHA_CORTE: {
      PAGO: [{ to: "EM_PREPARO", label: "Iniciar Preparo / Corte", cls: "btn--primary" }],
      EM_PREPARO: [{ to: "PRONTO_EXPEDICAO", label: "Marcar Pronto p/ Expedição", cls: "btn--primary" }]
    },
    LOGISTICA_ENTREGA: {
      PRONTO_EXPEDICAO: [{ to: "SAIU_PARA_ENTREGA", label: "Iniciar Rota Refrigerada", cls: "btn--primary" }],
      SAIU_PARA_ENTREGA: [{ to: "ENTREGUE", label: "Confirmar Entrega", cls: "btn--primary" }]
    },
    CONCIERGE: {
      PENDENTE_PAGAMENTO: [{ to: "CANCELADO", label: "Cancelar (Não Pago)", cls: "btn--danger" }]
    },
    GERENTE_OP: {
      PENDENTE_PAGAMENTO: [
        { to: "PAGO", label: "Confirmar Pagamento", cls: "btn--primary" },
        { to: "CANCELADO", label: "Cancelar", cls: "btn--danger" }
      ],
      PAGO: [
        { to: "EM_PREPARO", label: "Enviar p/ Cozinha", cls: "btn--primary" },
        { to: "CANCELADO", label: "Cancelar", cls: "btn--danger" }
      ],
      EM_PREPARO: [{ to: "PRONTO_EXPEDICAO", label: "Pronto p/ Expedição", cls: "btn--primary" }],
      PRONTO_EXPEDICAO: [{ to: "SAIU_PARA_ENTREGA", label: "Saiu p/ Entrega", cls: "btn--primary" }],
      SAIU_PARA_ENTREGA: [{ to: "ENTREGUE", label: "Marcar Entregue", cls: "btn--primary" }],
      ENTREGUE: [{ to: "ESTORNADO", label: "Registrar Estorno", cls: "btn--danger" }]
    },
    ADMIN: {
      PENDENTE_PAGAMENTO: [
        { to: "PAGO", label: "Confirmar Pagamento", cls: "btn--primary" },
        { to: "CANCELADO", label: "Cancelar", cls: "btn--danger" }
      ],
      PAGO: [
        { to: "EM_PREPARO", label: "Enviar p/ Cozinha", cls: "btn--primary" },
        { to: "CANCELADO", label: "Cancelar", cls: "btn--danger" }
      ],
      EM_PREPARO: [{ to: "PRONTO_EXPEDICAO", label: "Pronto p/ Expedição", cls: "btn--primary" }],
      PRONTO_EXPEDICAO: [{ to: "SAIU_PARA_ENTREGA", label: "Saiu p/ Entrega", cls: "btn--primary" }],
      SAIU_PARA_ENTREGA: [{ to: "ENTREGUE", label: "Marcar Entregue", cls: "btn--primary" }],
      ENTREGUE: [{ to: "ESTORNADO", label: "Registrar Estorno", cls: "btn--danger" }]
    }
  };

  const formatCents = (c) =>
    ((Number(c) || 0) / 100).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

  const esc = (s) =>
    String(s ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");

  function toast(msg) {
    const el = document.getElementById("admin-toast");
    el.textContent = msg;
    el.classList.add("is-visible");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove("is-visible"), 2800);
  }

  function hasPerm(perm) {
    return currentUser && Array.isArray(currentUser.permissions) && currentUser.permissions.includes(perm);
  }

  async function api(path, options = {}) {
    const headers = Object.assign({ Accept: "application/json" }, options.headers || {});
    if (options.body && !headers["Content-Type"]) {
      headers["Content-Type"] = "application/json";
    }
    if (options.method && options.method !== "GET" && csrfToken) {
      headers["X-CSRF-Token"] = csrfToken;
    }

    const res = await fetch(`../api/${path}`, Object.assign({}, options, { headers, credentials: "same-origin" }));
    const data = await res.json().catch(() => ({}));

    if (res.status === 401 && path !== "auth/login.php") {
      showLogin("Sessão expirada. Faça login novamente.");
      throw new Error("Sessão expirada.");
    }
    if (!res.ok) {
      throw new Error(data.error || `Erro HTTP ${res.status}`);
    }
    return data;
  }

  function showLogin(errorMsg = "") {
    currentUser = null;
    csrfToken = "";
    document.getElementById("app-view").hidden = true;
    document.getElementById("login-view").hidden = false;
    const err = document.getElementById("login-error");
    if (errorMsg) {
      err.textContent = errorMsg;
      err.hidden = false;
    } else {
      err.hidden = true;
    }
  }

  function showApp(user, token) {
    currentUser = user;
    csrfToken = token;
    document.getElementById("login-view").hidden = true;
    document.getElementById("app-view").hidden = false;
    document.getElementById("staff-name").textContent = user.full_name;
    document.getElementById("staff-role").textContent = user.role;
    renderNavTabs();
    switchTab("orders");
  }

  function renderNavTabs() {
    const tabs = [{ id: "orders", label: "Pedidos" }];
    if (hasPerm("catalog.write")) tabs.push({ id: "catalog", label: "Catálogo & Estoque" });
    if (hasPerm("inquiries.manage")) tabs.push({ id: "inquiries", label: "Embaixadas & Corp." });
    if (hasPerm("reports.read")) tabs.push({ id: "reports", label: "Relatórios" });
    if (hasPerm("staff.manage")) tabs.push({ id: "staff", label: "Equipe & RBAC" });
    if (hasPerm("audit.read")) tabs.push({ id: "audit", label: "Auditoria" });

    document.getElementById("admin-tabs").innerHTML = tabs
      .map((t) => `<button class="admin-tab" type="button" data-tab="${t.id}">${t.label}</button>`)
      .join("");
  }

  function switchTab(tabId) {
    activeTab = tabId;
    document.querySelectorAll(".admin-tab").forEach((b) =>
      b.classList.toggle("is-active", b.dataset.tab === tabId)
    );
    document.querySelectorAll(".admin-panel").forEach((p) => {
      p.hidden = p.id !== `panel-${tabId}`;
    });

    if (tabId === "orders") loadOrders();
    if (tabId === "catalog") loadCatalog();
    if (tabId === "inquiries") loadInquiries();
    if (tabId === "reports") loadReports();
    if (tabId === "staff") loadStaff();
    if (tabId === "audit") loadAudit();
  }

  /* ---- 1. Orders ---- */
  async function loadOrders() {
    const params = new URLSearchParams();
    const st = document.getElementById("filter-order-status").value;
    const zn = document.getElementById("filter-order-zone").value;
    const q = document.getElementById("filter-order-q").value.trim();
    if (st) params.set("status", st);
    if (zn) params.set("zone", zn);
    if (q) params.set("q", q);

    try {
      const data = await api(`orders/list.php?${params.toString()}`);
      const container = document.getElementById("orders-container");
      if (!data.orders || data.orders.length === 0) {
        container.innerHTML = `<p style="color:var(--muted);">Nenhum pedido encontrado na fila para os filtros atuais.</p>`;
        return;
      }

      const roleTransitions = TRANSITIONS_BY_ROLE[currentUser.role] || {};

      container.innerHTML = data.orders
        .map((o) => {
          const actions = roleTransitions[o.status] || [];
          const addrHtml = o.address && o.address.street
            ? `<div style="font-size:0.8rem; color:var(--muted);"><strong>Entrega:</strong> ${esc(o.address.street)}, ${esc(o.address.number_text)} — ${esc(o.address.district)} (${esc(o.address.zip_code)})${o.address.reference_note ? " · Ref: " + esc(o.address.reference_note) : ""}</div>`
            : "";
          const custHtml = o.customer
            ? `<div style="font-size:0.82rem;"><strong>${esc(o.customer.name)}</strong> · ${esc(o.customer.phone)}${o.customer.email ? " · " + esc(o.customer.email) : ""}</div>`
            : "";
          const totalHtml = o.totals
            ? `<div class="tabular" style="font-size:0.86rem; font-weight:600; color:var(--wine);">Total: ${formatCents(o.totals.total_cents)}</div>`
            : "";

          return `
            <article class="order-card">
              <div class="order-card-head">
                <div>
                  <div class="order-code">${esc(o.order_code)}</div>
                  <div style="font-size:0.75rem; color:var(--muted);">${esc(o.zone_name)} · ${esc(o.delivery_window || "")}</div>
                </div>
                <span class="status-pill status-pill--${esc(o.status)}">${esc(o.status)}</span>
              </div>
              ${custHtml}
              ${addrHtml}
              ${o.customer_notes ? `<div style="background:var(--linen); padding:0.45rem 0.65rem; font-size:0.79rem;"><strong>Obs.:</strong> ${esc(o.customer_notes)}</div>` : ""}
              <ul class="order-items-mini">
                ${(o.items || []).map((it) => `
                  <li>
                    <strong>${it.quantity}×</strong> ${esc(it.product_name_snapshot)}
                    <span style="color:var(--muted);">(${esc(it.region_name_snapshot)} · ${esc(it.weight_label)})</span>
                    ${it.is_made_to_order ? `<span style="color:var(--terracotta); font-weight:600;"> · Sob encomenda</span>` : ""}
                  </li>`).join("")}
              </ul>
              ${totalHtml}
              ${actions.length > 0 ? `
                <div class="order-actions">
                  ${actions.map((a) => `<button class="btn ${a.cls} btn--sm js-transition" type="button" data-order-id="${o.id}" data-to="${a.to}">${a.label}</button>`).join("")}
                </div>` : ""}
            </article>`;
        })
        .join("");
    } catch (err) {
      toast(err.message);
    }
  }

  /* ---- 2. Catalog ---- */
  async function loadCatalog() {
    const q = document.getElementById("filter-catalog-q").value.trim();
    const qs = new URLSearchParams({ include_inactive: "1" });
    if (q) qs.set("q", q);

    try {
      const data = await api(`catalog/products.php?${qs.toString()}`);
      document.getElementById("catalog-tbody").innerHTML = (data.products || [])
        .map((p) => `
          <tr data-pid="${p.id}">
            <td><strong>${esc(p.sku)}</strong><div style="font-size:0.74rem; color:var(--muted);">${esc(p.region_name)}</div></td>
            <td>${esc(p.name)}</td>
            <td><input class="inline-input tabular js-p-price" type="number" step="0.01" min="1" value="${(p.price_cents / 100).toFixed(2)}" /></td>
            <td><input class="inline-input tabular js-p-stock" type="number" min="0" value="${p.stock_qty}" /></td>
            <td><input class="js-p-mto" type="checkbox" ${p.is_made_to_order ? "checked" : ""} /></td>
            <td><input class="js-p-active" type="checkbox" ${p.is_active ? "checked" : ""} /></td>
            <td><button class="btn btn--primary btn--sm js-save-product" type="button">Salvar</button></td>
          </tr>`)
        .join("");
    } catch (err) {
      toast(err.message);
    }
  }

  /* ---- 3. Corporate Inquiries ---- */
  async function loadInquiries() {
    try {
      const data = await api("inquiries/corporate.php");
      const statuses = ["NOVO", "EM_ATENDIMENTO", "PROPOSTA_ENVIADA", "FECHADO", "CANCELADO"];
      document.getElementById("inquiries-tbody").innerHTML = (data.inquiries || [])
        .map((iq) => `
          <tr data-iqid="${iq.id}">
            <td class="tabular">#${iq.id}</td>
            <td><strong>${esc(iq.organization_name)}</strong><div style="font-size:0.75rem; color:var(--muted);">${esc(iq.contact_name)} · ${esc(iq.phone)} · ${esc(iq.email)}</div></td>
            <td>${iq.box_quantity} caixas<div style="font-size:0.75rem; color:var(--muted);">${esc(iq.event_date || "Sem data")}</div></td>
            <td>${esc(iq.preferred_regions || "A definir")}${Number(iq.needs_jamon_carver) ? " · <strong>Cortador ao vivo</strong>" : ""}</td>
            <td>
              <select class="js-iq-status">
                ${statuses.map((s) => `<option value="${s}" ${s === iq.status ? "selected" : ""}>${s}</option>`).join("")}
              </select>
            </td>
            <td><button class="btn btn--secondary btn--sm js-save-iq" type="button">Salvar</button></td>
          </tr>`)
        .join("");
    } catch (err) {
      toast(err.message);
    }
  }

  /* ---- 4. Reports ---- */
  async function loadReports() {
    try {
      const data = await api("admin/reports.php?days=30");
      const s = data.summary || {};
      document.getElementById("reports-kpis").innerHTML = `
        <div class="kpi-card"><div class="kpi-label">Pedidos (30 dias)</div><div class="kpi-value tabular">${s.total_orders || 0}</div></div>
        <div class="kpi-card"><div class="kpi-label">Receita Confirmada</div><div class="kpi-value tabular">${formatCents(s.paid_revenue_cents)}</div></div>
        <div class="kpi-card"><div class="kpi-label">Ticket Médio</div><div class="kpi-value tabular">${formatCents(s.avg_ticket_cents)}</div></div>
        <div class="kpi-card"><div class="kpi-label">Alertas de Estoque (&le;5)</div><div class="kpi-value tabular">${(data.low_stock || []).length}</div></div>
      `;
      document.getElementById("reports-regions-tbody").innerHTML = (data.top_regions || [])
        .map((r) => `<tr><td>${esc(r.region_name)}</td><td class="tabular">${r.units_sold}</td><td class="tabular">${formatCents(r.revenue_cents)}</td></tr>`)
        .join("") || `<tr><td colspan="3" style="color:var(--muted);">Sem vendas registradas no período.</td></tr>`;

      document.getElementById("reports-zones-tbody").innerHTML = (data.by_df_zone || [])
        .map((z) => `<tr><td>${esc(z.zone_name)}</td><td class="tabular">${z.orders_count}</td><td class="tabular">${formatCents(z.revenue_cents)}</td></tr>`)
        .join("") || `<tr><td colspan="3" style="color:var(--muted);">Sem entregas registradas no período.</td></tr>`;
    } catch (err) {
      toast(err.message);
    }
  }

  /* ---- 5. Staff RBAC ---- */
  async function loadStaff() {
    try {
      const data = await api("admin/staff.php");
      document.getElementById("staff-tbody").innerHTML = (data.staff || [])
        .map((u) => `
          <tr data-sid="${u.id}">
            <td><strong>${esc(u.full_name)}</strong><div style="font-size:0.75rem; color:var(--muted);">${esc(u.email)}</div></td>
            <td><span class="status-pill">${esc(u.role)}</span></td>
            <td>${u.is_active ? "Ativo" : "Suspenso"}${u.locked_until ? " (Bloqueado)" : ""}</td>
            <td class="tabular">${esc(u.last_login_at || "Nunca")}</td>
            <td style="display:flex; gap:0.4rem; flex-wrap:wrap;">
              <button class="btn btn--secondary btn--sm js-toggle-staff" type="button" data-active="${u.is_active ? "0" : "1"}">${u.is_active ? "Suspender" : "Ativar"}</button>
              ${u.locked_until ? `<button class="btn btn--secondary btn--sm js-unlock-staff" type="button">Desbloquear</button>` : ""}
            </td>
          </tr>`)
        .join("");
    } catch (err) {
      toast(err.message);
    }
  }

  /* ---- 6. Audit ---- */
  async function loadAudit() {
    try {
      const data = await api("admin/audit.php?limit=80");
      document.getElementById("audit-tbody").innerHTML = (data.logs || [])
        .map((l) => `
          <tr>
            <td class="tabular">${esc(l.created_at)}</td>
            <td>${esc(l.staff_name || "Sistema")} ${l.staff_role ? `(${esc(l.staff_role)})` : ""}</td>
            <td><strong>${esc(l.action)}</strong></td>
            <td>${esc(l.entity_type)} ${l.entity_id ? `#${esc(l.entity_id)}` : ""}</td>
            <td class="tabular">${esc(l.ip_address)}</td>
            <td style="font-size:0.74rem; max-width:280px; word-break:break-word;">${esc(JSON.stringify(l.new_values || l.old_values || {}))}</td>
          </tr>`)
        .join("");
    } catch (err) {
      toast(err.message);
    }
  }

  /* ---- Event Bindings ---- */
  document.getElementById("login-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const errEl = document.getElementById("login-error");
    errEl.hidden = true;
    try {
      const data = await api("auth/login.php", {
        method: "POST",
        body: JSON.stringify({
          email: document.getElementById("login-email").value,
          password: document.getElementById("login-password").value
        })
      });
      showApp(data.user, data.csrf_token);
    } catch (err) {
      errEl.textContent = err.message;
      errEl.hidden = false;
    }
  });

  document.getElementById("logout-btn").addEventListener("click", async () => {
    try {
      await api("auth/logout.php", { method: "POST" });
    } catch { /* ignore */ }
    showLogin();
  });

  document.getElementById("admin-tabs").addEventListener("click", (e) => {
    const btn = e.target.closest(".admin-tab");
    if (btn) switchTab(btn.dataset.tab);
  });

  document.getElementById("refresh-orders-btn").addEventListener("click", loadOrders);
  document.getElementById("filter-order-status").addEventListener("change", loadOrders);
  document.getElementById("filter-order-zone").addEventListener("change", loadOrders);
  document.getElementById("filter-order-q").addEventListener("input", loadOrders);
  document.getElementById("refresh-catalog-btn").addEventListener("click", loadCatalog);
  document.getElementById("filter-catalog-q").addEventListener("input", loadCatalog);
  document.getElementById("refresh-inquiries-btn").addEventListener("click", loadInquiries);
  document.getElementById("refresh-reports-btn").addEventListener("click", loadReports);
  document.getElementById("refresh-audit-btn").addEventListener("click", loadAudit);

  // Order transition clicks
  document.getElementById("orders-container").addEventListener("click", async (e) => {
    const btn = e.target.closest(".js-transition");
    if (!btn) return;
    const note = window.prompt(`Observação opcional para transição → ${btn.dataset.to}:`, "") ?? "";
    try {
      await api("orders/status.php", {
        method: "PATCH",
        body: JSON.stringify({
          order_id: Number(btn.dataset.orderId),
          to_status: btn.dataset.to,
          note
        })
      });
      toast(`Status atualizado para ${btn.dataset.to}`);
      loadOrders();
    } catch (err) {
      toast(err.message);
    }
  });

  // Catalog save
  document.getElementById("catalog-tbody").addEventListener("click", async (e) => {
    const btn = e.target.closest(".js-save-product");
    if (!btn) return;
    const tr = btn.closest("tr");
    try {
      await api("catalog/products.php", {
        method: "PATCH",
        body: JSON.stringify({
          id: Number(tr.dataset.pid),
          price_cents: Math.round(Number(tr.querySelector(".js-p-price").value) * 100),
          stock_qty: Number(tr.querySelector(".js-p-stock").value),
          is_made_to_order: tr.querySelector(".js-p-mto").checked,
          is_active: tr.querySelector(".js-p-active").checked
        })
      });
      toast("Produto atualizado e registrado na auditoria.");
    } catch (err) {
      toast(err.message);
    }
  });

  // Inquiry save
  document.getElementById("inquiries-tbody").addEventListener("click", async (e) => {
    const btn = e.target.closest(".js-save-iq");
    if (!btn) return;
    const tr = btn.closest("tr");
    try {
      await api("inquiries/corporate.php", {
        method: "PATCH",
        body: JSON.stringify({
          id: Number(tr.dataset.iqid),
          status: tr.querySelector(".js-iq-status").value
        })
      });
      toast("Solicitação corporativa atualizada.");
    } catch (err) {
      toast(err.message);
    }
  });

  // Create staff
  document.getElementById("create-staff-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    try {
      await api("admin/staff.php", {
        method: "POST",
        body: JSON.stringify({
          full_name: document.getElementById("st-name").value,
          email: document.getElementById("st-email").value,
          role: document.getElementById("st-role").value,
          password: document.getElementById("st-pass").value
        })
      });
      e.target.reset();
      toast("Empregado cadastrado com sucesso.");
      loadStaff();
    } catch (err) {
      toast(err.message);
    }
  });

  // Toggle/unlock staff
  document.getElementById("staff-tbody").addEventListener("click", async (e) => {
    const toggle = e.target.closest(".js-toggle-staff");
    const unlock = e.target.closest(".js-unlock-staff");
    if (!toggle && !unlock) return;
    const tr = (toggle || unlock).closest("tr");
    const payload = { id: Number(tr.dataset.sid) };
    if (toggle) payload.is_active = toggle.dataset.active === "1";
    if (unlock) payload.unlock = true;

    try {
      await api("admin/staff.php", { method: "PATCH", body: JSON.stringify(payload) });
      toast("Conta atualizada.");
      loadStaff();
    } catch (err) {
      toast(err.message);
    }
  });

  // Boot: check active session
  (async function boot() {
    try {
      const data = await api("auth/me.php");
      showApp(data.user, data.csrf_token);
    } catch {
      showLogin();
    }
  })();
})();
