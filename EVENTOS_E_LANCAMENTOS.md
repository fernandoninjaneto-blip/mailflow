# Eventos e Lançamentos — Guia operacional

## 1. Criar o evento

Cadastre nome, tipo, início, término, fuso horário, plataforma, link, público e, se houver oferta, datas de abertura/encerramento.

Para operações no Pará/Brasil, por exemplo:

```text
Fuso: America/Belem
Plataforma: Zoom
```

## 2. Criar o plano

Use **Criar plano sugerido** ou adicione itens manualmente.

Deslocamentos comuns:

```text
-1440  = 24 horas antes
-60    = 1 hora antes
-10    = 10 minutos antes
0      = no momento do marco
30     = 30 minutos depois
```

## 3. Vincular templates

Cada comunicação habilitada precisa de um template para virar campanha.

O template pode misturar variáveis de evento e contato:

```text
Assunto: {{nome|Olá}}, amanhã começa {{evento_nome}}

Corpo:
O evento começa em {{evento_inicio}}.
Acesse pelo link: {{evento_link}}
```

## 4. Preparar campanhas

**Preparar / sincronizar campanhas** cria uma campanha para cada comunicação válida.

As campanhas:

- herdam público do evento;
- herdam remetente do evento;
- recebem horário do cronograma;
- recebem UTMs automáticas;
- ficam desarmadas.

## 5. Revisar cada campanha

Abra a campanha criada e use o fluxo de revisão do Passo 9. Confira audiência, exclusões, remetente, horário e conteúdo.

Somente depois digite `AGENDAR` ou `ENVIAR`.

## 6. Mudanças de data

Se nenhuma campanha estiver armada, mudar as datas do evento atualiza automaticamente as campanhas preparadas.

Se alguma estiver armada/enviando, a mudança é bloqueada. Isso é intencional para evitar disparos em datas divergentes.

## 7. Confirmação de inscrição

Se o evento usa uma lista estática como público, use **Confirmação de inscrição** para criar uma automação de boas-vindas. Por padrão ela nasce pausada para revisão.

## Checklist recomendado

```text
[ ] Data e fuso revisados
[ ] Público correto
[ ] Remetente/domínio prontos
[ ] Link do evento configurado
[ ] Oferta configurada, se houver
[ ] Plano de comunicação criado
[ ] Template em todas as comunicações habilitadas
[ ] Campanhas preparadas
[ ] Cada campanha revisada e armada individualmente
[ ] Automação de confirmação revisada, se usada
```
