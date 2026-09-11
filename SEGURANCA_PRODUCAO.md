# Segurança de produção — MailFlow v0.16

## 1. Segredos

Nunca reutilize o mesmo valor entre:

- `MAILFLOW_CSRF_SECRET`;
- `MAILFLOW_SECURITY_SECRET`;
- `MAILFLOW_UNSUBSCRIBE_SECRET`;
- `MAILFLOW_SUPPRESSION_SECRET`.

Use no mínimo 32 caracteres aleatórios; 64 é recomendado. Não salve `.env.production` no Git.

## 2. Cookies

Em produção use obrigatoriamente:

```env
SESSION_COOKIE_NAME=__Host-mailflow_session
CSRF_COOKIE_NAME=__Host-mailflow_csrf
COOKIE_SECURE=true
```

O prefixo `__Host-` exige HTTPS, `Path=/` e ausência de atributo `Domain`, reduzindo risco de sobrescrita por subdomínios.

## 3. CSRF

Operações autenticadas mutáveis exigem token HMAC vinculado à sessão. O valor do cookie CSRF deve ser enviado no header `X-CSRF-Token`.

`SameSite` é defesa adicional; não é a única proteção.

## 4. Origem

Defina somente o host real:

```env
MAILFLOW_TRUSTED_ORIGINS=https://app.seudominio.com.br
```

Não use `*` em produção quando `allow_credentials=true`.

## 5. Rate limiting

Mantenha:

```env
MAILFLOW_RATE_LIMIT_ENABLED=true
MAILFLOW_SECURITY_SECRET=<segredo forte>
```

O bloqueio não substitui MFA. MFA permanece melhoria recomendada pós-MVP para contas administrativas.

## 6. Reverse proxy

`TRUST_PROXY_HEADERS=true` só deve ser usado porque a API de produção não é exposta diretamente à internet. O tráfego chega à API através de Caddy/Nginx controlados pelo projeto.

Não publique a porta 8000 da API no host em produção.

## 7. Headers

O frontend envia:

- Content-Security-Policy;
- X-Content-Type-Options;
- X-Frame-Options;
- Referrer-Policy;
- Permissions-Policy.

A API também inclui headers de segurança básicos e HSTS em ambiente production-like.

## 8. Uploads

O Nginx limita request body em 25 MB. O importador de contatos mantém validações próprias. Não aumente esse limite sem revisar memória, timeout e tamanho máximo do CSV.

## 9. Logs

Não registre:

- senha;
- token de sessão;
- token de reset;
- payload completo de formulários;
- API keys.

O middleware HTTP não registra query string por padrão.

## 10. Rotação

Rotacione imediatamente se houver suspeita de vazamento:

- senha PostgreSQL;
- chave Resend;
- segredo de webhook.

A rotação do `MAILFLOW_SUPPRESSION_SECRET` exige planejamento, porque esse segredo participa da identidade hash da lista de supressão. Não troque casualmente.


## 11. Senhas

Novos hashes usam `scrypt` com `N=2^14`, `r=8`, `p=5`. O verificador continua lendo os parâmetros gravados no próprio hash, portanto contas existentes com o fator anterior continuam funcionando e podem ser atualizadas naturalmente em uma futura política de rehash após login.

O login executa um hash fictício quando o e-mail não existe para reduzir diferença de tempo que poderia facilitar enumeração de contas.
