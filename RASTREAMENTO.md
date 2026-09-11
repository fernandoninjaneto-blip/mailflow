# Configuração de rastreamento — MailFlow v0.10

## 1. Domínio

No Resend, o domínio usado pelo remetente deve ter open/click tracking habilitado para que os eventos correspondentes sejam gerados. O MailFlow já armazena essas opções no módulo de Domínios.

Se o tracking estiver desativado, a revisão pré-disparo apresenta um aviso.

## 2. Webhook

Configure o endpoint público:

```text
https://SEU-DOMINIO/api/webhooks/resend
```

Inclua pelo menos os eventos:

```text
email.delivered
email.opened
email.clicked
email.bounced
email.complained
email.failed
email.delivery_delayed
```

Depois configure o segredo:

```env
RESEND_WEBHOOK_SECRET=whsec_...
```

## 3. Eventos de clique

O MailFlow usa `data.click.link` do evento `email.clicked` para identificar qual URL foi acionada.

Também persiste, quando fornecidos:

```text
ipAddress
userAgent
timestamp
```

## 4. UTMs

UTM e click tracking resolvem problemas diferentes:

- click tracking informa **quem clicou e em qual link**;
- UTM permite que analytics, páginas e checkout reconheçam **de qual campanha veio a visita**.

Recomenda-se usar ambos.

## 5. Interpretação de abertura

Abertura é uma métrica aproximada. Clientes de e-mail podem bloquear imagens, pré-carregar pixels ou usar mecanismos de proteção de privacidade. Prefira cliques e conversões ao tomar decisões de alta confiança.
