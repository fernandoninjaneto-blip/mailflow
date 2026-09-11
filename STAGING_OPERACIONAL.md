# MailFlow v0.16 — Staging e teste operacional

Este passo transforma a homologação em um **gate repetível**, em vez de depender apenas de uma checklist manual.

## Objetivo

Antes de produção, staging precisa comprovar:

1. API viva e pronta;
2. autenticação + CSRF + Origin funcionando;
3. rate limiting ativo;
4. importação e gestão de contatos;
5. listas e segmentos;
6. campanha, revisão, fila e worker;
7. supressão;
8. automações;
9. relatórios;
10. detecção de worker parado;
11. recuperação após restart do worker;
12. backup íntegro e restore verificável.

## Gate automatizado no servidor

Depois de configurar `.env.staging` e DNS:

```bash
./ops/staging_gate.sh
```

O script:

```text
preflight
  ↓
docker compose up --build
  ↓
/live = 200
/ready = 200
  ↓
smoke HTTP completo
  ↓
para worker
  ↓
/ready precisa falhar
  ↓
reinicia worker
  ↓
/ready precisa voltar a 200
  ↓
backup PostgreSQL
  ↓
restore em banco temporário
  ↓
compara dados críticos
  ↓
PASS
```

O ambiente permanece no ar ao final para inspeção manual.

## Preflight

```bash
python3 ops/staging_preflight.py \
  --env-file .env.staging \
  --compose-file docker-compose.staging.yml
```

Valida:

- host preenchido;
- ausência de placeholders;
- senha PostgreSQL mínima;
- quatro segredos independentes com tamanho mínimo;
- `MAIL_PROVIDER=console` no primeiro staging;
- serviços obrigatórios no Compose;
- `docker compose config -q`.

## Smoke HTTP

Pode ser executado sozinho:

```bash
python3 ops/staging_smoke.py \
  --base-url https://staging.seudominio.com.br
```

O smoke cria um workspace isolado com identificador aleatório e testa:

- liveness/readiness;
- cadastro;
- cookies de sessão e CSRF;
- logout/login;
- 429 após excesso de tentativas de login;
- importação CSV;
- busca de contatos;
- lista e membros;
- segmento e preview;
- template;
- campanha e revisão;
- enfileiramento;
- processamento pelo worker;
- supressão global;
- exclusão da audiência por supressão/status;
- automação manual;
- processamento da automação pelo worker;
- relatórios avançados;
- readiness final.

O endereço usado pelo smoke é `example.com`; nenhum envio externo ocorre porque staging começa em `MAIL_PROVIDER=console`.

## Resiliência do worker

No staging gate, o worker é parado de propósito. Após `MAILFLOW_WORKER_STALE_SECONDS`, `/api/health/ready` precisa deixar de retornar 200.

Depois do restart, o heartbeat precisa se recuperar e `/ready` voltar a 200.

Isso prova que o balanceador/monitor pode distinguir API viva de aplicação realmente pronta para operar filas.

## Backup/restore não destrutivo

O teste anterior restaurava sobre o próprio staging. Na v0.16 isso foi alterado.

Agora:

1. cria `pg_dump -Fc`;
2. valida SHA-256;
3. cria um banco PostgreSQL temporário;
4. restaura o dump nele;
5. compara `workspaces`, `contacts`, `campaigns` e `email_deliveries` com a origem;
6. confirma `alembic_version`;
7. remove o banco temporário.

Comando:

```bash
MAILFLOW_ENVIRONMENT=staging \
ENV_FILE=.env.staging \
COMPOSE_FILE=docker-compose.staging.yml \
./ops/test_backup_restore.sh
```

O script destrutivo `restore_postgres.sh` continua existindo para recuperação real, mas exige `MAILFLOW_CONFIRM_RESTORE=RESTORE`.

## Homologação local sem Docker

Para validar a lógica operacional em uma máquina sem Docker/PostgreSQL público:

```bash
python ops/local_operational_smoke.py
```

Ele cria um banco SQLite temporário, aplica Alembic, sobe Uvicorn e um worker em processos reais, executa o smoke HTTP e testa queda/recuperação do worker.

Isto **não substitui o staging público**, porque não valida PostgreSQL real, Docker, Caddy, DNS ou TLS público. Serve como pré-validação de aplicação/processos.

## Critério de aprovação do Passo 16

Só marque staging público como aprovado quando todos forem verdadeiros:

- `staging_preflight.py` = PASS;
- certificado HTTPS público válido;
- `/live` = 200;
- `/ready` = 200;
- `staging_smoke.py` = PASS;
- readiness falha com worker parado;
- readiness recupera com worker reiniciado;
- `test_backup_restore.sh` = PASS;
- inspeção manual do frontend sem erros de console;
- nenhuma credencial/segredo exposta ao frontend;
- staging ainda usa `MAIL_PROVIDER=console` durante a primeira bateria.

Somente depois disso habilite uma segunda bateria controlada com Resend e destinatários internos/consentidos.
