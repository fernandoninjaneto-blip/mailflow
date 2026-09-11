# Validação técnica — MailFlow v0.15

## Testes automatizados

```text
19 passed
```

Cobertura funcional herdada dos Passos 3–14 mais testes novos para:

- CSRF HMAC vinculado à sessão;
- rate limit persistente e reset de bucket;
- heartbeat e health do banco;
- compatibilidade de hashes scrypt legados.

## Alembic

### Banco vazio

Executado:

```bash
alembic upgrade head
alembic check
```

Resultado: `No new upgrade operations detected.`

### Upgrade v0.14 → v0.15

Foi criada uma base real usando o código da v0.14, com workspace, contato e campanha. Em seguida:

```bash
python scripts/upgrade_existing_v14.py
```

Resultado:

- baseline `0001_v14_baseline` aplicado;
- `0002_v15_production` aplicado;
- contato preservado;
- campanha preservada;
- tabelas `security_rate_limits` e `service_heartbeats` criadas;
- `alembic_version = 0002_v15_production`.

## Segurança

Validado em processo separado com middleware ativado:

- requisição autenticada mutável sem CSRF → HTTP 403;
- origem não confiável em login → HTTP 403;
- configuração production-like válida → aceita;
- token CSRF não funciona com outra sessão;
- token CSRF alterado → rejeitado.

## Sintaxe e configuração

- Python `compileall`: OK;
- `node --check frontend/app.js`: OK;
- `node --check frontend/editor.js`: OK;
- YAML `docker-compose.yml`: OK;
- YAML `docker-compose.staging.yml`: OK;
- YAML `docker-compose.production.yml`: OK.

## Limitação do ambiente de validação

O ambiente de execução usado para gerar este pacote **não possui Docker/Caddy/Nginx executáveis disponíveis**, portanto não foi possível fazer `docker compose build/up` nem validar handshake TLS real. Esses testes fazem parte do próximo estágio em um servidor de staging.

Isso não foi substituído por uma afirmação de deploy concluído: a v0.15 está preparada para staging, mas ainda precisa ser executada em infraestrutura real antes de produção.
