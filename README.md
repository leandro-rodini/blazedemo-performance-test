# Desafio Tecnico - Performance BlazeDemo

Repositorio com automacao de teste de performance para o fluxo de compra de passagem no https://www.blazedemo.com, utilizando Apache JMeter.

## Atendimento ao Enunciado

- Ferramenta escolhida: Apache JMeter.
- Cenario implementado: compra de passagem com sucesso.
- Testes implementados: carga (`BlazeDemo_Load.jmx`) e pico (`BlazeDemo_Spike.jmx`).
- Evidencia anexada no repositorio: resultado bruto (`results/results.jtl`) e consolidacao de metricas no README.
- Conclusao tecnica documentada: criterio de aceitacao nao foi totalmente atendido (p90 acima de 2s).

Link do repositorio publico para colar no formulario:

- `https://github.com/leandro-rodini/blazedemo-performance-test`

## 1. Objetivo

Validar o criterio de aceitacao:

- Vazao alvo: 250 requisicoes por segundo (RPS)
- Latencia alvo: percentil 90 (p90) menor que 2 segundos

Cenario testado:

- Compra de passagem aerea com sucesso

## 2. Stack e Ferramentas

- Apache JMeter 5.6.3
- Java 11+
- GitHub Actions para execucao automatizada
- GitHub Pages para publicacao do dashboard HTML

## 3. Estrutura de Projeto (Padrao de Mercado)

```text
.
|-- test-plans/
|   `-- scenarios/
|       |-- BlazeDemo_Load.jmx
|       `-- BlazeDemo_Spike.jmx
|-- env/
|   `-- dev.properties
|-- data/
|   `-- cities.csv
|-- scripts/
|   |-- run.sh
|   |-- run.ps1
|   |-- check-threshold.sh
|   `-- check-threshold.ps1
|-- results/
|   `-- results.jtl                 # gerado na execucao
|-- .github/workflows/
|   `-- performance.yml
`-- docs/
	`-- flow.md
```

## 4. Arquitetura de Execucao

![Fluxo GitHub Actions](fluxo%20gitlab%20actions.gif)

## 5. Estrategia de Testes

O projeto disponibiliza duas formas de execucao, conforme solicitado no enunciado:

- `BlazeDemo_Load.jmx`: somente carga sustentada
- `BlazeDemo_Spike.jmx`: somente pico

Os cenarios usam `CSV Data Set Config` com `data/cities.csv` e tambem propriedades por ambiente (`env/*.properties`) para host/protocolo.

Ambos usam `Precise Throughput Timer` para controle de vazao e validam sucesso funcional com assertion de texto:

- `Thank you for your purchase today!`

## 6. Fluxo da Jornada Testada

1. `GET /` (home)
2. `POST /reserve.php` (busca voos)
3. `POST /purchase.php` (seleciona voo)
4. `POST /confirmation.php` (confirma compra)
5. Assertion da mensagem de sucesso

Detalhamento visual em `docs/flow.md`.

## 7. Como Executar Localmente

### 7.1 Pre-requisitos

- Java 11+ instalado e configurado
- JMeter 5.6.3 no PATH

### 7.2 Execucao Linux/macOS

```bash
./scripts/run.sh dev load
```

Para validar threshold local no final da execucao:

```bash
./scripts/run.sh dev load true
```

### 7.3 Execucao Windows (PowerShell)

```powershell
./scripts/run.ps1 -Environment dev -Scenario load
```

Para validar threshold local no final da execucao:

```powershell
./scripts/run.ps1 -Environment dev -Scenario spike -EvaluateThreshold
```

## 8. Resultado da Execucao (evidencia atual)

- Throughput total: 252.53 req/s
- p90 total: 2.723 s
- Erro total: 0.216%
- Samples totais: 155409

## 9. Conclusao Tecnica

O criterio de aceitacao nao foi totalmente atendido.

- Atendido: vazao >= 250 RPS
- Nao atendido: p90 < 2 s (resultado observado: 2.723 s)

Analise:

- O sistema sustenta a taxa de requisicoes, mas com degradacao de latencia no percentil alto.
- Ha presenca de cauda longa (maximo acima de 11 s), sugerindo filas/transientes sob carga.
- Para reprovacao formal, bastou o p90 acima do limite definido.

## 10. GitHub Actions (CI/CD de Testes)

Pipeline em `.github/workflows/performance.yml`:

- Executa matriz de cenarios (`load` e `spike`) em modo headless via `scripts/run.sh`
- Publica artefatos por cenario (`jmeter-report-load` e `jmeter-report-spike`)
- Gera quadro comparativo no `Step Summary` com throughput, p90, erro e status por cenario
- Falha os jobs de cenario quando os criterios nao forem atendidos
- Publica dashboards HTML no GitHub Pages para os dois cenarios (`load` e `spike`)

## 11. GitHub Pages

Configuracao inicial (uma unica vez):

1. Acesse `Settings > Pages` no repositorio.
2. Em `Build and deployment`, selecione `Source: GitHub Actions`.
3. Execute o workflow `Performance Test` manualmente em `Actions` ou realize push na branch principal.
4. Aguarde a conclusao dos jobs de Pages.

Depois da primeira publicacao, o relatorio fica disponivel em:

- `https://leandro-rodini.github.io/blazedemo-performance-test/`

Links esperados no Pages:

- `https://leandro-rodini.github.io/blazedemo-performance-test/load/index.html`
- `https://leandro-rodini.github.io/blazedemo-performance-test/spike/index.html`
