# 💰🧠 BRAINROTS MONEY - Instruções Simples

## 🚀 Scripts Renomeados:

- **`1.sh`** = Servidor web (serve HTML)
- **`2.sh`** = Sistema completo (keep-alive + servidor)

## ⚡ Início Rápido (3 comandos):

```bash
# 1. Tornar executável
chmod +x 2.sh

# 2. Configurar sistema
./2.sh setup

# 3. Iniciar tudo
./2.sh start
```

## 📋 Comandos Principais:

### 🌐 Script 1.sh (Apenas Servidor Web):
```bash
./1.sh start     # Iniciar servidor
./1.sh status    # Ver status
./1.sh open      # Abrir no navegador
./1.sh stop      # Parar servidor
```

### 🚀 Script 2.sh (Sistema Completo - RECOMENDADO):
```bash
./2.sh start     # Iniciar tudo (keep-alive + servidor)
./2.sh status    # Ver status completo
./2.sh open      # Abrir aplicação
./2.sh logs      # Ver logs
./2.sh stop      # Parar tudo
```

## 🎯 Qual usar?

- **Use `2.sh`** - Sistema completo (recomendado)
  - ✅ Mantém Codespace ativo 24/7
  - ✅ Servidor web funcionando
  - ✅ Auto-restart se parar
  - ✅ Logs detalhados

- **Use `1.sh`** - Apenas se quiser só o servidor web
  - ✅ Serve HTML/CSS/JS
  - ❌ Não mantém Codespace ativo

## 🔗 Resultado:

Após `./2.sh start`, você terá:
- 🌍 URL pública: `https://seu-codespace-8000.app.github.dev`
- 💰 Aplicação Brainrots Money funcionando
- 🔄 Sistema ativo 24/7

## 👥 Login:
- **@moderador** / senha: `mapas1020304050607080900`
- **@adm** / senha: `mapas102030405060708090`

**Use `./2.sh start` para ter tudo funcionando!** 🚀