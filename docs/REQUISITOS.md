# Requisitos

Prioridade: **[M]** obrigatório para a entrega de 24/11 · **[D]** desejável se sobrar tempo · **[F]** futuro (TCC).

## RF — Requisitos Funcionais

### Autenticação
- **RF01 [M] Cadastro com e-mail e senha.** Campos: nome, e-mail, senha, confirmar senha.
  - Aceite: e-mail em formato válido; senha com no mínimo 8 caracteres, contendo letra e número; confirmação igual à senha; mensagens de erro em português abaixo de cada campo.
- **RF02 [M] Login com e-mail e senha.**
  - Aceite: mensagens claras para "e-mail ou senha incorretos", "usuário não encontrado", "muitas tentativas, tente mais tarde", "sem conexão". Botão desabilitado + indicador de carregamento durante a requisição.
- **RF03 [M] Login com Google.** Se for o primeiro acesso, cria o documento do usuário no Firestore.
- **RF04 [M] Recuperação de senha** por e-mail.
- **RF05 [D] Verificação de e-mail** após cadastro (tela "verifique seu e-mail" com botão de reenviar).
- **RF06 [M] Sessão persistente:** ao reabrir o app logado, vai direto para a Home. **Logout** no perfil.

### Casa (household)
- **RF07 [M]** No primeiro acesso, o usuário **cria uma casa** (nome) **ou entra em uma existente** com um **código de convite** de 6 caracteres.
- **RF08 [M]** Todos os membros de uma casa veem e editam os mesmos alimentos. Usuários de outras casas **não têm acesso** (garantido pelas regras do Firestore, não só pela interface).
- **RF09 [M]** Tela da casa mostra nome, código de convite (com botão copiar) e lista de membros.
- **RF10 [D]** Sair da casa.

### Locais de armazenamento
- **RF11 [M]** Ao criar a casa, são criados 3 locais padrão: Geladeira, Freezer, Despensa.
- **RF12 [D]** Criar/renomear/excluir locais.

### Alimentos
- **RF13 [M] Cadastrar alimento:** nome, categoria, quantidade, unidade, data de validade, local, observação (opcional).
  - Aceite: nome obrigatório; quantidade > 0; validade obrigatória (date picker em pt-BR); registra quem adicionou.
- **RF14 [M] Listar alimentos** da casa ordenados pela validade (mais próximos primeiro), com indicador visual de status (ver Regras de Negócio).
- **RF15 [M] Filtrar** por local e por status; **buscar** por nome.
- **RF16 [M] Editar e excluir** alimento.
- **RF17 [M] Marcar como consumido ou descartado** (sai da lista ativa, mas fica no histórico — útil para métricas de desperdício).
- **RF18 [D] Escanear código de barras** pela câmera e preencher nome/categoria via API Open Food Facts. Se não encontrar, preenche só o código e o usuário digita o resto.
- **RF19 [D] Validade sugerida** por categoria + local (ex.: carne fresca na geladeira) — o usuário pode alterar.
- **RF20 [D] Reaproveitar do histórico:** ao digitar o nome, sugerir itens já cadastrados antes (autocompletar com categoria/unidade).

### Home e alertas
- **RF21 [M] Home** com resumo: quantos alimentos vencidos, vencendo em breve e total; lista "consuma primeiro".
- **RF22 [D] Notificação local** diária avisando itens que vencem em até 2 dias.

### Sugestão de pratos
- **RF23 [M] Sugerir receitas** a partir dos alimentos da casa, priorizando os que estão vencendo. Base de receitas local (arquivo JSON no app).
  - Aceite: cada sugestão mostra quais ingredientes a casa tem e quais faltam; ordena por (nº de ingredientes vencendo usados, nº de ingredientes que a casa tem).
- **RF24 [D]** Tela de detalhe da receita (ingredientes + modo de preparo).

### IoT (preparado, não implementado)
- **RF25 [D] Simulador de leitura RFID** (tela de debug): gera uma "etiqueta nova" e simula leituras, para demonstrar o fluxo do TCC.
- **RF26 [F]** Etiquetas pendentes de cadastro vindas da antena.
- **RF27 [F]** Detecção de item removido (não lido em N leituras) → perguntar se foi consumido.
- **RF28 [F]** Leituras de temperatura/umidade e alerta de faixa fora do seguro.

## RNF — Requisitos Não Funcionais
- **RNF01** Android (minSdk definido pelo Flutter/Firebase atuais). Interface em **português (pt-BR)**, datas no formato dd/MM/aaaa.
- **RNF02** Backend: Firebase (Authentication + Cloud Firestore), plano gratuito (Spark). Firestore na região `southamerica-east1` (São Paulo).
- **RNF03** Segurança: regras do Firestore garantem que só membros acessam os dados da casa e que cada usuário só edita o próprio perfil.
- **RNF04** Todas as telas tratam estados de **carregando, vazio e erro**.
- **RNF05** Código passa em `flutter analyze` sem avisos.
- **RNF06** Testes unitários para validadores e regras de validade/receitas.
- **RNF07** Material 3, layout funcional em telas de 5" a 6,7".

## Regras de Negócio
- **RN01 Status de validade** (dias restantes = data de validade − hoje, por data, sem horas):
  | Status | Condição | Cor |
  |---|---|---|
  | `expired` (Vencido) | dias < 0 | vermelho |
  | `critical` (Consumir hoje/amanhã) | 0 ≤ dias ≤ 2 | laranja |
  | `warning` (Vence em breve) | 3 ≤ dias ≤ 5 | amarelo |
  | `ok` | dias > 5 | verde |
  Limites ficam em constantes (`lib/core/constants.dart`).
- **RN02** Item consumido/descartado não aparece na lista ativa nem nas sugestões.
- **RN03** Código de convite: 6 caracteres alfanuméricos maiúsculos, sem caracteres ambíguos (0/O, 1/I).
- **RN04** Um usuário pertence a **uma** casa por vez.
- **RN05 Validade sugerida** (estimativas padrão, editáveis — baseadas em referências como o USDA FoodKeeper, revisar antes da entrega):
  | Categoria | Geladeira | Freezer | Despensa |
  |---|---|---|---|
  | Carne vermelha fresca | 3 dias | 120 dias | — |
  | Carne moída / Frango / Peixe | 2 dias | 90 dias | — |
  | Laticínios (aberto) | 5 dias | — | — |
  | Frutas e verduras | 5 dias | 60 dias | 5 dias |
  | Sobras / comida pronta | 3 dias | 60 dias | — |
  | Outros | sem sugestão | sem sugestão | sem sugestão |

## Categorias (enum)
`meat` Carnes · `poultry` Aves · `fish` Peixes · `dairy` Laticínios · `eggs` Ovos · `produce` Frutas e verduras · `grains` Grãos e massas · `bakery` Pães · `canned` Enlatados · `beverages` Bebidas · `leftovers` Sobras · `other` Outros

## Unidades (enum)
`unit` un · `kg` · `g` · `l` L · `ml` · `pack` pct
