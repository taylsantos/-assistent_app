const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const DATA_FILE = path.join(__dirname, 'app_data.json');

// Função para ler dados salvos no servidor
function loadAppData() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const raw = fs.readFileSync(DATA_FILE, 'utf8');
      return JSON.parse(raw);
    }
  } catch (err) {
    console.error('Erro ao ler arquivo de dados:', err);
  }
  return {
    saldoPre: 0,
    saldoPos: 0,
    contasPre: [],
    contasFixasPre: [],
    contasFixasPos: [],
    comprasPre: [],
    comprasPos: [],
    caixas: [],
    chatMsgs: []
  };
}

// Função para salvar dados no servidor
function saveAppData(data) {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
  } catch (err) {
    console.error('Erro ao salvar dados:', err);
  }
}

let db = loadAppData();

function parseMessageAndApply(text, modo = 'pre') {
  const isPre = modo === 'pre';
  const lowerText = text.toLowerCase();
  let responseText = "Mensagem recebida e registrada!";

  // Extrair números do texto
  const matches = [...text.matchAll(/\d+([.,]\d{1,2})?/g)];
  const numbers = matches.map(m => parseFloat(m[0].replace(',', '.')));

  if (numbers.length > 0) {
    const val = numbers[0];

    if (lowerText.includes('recebi') || lowerText.includes('saldo') || lowerText.includes('tenho')) {
      if (isPre) db.saldoPre = val;
      else db.saldoPos = val;
      responseText = `💰 Saldo atualizado para R$ ${val.toFixed(2)}`;
    } else if (lowerText.includes('gastei') || lowerText.includes('paguei') || lowerText.includes('comprei')) {
      const novoGasto = {
        id: Date.now(),
        nome: text.replace(/[0-9.,]/g, '').trim() || 'Gasto WhatsApp',
        valor: val,
        categoria: 'WhatsApp',
        status: 'Pago'
      };
      if (isPre) db.contasPre.push(novoGasto);
      else db.contasFixasPos.push(novoGasto);
      responseText = `💸 Lançado gasto de R$ ${val.toFixed(2)} (${novoGasto.nome})`;
    } else if (lowerText.includes('comprar') || lowerText.includes('adicionar item')) {
      const itemNome = text.replace(/adicionar|comprar|item/gi, '').trim();
      const novoItem = { id: Date.now(), nome: itemNome || text };
      if (isPre) db.comprasPre.push(novoItem);
      else db.comprasPos.push(novoItem);
      responseText = `🛒 Item "${novoItem.nome}" adicionado à lista de compras!`;
    }
  } else if (lowerText.includes('caixa')) {
    const caixaNome = text.replace(/criar|caixa/gi, '').trim();
    db.caixas.push({ id: Date.now(), nome: caixaNome || text });
    responseText = `📦 Caixa "${caixaNome}" adicionada!`;
  }

  // Guardar no histórico do chat
  db.chatMsgs.push({ autor: 'user', texto: text, timestamp: new Date() });
  db.chatMsgs.push({ autor: 'bot', texto: responseText, timestamp: new Date() });

  saveAppData(db);
  return responseText;
}

// Endpoint para validação inicial do Webhook do WhatsApp (Meta Cloud API)
app.get('/webhook/whatsapp', (req, res) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  const MY_VERIFY_TOKEN = 'assistente_secret_token';

  if (mode && token === MY_VERIFY_TOKEN) {
    console.log('✅ Webhook verificado com sucesso!');
    return res.status(200).send(challenge);
  }
  res.sendStatus(403);
});

// Endpoint para receber mensagens do WhatsApp em tempo real
app.post('/webhook/whatsapp', async (req, res) => {
  try {
    const body = req.body;
    console.log('📩 Nova mensagem recebida via Webhook:', JSON.stringify(body, null, 2));

    let textReceived = '';
    
    if (body.entry && body.entry[0]?.changes[0]?.value?.messages) {
      const msg = body.entry[0].changes[0].value.messages[0];
      if (msg && msg.type === 'text') {
        textReceived = msg.text.body;
      }
    } else if (body.message) {
      textReceived = body.message.text || body.message || '';
    } else if (body.text) {
      textReceived = body.text;
    }

    if (textReceived) {
      const resposta = parseMessageAndApply(textReceived, 'pre');
      console.log('🤖 Resposta gerada:', resposta);
    }

    res.status(200).json({ status: 'success' });
  } catch (error) {
    console.error('❌ Erro no webhook:', error);
    res.status(500).json({ error: 'Erro interno no servidor' });
  }
});

// Endpoint para o App Flutter puxar os dados atualizados
app.get('/api/sync', (req, res) => {
  res.json(db);
});

// Endpoint para o App Flutter enviar mensagens/atualizações diretamente
app.post('/api/chat', (req, res) => {
  const { texto, modo } = req.body;
  if (!texto) return res.status(400).json({ error: 'Texto não informado' });

  const resposta = parseMessageAndApply(texto, modo || 'pre');
  res.json({ resposta, db });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor Bot & API rodando na porta ${PORT}`);
  console.log(`🔗 Webhook pronto em: http://localhost:${PORT}/webhook/whatsapp`);
});