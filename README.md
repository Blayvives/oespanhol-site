# O Espanhol (`oespanhol.com.br`) — E-commerce, Assinaturas e Logística Refrigerada (DF)

Sistema completo de vitrine editorial das **17 Comunidades Autônomas da Espanha**, **Rotas do Sommelier**, **Clube La Mesa**, **Presentes & Embaixadas**, **Checkout com cálculo server-side no DF** e **Backoffice Operacional com RBAC**, projetado para hospedagem Linux **KingHost** com **PHP 8.x + PDO** e **MySQL 11.4**.

## Estrutura do Repositório (Fonte Única de Verdade)

```text
oespanhol-site/
├── database/
│   ├── schema.sql               # 15 tabelas InnoDB (utf8mb4_unicode_ci)
│   └── seed.sql                 # 17 regiões, 59 itens (56 pratos + 3 extras), 8 zonas DF e 4 rotas
├── app_private/                 # Idealmente posicionada ACIMA de www/ na KingHost
│   ├── .htaccess                # Bloqueio HTTP direto (defesa em profundidade)
│   ├── config.example.php       # Modelo de configuração sem segredos hardcoded
│   ├── db.php                   # PDO singleton com failover KingHost e transações
│   ├── rbac.php                 # Autenticação Argon2id/bcrypt, CSRF, RBAC, máquina de estados e auditoria
│   ├── bootstrap.php            # Cabeçalhos de segurança e handler centralizado de exceções
│   └── services/
│       ├── PricingService.php   # Cálculo server-side de preços, descontos de rota e frete DF
│       ├── OrderService.php     # Transação BEGIN/FOR UPDATE/COMMIT, baixa/estorno de estoque e projeções RBAC
│       └── PaymentService.php   # Cobranças e webhooks assinados/idempotentes
└── public_html/                 # Raiz pública (www/) na KingHost
    ├── .htaccess                # HTTPS obrigatório, bloqueio de dotfiles e cache de estáticos
    ├── index.html               # Vitrine editorial das 17 Comunidades + Checkout DF + Corporativo
    ├── styles.css               # Design system editorial + tema dinâmico por região
    ├── data-regions.js          # Motivos SVG e camada fallback estática
    ├── app.js                   # Integração com /api/ (com fallback gracioso sem backend)
    ├── assets/                  # 10 fotografias editoriais otimizadas
    ├── api/                     # Endpoints REST PHP 8.x + PDO
    └── admin/                   # Backoffice operacional por papel RBAC (/admin/)
```

## Papéis RBAC no Backoffice (`/admin/`)
- `ADMIN` — Direção: gestão de equipe/papéis, auditoria, relatórios, catálogo/preços e pedidos.
- `GERENTE_OP` — Operação: pedidos (inclusive cancelamento/estorno), estoque, catálogo, relatórios e propostas corporativas.
- `CONCIERGE` — Atendimento: consulta de clientes/pedidos, cancelamento de não pagos e gestão de *Presentes & Embaixadas*.
- `COZINHA_CORTE` — Produção: fila `PAGO → EM_PREPARO → PRONTO_EXPEDICAO` sem exposição de dados financeiros/pagamento.
- `LOGISTICA_ENTREGA` — Expedição DF: fila `PRONTO_EXPEDICAO → SAIU_PARA_ENTREGA → ENTREGUE` por zona administrativa.

## Implantação na KingHost (MySQL 11.4 + PHP 8.x)
1. Importe `database/schema.sql` e `database/seed.sql` no banco `oespanhol` (`mysql.oespanhol.com.br`).
2. Envie `app_private/` para **fora** de `www/` (ex.: `/home/oespanhol/app_private/`) e o conteúdo de `public_html/` para dentro de `www/`.
3. Crie `app_private/config.local.php` (a partir de `config.example.php`) com as credenciais reais do MySQL e segredos aleatórios (`CSRF_SECRET` e `PAYMENT_WEBHOOK_SECRET`).
4. Crie o primeiro usuário `ADMIN` gerando o hash via PHP:
   ```bash
   php -r "echo password_hash('SUA_SENHA_FORTE', PASSWORD_ARGON2ID), PHP_EOL;"
   ```
5. Acesse `https://oespanhol.com.br/` (vitrine) e `https://oespanhol.com.br/admin/` (backoffice).
