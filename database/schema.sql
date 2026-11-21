-- =============================================================================
-- O ESPANHOL (oespanhol.com.br) — Schema Relacional MySQL 11.4
-- Hospedagem alvo: KingHost (InnoDB, utf8mb4_unicode_ci)
-- =============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET time_zone = '-03:00';
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. Empregados e Controle de Acesso (RBAC)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS staff_users (
  id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name           VARCHAR(160)    NOT NULL,
  email               VARCHAR(190)    NOT NULL,
  password_hash       VARCHAR(255)    NOT NULL,
  role                ENUM(
                        'ADMIN',
                        'GERENTE_OP',
                        'CONCIERGE',
                        'COZINHA_CORTE',
                        'LOGISTICA_ENTREGA'
                      )               NOT NULL,
  is_active           TINYINT(1)      NOT NULL DEFAULT 1,
  failed_attempts     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  locked_until        DATETIME        NULL,
  password_changed_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at       DATETIME        NULL,
  created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_staff_users_email (email),
  KEY idx_staff_users_role_active (role, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Trilha de Auditoria
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  staff_user_id   BIGINT UNSIGNED NULL,
  action          VARCHAR(80)     NOT NULL,
  entity_type     VARCHAR(60)     NOT NULL,
  entity_id       VARCHAR(64)     NULL,
  old_values_json JSON            NULL,
  new_values_json JSON            NULL,
  ip_address      VARCHAR(45)     NOT NULL,
  user_agent      VARCHAR(255)    NULL,
  created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_staff_created (staff_user_id, created_at),
  KEY idx_audit_entity (entity_type, entity_id),
  KEY idx_audit_created (created_at),
  CONSTRAINT fk_audit_logs_staff
    FOREIGN KEY (staff_user_id) REFERENCES staff_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. Comunidades Autônomas da Espanha (17 Regiões)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS regions (
  id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  slug          VARCHAR(64)   NOT NULL,
  code          CHAR(2)       NOT NULL,
  name          VARCHAR(100)  NOT NULL,
  spanish_name  VARCHAR(120)  NOT NULL,
  capital       VARCHAR(120)  NOT NULL,
  macro_region  ENUM('norte', 'mediterraneo', 'interior', 'sul') NOT NULL,
  macro_label   VARCHAR(60)   NOT NULL,
  accent_hex    CHAR(7)       NOT NULL,
  accent_soft   VARCHAR(40)   NOT NULL,
  motif_key     VARCHAR(40)   NOT NULL,
  motif_label   VARCHAR(140)  NOT NULL,
  dops_json     JSON          NOT NULL,
  tagline       VARCHAR(255)  NOT NULL,
  story         TEXT          NOT NULL,
  ritual        TEXT          NOT NULL,
  map_x         SMALLINT UNSIGNED NOT NULL,
  map_y         SMALLINT UNSIGNED NOT NULL,
  sort_order    TINYINT UNSIGNED  NOT NULL,
  is_active     TINYINT(1)    NOT NULL DEFAULT 1,
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_regions_slug (slug),
  UNIQUE KEY uq_regions_code (code),
  KEY idx_regions_macro_sort (macro_region, sort_order),
  KEY idx_regions_active_sort (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. Catálogo de Produtos (Pratos Regionais, Caixas Presente e Planos do Clube)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
  id                 INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  sku                VARCHAR(64)      NOT NULL,
  region_id          INT UNSIGNED     NULL,
  item_type          ENUM('DISH', 'BOX', 'CLUB_PLAN') NOT NULL DEFAULT 'DISH',
  name               VARCHAR(180)     NOT NULL,
  category           VARCHAR(80)      NOT NULL,
  dop_label          VARCHAR(120)     NOT NULL,
  weight_label       VARCHAR(120)     NOT NULL,
  price_cents        INT UNSIGNED     NOT NULL,
  stock_qty          INT UNSIGNED     NOT NULL DEFAULT 25,
  is_made_to_order   TINYINT(1)       NOT NULL DEFAULT 0,
  availability_note  VARCHAR(255)     NULL,
  short_desc         TEXT             NOT NULL,
  origin_detail      VARCHAR(180)     NULL,
  aging_detail       VARCHAR(180)     NULL,
  serving_detail     VARCHAR(220)     NULL,
  pairing_detail     VARCHAR(220)     NULL,
  image_url          VARCHAR(255)     NOT NULL,
  is_active          TINYINT(1)       NOT NULL DEFAULT 1,
  created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_region_active (region_id, is_active),
  KEY idx_products_type_active (item_type, is_active),
  KEY idx_products_category (category),
  CONSTRAINT chk_products_price_positive CHECK (price_cents > 0),
  CONSTRAINT fk_products_region
    FOREIGN KEY (region_id) REFERENCES regions (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. Rotas do Sommelier (Regras de Desconto Auditáveis no Servidor)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sommelier_routes (
  id            INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  slug          VARCHAR(48)       NOT NULL,
  title         VARCHAR(140)      NOT NULL,
  subtitle      VARCHAR(220)      NOT NULL,
  curator_note  TEXT              NOT NULL,
  discount_bps  SMALLINT UNSIGNED NOT NULL DEFAULT 800 COMMENT 'Basis points: 800 = 8.00%',
  rules_json    JSON              NOT NULL COMMENT 'Lista de SKUs e fator de escala por convidado',
  is_active     TINYINT(1)        NOT NULL DEFAULT 1,
  sort_order    TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  created_at    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sommelier_routes_slug (slug),
  CONSTRAINT chk_sommelier_discount_bps CHECK (discount_bps <= 5000)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. Zonas de Entrega Refrigerada no Distrito Federal
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS delivery_zones (
  id                       INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  slug                     VARCHAR(64)      NOT NULL,
  name                     VARCHAR(100)     NOT NULL,
  eta_label                VARCHAR(60)      NOT NULL,
  fee_cents                INT UNSIGNED     NOT NULL,
  free_shipping_min_cents  INT UNSIGNED     NOT NULL,
  delivery_note            TEXT             NOT NULL,
  is_active                TINYINT(1)       NOT NULL DEFAULT 1,
  sort_order               TINYINT UNSIGNED NOT NULL DEFAULT 1,
  created_at               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_delivery_zones_slug (slug),
  KEY idx_delivery_zones_active_sort (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. Clientes e Endereços no DF
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name   VARCHAR(160)    NOT NULL,
  email       VARCHAR(190)    NOT NULL,
  phone       VARCHAR(32)     NOT NULL,
  cpf         VARCHAR(14)     NULL,
  created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_customers_email (email),
  KEY idx_customers_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_addresses (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id       BIGINT UNSIGNED NOT NULL,
  delivery_zone_id  INT UNSIGNED    NOT NULL,
  zip_code          VARCHAR(10)     NOT NULL,
  street            VARCHAR(180)    NOT NULL COMMENT 'Quadra / SHIS / SQS / SQN / Logradouro',
  number_text       VARCHAR(40)     NOT NULL COMMENT 'Conjunto / Bloco / Casa / Apto',
  complement        VARCHAR(120)    NULL,
  district          VARCHAR(100)    NOT NULL,
  city              VARCHAR(80)     NOT NULL DEFAULT 'Brasília',
  state_uf          CHAR(2)         NOT NULL DEFAULT 'DF',
  reference_note    VARCHAR(255)    NULL,
  created_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_addresses_customer (customer_id),
  KEY idx_addresses_zone (delivery_zone_id),
  CONSTRAINT fk_addresses_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_addresses_zone
    FOREIGN KEY (delivery_zone_id) REFERENCES delivery_zones (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. Pedidos, Itens e Histórico de Estados
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id                         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_code                 VARCHAR(32)     NOT NULL,
  customer_id                BIGINT UNSIGNED NOT NULL,
  address_id                 BIGINT UNSIGNED NULL,
  delivery_zone_id           INT UNSIGNED    NOT NULL,
  fulfillment_type           ENUM('DELIVERY', 'PICKUP_ATELIER') NOT NULL DEFAULT 'DELIVERY',
  delivery_window            VARCHAR(80)     NULL COMMENT 'Ex.: Hoje 18h-20h / Retirada CLS 405',
  sommelier_route_slug       VARCHAR(48)     NULL,
  status                     ENUM(
                               'PENDENTE_PAGAMENTO',
                               'PAGO',
                               'EM_PREPARO',
                               'PRONTO_EXPEDICAO',
                               'SAIU_PARA_ENTREGA',
                               'ENTREGUE',
                               'CANCELADO',
                               'ESTORNADO'
                             )               NOT NULL DEFAULT 'PENDENTE_PAGAMENTO',
  subtotal_cents             INT UNSIGNED    NOT NULL,
  discount_cents             INT UNSIGNED    NOT NULL DEFAULT 0,
  shipping_cents             INT UNSIGNED    NOT NULL DEFAULT 0,
  total_cents                INT UNSIGNED    NOT NULL,
  customer_notes             TEXT            NULL,
  assigned_kitchen_staff_id  BIGINT UNSIGNED NULL,
  assigned_courier_staff_id  BIGINT UNSIGNED NULL,
  created_at                 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at                 DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_code (order_code),
  KEY idx_orders_status_created (status, created_at),
  KEY idx_orders_zone_status (delivery_zone_id, status),
  KEY idx_orders_customer (customer_id),
  CONSTRAINT chk_orders_totals CHECK (total_cents = (subtotal_cents - discount_cents + shipping_cents)),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_orders_address
    FOREIGN KEY (address_id) REFERENCES customer_addresses (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_zone
    FOREIGN KEY (delivery_zone_id) REFERENCES delivery_zones (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_orders_kitchen_staff
    FOREIGN KEY (assigned_kitchen_staff_id) REFERENCES staff_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_courier_staff
    FOREIGN KEY (assigned_courier_staff_id) REFERENCES staff_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS order_items (
  id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id               BIGINT UNSIGNED NOT NULL,
  product_id             INT UNSIGNED    NOT NULL,
  product_name_snapshot  VARCHAR(180)    NOT NULL,
  region_name_snapshot   VARCHAR(100)    NOT NULL,
  unit_price_cents       INT UNSIGNED    NOT NULL,
  quantity               INT UNSIGNED    NOT NULL,
  line_total_cents       INT UNSIGNED    NOT NULL,
  created_at             DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  KEY idx_order_items_product (product_id),
  CONSTRAINT chk_order_items_qty CHECK (quantity > 0),
  CONSTRAINT chk_order_items_line_total CHECK (line_total_cents = unit_price_cents * quantity),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS order_status_history (
  id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id             BIGINT UNSIGNED NOT NULL,
  from_status          VARCHAR(32)     NULL,
  to_status            VARCHAR(32)     NOT NULL,
  changed_by_staff_id  BIGINT UNSIGNED NULL,
  note                 VARCHAR(255)    NULL,
  created_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_status_history_order_created (order_id, created_at),
  CONSTRAINT fk_status_history_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_status_history_staff
    FOREIGN KEY (changed_by_staff_id) REFERENCES staff_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. Pagamentos e Webhooks Idempotentes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
  id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id            BIGINT UNSIGNED NOT NULL,
  provider            VARCHAR(40)     NOT NULL COMMENT 'Ex.: asaas, mercadopago, pagarme, manual',
  provider_reference  VARCHAR(128)    NULL,
  method              ENUM('PIX', 'CREDIT_CARD', 'BOLETO', 'OTHER') NOT NULL DEFAULT 'PIX',
  amount_cents        INT UNSIGNED    NOT NULL,
  status              ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
  paid_at             DATETIME        NULL,
  created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_payments_provider_ref (provider, provider_reference),
  KEY idx_payments_order_status (order_id, status),
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS webhook_events (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  provider       VARCHAR(40)     NOT NULL,
  event_id       VARCHAR(160)    NOT NULL,
  payload_json   JSON            NOT NULL,
  processed_at   DATETIME        NULL,
  status         ENUM('RECEIVED', 'PROCESSED', 'IGNORED', 'FAILED') NOT NULL DEFAULT 'RECEIVED',
  error_message  VARCHAR(255)    NULL,
  created_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_webhook_provider_event (provider, event_id),
  KEY idx_webhook_status_created (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 10. Assinaturas Clube La Mesa e Presentes Corporativos / Embaixadas
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS club_subscriptions (
  id                      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id             BIGINT UNSIGNED NOT NULL,
  address_id              BIGINT UNSIGNED NOT NULL,
  product_id              INT UNSIGNED    NOT NULL,
  plan_name_snapshot      VARCHAR(180)    NOT NULL,
  monthly_price_cents     INT UNSIGNED    NOT NULL,
  status                  ENUM('ATIVA', 'PAUSADA', 'INADIMPLENTE', 'CANCELADA') NOT NULL DEFAULT 'ATIVA',
  preferred_delivery_day  VARCHAR(60)     NOT NULL DEFAULT 'Primeira sexta-feira do mês',
  started_at              DATE            NOT NULL,
  next_billing_date       DATE            NOT NULL,
  notes                   TEXT            NULL,
  created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_club_sub_customer_status (customer_id, status),
  KEY idx_club_sub_next_billing (status, next_billing_date),
  CONSTRAINT fk_club_sub_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_club_sub_address
    FOREIGN KEY (address_id) REFERENCES customer_addresses (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_club_sub_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS corporate_inquiries (
  id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_name   VARCHAR(180)    NOT NULL,
  contact_name        VARCHAR(160)    NOT NULL,
  email               VARCHAR(190)    NOT NULL,
  phone               VARCHAR(32)     NOT NULL,
  box_quantity        INT UNSIGNED    NOT NULL DEFAULT 6,
  preferred_regions   VARCHAR(255)    NULL,
  event_date          DATE            NULL,
  needs_jamon_carver  TINYINT(1)      NOT NULL DEFAULT 0,
  notes               TEXT            NULL,
  status              ENUM(
                        'NOVO',
                        'EM_ATENDIMENTO',
                        'PROPOSTA_ENVIADA',
                        'FECHADO',
                        'CANCELADO'
                      )               NOT NULL DEFAULT 'NOVO',
  assigned_staff_id   BIGINT UNSIGNED NULL,
  created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_corp_status_created (status, created_at),
  KEY idx_corp_assigned (assigned_staff_id),
  CONSTRAINT fk_corp_assigned_staff
    FOREIGN KEY (assigned_staff_id) REFERENCES staff_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
