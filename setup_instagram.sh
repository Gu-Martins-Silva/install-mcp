#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar sistema operacional
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
else
    echo -e "${RED}Erro: Sistema operacional não suportado${NC}"
    exit 1
fi

# Verificar se é Debian/Ubuntu
if [[ ! "$OS" =~ "Debian" ]] && [[ ! "$OS" =~ "Ubuntu" ]]; then
    echo -e "${RED}Erro: Este script só funciona em sistemas Debian/Ubuntu${NC}"
    exit 1
fi

# Criar diretório
cd /opt
mkdir -p mcp_instagram
cd mcp_instagram

# Instalar dependências
echo -e "${YELLOW}Instalando dependências...${NC}"
apt-get update
apt-get install -y curl git build-essential

# Instalar Node.js e npm
echo -e "${YELLOW}Instalando Node.js e npm...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Instalar TypeScript globalmente
echo -e "${YELLOW}Instalando TypeScript...${NC}"
npm install -g typescript

# Inicializar projeto npm
echo -e "${YELLOW}Inicializando projeto npm...${NC}"
npm init -y

# Instalar dependências do projeto
echo -e "${YELLOW}Instalando dependências do projeto...${NC}"
npm install dotenv axios zod @modelcontextprotocol/sdk

# Criar arquivo index.js
echo -e "${YELLOW}Criando arquivo index.js...${NC}"
cat > index.js << 'EOL'
const { z } = require('zod');
const { MCPClient } = require('@modelcontextprotocol/sdk');
const axios = require('axios');
require('dotenv').config();

// Schemas
const MediaSchema = z.object({
  image_url: z.string().url(),
  caption: z.string().optional(),
  location: z.string().optional(),
  hashtags: z.array(z.string()).optional(),
  mentions: z.array(z.string()).optional(),
  carousel_images: z.array(z.string().url()).optional(),
  reel_video_url: z.string().url().optional(),
  reel_duration: z.number().optional(),
  story_duration: z.number().optional(),
  story_type: z.enum(['image', 'video', 'carousel']).optional(),
  story_stickers: z.array(z.object({
    type: z.enum(['location', 'mention', 'hashtag', 'poll', 'question', 'slider', 'countdown']),
    data: z.any()
  })).optional()
});

const CommentSchema = z.object({
  media_id: z.string(),
  text: z.string(),
  parent_comment_id: z.string().optional(),
  reply_to_user_id: z.string().optional()
});

const LikeSchema = z.object({
  media_id: z.string(),
  user_id: z.string().optional()
});

const FollowSchema = z.object({
  user_id: z.string(),
  action: z.enum(['follow', 'unfollow'])
});

const UserSchema = z.object({
  username: z.string(),
  full_name: z.string().optional(),
  biography: z.string().optional(),
  website: z.string().url().optional(),
  profile_picture_url: z.string().url().optional(),
  is_private: z.boolean().optional(),
  is_business: z.boolean().optional(),
  business_category: z.string().optional(),
  business_email: z.string().email().optional(),
  business_phone: z.string().optional(),
  business_address: z.string().optional()
});

const HashtagSchema = z.object({
  hashtag: z.string(),
  limit: z.number().optional()
});

const LocationSchema = z.object({
  location_id: z.string(),
  limit: z.number().optional()
});

const SearchSchema = z.object({
  query: z.string(),
  type: z.enum(['user', 'hashtag', 'location']),
  limit: z.number().optional()
});

