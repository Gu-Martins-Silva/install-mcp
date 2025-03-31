#!/bin/bash

# Cores para output
verde="\e[32m"
vermelho="\e[31m"
amarelo="\e[33m"
azul="\e[34m"
roxo="\e[35m"
reset="\e[0m"

# Banner
echo -e "
██████╗ ██████╗  ██████╗    ███╗   ███╗ ██████╗██████╗ 
██╔══██╗██╔══██╗██╔════╝    ████╗ ████║██╔════╝██╔══██╗
███████║██████╔╝██║         ██╔████╔██║██║     ██████╔╝
██╔══██╗██╔══██╗██║         ██║╚██╔╝██║██║     ██╔═══╝
██║  ██║██████╔╝╚██████╗    ██║ ╚═╝ ██║╚██████╗██║  
╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚═╝     ╚═╝ ╚═════╝╚═╝  
                                                                             
              Auto Instalador do ABC MCP
              Criado por Robson Milioli
"

# 1. Mostra as opções disponíveis
echo -e "${azul}Opções disponíveis:${reset}"
echo -e "${amarelo}1${reset} - Google Calendar MCP"
echo -e "${amarelo}2${reset} - Evolution API MCP"
echo -e "${amarelo}3${reset} - Sair"
echo ""

# 2. Faz a pausa e aguarda a escolha do usuário
echo -e "${amarelo}Digite a opção desejada (1, 2 ou 3) e pressione ENTER${reset}"
echo -e "${vermelho}Exemplo: Digite 1 e pressione ENTER para instalar o Google Calendar MCP${reset}"
read -p "> " opcao

# 3. Só depois que o usuário responder e pressionar ENTER,
#    o script processa a escolha
case $opcao in
    1)
        echo -e "${azul}Iniciando instalação do ABC MCP Google Calendar...${reset}"
        echo -e "${amarelo}Baixando script de configuração...${reset}"
        
        # Baixar o script setup.sh
        curl -fsSL https://raw.githubusercontent.com/ABCMilioli/google-calendar-mcp/main/setup.sh -o setup.sh
        
        if [ $? -eq 0 ]; then
            echo -e "${verde}Script baixado com sucesso!${reset}"
            chmod +x setup.sh
            sudo ./setup.sh
        else
            echo -e "${vermelho}Erro ao baixar o script. Verifique sua conexão com a internet e tente novamente.${reset}"
            exit 1
        fi
        ;;
    2)
        echo -e "${azul}Iniciando instalação do Evolution API MCP...${reset}"
        
        # Verificar sistema operacional
        if [ -f /etc/debian_version ]; then
            echo -e "${azul}Sistema Debian/Ubuntu detectado${reset}"
        else
            echo -e "${vermelho}Sistema operacional não suportado${reset}"
            exit 1
        fi

        # Acessar diretório /opt
        cd /opt || {
            echo -e "${vermelho}Erro ao acessar o diretório /opt${reset}"
            exit 1
        }

        # Criar diretório mcp_evo
        mkdir -p mcp_evo
        cd mcp_evo || {
            echo -e "${vermelho}Erro ao acessar o diretório mcp_evo${reset}"
            exit 1
        }

        # Instalar/atualizar dependências
        echo -e "${azul}Instalando/atualizando dependências...${reset}"
        sudo apt update
        sudo apt install -y nodejs
        sudo npm install -g typescript
        sudo apt install -y npm

        # Inicializar projeto npm
        echo -e "${azul}Inicializando projeto npm...${reset}"
        npm init -y

        # Instalar dependências do projeto
        echo -e "${azul}Instalando dependências do projeto...${reset}"
        npm install dotenv axios zod @modelcontextprotocol/sdk

        # Criar arquivo index.js
        echo -e "${azul}Criando arquivo index.js...${reset}"
        cat > index.js << 'EOL'
const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");
const { z } = require("zod");
const axios = require("axios");
const dotenv = require("dotenv");

dotenv.config();

const schemas = {
  toolInputs: {
    enviaMensagem: z.object({      
      number: z.string(),
      mensagem: z.string(),
    }),
    criaGrupo: z.object({      
      subject: z.string(),
      description: z.string().optional(),
      participants: z.array(z.string()),
    }),
    buscaGrupos: z.object({      
      getParticipants: z.boolean().optional().default(false)
    }),
    buscaParticipantesGrupo: z.object({      
      groupJid: z.string()
    })
  },
};

