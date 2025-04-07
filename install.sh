#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Por favor, execute como root${NC}"
  exit 1
fi

# Função para mostrar menu
show_menu() {
    echo -e "${YELLOW}=== MCP Installation Menu ===${NC}"
    echo "1) Google Calendar MCP"
    echo "2) Evolution API MCP"
    echo "3) Instagram MCP"
    echo "4) Sair"
    echo -e "${YELLOW}===========================${NC}"
}

# Função para baixar e executar script
download_and_run() {
    local script_url=$1
    local script_name=$2
    
    echo -e "${YELLOW}Baixando $script_name...${NC}"
    curl -s "$script_url" -o "$script_name"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Download concluído!${NC}"
        chmod +x "$script_name"
        ./"$script_name"
    else
        echo -e "${RED}Erro ao baixar $script_name${NC}"
    fi
}

# Loop principal
while true; do
    show_menu
    read -p "Escolha uma opção (1-4): " choice
    
    case $choice in
        1)
            download_and_run "https://raw.githubusercontent.com/seu-usuario/mcp-install/main/setup_google.sh" "setup_google.sh"
            ;;
        2)
            download_and_run "https://raw.githubusercontent.com/seu-usuario/mcp-install/main/setup_evolution.sh" "setup_evolution.sh"
            ;;
        3)
            download_and_run "https://raw.githubusercontent.com/seu-usuario/mcp-install/main/setup_instagram.sh" "setup_instagram.sh"
            ;;
        4)
            echo -e "${GREEN}Saindo...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac
    
    echo -e "\nPressione Enter para continuar..."
    read
done 
