# ABC MCP Installer

Script de instalação automatizada para servidores MCP (Model Context Protocol).

## Opções de Instalação

O instalador oferece as seguintes opções:

1. Google Calendar MCP
2. Evolution API MCP

## Uso

Para instalar, execute:

```bash
curl -fsSL https://raw.githubusercontent.com/ABCMilioli/install-mcp/main/install.sh | sudo bash
```

Ou baixe e execute manualmente:

```bash
# 1. Baixar o script
curl -fsSL https://raw.githubusercontent.com/ABCMilioli/install-mcp/main/setup.sh -o setup.sh

# 2. Dar permissão de execução
chmod +x setup.sh

# 3. Executar o script
sudo ./setup.sh
```

## Requisitos

- Sistema operacional: Debian/Ubuntu
- Acesso root
- Para Google Calendar MCP: Credenciais do Google Calendar API (Client ID e Client Secret)
- Para Evolution API MCP: Credenciais da API Evolution (Instance, API Key e API Base URL)

## Instalação

### Google Calendar MCP

O script irá:
1. Verificar requisitos do sistema
2. Atualizar os pacotes do sistema
3. Instalar Node.js e dependências
4. Clonar o repositório
5. Instalar dependências do projeto
6. Configurar arquivos necessários
7. Solicitar credenciais do Google
8. Gerar refresh token
9. Compilar o projeto

### Evolution API MCP

O script irá:
1. Verificar requisitos do sistema
2. Atualizar os pacotes do sistema
3. Instalar Node.js e dependências
4. Criar diretório de instalação
5. Inicializar projeto Node.js
6. Instalar dependências do projeto
7. Configurar arquivos necessários
8. Compilar o projeto

## Configuração

### Google Calendar MCP
Durante a instalação, você precisará fornecer:
1. GOOGLE_CLIENT_ID
2. GOOGLE_CLIENT_SECRET

### Evolution API MCP
Durante a instalação, você precisará configurar:
1. EVOLUTION_INSTANCIA
2. EVOLUTION_APIKEY
3. EVOLUTION_API_BASE

## Uso

Após a instalação, o servidor MCP selecionado estará pronto para uso. As credenciais serão salvas no arquivo .env para referência futura.

## Suporte

Para suporte, abra uma issue no repositório: https://github.com/ABCMilioli/install-mcp/issues 