const TOOL_DEFINITIONS = [
  {
    name: "envia_mensagem",
    description: "Envia mensagem de texto via API Evolution",
    inputSchema: {
      type: "object",
      properties: {       
        number: { type: "string", description: "Número do destinatário com DDI e DDD" },
        mensagem: { type: "string", description: "Texto da mensagem a ser enviada" },
      },
      required: ["number", "mensagem"],
    },
  },
  {
    name: "cria_grupo",
    description: "Cria um grupo via API Evolution",
    inputSchema: {
      type: "object",
      properties: {        
        subject: { type: "string", description: "Nome do grupo" },
        description: { type: "string", description: "Descrição do grupo" },
        participants: {
          type: "array",
          items: { type: "string" },
          description: "Participantes do grupo (números com DDI/DDD)"
        },
      },
      required: ["subject", "participants"],
    },
  },
  {
    name: "busca_grupos",
    description: "Busca todos os grupos da instância com opção de listar participantes.",
    inputSchema: {
      type: "object",
      properties: {       
        getParticipants: { type: "boolean", description: "Listar participantes dos grupos?", default: false },
      },
      required: [],
    },
  },
  {
    name: "busca_participantes_grupo",
    description: "Busca participantes específicos de um grupo pela instância.",
    inputSchema: {
      type: "object",
      properties: {        
        groupJid: { type: "string", description: "Identificador do grupo" },
      },
      required: ["groupJid"],
    },
  },
];

const toolHandlers = {
  envia_mensagem: async (args) => {
    const parsed = schemas.toolInputs.enviaMensagem.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
    console.log("EVOLUTION_INSTANCIA:", process.env.EVOLUTION_INSTANCIA);
   console.log("EVOLUTION_APIKEY:", process.env.EVOLUTION_APIKEY);
   console.log("EVOLUTION_API_BASE:", process.env.EVOLUTION_API_BASE);
    const instancia = process.env.EVOLUTION_INSTANCIA;
    const apikey = process.env.EVOLUTION_APIKEY;
    const apiBase = process.env.EVOLUTION_API_BASE || 'sua_url_evolution';

    const url = `https://${apiBase}/message/sendText/${instancia}`;
    const response = await axios.post(url, {
      number: parsed.number,
      text: parsed.mensagem,
    }, {
      headers: {
        'Content-Type': 'application/json',
        'apikey': apikey,
      },
    });
    return {
      content: [{
        type: "text",
        text: `Mensagem enviada com sucesso para ${parsed.number}.\nResposta: ${JSON.stringify(response.data)}`,
      }],
    };
  },

  cria_grupo: async (args) => {
    const parsed = schemas.toolInputs.criaGrupo.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
  console.log("EVOLUTION_INSTANCIA:", process.env.EVOLUTION_INSTANCIA);
  console.log("EVOLUTION_APIKEY:", process.env.EVOLUTION_APIKEY);
  console.log("EVOLUTION_API_BASE:", process.env.EVOLUTION_API_BASE);
    const instancia = process.env.EVOLUTION_INSTANCIA;
    const apikey = process.env.EVOLUTION_APIKEY;
    const apiBase = process.env.EVOLUTION_API_BASE || 'url_evolution';

    const url = `https://${apiBase}/group/create/${instancia}`;
    const response = await axios.post(url, {
      subject: parsed.subject,
      description: parsed.description,
      participants: parsed.participants,
    }, {
      headers: {
        'Content-Type': 'application/json',
        'apikey': apikey,
      },
    });
    return {
      content: [{
        type: "text",
        text: `Grupo criado com sucesso!\nResposta: ${JSON.stringify(response.data)}`,
      }],
    };
  },

  busca_grupos : async (args) => {
    const parsed = schemas.toolInputs.buscaGrupos.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
  console.log("EVOLUTION_INSTANCIA:", process.env.EVOLUTION_INSTANCIA);
  console.log("EVOLUTION_APIKEY:", process.env.EVOLUTION_APIKEY);
  console.log("EVOLUTION_API_BASE:", process.env.EVOLUTION_API_BASE);
    const instancia = process.env.EVOLUTION_INSTANCIA;
    const apikey = process.env.EVOLUTION_APIKEY;
    const apiBase = process.env.EVOLUTION_API_BASE || 'url_evolution';

    const url = `https://${apiBase}/group/fetchAllGroups/${instancia}?getParticipants=${parsed.getParticipants}`;

    try {
      const response = await axios.get(url, {
        headers: {
          'Content-Type': 'application/json',
          'apikey': apikey,
        },
      });

      return {
        content: [{
          type: "text",
          text: `Grupos obtidos com sucesso:\n${JSON.stringify(response.data, null, 2)}`,
        }],
      };

    } catch (error) {
      console.error("Erro na chamada API Evolution:", error);
      return {
        content: [{
          type: "text",
          text: `Erro ao obter grupos: ${error.message}`,
        }],
      };
    }
  },

  busca_participantes_grupo: async (args) => {
    const parsed = schemas.toolInputs.buscaParticipantesGrupo.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
  console.log("EVOLUTION_INSTANCIA:", process.env.EVOLUTION_INSTANCIA);
  console.log("EVOLUTION_APIKEY:", process.env.EVOLUTION_APIKEY);
  console.log("EVOLUTION_API_BASE:", process.env.EVOLUTION_API_BASE);
    const instancia = process.env.EVOLUTION_INSTANCIA;
    const apikey = process.env.EVOLUTION_APIKEY;
    const apiBase = process.env.EVOLUTION_API_BASE || 'url_evolution';

    const url = `https://${apiBase}/group/participants/${instancia}?groupJid=${parsed.groupJid}`;

    try {
      const response = await axios.get(url, {
        headers: {
          'Content-Type': 'application/json',
          'apikey': apikey,
        },
      });

      return {
        content: [{
          type: "text",
          text: `Participantes obtidos com sucesso:\n${JSON.stringify(response.data, null, 2)}`,
        }],
      };

    } catch (error) {
      console.error("Erro na chamada API Evolution:", error);
      return {
        content: [{
          type: "text",
          text: `Erro ao obter participantes: ${error.message}`,
        }],
      };
    }
  },
};

