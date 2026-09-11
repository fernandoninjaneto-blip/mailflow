# MailFlow — staging no Render

Este pacote acrescenta suporte declarativo ao Render sem remover a infraestrutura Docker/Caddy já existente.

## Opção recomendada: `render.yaml`

Arquitetura production-like:

- web service público (free no staging);
- background worker separado (`0.5c-512mb`, plano pago mínimo do worker);
- Render Postgres free apenas para staging temporário;
- HTTPS fornecido pelo Render;
- migrações Alembic no `preDeployCommand`;
- `MAIL_PROVIDER=console`, portanto nenhum e-mail externo é enviado.

O web service e o worker compartilham os segredos gerados no próprio Render. A URL pública é propagada automaticamente usando `RENDER_EXTERNAL_URL`.

## Opção sem cobrança: `render-free.yaml`

Executa API e worker dentro do mesmo web service free. É adequada somente para uma primeira validação pública. Não comprova isolamento/restart independente do worker e o free service pode dormir quando ocioso.

O banco Postgres free do Render expira após 30 dias segundo a documentação atual do provedor. Não use essa opção como banco de produção.

## Gate

Depois do deploy público:

1. `/api/health/live` precisa retornar 200;
2. `/api/health/ready` precisa retornar 200;
3. executar `ops/staging_smoke.py` contra a URL pública;
4. no modo production-like, interromper/reiniciar o worker e verificar que readiness reage corretamente;
5. testar backup/restore antes da promoção para produção.

## Envio real

O Blueprint mantém `MAIL_PROVIDER=console`. Resend só deve ser ativado depois do staging funcional, domínio autenticado e teste com lista pequena e consentida.