// Tool Definitions
const tools = [
  {
    name: 'create_media',
    description: 'Create a new media post on Instagram',
    parameters: MediaSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Media created successfully' };
      } catch (error) {
        throw new Error(`Failed to create media: ${error.message}`);
      }
    }
  },
  {
    name: 'publish_media',
    description: 'Publish a created media post',
    parameters: z.object({ media_id: z.string() }),
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Media published successfully' };
      } catch (error) {
        throw new Error(`Failed to publish media: ${error.message}`);
      }
    }
  },
  {
    name: 'create_carousel',
    description: 'Create a carousel post with multiple images',
    parameters: MediaSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Carousel created successfully' };
      } catch (error) {
        throw new Error(`Failed to create carousel: ${error.message}`);
      }
    }
  },
  {
    name: 'create_reel',
    description: 'Create a new Instagram Reel',
    parameters: MediaSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Reel created successfully' };
      } catch (error) {
        throw new Error(`Failed to create reel: ${error.message}`);
      }
    }
  },
  {
    name: 'create_story',
    description: 'Create a new Instagram Story',
    parameters: MediaSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Story created successfully' };
      } catch (error) {
        throw new Error(`Failed to create story: ${error.message}`);
      }
    }
  },
  {
    name: 'add_comment',
    description: 'Add a comment to a media post',
    parameters: CommentSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Comment added successfully' };
      } catch (error) {
        throw new Error(`Failed to add comment: ${error.message}`);
      }
    }
  },
  {
    name: 'reply_to_comment',
    description: 'Reply to an existing comment',
    parameters: CommentSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Reply added successfully' };
      } catch (error) {
        throw new Error(`Failed to add reply: ${error.message}`);
      }
    }
  },
  {
    name: 'like_media',
    description: 'Like a media post',
    parameters: LikeSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Media liked successfully' };
      } catch (error) {
        throw new Error(`Failed to like media: ${error.message}`);
      }
    }
  },
  {
    name: 'follow_user',
    description: 'Follow or unfollow a user',
    parameters: FollowSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: `User ${params.action}ed successfully` };
      } catch (error) {
        throw new Error(`Failed to ${params.action} user: ${error.message}`);
      }
    }
  },
  {
    name: 'update_profile',
    description: 'Update Instagram profile information',
    parameters: UserSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, message: 'Profile updated successfully' };
      } catch (error) {
        throw new Error(`Failed to update profile: ${error.message}`);
      }
    }
  },
  {
    name: 'get_hashtag_info',
    description: 'Get information about a hashtag',
    parameters: HashtagSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, data: {} };
      } catch (error) {
        throw new Error(`Failed to get hashtag info: ${error.message}`);
      }
    }
  },
  {
    name: 'get_location_info',
    description: 'Get information about a location',
    parameters: LocationSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, data: {} };
      } catch (error) {
        throw new Error(`Failed to get location info: ${error.message}`);
      }
    }
  },
  {
    name: 'search',
    description: 'Search for users, hashtags, or locations',
    parameters: SearchSchema,
    handler: async (params) => {
      try {
        // Implement Instagram API call
        return { success: true, data: [] };
      } catch (error) {
        throw new Error(`Failed to perform search: ${error.message}`);
      }
    }
  }
];

// Inicializar cliente MCP
const client = new MCPClient({
  tools,
  apiKey: process.env.MCP_API_KEY,
  baseUrl: process.env.MCP_BASE_URL || 'https://api.modelcontextprotocol.com'
});

// Configurar servidor
const PORT = process.env.PORT || 3000;

client.startServer(PORT, () => {
  console.log(`Instagram MCP server running on port ${PORT}`);
});

// Tratamento de erros
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled Rejection:', error);
});
EOL

# Criar arquivo .env
echo -e "${YELLOW}Criando arquivo .env...${NC}"
cat > .env << 'EOL'
MCP_API_KEY=your_api_key_here
MCP_BASE_URL=https://api.modelcontextprotocol.com
PORT=3000
EOL

# Criar arquivo .gitignore
echo -e "${YELLOW}Criando arquivo .gitignore...${NC}"
cat > .gitignore << 'EOL'
node_modules/
.env
*.log
EOL

# Configurar permissões
echo -e "${YELLOW}Configurando permissões...${NC}"
chown -R root:root /opt/mcp_instagram
chmod -R 755 /opt/mcp_instagram

echo -e "${GREEN}Instagram MCP instalado com sucesso!${NC}"
echo -e "${YELLOW}Por favor, configure o arquivo .env com suas credenciais antes de iniciar o servidor.${NC}" 