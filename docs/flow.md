# Fluxo de Teste de Performance

## Objetivo

Validar a jornada de compra no BlazeDemo sob carga controlada em 250 RPS, medindo principalmente throughput e p90.

## Fluxo funcional

1. Home (`GET /`)
2. Busca de voos (`POST /reserve.php`)
3. Escolha do voo (`POST /purchase.php`)
4. Confirmacao da compra (`POST /confirmation.php`)
5. Validacao da mensagem de sucesso

## Diagrama (Mermaid)

```mermaid
flowchart LR
    A[Inicio da iteracao] --> B[GET /]
    B --> C[POST /reserve.php]
    C --> D[POST /purchase.php]
    D --> E[POST /confirmation.php]
    E --> F{Response contem\nThank you for your purchase today!}
    F -->|Sim| G[Iteracao valida]
    F -->|Nao| H[Erro funcional]
    G --> I[Coleta metricas\nlatencia throughput erros]
    H --> I
```

## Fluxo de execucao no JMeter

1. `BlazeDemo_Load.jmx`: thread group de carga por 5 minutos com 250 RPS.
2. `BlazeDemo_Spike.jmx`: thread group de pico por 5 minutos com 250 RPS e maior concorrencia.
3. Resultado consolidado em `results/results.jtl`.
4. Relatorio HTML consolidado em `reports/dashboard/`.
5. CI publica artefatos, quadro comparativo no summary e dashboards no GitHub Pages (`/load` e `/spike`).

## Diagrama de execucao (local e CI)

```mermaid
flowchart TD
    A[Disparo local ou GitHub Actions] --> B[scripts/run.sh ou scripts/run.ps1]
    B --> C[Carrega env/dev.properties]
    C --> D[Escolhe scenario: load ou spike]
    D --> E[results/results.jtl]
    D --> F[reports/dashboard]
    E --> G[Upload de artefatos]
    F --> H[Analise de metricas]
    F --> I[Publicacao no GitHub Pages
    load e spike]
```
