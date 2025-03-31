#!/bin/bash

# Cores para output
verde="\e[32m"
vermelho="\e[31m"
amarelo="\e[33m"
azul="\e[34m"
roxo="\e[35m"
reset="\e[0m"

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

# Criar diretório mcp_google
mkdir -p mcp_google
cd mcp_google || {
    echo -e "${vermelho}Erro ao acessar o diretório mcp_google${reset}"
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
npm install dotenv axios zod @modelcontextprotocol/sdk googleapis

# Criar arquivo index.js
echo -e "${azul}Criando arquivo index.js...${reset}"
cat > index.js << 'EOL'
const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");
const { z } = require("zod");
const axios = require("axios");
const dotenv = require("dotenv");
const { google } = require('googleapis');

dotenv.config();

const schemas = {
  toolInputs: {
    criaEvento: z.object({      
      summary: z.string(),
      description: z.string().optional(),
      startTime: z.string(),
      endTime: z.string(),
      attendees: z.array(z.string()).optional(),
    }),
    buscaEventos: z.object({      
      timeMin: z.string().optional(),
      timeMax: z.string().optional(),
    }),
    deletaEvento: z.object({      
      eventId: z.string(),
    }),
  },
};

const TOOL_DEFINITIONS = [
  {
    name: "cria_evento",
    description: "Cria um evento no Google Calendar",
    inputSchema: {
      type: "object",
      properties: {       
        summary: { type: "string", description: "Título do evento" },
        description: { type: "string", description: "Descrição do evento" },
        startTime: { type: "string", description: "Data/hora de início (ISO 8601)" },
        endTime: { type: "string", description: "Data/hora de término (ISO 8601)" },
        attendees: {
          type: "array",
          items: { type: "string" },
          description: "Lista de emails dos participantes"
        },
      },
      required: ["summary", "startTime", "endTime"],
    },
  },
  {
    name: "busca_eventos",
    description: "Busca eventos no Google Calendar",
    inputSchema: {
      type: "object",
      properties: {       
        timeMin: { type: "string", description: "Data/hora mínima (ISO 8601)" },
        timeMax: { type: "string", description: "Data/hora máxima (ISO 8601)" },
      },
      required: [],
    },
  },
  {
    name: "deleta_evento",
    description: "Deleta um evento do Google Calendar",
    inputSchema: {
      type: "object",
      properties: {       
        eventId: { type: "string", description: "ID do evento" },
      },
      required: ["eventId"],
    },
  },
];

const toolHandlers = {
  cria_evento: async (args) => {
    const parsed = schemas.toolInputs.criaEvento.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
    console.log("GOOGLE_CALENDAR_ID:", process.env.GOOGLE_CALENDAR_ID);
    console.log("GOOGLE_CLIENT_EMAIL:", process.env.GOOGLE_CLIENT_EMAIL);
    console.log("GOOGLE_PRIVATE_KEY:", process.env.GOOGLE_PRIVATE_KEY);

    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: process.env.GOOGLE_CLIENT_EMAIL,
        private_key: process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      },
      scopes: ['https://www.googleapis.com/auth/calendar'],
    });

    const calendar = google.calendar({ version: 'v3', auth });

    const event = {
      summary: parsed.summary,
      description: parsed.description,
      start: {
        dateTime: parsed.startTime,
        timeZone: 'America/Sao_Paulo',
      },
      end: {
        dateTime: parsed.endTime,
        timeZone: 'America/Sao_Paulo',
      },
      attendees: parsed.attendees?.map(email => ({ email })),
    };

    try {
      const response = await calendar.events.insert({
        calendarId: process.env.GOOGLE_CALENDAR_ID,
        resource: event,
      });

      return {
        content: [{
          type: "text",
          text: `Evento criado com sucesso!\nResposta: ${JSON.stringify(response.data)}`,
        }],
      };
    } catch (error) {
      console.error("Erro ao criar evento:", error);
      return {
        content: [{
          type: "text",
          text: `Erro ao criar evento: ${error.message}`,
        }],
      };
    }
  },

  busca_eventos: async (args) => {
    const parsed = schemas.toolInputs.buscaEventos.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
    console.log("GOOGLE_CALENDAR_ID:", process.env.GOOGLE_CALENDAR_ID);
    console.log("GOOGLE_CLIENT_EMAIL:", process.env.GOOGLE_CLIENT_EMAIL);
    console.log("GOOGLE_PRIVATE_KEY:", process.env.GOOGLE_PRIVATE_KEY);

    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: process.env.GOOGLE_CLIENT_EMAIL,
        private_key: process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      },
      scopes: ['https://www.googleapis.com/auth/calendar'],
    });

    const calendar = google.calendar({ version: 'v3', auth });

    try {
      const response = await calendar.events.list({
        calendarId: process.env.GOOGLE_CALENDAR_ID,
        timeMin: parsed.timeMin,
        timeMax: parsed.timeMax,
      });

      return {
        content: [{
          type: "text",
          text: `Eventos obtidos com sucesso:\n${JSON.stringify(response.data, null, 2)}`,
        }],
      };
    } catch (error) {
      console.error("Erro ao buscar eventos:", error);
      return {
        content: [{
          type: "text",
          text: `Erro ao buscar eventos: ${error.message}`,
        }],
      };
    }
  },

  deleta_evento: async (args) => {
    const parsed = schemas.toolInputs.deletaEvento.parse(args);
    console.log("🔐 Variáveis de ambiente utilizadas:");
    console.log("GOOGLE_CALENDAR_ID:", process.env.GOOGLE_CALENDAR_ID);
    console.log("GOOGLE_CLIENT_EMAIL:", process.env.GOOGLE_CLIENT_EMAIL);
    console.log("GOOGLE_PRIVATE_KEY:", process.env.GOOGLE_PRIVATE_KEY);

    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: process.env.GOOGLE_CLIENT_EMAIL,
        private_key: process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      },
      scopes: ['https://www.googleapis.com/auth/calendar'],
    });

    const calendar = google.calendar({ version: 'v3', auth });

    try {
      await calendar.events.delete({
        calendarId: process.env.GOOGLE_CALENDAR_ID,
        eventId: parsed.eventId,
      });

      return {
        content: [{
          type: "text",
          text: `Evento deletado com sucesso!`,
        }],
      };
    } catch (error) {
      console.error("Erro ao deletar evento:", error);
      return {
        content: [{
          type: "text",
          text: `Erro ao deletar evento: ${error.message}`,
        }],
      };
    }
  },
};

const server = new Server({
  name: "google-calendar-tools-server",
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
  console.error("Google Calendar MPC Server rodando no stdio");
}

const args = process.argv.slice(2);
console.log("Inicializando chamada... buscando varíaveis");
if (args.length > 0) {
  const funcao = args[0];
  const input = args[1] ? JSON.parse(args[1]) : {};

  // Exibe as variáveis de ambiente no console
  console.log("🔐 Variáveis de ambiente utilizadas:");
  console.log("GOOGLE_CALENDAR_ID:", process.env.GOOGLE_CALENDAR_ID);
  console.log("GOOGLE_CLIENT_EMAIL:", process.env.GOOGLE_CLIENT_EMAIL);
  console.log("GOOGLE_PRIVATE_KEY:", process.env.GOOGLE_PRIVATE_KEY);

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

echo -e "${verde}Google Calendar MCP instalado com sucesso!${reset}" 
