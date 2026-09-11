# MailFlow v0.14 — Dashboard e Relatórios Avançados

## Objetivo

O Passo 14 transforma os dados operacionais já existentes em uma camada gerencial. Nenhum novo mecanismo de envio foi criado: os relatórios leem a mesma fila (`EmailDelivery`), eventos de tracking, campanhas, automações e eventos/lançamentos usados pelo restante do MailFlow.

## Períodos

A interface permite analisar 7, 30, 90, 180 ou 365 dias. O endpoint aceita de 1 a 365 dias:

```text
GET /api/reports/overview?days=30
```

O período atual é comparado ao período imediatamente anterior de mesma duração. Quando o período anterior é zero, a API retorna `null` para a variação percentual em vez de inventar uma porcentagem infinita.

## Fonte de verdade das métricas

Para indicadores operacionais, o MailFlow usa `EmailDelivery` e ignora entregas de teste (`is_test=true`).

- **Enviados:** entregas com `sent_at`.
- **Entregues:** entregas com `delivered_at`.
- **Abertura única:** entregas com `opened_at`.
- **Clique único:** entregas com `clicked_at`.
- **Bounce:** entregas com `bounced_at`.
- **Reclamação:** entregas com `complained_at`.
- **Descadastro:** entregas com `unsubscribed_at`.
- **Falha:** `failed_at` preenchido ou status `failed`.

Taxas:

```text
entregabilidade = entregues / enviados
abertura = aberturas únicas / entregues
CTR = cliques únicos / entregues
CTOR = cliques únicos / aberturas únicas
bounce = bounces / enviados
reclamação = complaints / entregues
descadastro = unsubscribes / entregues
```

## Eventos totais x pessoas únicas

Abertura e clique únicos são derivados do snapshot da entrega. O ranking de links usa `EmailEngagementEvent`:

- `unique_clicks`: quantidade de entregas distintas que clicaram;
- `total_clicks`: todos os eventos de clique recebidos.

Isso evita confundir uma pessoa que clicou várias vezes com vários destinatários diferentes.

## Dashboard

O Dashboard mostra:

- contatos ativos;
- novos contatos no período;
- e-mails enviados;
- entregabilidade;
- abertura única;
- clique único;
- tendência diária;
- alertas operacionais;
- campanhas recentes;
- funil resumido.

## Relatórios avançados

A página de Relatórios contém:

1. KPIs e comparação com o período anterior;
2. série diária de envios, entregas, aberturas e cliques;
3. crescimento diário da base;
4. comparativo entre campanhas;
5. melhores assuntos por taxa de abertura;
6. links mais clicados;
7. desempenho de automações;
8. desempenho agregado de eventos e lançamentos;
9. origem dos envios: campanhas, automações e outros jobs;
10. alertas de saúde operacional.

## Alertas operacionais

Os limites atuais são **limites internos do produto**, usados para observabilidade, não regras jurídicas nem garantias de entregabilidade:

```text
Entregabilidade mínima: 95%
Bounce máximo: 2%
Reclamação máxima: 0,1%
Descadastro máximo: 1%
Job parado em fila/retry: 30 minutos
```

O painel também alerta quando:

- existe campanha armada com horário vencido;
- existem falhas em automações no período;
- não existe domínio marcado como pronto;
- não existe remetente padrão ativo.

Para reduzir ruído, alertas de taxa só são avaliados após volume mínimo de 100 mensagens relevantes no período.

## Campanhas

O comparativo de campanhas considera entregas que entraram na fila no período selecionado. Cada linha mostra:

- enviados;
- entrega;
- abertura;
- CTR;
- CTOR;
- bounce;
- reclamação;
- acesso ao relatório detalhado já existente no Passo 10.

## Eventos e automações

Automações são medidas pelas execuções iniciadas no período, com concluídas, em andamento, falhas e taxa de conclusão.

Eventos/lançamentos não duplicam tracking: o relatório encontra as campanhas vinculadas em `EventCommunication` e agrega seus resultados.

## Privacidade

O overview não expõe e-mails individuais nem dados pessoais dos contatos. Ranking de links permanece restrito ao workspace autenticado. Os relatórios continuam sujeitos ao isolamento por `workspace_id`.

## Limitações conhecidas

- abertura de e-mail continua sendo uma métrica aproximada por causa de mecanismos de privacidade dos clientes de e-mail;
- os thresholds de alerta ainda são fixos e poderão virar configuração por workspace;
- não há exportação PDF/CSV do dashboard avançado nesta versão;
- não há atribuição financeira/receita porque o MVP ainda não possui integração de checkout;
- a série diária é operacional e não substitui um data warehouse para análises de longo prazo em grande escala.
