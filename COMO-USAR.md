# 💰🧠 BRAINROTS MONEY - Como Usar

## 🚀 Início Rápido (3 comandos)

```bash
# 1. Tornar executável
chmod +x brainrots-complete.sh

# 2. Configurar sistema
./brainrots-complete.sh setup

# 3. Iniciar tudo
./brainrots-complete.sh start
```

## 🎯 O que acontece quando você executa:

### ✅ Sistema Keep-Alive 24/7
- Mantém o Codespace ativo mesmo com PC desligado
- Simula atividade de usuário constantemente
- Auto-restart se algo parar
- Logs detalhados de tudo

### 🌐 Servidor Web Automático
- Serve sua aplicação HTML automaticamente
- Tenta Python, PHP ou Node.js (o que estiver disponível)
- Encontra porta livre automaticamente
- URL pública do Codespace gerada automaticamente

### 💰 Aplicação Brainrots Money
- Sistema de moeda digital funcionando
- Login com usuários pré-configurados
- Criação de novas contas
- Transferências entre usuários
- Painel administrativo

## 📋 Comandos Principais

```bash
# Ver status de tudo
./brainrots-complete.sh status

# Abrir aplicação no navegador
./brainrots-complete.sh open

# Ver logs em tempo real
./brainrots-complete.sh logs

# Reiniciar tudo se necessário
./brainrots-complete.sh restart

# Parar tudo
./brainrots-complete.sh stop
```

## 🔗 Como Acessar sua Aplicação

Após executar `./brainrots-complete.sh start`, você verá:

```
🔗 LINKS DE ACESSO
==================
🔗 Local: http://localhost:8000
🌍 Público: https://seu-codespace-8000.app.github.dev
```

### 🌍 URL Pública
- Funciona de qualquer lugar do mundo
- Não precisa de VPN ou configuração
- Compartilhável com outras pessoas
- Sempre no formato: `https://CODESPACE-PORTA.app.github.dev`

## 👥 Usuários Pré-configurados

### 🔑 Administradores
- **@moderador** / senha: `mapas1020304050607080900`
- **@adm** / senha: `mapas102030405060708090`

### ➕ Criar Nova Conta
1. Clique em "Criar Conta" na tela de login
2. Preencha username e senha (min. 6 caracteres)
3. Conta criada automaticamente com 500 BRM

## 🛠️ Scripts Individuais (Avançado)

Se quiser controlar separadamente:

```bash
# Apenas Keep-Alive (manter Codespace ativo)
./all-codespace-active.sh start

# Apenas Servidor Web (servir HTML)
./serve-brainrots-money.sh start

# Sistema Completo (recomendado)
./brainrots-complete.sh start
```

## 🔧 Solução de Problemas

### ❌ Se não funcionar:
```bash
# 1. Testar sistema
./brainrots-complete.sh test

# 2. Ver logs para debug
./brainrots-complete.sh logs

# 3. Reiniciar tudo
./brainrots-complete.sh restart
```

### 🐛 Problemas Comuns:

**"Servidor não inicia"**
- Verifique se Python, PHP ou Node.js estão instalados
- Execute: `./brainrots-complete.sh test`

**"Keep-alive não funciona"**
- Verifique se está no GitHub Codespace
- Execute: `./all-codespace-active.sh status`

**"Aplicação não carrega"**
- Verifique se `index.html` existe
- Teste: `curl http://localhost:8000`

## 🎉 Resultado Final

Após configurar, você terá:

- ✅ **Codespace ativo 24/7** (nunca suspende)
- ✅ **Aplicação web funcionando** (acessível globalmente)
- ✅ **Sistema de moeda digital** (Brainrots Money)
- ✅ **Auto-restart** (se algo parar, reinicia sozinho)
- ✅ **Logs detalhados** (para debug)
- ✅ **URLs públicas** (compartilháveis)

## 🚀 Comandos de Monitoramento

```bash
# Status rápido
./brainrots-complete.sh status

# Logs específicos
./brainrots-complete.sh logs server    # Servidor web
./brainrots-complete.sh logs ka        # Keep-alive

# Abrir aplicação
./brainrots-complete.sh open
```

**Seu sistema Brainrots Money agora roda 24/7 na nuvem!** 💰🧠🚀