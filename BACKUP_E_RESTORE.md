# Backup e recuperação — MailFlow v0.16

## Backup

Produção:

```bash
ENV_FILE=.env.production \
COMPOSE_FILE=docker-compose.production.yml \
./ops/backup_postgres.sh
```

Staging:

```bash
ENV_FILE=.env.staging \
COMPOSE_FILE=docker-compose.staging.yml \
./ops/backup_postgres.sh
```

Cada backup é criado em formato custom do `pg_dump` e recebe um arquivo `.sha256`.

## Teste de restauração em staging — não destrutivo

```bash
MAILFLOW_ENVIRONMENT=staging \
ENV_FILE=.env.staging \
COMPOSE_FILE=docker-compose.staging.yml \
./ops/test_backup_restore.sh
```

Na v0.16 este teste **não substitui o banco de staging**. Ele:

1. gera o backup;
2. valida checksum;
3. cria um banco temporário;
4. restaura o dump;
5. compara contagens de `workspaces`, `contacts`, `campaigns` e `email_deliveries`;
6. valida `alembic_version`;
7. remove o banco temporário.

Esse teste deve passar antes da liberação de produção.

## Restore real/destrutivo

Use apenas para recuperação planejada:

```bash
MAILFLOW_CONFIRM_RESTORE=RESTORE \
ENV_FILE=.env.production \
COMPOSE_FILE=docker-compose.production.yml \
./ops/restore_postgres.sh ./ops/backups/mailflow_YYYYMMDDTHHMMSSZ.dump
```

O restore real:

- valida o checksum, quando disponível;
- para API e worker;
- recria o banco `mailflow`;
- restaura o dump;
- executa Alembic até `head`;
- reinicia API e worker.

Depois, `/api/health/ready` precisa retornar 200 antes de liberar tráfego.

## Política mínima recomendada

- backup diário;
- retenção em armazenamento externo ao servidor;
- cópia criptografada;
- teste periódico de restauração;
- monitoramento de falhas do job;
- nunca considere backup válido apenas porque o arquivo existe.
