# Visão do Produto

## O que é
Aplicativo Android (Flutter) para **gestão de alimentos da casa**: o usuário registra o que tem na geladeira, freezer e despensa, acompanha as validades e recebe sugestões do que consumir primeiro (e de pratos para usar esses alimentos), reduzindo desperdício.

## Para quem
Famílias / moradores de uma mesma casa. Cada pessoa tem **sua própria conta**, e as contas de uma mesma casa compartilham **os mesmos alimentos**. Casas diferentes nunca veem os dados umas das outras.

## Contexto acadêmico
| Entrega | O que inclui | Prazo |
|---|---|---|
| **Cadeira de Flutter** (este escopo) | App funcionando: login individual com validação, login com Google, casas, cadastro de alimentos, alertas de validade, sugestões de pratos | **24/11/2026** |
| **TCC** (depois) | Protótipo IoT: leitor RFID UHF + ESP32 + sensores de temperatura/umidade escrevendo no mesmo Firebase | Posterior |

Autor: Tiago (projeto individual). Plataforma: **somente Android**.

## Visão completa (com IoT, para o TCC)
1. Cada alimento recebe uma **etiqueta RFID** (UHF).
2. Uma **antena** em cada local (geladeira/despensa) lê as etiquetas algumas vezes ao dia (ex.: 3x).
3. Etiqueta nova → app mostra "nova etiqueta detectada, toque para cadastrar" (o usuário **nunca digita o ID da etiqueta**). Ele escaneia o **código de barras** (preenche nome/categoria) e informa a validade.
4. Etiqueta que some em leituras seguidas → app pergunta "você consumiu X?" e libera a etiqueta para reuso.
5. **Sensores de temperatura/umidade** por local → alerta se ficou fora da faixa segura (ex.: carne em geladeira quente) e antecipa a validade estimada.

> Observação técnica: celular não lê RFID UHF (o NFC do celular é 13,56 MHz e alcance de cm). Por isso o vínculo de etiquetas acontece pela antena, não pelo celular.

## Por que o escopo da cadeira já "prepara" o TCC
- O modelo de dados já tem `tagId`, `storages`, `tags` e `readings` previstos (ver `MODELO_DADOS.md`), mesmo sem usar agora.
- No TCC, o ESP32 apenas escreve no Firestore; o app não precisa ser reescrito.

## Fora do escopo da cadeira
- Hardware, ESP32, leitura RFID real, sensores.
- iOS.
- Sugestões por IA (Gemini) — possível extra futuro.
