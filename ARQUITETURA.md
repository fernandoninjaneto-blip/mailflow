# MailFlow v0.16 — Arquitetura de produção

## Componentes

### Caddy

Termina HTTPS e é o único serviço exposto publicamente no compose de produção.

### Nginx / Frontend

Serve os arquivos estáticos e encaminha `/api/` para a API. Aplica limite de upload e headers de segurança no navegador.

### FastAPI

Responsável pela API, autenticação, campanhas, contatos, relatórios, configurações e webhooks. Não altera o schema automaticamente durante o startup.

### Worker

Processa fila de e-mail e automações. Registra heartbeat persistente no PostgreSQL a cada ciclo.

### PostgreSQL

Fonte persistente de dados, fila, rate limit e heartbeat.

### Resend

Provider externo de entrega. Continua isolado atrás da interface de provider criada nos passos anteriores.

## Inicialização

```text
DB saudável
   ↓
Alembic upgrade head
   ↓
API + Worker
   ↓
Frontend
   ↓
Caddy / HTTPS
```

Se a migração falha, API e worker não sobem pelo Compose.

## Migrações

A v0.15 possui:

- `0001_v14_baseline`: schema completo conhecido da v0.14;
- `0002_v15_production`: tabelas de rate limiting e heartbeat.

Instalações novas executam todas as revisões.

Bases v0.14 existentes usam `scripts/upgrade_existing_v14.py`, que primeiro valida o schema e aplica `stamp` do baseline somente se ele for compatível.

## Segurança de sessão

Produção utiliza:

```text
__Host-mailflow_session
  Secure
  HttpOnly
  SameSite=Lax
  Path=/
```

O token CSRF é independente e legível pelo frontend:

```text
__Host-mailflow_csrf
  Secure
  SameSite=Lax
  Path=/
```

O valor é um nonce assinado por HMAC e explicitamente vinculado ao token da sessão. O frontend replica o valor no header `X-CSRF-Token`; o backend exige cookie, header e assinatura válidos.

## Origin check

POST/PUT/PATCH/DELETE de navegador são limitados às origens definidas em `MAILFLOW_TRUSTED_ORIGINS`.

Webhooks assinados e o endpoint público de descadastro possuem tratamento específico e não dependem de CSRF de sessão.

## Rate limiting

Os buckets ficam em `security_rate_limits`, não na memória do processo. Portanto, continuam válidos quando a API reinicia e podem ser compartilhados por réplicas que usam o mesmo banco.

Proteções iniciais:

- login por e-mail;
- login por IP;
- criação de conta por IP;
- recuperação de senha por e-mail/IP;
- redefinição por IP.

Identidades são armazenadas como HMAC, não como e-mail/IP puro dentro da tabela de rate limit.

## Observabilidade

Logs são emitidos em JSON com:

- timestamp UTC;
- nível;
- serviço;
- request ID;
- método;
- path;
- status;
- duração.

Query strings não entram no log HTTP padrão para reduzir vazamento acidental de PII/tokens.

## Readiness

`/api/health/ready` verifica PostgreSQL. Em produção também verifica `service_heartbeats.worker`.

Um worker ausente, em erro ou com heartbeat antigo torna a API **not ready**, embora o processo continue vivo e `/live` permaneça 200.

## Rede de produção

A rede Docker `backend` contém DB, API, worker e frontend. PostgreSQL e API não publicam portas no host. Caddy publica somente 80/443.

## Backup

O backup usa `pg_dump -Fc`, gera checksum SHA-256 e precisa ser copiado para armazenamento fora do mesmo servidor. Um backup só é considerado válido depois de restore testado em staging.
