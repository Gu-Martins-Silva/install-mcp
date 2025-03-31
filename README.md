# ABC MCP Installer

Script de instalação automatizada para servidores MCP.

## Estrutura do Projeto

O projeto é composto por três scripts principais:

1. `install.sh` - Script principal que exibe o menu e gerencia a instalação
2. `setup_google.sh` - Script para instalação do Google Calendar MCP
3. `setup_evolution.sh` - Script para instalação do Evolution API MCP

## Uso

Você pode instalar de duas maneiras:

### Opção 1 - Comando em uma linha (Recomendado)
```bash
curl -fsSL https://raw.githubusercontent.com/ABCMilioli/install-mcp/main/install.sh | sudo bash
```

### Opção 2 - Comandos separados
```bash
# 1. Baixar o script de instalação
curl -fsSL https://raw.githubusercontent.com/ABCMilioli/install-mcp/main/install.sh > install.sh

# 2. Executar o script com privilégios de root
sudo bash install.sh
```

## Opções Disponíveis

1. Google Calendar MCP
   - Criação de eventos
   - Busca de eventos
   - Deleção de eventos
   - Requer credenciais do Google Calendar API

2. Evolution API MCP
   - Envio de mensagens
     - Envio de mensagens de texto
     - Envio de mídia (imagens, vídeos, documentos)
     - Envio de áudio
     - Envio de enquetes
     - Envio de listas interativas
   - Gerenciamento de Grupos
     - Criação de grupos
     - Atualização de foto do grupo
     - Envio de convites para grupos
     - Gerenciamento de participantes (adicionar/remover)
     - Busca de grupos
     - Busca de participantes de grupos
   - Requer credenciais da Evolution API (EVOLUTION_INSTANCIA, EVOLUTION_APIKEY, EVOLUTION_API_BASE)

3. Sair

## Requisitos

- Sistema operacional: Debian/Ubuntu
- Acesso root
- Credenciais específicas para cada tipo de MCP:
  - Google Calendar: GOOGLE_CALENDAR_ID, GOOGLE_CLIENT_EMAIL, GOOGLE_PRIVATE_KEY
  - Evolution API: EVOLUTION_INSTANCIA, EVOLUTION_APIKEY, EVOLUTION_API_BASE

## Processo de Instalação

O script irá:

1. Verificar requisitos do sistema
2. Atualizar os pacotes do sistema
3. Instalar Node.js e dependências
4. Configurar o ambiente específico para cada tipo de MCP
5. Instalar dependências do projeto
6. Configurar arquivos necessários

## Suporte

Para suporte, abra uma issue no repositório: https://github.com/ABCMilioli/install-mcp/issues 
