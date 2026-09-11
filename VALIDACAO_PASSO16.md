# Validação técnica — MailFlow v0.16 / Passo 16

## O que foi executado neste ambiente

### Regressão

```text
pytest -q
19 passed
```

Toda a suíte funcional e de segurança da v0.15 permaneceu verde.

### Smoke operacional local com processos reais

Executado:

```bash
python ops/local_operational_smoke.py
```

Resultado: PASS.

Foram validados por HTTP real contra Uvicorn + worker separados:

- `/live` e `/ready`;
- cadastro;
- cookie de sessão;
- cookie CSRF;
- sessão autenticada;
- logout/login;
- rate limit 429;
- importação CSV;
- contatos;
- listas;
- segmentos;
- templates;
- revisão de campanha;
- fila;
- processamento pelo worker;
- supressão;
- automação;
- relatórios;
- readiness final.

Depois o processo do worker foi encerrado. Com o heartbeat stale, `/ready` deixou de retornar 200. Um novo worker foi iniciado e `/ready` voltou a 200.

### Sintaxe/arquivos

Validados:

- `staging_gate.sh` com `sh -n`;
- `backup_postgres.sh` com `sh -n`;
- `restore_postgres.sh` com `sh -n`;
- `test_backup_restore.sh` com `sh -n`;
- scripts Python com `py_compile`;
- `frontend/app.js` com `node --check`;
- `frontend/editor.js` com `node --check`;
- preflight com ambiente de teste válido = PASS;
- YAML de staging analisado no ambiente de desenvolvimento.

## Correções operacionais encontradas no Passo 16

1. **ENV_FILE no backup/restore** — os scripts agora passam o mesmo `--env-file` ao Docker Compose. Isso evita substituições vazias de variáveis quando a senha não está exportada no shell.
2. **Restore test não destrutivo** — o teste de recuperação não substitui mais o banco de staging. O dump é restaurado em um banco temporário e comparado com a origem.
3. **Readiness testável em staging** — `MAILFLOW_WORKER_STALE_SECONDS` passou a ser configurável no compose de staging, com exemplo de 15s para o gate.
4. **Gate único** — `ops/staging_gate.sh` consolida preflight, subida, smoke HTTP, falha/recuperação do worker e restore test.

## O que NÃO pôde ser executado neste ambiente

Não há Docker Engine, PostgreSQL server nem um domínio DNS público vinculado a este ambiente. Portanto ainda não foram validados aqui:

- build real das imagens Docker;
- PostgreSQL 17 dentro do compose;
- Caddy emitindo certificado público;
- DNS real de staging;
- tráfego HTTPS externo;
- restore real dentro do container PostgreSQL;
- webhooks chegando pela internet;
- entrega real via Resend.

Por isso, esta validação não declara o **staging público aprovado**. Ela declara o pacote v0.16 pronto para executar o gate em um servidor de homologação.
