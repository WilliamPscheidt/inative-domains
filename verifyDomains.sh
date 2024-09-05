#!/bin/bash

# Define os NameServers desejados
NS_DESEJADO1="ns1.sdparking.com.br."
NS_DESEJADO2="ns2.sdparking.com.br."

# Diretório onde os arquivos de domínio estão localizados
DIRETORIO_DOMINIOS="/var/named"

# Arquivo CSV de saída
ARQUIVO_CSV="resultado_nameservers.csv"

# Função para verificar os NameServers de um domínio
verificar_nameservers() {
    dominio=$1
    ns=$(dig NS +short $dominio)

    if [[ "$ns" == *"$NS_DESEJADO1"* && "$ns" == *"$NS_DESEJADO2"* ]]; then
        status="OK - NameServers corretos"
    else
        status="FALHA - NameServers incorretos ou não encontrados"
    fi

    # Exibe o resultado no terminal
    echo "$dominio: $status"
    
    # Adiciona o resultado no arquivo CSV
    echo "$dominio,$status" >> $ARQUIVO_CSV
}

# Função para percorrer os arquivos na pasta /var/named e verificar os domínios
verificar_dominios_pasta() {
    for arquivo in "$DIRETORIO_DOMINIOS"/*.db; do
        # Extrai o nome do domínio removendo o sufixo ".db"
        dominio=$(basename "$arquivo" .db)
        verificar_nameservers $dominio
    done
}

# Verifica se a pasta existe
if [[ ! -d "$DIRETORIO_DOMINIOS" ]]; then
    echo "Erro: Diretório $DIRETORIO_DOMINIOS não encontrado."
    exit 1
fi

# Cria o arquivo CSV e adiciona o cabeçalho
echo "Domínio,Status" > $ARQUIVO_CSV

# Chama a função para verificar os domínios na pasta
verificar_dominios_pasta

# Mensagem final
echo "Resultados exportados para $ARQUIVO_CSV"
