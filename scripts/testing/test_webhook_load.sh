#!/bin/bash

# Script avançado para teste de carga máxima
# Executa múltiplos webhooks com alta concorrência

WEBHOOK_URL="https://admpm3.app.n8n.cloud/webhook/8c501659-f8bd-420a-9d08-a91f5465616f"

echo "🚀 Iniciando teste de carga máxima..."
echo "📍 Webhook: $WEBHOOK_URL"
echo "🔢 Cenários de teste:"
echo "   • 20 execuções simultâneas (Cenário 1)"
echo "   • 50 execuções simultâneas (Cenário 2)"
echo "   • 100 execuções simultâneas (Cenário 3)"
echo ""

# Função para executar teste com N chamadas simultâneas
run_load_test() {
    local num_calls=$1
    local scenario_name=$2
    local start_time=$(date +%s)

    echo "🎯 $scenario_name - Executando $num_calls chamadas simultâneas..."

    # Array para armazenar tempos de resposta
    declare -a response_times

    # Executa as chamadas simultâneas
    for i in $(seq 1 $num_calls); do
        {
            local payload='{
              "scenario": "'$scenario_name'",
              "request_number": '$i',
              "timestamp": "'$(date -Iseconds)'",
              "load_test": true,
              "message": "Teste de carga - '$scenario_name' - Request '$i'"
            }'

            local start_request=$(date +%s%N)
            local response=$(curl -s -w "\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s\n" \
                -X POST \
                -H "Content-Type: application/json" \
                -d "$payload" \
                "$WEBHOOK_URL")
            local end_request=$(date +%s%N)

            local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
            local time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
            local body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')

            # Calcula tempo em milissegundos
            local response_time_ms=$(( (end_request - start_request) / 1000000 ))

            echo "✅ Request #$i: Status $http_status | Tempo ${time_taken}s"
        } &
    done

    # Aguarda todas as chamadas terminarem
    wait

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "📊 $scenario_name concluído em ${duration}s"
    echo ""
}

# Executa os três cenários de teste
run_load_test 20 "Cenário 1: Carga Moderada"
run_load_test 50 "Cenário 2: Carga Alta"
run_load_test 100 "Cenário 3: Carga Extrema"

echo "🎉 Todos os cenários de carga foram concluídos!"
echo "📈 Teste de carga máxima finalizado com sucesso!"

