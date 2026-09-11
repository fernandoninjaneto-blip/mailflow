# MailFlow v0.16 — Passo 16: Staging e Teste Operacional

A v0.16 preserva todas as funcionalidades e proteções da v0.15 e adiciona uma camada repetível de **homologação operacional**.

O foco desta versão é provar que a aplicação se comporta corretamente como sistema em execução: HTTP, sessão, CSRF, rate limit, fila, worker, automação, readiness e recuperação de backup.

## Novidades da v0.16

- `ops/staging_preflight.py` — valida ambiente antes de subir;
- `ops/staging_smoke.py` — smoke HTTP completo contra staging;
- `ops/staging_gate.sh` — gate automatizado ponta a ponta;
- `ops/local_operational_smoke.py` — pré-homologação com Uvicorn + worker em processos reais;
- teste explícito de perda e recuperação do worker;
- `MAILFLOW_WORKER_STALE_SECONDS` configurável em staging;
- backup/restore com suporte consistente a `ENV_FILE`;
- restore test de staging **não destrutivo** em banco PostgreSQL temporário;
- documentação específica em `STAGING_OPERACIONAL.md`;
- relatório de validação em `VALIDACAO_PASSO16.md`.

## Pré-homologação local

```bash
python ops/local_operational_smoke.py
```

Este teste não exige Docker e usa banco temporário. Ele não substitui o staging público, mas valida processos e fluxos reais via HTTP.

## Staging público

1. copie o ambiente:

```bash
cp .env.staging.example .env.staging
```

2. configure DNS de `MAILFLOW_HOST` para o servidor;
3. substitua todos os placeholders e gere segredos fortes;
4. rode:

```bash
./ops/staging_gate.sh
```

O gate deixa o ambiente no ar ao final para inspeção manual.

## Gate de staging

O gate executa:

```text
preflight
  ↓
Docker Compose + Alembic
  ↓
HTTPS / live / ready
  ↓
smoke HTTP
  ↓
stop worker
  ↓
ready precisa falhar
  ↓
start worker
  ↓
ready precisa recuperar
  ↓
backup + restore temporário + comparação
  ↓
PASS
```

Leia `STAGING_OPERACIONAL.md` para os detalhes.

## Testes de regressão

```bash
cd backend
pytest -q
```

Resultado deste pacote:

```text
19 passed
```

Além disso, `python ops/local_operational_smoke.py` passou integralmente neste ambiente.

## Status honesto da v0.16

O software e o gate de staging estão preparados. O **staging público ainda precisa ser executado em infraestrutura real** com Docker, PostgreSQL, DNS e HTTPS. Este pacote não afirma que um deploy público ocorreu.

O próximo marco só deve ser produção depois que `./ops/staging_gate.sh` passar no servidor de homologação e uma inspeção manual final também for aprovada.
