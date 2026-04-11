# Desafio Técnico - Performance BlazeDemo

Repositório com automação de teste de performance para o fluxo de compra de passagem no https://www.blazedemo.com, utilizando Apache JMeter.


# Relatório público (GitHub Pages)

### Acesse o relatório público no GitHub Pages.

- URL `https://leandro-rodini.github.io/blazedemo-performance-test/`

## Atendimento ao Enunciado

- Ferramenta escolhida: Apache JMeter.
- Cenário implementado: compra de passagem com sucesso.
- Testes implementados: carga (`BlazeDemo_Load.jmx`) e pico (`BlazeDemo_Spike.jmx`).
- Evidência anexada no repositório: resultado bruto (`results/results.jtl`) e consolidação de métricas no README.
- Conclusão técnica documentada: critério de aceitação não foi totalmente atendido (p90 acima de 2s).

Link do repositório público para colar no formulário:

- `https://github.com/leandro-rodini/blazedemo-performance-test`

## 1. Objetivo

Validar o critério de aceitação:

- Vazão alvo: 250 requisições por segundo (RPS)
- Latência alvo: percentil 90 (p90) menor que 2 segundos

Cenário testado:

- Compra de passagem aérea com sucesso

## 2. Stack e Ferramentas

- Apache JMeter 5.6.3
- Java 11+
- GitHub Actions para execução automatizada
- GitHub Pages para publicação do dashboard HTML

## 3. Estrutura de Projeto (Padrão de Mercado)

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
|   `-- results.jtl                 # gerado na execução
|-- .github/workflows/
|   `-- performance.yml
`-- docs/
    |-- diagrams/
    |   `-- fluxo gitlab actions.gif
    `-- flow.md
```

## 4. Arquitetura de Execução

![Fluxo GitHub Actions](docs/diagrams/fluxo%20gitlab%20actions.gif)

## 5. Estratégia de Testes

O projeto disponibiliza duas formas de execução, conforme solicitado no enunciado:

- `BlazeDemo_Load.jmx`: somente carga sustentada
- `BlazeDemo_Spike.jmx`: somente pico

Os cenários usam `CSV Data Set Config` com `data/cities.csv` e também propriedades por ambiente (`env/*.properties`) para host/protocolo.

Ambos usam `Precise Throughput Timer` para controle de vazão e validam sucesso funcional com assertion de texto:

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

### 7.2 Execução Linux/macOS

```bash
./scripts/run.sh dev load
```

Para validar threshold local no final da execução:

```bash
./scripts/run.sh dev load true
```

### 7.3 Execução Windows (PowerShell)

```powershell
./scripts/run.ps1 -Environment dev -Scenario load
```

Para validar threshold local no final da execução:

```powershell
./scripts/run.ps1 -Environment dev -Scenario spike -EvaluateThreshold
```

## 8. Resultado da Execução (evidência atual)

- Throughput total: 252.53 req/s
- p90 total: 2.723 s
- Erro total: 0.216%
- Samples totais: 155409

## 9. Conclusão Técnica

O critério de aceitação não foi totalmente atendido.

- Atendido: vazão >= 250 RPS
- Não atendido: p90 < 2 s (resultado observado: 2.723 s)

Análise:

- O sistema sustenta a taxa de requisições, mas com degradação de latência no percentil alto.
- Há presença de cauda longa (máximo acima de 11 s), sugerindo filas/transientes sob carga.
- Para reprovação formal, bastou o p90 acima do limite definido.

## 10. GitHub Actions (CI/CD de Testes)

Pipeline em `.github/workflows/performance.yml`:

- Executa matriz de cenários (`load` e `spike`) em modo headless via `scripts/run.sh`
- Publica artefatos por cenário (`jmeter-report-load` e `jmeter-report-spike`)
- Gera quadro comparativo no `Step Summary` com throughput, p90, erro e status por cenário
- Falha os jobs de cenário quando os critérios não forem atendidos
- Publica dashboards HTML no GitHub Pages para os dois cenários (`load` e `spike`)

## 11. GitHub Pages

Configuração inicial (uma única vez):

1. Acesse `Settings > Pages` no repositório.
2. Em `Build and deployment`, selecione `Source: GitHub Actions`.
3. Execute o workflow `Performance Test` manualmente em `Actions` ou realize push na branch principal.
4. Aguarde a conclusão dos jobs de Pages.

Depois da primeira publicação, o relatório fica disponível em:

- `https://leandro-rodini.github.io/blazedemo-performance-test/`

Links esperados no Pages:

- `https://leandro-rodini.github.io/blazedemo-performance-test/load/index.html`
- `https://leandro-rodini.github.io/blazedemo-performance-test/spike/index.html`
