# Configuração de privacidade e descadastro

## Produção

Configure uma URL pública HTTPS que a internet consiga acessar:

```env
MAILFLOW_PUBLIC_BASE_URL=https://app.suaempresa.com.br
```

Gere dois segredos diferentes e longos:

```env
MAILFLOW_UNSUBSCRIBE_SECRET=...
MAILFLOW_SUPPRESSION_SECRET=...
```

Não altere `MAILFLOW_SUPPRESSION_SECRET` depois que a operação estiver em produção sem uma migração dos hashes existentes.

## Teste manual do one-click

1. Crie um contato.
2. Crie e aprove uma campanha.
3. Abra a entrega gerada ou receba o e-mail real.
4. O HTML deve conter “Cancelar inscrição”.
5. O header deve conter `List-Unsubscribe` e `List-Unsubscribe-Post`.
6. Faça `POST` para a URL do token com corpo `List-Unsubscribe=One-Click`.
7. Confirme em Configurações → Supressão global que o contato entrou como `unsubscribe`.
8. Faça nova revisão de campanha: o contador “Supressão global” deve aumentar e esse contato não pode estar na audiência elegível.

## Reconsentimento

Nunca remova uma supressão apenas para “forçar” um envio. Registre primeiro a origem de um novo opt-in. A interface exige origem/base registrada para liberar a supressão vinculada a um contato.

## Exclusão de dados

No detalhe do contato, use “Excluir dados”. O sistema solicita confirmação `EXCLUIR`, anonimiza o histórico operacional e preserva somente o marcador HMAC de supressão.

Este módulo oferece controles técnicos e registros operacionais; a definição da base legal, dos prazos de retenção e dos procedimentos internos da organização deve ser validada conforme o contexto jurídico da operação.
