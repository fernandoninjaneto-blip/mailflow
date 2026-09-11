# Configurar Resend no MailFlow v0.8

## Passo 8: domínio obrigatório para envio real

Depois de configurar a API key, abra **Configurações → Domínios de envio** no MailFlow e cadastre um domínio/subdomínio próprio. A v0.8 não libera a fila live apenas porque a API key existe.

O gate de produção exige domínio com SPF, DKIM e DMARC validados e um remetente padrão ligado a ele. Veja `CONFIGURAR_DOMINIO.md`.


Este guia ativa o caminho de envio real que já existe no Passo 7.

## 1. Comece em modo seguro

Mantenha primeiro:

```env
MAIL_PROVIDER=console
```

Suba o app e valide uma campanha pequena. Em modo console, nenhum e-mail sai para a internet.

## 2. Crie/configure sua conta no Resend

No Resend, obtenha uma API key apropriada para envio.

Nunca coloque a API key no frontend.

## 3. Configure o domínio de envio

Adicione e valide o domínio no Resend. O Passo 8 do MailFlow será dedicado a SPF, DKIM, DMARC e entregabilidade.

Não use volume real antes de concluir essa configuração.

## 4. Configure as variáveis do servidor

No `.env`:

```env
MAIL_PROVIDER=resend
RESEND_API_KEY=re_xxxxxxxxx
RESEND_API_BASE=https://api.resend.com
MAILFLOW_EXPOSE_RESET_TOKEN=false
APP_URL=https://app.seudominio.com
COOKIE_SECURE=true
```

O e-mail cadastrado em **Configurações → Identidade do remetente** precisa ser compatível com o domínio validado no provider.

## 5. Reinicie API e worker

Com Docker Compose:

```bash
docker compose up -d --build api worker
```

Depois abra **Configurações → Provedor de envio**.

O painel deve mostrar:

```text
Resend
Conectado • envio real
```

## 6. Faça um envio de teste

Crie uma campanha e use:

```text
Enviar teste
```

Use inicialmente apenas um endereço seu.

O MailFlow registrará o `provider_message_id` retornado pela API.

## 7. Crie o webhook

No Resend, crie um webhook apontando para:

```text
https://app.seudominio.com/api/webhooks/resend
```

Assine pelo menos os eventos:

```text
email.sent
email.delivered
email.delivery_delayed
email.bounced
email.complained
email.opened
email.clicked
email.failed
email.suppressed
```

## 8. Salve o signing secret

Copie o signing secret do webhook para o servidor:

```env
RESEND_WEBHOOK_SECRET=whsec_xxxxxxxxx
```

Reinicie a API.

Em **Configurações → Provedor de envio**, o painel deverá mostrar que a assinatura de webhook está configurada.

## 9. Teste o retorno

Envie uma mensagem de teste, abra e clique em um link.

Depois abra:

```text
Campanhas → Entregas
```

O MailFlow poderá receber e armazenar os eventos correspondentes.

## 10. Segurança

Nunca publique:

```text
RESEND_API_KEY
RESEND_WEBHOOK_SECRET
```

Não inclua essas credenciais em:

- Git;
- HTML;
- JavaScript;
- screenshots públicos;
- banco de dados de contatos;
- arquivos enviados a clientes.

## 11. Antes de volume real

Concluir o Passo 8:

- SPF;
- DKIM;
- DMARC;
- domínio dedicado/subdomínio;
- política de remetente;
- testes de inbox;
- aquecimento quando necessário.

Depois disso, avançaremos para a camada de conformidade e supressão do MailFlow.

## Passo 10 — eventos de rastreamento

Para preencher os relatórios detalhados, mantenha **Open Tracking** e **Click Tracking** habilitados no domínio e assine no webhook pelo menos:

- `email.delivered`
- `email.opened`
- `email.clicked`
- `email.bounced`
- `email.complained`
- `email.failed`

O endpoint continua sendo:

```text
https://SEU-DOMINIO/api/webhooks/resend
```

Consulte também `RASTREAMENTO.md`.

## Passo 11 — headers de descadastro

O MailFlow v0.11 envia custom headers via Email API do Resend:

```text
List-Unsubscribe: <https://SEU-DOMINIO/api/unsubscribe/TOKEN>
List-Unsubscribe-Post: List-Unsubscribe=One-Click
```

Configure também:

```env
MAILFLOW_PUBLIC_BASE_URL=https://app.suaempresa.com.br
MAILFLOW_UNSUBSCRIBE_SECRET=...
MAILFLOW_SUPPRESSION_SECRET=...
```

A URL precisa ser pública e HTTPS para marketing em produção.
