# Configurar domínio de envio no MailFlow v0.8

## Objetivo

Antes de enviar campanhas reais, autentique um domínio ou subdomínio próprio.

Recomendação de estrutura:

```text
Site principal: suaempresa.com.br
E-mail marketing: email.suaempresa.com.br
Return-Path: send.email.suaempresa.com.br
Tracking: links.email.suaempresa.com.br
```

Usar um subdomínio dedicado ajuda a separar a reputação do tráfego promocional de outros fluxos de e-mail.

## 1. Configure o Resend no servidor

No `.env`:

```env
MAIL_PROVIDER=resend
RESEND_API_KEY=re_xxxxxxxxx
RESEND_WEBHOOK_SECRET=whsec_xxxxxxxxx
```

Reinicie API e worker.

## 2. Cadastre o domínio

No MailFlow:

```text
Configurações
→ Domínios de envio
→ + Domínio
```

Preencha, por exemplo:

```text
Domínio: email.suaempresa.com.br
Região: sa-east-1
Return-Path: send
Tracking: links
DMARC: p=none
TLS: opportunistic
```

## 3. Copie os registros SPF/DKIM/Tracking

Clique em **DNS**.

O MailFlow mostra os registros retornados pela API do Resend. Copie nome, tipo, valor e prioridade exatamente como forem exibidos.

Não crie manualmente um segundo SPF no mesmo host. Use exatamente a estrutura pedida pelo provedor.

## 4. Publique DMARC

O MailFlow gera também um registro:

```text
Host: _dmarc.email.suaempresa.com.br
Tipo: TXT
Valor: v=DMARC1; p=none; ...
```

Se você fornecer um endereço de relatórios, o valor inclui:

```text
rua=mailto:seu-endereco-de-relatorios
```

Garanta que esse endereço realmente possa receber mensagens.

## 5. Aguarde a propagação

Depois de publicar os registros, use:

```text
Atualizar
Verificar
```

A verificação do Resend é assíncrona. DNS normalmente propaga rapidamente, mas pode levar mais tempo conforme o provedor e o TTL.

## 6. Cadastre o remetente

Depois do domínio:

```text
Configurações
→ Remetentes verificados
→ + Remetente
```

Exemplo:

```text
Nome: Minha Empresa
E-mail: campanhas@email.suaempresa.com.br
Reply-To: suporte@suaempresa.com.br
Padrão: Sim
```

O endereço `From` precisa pertencer exatamente ao domínio selecionado.

## 7. Confira o painel de prontidão

O envio real só será liberado quando a tela mostrar:

```text
ENVIO LIBERADO
```

Critérios da v0.8:

```text
SPF = verified
DKIM = verified
DMARC = valid
Tracking = verified (se habilitado)
Domínio do Resend = verified/partially_verified
Remetente padrão = ativo
```

## Cloudflare

Para CNAMEs de tracking, se houver problemas de verificação, mantenha o registro como **DNS Only** em vez de proxy laranja, conforme a orientação do Resend.

## DMARC: quando sair de p=none?

Não comece diretamente em `p=reject` sem saber quem envia e-mail legitimamente pelo domínio.

Fluxo recomendado:

```text
p=none
↓
monitorar relatórios e autenticação
↓
p=quarantine
↓
monitorar novamente
↓
p=reject
```

O MailFlow permite atualizar a instrução de DMARC, mas a alteração só vale de verdade depois que você atualizar o TXT no DNS.

## Observação importante

SPF/DKIM/DMARC são apenas uma parte da entregabilidade. Na v0.11 o MailFlow também exige configuração pública HTTPS e segredos de descadastro/supressão para marcar a operação como pronta para marketing em massa. Veja `PRIVACIDADE_E_DESCADASTRO.md`.
