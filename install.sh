#!/bin/bash

# Cores para output
verde="\e[32m"
vermelho="\e[31m"
amarelo="\e[33m"
azul="\e[34m"
reset="\e[0m"

echo -e "${azul}Baixando script de instalação...${reset}"

# Baixa o setup.sh
curl -fsSL https://raw.githubusercontent.com/ABCMilioli/install-mcp/main/setup.sh -o /tmp/setup.sh

if [ $? -ne 0 ]; then
    echo -e "${vermelho}Erro ao baixar o script de instalação${reset}"
    exit 1
fi

# Dá permissão de execução
chmod +x /tmp/setup.sh

# Executa o script
echo -e "${verde}Iniciando instalação...${reset}"
/tmp/setup.sh

# Remove o arquivo temporário
rm /tmp/setup.sh 
