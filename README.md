# ABC MCP Installer

Script de instalação automatizada para servidores MCP.

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
2. Evolution API MCP
3. Sair

## Requisitos

- Sistema operacional: Debian/Ubuntu
- Acesso root
- Credenciais específicas para cada tipo de MCP

## Instalação

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
