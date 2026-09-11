# MailFlow v0.13 — Motor de Automações

## Estados

### Automação

- ativa: novos eventos podem inscrever contatos e execuções existentes avançam;
- pausada: o worker não cria novas entradas e não avança as atuais;
- ao reativar, eventos ocorridos durante a pausa não são retroativamente inscritos.

### Execução (`automation_runs`)

```text
running   etapa pronta para executar
waiting   aguardando tempo ou entrega de e-mail
completed fluxo concluído
cancelled contato removido/suprimido ou fluxo cancelado
failed    erro de configuração/entrega
```

## Reentrada

`once`: um contato só participa uma vez da automação.

`reenter`: novos eventos compatíveis podem iniciar novas execuções.

## Snapshot

Na entrada do contato, o MailFlow salva um snapshot de `steps_json` e do remetente selecionado. Isso evita que editar a automação altere silenciosamente o roteiro de uma execução que já começou.

Templates continuam sendo resolvidos quando a etapa de e-mail é executada. Portanto, editar um template afeta envios futuros que ainda não chegaram àquela etapa.

## Condições

A condição usa o mesmo motor de regras de segmentos. Nesta versão o frontend cria uma regra por bloco, embora a API aceite múltiplas regras.

Campos suportados incluem:

- tag;
- status;
- origem;
- e-mail;
- nome;
- telefone;
- data de cadastro;
- campo personalizado.

## Descadastro durante fluxo

A fila revalida a supressão imediatamente antes de chamar o provider. Isso significa que uma execução pode estar aguardando por dias; se o contato descadastrar nesse período, o próximo e-mail é bloqueado.

## Worker

A cada ciclo:

```text
1. procura eventos compatíveis com automações ativas
2. cria inscrições sem duplicar eventos
3. processa execuções vencidas
4. cria deliveries de e-mail quando necessário
5. processa a fila de e-mail
6. no ciclo seguinte, confirma a entrega e avança a automação
```

A frequência é controlada por `MAILFLOW_WORKER_INTERVAL_SECONDS`.
