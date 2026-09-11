# Deploy de staging e produção — MailFlow v0.16

A publicação é dividida em **staging aprovado** e só depois **produção**. Não pule o gate operacional.

# Fase A — Staging

## 1. Servidor

Pré-requisitos:

- Docker Engine + Docker Compose v2;
- portas 80 e 443 públicas;
- DNS do host de staging apontando para o servidor;
- armazenamento persistente para PostgreSQL/Caddy/backups;
- Python 3 disponível no host para os scripts do gate;
- `curl` disponível.

## 2. Ambiente

```bash
cp .env.staging.example .env.staging
```

Substitua todos os placeholders. O primeiro ciclo permanece:

```env
MAIL_PROVIDER=console
```

Assim a homologação operacional não envia e-mails externos.

## 3. Preflight

```bash
python3 ops/staging_preflight.py \
  --env-file .env.staging \
  --compose-file docker-compose.staging.yml
```

Não prossiga em caso de FAIL.

## 4. Gate automatizado

Com DNS já propagado:

```bash
./ops/staging_gate.sh
```

O gate:

1. valida a configuração;
2. executa `docker compose up -d --build`;
3. aguarda HTTPS, `/live` e `/ready`;
4. executa o smoke HTTP;
5. para o worker e exige falha de readiness;
6. reinicia o worker e exige recuperação;
7. cria backup;
8. restaura o backup em banco PostgreSQL temporário;
9. compara tabelas críticas e Alembic;
10. mantém staging no ar para inspeção manual.

Leia `STAGING_OPERACIONAL.md`.

## 5. Inspeção manual obrigatória

Depois do PASS automatizado:

- abrir o frontend em desktop e mobile;
- observar console do navegador;
- navegar por Contatos, Segmentos, Campanhas, Automações, Eventos e Relatórios;
- confirmar que não há secrets no HTML/JS/network responses;
- confirmar certificado TLS válido;
- confirmar cookies `Secure`, `HttpOnly` onde aplicável e prefixo `__Host-`;
- testar upload CSV real pequeno;
- revisar os logs JSON do API/worker/Caddy.

## 6. Segunda bateria controlada com Resend

Somente depois do staging em console estar aprovado:

- configure um domínio/subdomínio de teste;
- SPF/DKIM/DMARC;
- webhook público;
- poucos destinatários internos e consentidos;
- valide Gmail/Outlook/Yahoo, clique, abertura, bounce e one-click unsubscribe.

Não aumente volume no staging.

# Fase B — Produção

Produção só começa depois de registrar formalmente o PASS do staging.

## 1. Ambiente

```bash
cp .env.production.example .env.production
```

Preencha domínio, senha do PostgreSQL, quatro secrets independentes, `RESEND_API_KEY` e `RESEND_WEBHOOK_SECRET`.

## 2. Banco

Instalação nova:

```bash
docker compose --env-file .env.production -f docker-compose.production.yml run --rm migrate
```

Base v0.14 sem Alembic:

```bash
cd backend
DATABASE_URL='...' python scripts/upgrade_existing_v14.py
```

Banco já gerenciado:

```bash
alembic upgrade head
```

Faça backup antes de qualquer upgrade de base existente.

## 3. Subir

```bash
docker compose --env-file .env.production -f docker-compose.production.yml up -d --build
```

Confirme `/api/health/live` e `/api/health/ready` = 200.

## 4. Primeira campanha real

Use um grupo pequeno e consentido. Só aumente volume depois de validar entrega, eventos, descadastro, reclamações e observabilidade.

# Rollback

- código: reverta apenas para uma imagem compatível com o schema atual;
- dados: para incidente de dados, prefira restore de um backup validado;
- nunca execute downgrade Alembic destrutivo às cegas.