const server = new Server({
  name: "evolution-tools-server",
  version: "1.0.0",
}, {
  capabilities: {
    tools: {},
  },
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
  console.error("Ferramenta requesitada pelo cliente");
  return { tools: TOOL_DEFINITIONS };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  try {
    const handler = toolHandlers[name];
    if (!handler) throw new Error(`Tool Desconhecida: ${name}`);
    return await handler(args);
  } catch (error) {
    console.error(`Error executando a tool ${name}:`, error);
    throw error;
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Evolution API MPC Server rodando no stdio");
}

const args = process.argv.slice(2);
console.log("Inicializando chamada... buscando varíaveis");
if (args.length > 0) {
  const funcao = args[0];
  const input = args[1] ? JSON.parse(args[1]) : {};

  // Exibe as variáveis de ambiente no console
  console.log("🔐 Variáveis de ambiente utilizadas:");
  console.log("EVOLUTION_INSTANCIA:", process.env.EVOLUTION_INSTANCIA);
  console.log("EVOLUTION_APIKEY:", process.env.EVOLUTION_APIKEY);
  console.log("EVOLUTION_API_BASE:", process.env.EVOLUTION_API_BASE);

  if (toolHandlers[funcao]) {
    toolHandlers[funcao](input)
      .then((res) => {
        console.log(JSON.stringify(res, null, 2));
        process.exit(0);
      })
      .catch((err) => {
        console.error(`Erro ao executar ${funcao}:`, err);
        process.exit(1);
      });
  } else {
    console.error(`❌ Função desconhecida: ${funcao}`);
    process.exit(1);
  }
} else {
  main().catch((error) => {
    console.error("Erro Fatal:", error);
    process.exit(1);
  });
}
EOL

        echo -e "${verde}Evolution API MCP instalado com sucesso!${reset}"
        ;;
    3)
        echo -e "${amarelo}Saindo do instalador...${reset}"
        exit 0
        ;;
    *)
        echo -e "${vermelho}Opção inválida!${reset}"
        echo -e "${amarelo}Por favor, execute o script novamente e digite uma opção válida (1, 2 ou 3)${reset}"
        exit 1
        ;;
esac 
