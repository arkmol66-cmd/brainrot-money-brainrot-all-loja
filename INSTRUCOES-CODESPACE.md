# 🧠 ALL CODESPACE ACTIVE - Instruções de Uso

## 🚀 Início Rápido no GitHub Codespace

### 1. Primeiro Uso (Configuração)
```bash
# Tornar executável (no Codespace Linux)
chmod +x all-codespace-active.sh

# Configurar auto-start
./all-codespace-active.sh setup

# Iniciar sistema
./all-codespace-active.sh start
```

### 2. Comandos Principais
```bash
# Iniciar sistema completo 24/7
./all-codespace-active.sh start

# Verificar status
./all-codespace-active.sh status

# Ver logs em tempo real
./all-codespace-active.sh logs

# Parar sistema
./all-codespace-active.sh stop

# Reiniciar sistema
./all-codespace-active.sh restart
```

### 3. Comandos de Monitoramento
```bash
# Ver logs específicos
./all-codespace-active.sh logs ka    # Keep-alive logs
./all-codespace-active.sh logs hc    # Health check logs
./all-codespace-active.sh logs main  # Logs principais

# Testar sistema
./all-codespace-active.sh test
```

## 🔧 O que o Sistema Faz

### ✅ Keep-Alive (Manter Ativo)
- **Atividade de CPU**: Cálculos matemáticos leves
- **Atividade de Memória**: Operações com arrays
- **Atividade de Disco**: Criação/leitura de arquivos temporários
- **Atividade de Rede**: Requisições HTTP e pings
- **Simulação de Usuário**: Comandos de terminal automáticos

### 🏥 Health Check (Monitoramento)
- **Recursos**: CPU, memória, disco, load average
- **Conectividade**: Internet e GitHub API
- **Processos**: Verifica se serviços estão rodando
- **Auto-Recovery**: Reinicia serviços se pararem

### 👁️ Monitor Principal
- **Supervisão**: Monitora keep-alive e health check
- **Auto-Restart**: Reinicia componentes automaticamente
- **Logging**: Registra todas as atividades

## 📊 Funcionalidades Avançadas

### 🔄 Auto-Start
- Inicia automaticamente quando o Codespace é aberto
- Configurado no `.bashrc` do usuário
- Funciona mesmo após reinicializações

### 📝 Sistema de Logs
- **logs/codespace-active.log**: Log principal
- **logs/keep-alive.log**: Atividades de keep-alive
- **logs/health-check.log**: Monitoramento de saúde

### 🛡️ Proteções
- Verifica se já está rodando antes de iniciar
- Remove PIDs órfãos automaticamente
- Reinicia componentes falhos
- Mantém atividade mesmo com inatividade prolongada

## ⚙️ Configurações

### Intervalos (editáveis no script)
- **KEEP_ALIVE_INTERVAL**: 300 segundos (5 minutos)
- **HEALTH_CHECK_INTERVAL**: 300 segundos (5 minutos)

### Arquivos Importantes
- **pids/**: Diretório com PIDs dos processos
- **logs/**: Diretório com todos os logs
- **.codespace-heartbeat**: Arquivo de heartbeat

## 🚨 Solução de Problemas

### Se o Codespace parar:
1. `./all-codespace-active.sh status` - Verificar o que parou
2. `./all-codespace-active.sh restart` - Reiniciar tudo
3. `./all-codespace-active.sh logs` - Ver logs para debug

### Se não iniciar automaticamente:
1. `./all-codespace-active.sh setup` - Reconfigurar auto-start
2. Verificar se está no `.bashrc`: `cat ~/.bashrc | grep codespace`

### Para debug avançado:
```bash
# Ver todos os processos do usuário
ps aux | grep $(whoami)

# Ver logs em tempo real
tail -f logs/*.log

# Verificar conectividade manual
ping -c 3 8.8.8.8
curl -s https://api.github.com/zen
```

## 💡 Dicas Importantes

1. **Execute `setup` apenas uma vez** - configura auto-start permanente
2. **Use `status` regularmente** - para monitorar saúde do sistema  
3. **Logs são seus amigos** - sempre verifique em caso de problemas
4. **O sistema é resiliente** - se algo parar, será reiniciado automaticamente
5. **Funciona 24/7** - mesmo com PC/telefone desligados

## 🎯 Resultado Esperado

Após configurar e iniciar:
- ✅ Codespace permanece ativo 24/7
- ✅ Atividade constante simulada
- ✅ Monitoramento automático
- ✅ Auto-restart em falhas
- ✅ Logs detalhados de tudo
- ✅ Funciona independente de dispositivos

**O seu GitHub Codespace nunca mais será suspenso por inatividade!** 🚀