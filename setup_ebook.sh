#!/bin/bash

# Cores para output
verde="\e[32m"
vermelho="\e[31m"
amarelo="\e[33m"
azul="\e[34m"
roxo="\e[35m"
reset="\e[0m"

# Banner
cat << "EOF"
██████╗ ██████╗  ██████╗    ███╗   ███╗ ██████╗██████╗ 
██╔══██╗██╔══██╗██╔════╝    ████╗ ████║██╔════╝██╔══██╗
███████║██████╔╝██║         ██╔████╔██║██║     ██████╔╝
██╔══██╗██╔══██╗██║         ██║╚██╔╝██║██║     ██╔═══╝
██║  ██║██████╔╝╚██████╗    ██║ ╚═╝ ██║╚██████╗██║  
╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚═╝     ╚═╝ ╚═════╝╚═╝  

        Auto Instalador do ABC MCP - Ebook MCP
        Criado por Robson Milioli
EOF

echo -e "${azul}Iniciando instalação do Ebook MCP...${reset}"

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${vermelho}Este script precisa ser executado como root${reset}"
    echo -e "${amarelo}Use: sudo bash setup_ebook.sh${reset}"
    exit 1
fi

# Verificar sistema operacional
if [ -f /etc/debian_version ]; then
    echo -e "${azul}Sistema Debian/Ubuntu detectado${reset}"
else
    echo -e "${vermelho}Sistema operacional não suportado${reset}"
    exit 1
fi

# Instalar dependências do sistema
apt-get update
apt-get install -y git python3 python3-pip python3-venv curl build-essential

# Instalar uv (gerenciador Python)
if ! command -v uv &> /dev/null; then
    echo -e "${azul}Instalando uv...${reset}"
    pip3 install uv || pip install uv
else
    echo -e "${verde}uv já instalado!${reset}"
fi

# Diretório de instalação
cd /opt
if [ -d "ebook-mcp" ]; then
    echo -e "${amarelo}Diretório /opt/ebook-mcp já existe. Atualizando...${reset}"
    cd ebook-mcp
    git pull
else
    echo -e "${azul}Clonando repositório ebook-mcp...${reset}"
    git clone https://github.com/onebirdrocks/ebook-mcp.git ebook-mcp
    cd ebook-mcp
fi

# Instalar dependências Python
if [ -f "requirements.txt" ]; then
    echo -e "${azul}Instalando dependências Python via uv...${reset}"
    uv pip install -r requirements.txt
elif [ -f "pyproject.toml" ]; then
    echo -e "${azul}Instalando dependências Python via uv (pyproject.toml)...${reset}"
    uv pip install .
else
    echo -e "${vermelho}Nenhum requirements.txt ou pyproject.toml encontrado!${reset}"
    exit 1
fi

# (Opcional) Criar .env.example
if [ ! -f ".env.example" ]; then
    echo -e "${azul}Criando arquivo .env.example...${reset}"
    cat > .env.example << EOF
# Exemplo de variáveis de ambiente para o ebook-mcp
# Adapte conforme necessário para sua configuração
# Exemplo:
# EBOOK_MCP_PORT=5173
EOF
fi

# Mensagem final
cat << EOF
${verde}Ebook MCP instalado com sucesso!${reset}

Para rodar o servidor em modo desenvolvimento:
  ${amarelo}uv run mcp dev src/ebook_mcp/main.py${reset}

Para rodar em modo produção:
  ${amarelo}uv run src/ebook_mcp/main.py${reset}

Acesse a documentação e exemplos em:
  https://github.com/onebirdrocks/ebook-mcp
EOF 