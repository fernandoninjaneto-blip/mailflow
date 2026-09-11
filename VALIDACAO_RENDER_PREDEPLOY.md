# Validação pré-deploy Render

- Bundle derivado do MailFlow v0.16.
- Frontend pode ser servido pela mesma origem da API usando `MAILFLOW_FRONTEND_DIR`.
- Headers de segurança continuam sendo aplicados pelo middleware FastAPI, inclusive CSP.
- `render.yaml` separa web e worker e usa Postgres gerenciado.
- `render-free.yaml` existe apenas como staging temporário sem cobrança.
- Migrações executam via Alembic antes do deploy web.
- A URL pública usa `RENDER_EXTERNAL_URL`, sem hardcode.
- Segredos são gerados no Render e compartilhados entre web/worker via referências do Blueprint.
- Provider de e-mail permanece `console`.
