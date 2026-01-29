#!/bin/bash

# =============================================================================
# ALL CODESPACE ACTIVE - Sistema Completo 24/7
# Script único para manter GitHub Codespace ativo continuamente
# Autor: Sistema Brainrots Money
# =============================================================================

# Configurações globais
KEEP_ALIVE_INTERVAL=300  # 5 minutos
HEALTH_CHECK_INTERVAL=300  # 5 minutos
LOG_DIR="logs"
KEEP_ALIVE_LOG="$LOG_DIR/keep-alive.log"
HEALTH_LOG="$LOG_DIR/health-check.log"
MAIN_LOG="$LOG_DIR/codespace-active.log"
PID_DIR="pids"
KEEP_ALIVE_PID="$PID_DIR/keep-alive.pid"
HEALTH_PID="$PID_DIR/health-check.pid"
MONITOR_PID="$PID_DIR/monitor.pid"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Criar diretórios necessários
setup_directories() {
    mkdir -p "$LOG_DIR" "$PID_DIR"
}

# Função de logging
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$MAIN_LOG"
}

# Print colorido
print_header() {
    echo -e "${PURPLE}🧠 =================================="
    echo -e "🚀 ALL CODESPACE ACTIVE 24/7"
    echo -e "🧠 ==================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log_message "SUCCESS" "$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_message "WARNING" "$1"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    log_message "ERROR" "$1"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    log_message "INFO" "$1"
}

print_activity() {
    echo -e "${CYAN}🔄 $1${NC}"
    log_message "ACTIVITY" "$1"
}

# =============================================================================
# MÓDULO KEEP-ALIVE
# =============================================================================

# Atividade de CPU
cpu_activity() {
    echo "scale=10; 4*a(1)" | bc -l > /dev/null 2>&1
    dd if=/dev/zero of=/dev/null bs=1024 count=100 2>/dev/null &
    sleep 0.1
    pkill -f "dd if=/dev/zero" 2>/dev/null
}

# Atividade de memória
memory_activity() {
    local temp_array=($(seq 1 1000))
    local sum=0
    for i in "${temp_array[@]}"; do
        sum=$((sum + i))
    done
    unset temp_array
}

# Atividade de disco
disk_activity() {
    local temp_file="/tmp/codespace_activity_$(date +%s).tmp"
    echo "$(date) - Codespace alive check - $(whoami) - $$" > "$temp_file"
    cat "$temp_file" > /dev/null
    ls -la "$temp_file" > /dev/null 2>&1
    rm -f "$temp_file"
    
    # Tocar arquivos importantes
    touch index.html script.js style.css users.json 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Active" > .codespace-heartbeat
}

# Atividade de rede
network_activity() {
    # Múltiplas requisições para manter conexão ativa
    curl -s --max-time 5 https://api.github.com/zen > /dev/null 2>&1 &
    curl -s --max-time 5 https://httpbin.org/uuid > /dev/null 2>&1 &
    curl -s --max-time 5 https://jsonplaceholder.typicode.com/posts/1 > /dev/null 2>&1 &
    
    # Ping para diferentes servidores
    ping -c 1 8.8.8.8 > /dev/null 2>&1 &
    ping -c 1 1.1.1.1 > /dev/null 2>&1 &
    
    wait
}

# Simular atividade de usuário
simulate_user_activity() {
    print_activity "Simulando atividade de usuário..."
    
    # Atividades em paralelo
    cpu_activity &
    memory_activity &
    disk_activity &
    network_activity &
    
    # Simular comandos de terminal
    ps aux | head -10 > /dev/null 2>&1 &
    ls -la > /dev/null 2>&1 &
    df -h > /dev/null 2>&1 &
    free -h > /dev/null 2>&1 &
    
    wait
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User activity simulated" >> "$KEEP_ALIVE_LOG"
}

# Manter processos ativos
maintain_processes() {
    local user_processes=$(ps aux | grep -v grep | grep -c "$(whoami)")
    
    if [ "$user_processes" -lt 10 ]; then
        print_activity "Criando processos de background..."
        
        # Criar processos leves em background
        sleep 3600 &  # 1 hora
        tail -f /dev/null &  # Monitor infinito
        yes > /dev/null &  # Gerador de output
        local yes_pid=$!
        sleep 1
        kill $yes_pid 2>/dev/null
        
        # Processo de monitoramento de arquivos
        find . -name "*.html" -o -name "*.js" -o -name "*.css" | head -5 | xargs tail -f > /dev/null 2>&1 &
        local tail_pid=$!
        sleep 2
        kill $tail_pid 2>/dev/null
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Processes maintained: $user_processes" >> "$KEEP_ALIVE_LOG"
}

# Loop principal do keep-alive
keep_alive_loop() {
    log_message "KEEP-ALIVE" "Iniciando loop keep-alive (PID: $$)"
    
    while true; do
        simulate_user_activity
        maintain_processes
        
        # Status report a cada hora
        local current_min=$(date +%M)
        if [ "$current_min" = "00" ]; then
            local uptime_info=$(uptime | awk '{print $3,$4}' | sed 's/,//')
            local load_info=$(uptime | awk -F'load average:' '{print $2}')
            log_message "HOURLY" "Uptime: $uptime_info | Load: $load_info"
        fi
        
        sleep $KEEP_ALIVE_INTERVAL
    done
}

# =============================================================================
# MÓDULO HEALTH CHECK
# =============================================================================

# Verificar recursos do sistema
check_system_resources() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}' 2>/dev/null || echo "N/A")
    local memory_info=$(free -h | grep "Mem:" 2>/dev/null)
    local memory_used=$(echo $memory_info | awk '{print $3}' 2>/dev/null || echo "N/A")
    local memory_total=$(echo $memory_info | awk '{print $2}' 2>/dev/null || echo "N/A")
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' 2>/dev/null || echo "N/A")
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' 2>/dev/null || echo "N/A")
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - CPU: ${cpu_usage}% | Memory: $memory_used/$memory_total | Disk: $disk_usage | Load: $load_avg" >> "$HEALTH_LOG"
}

# Verificar conectividade
check_connectivity() {
    local internet_status="❌"
    local github_status="❌"
    
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        internet_status="✅"
    fi
    
    if curl -s --max-time 10 https://api.github.com/zen >/dev/null 2>&1; then
        github_status="✅"
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Internet: $internet_status | GitHub: $github_status" >> "$HEALTH_LOG"
}

# Verificar processos críticos
check_critical_processes() {
    local keep_alive_running="❌"
    local user_processes=$(ps aux | grep -v grep | grep -c "$(whoami)")
    
    if pgrep -f "keep_alive_loop" >/dev/null 2>&1; then
        keep_alive_running="✅"
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Keep-Alive: $keep_alive_running | User Processes: $user_processes" >> "$HEALTH_LOG"
    
    # Reiniciar keep-alive se necessário
    if [ "$keep_alive_running" = "❌" ]; then
        print_warning "Keep-alive parado, reiniciando..."
        start_keep_alive
    fi
}

# Verificar tempo de inatividade
check_idle_time() {
    local last_access=$(find . -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.json" 2>/dev/null | xargs stat -c %Y 2>/dev/null | sort -n | tail -1)
    local current_time=$(date +%s)
    
    if [ ! -z "$last_access" ]; then
        local idle_time=$((current_time - last_access))
        local idle_minutes=$((idle_time / 60))
        
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Idle time: ${idle_minutes} minutes" >> "$HEALTH_LOG"
        
        # Se inativo por mais de 15 minutos, forçar atividade
        if [ $idle_minutes -gt 15 ]; then
            print_activity "Sistema inativo por $idle_minutes min, forçando atividade..."
            simulate_user_activity
            
            # Criar atividade nos arquivos
            echo "# Auto-generated activity $(date)" >> .auto-activity.tmp
            rm -f .auto-activity.tmp 2>/dev/null
        fi
    fi
}

# Loop principal do health check
health_check_loop() {
    log_message "HEALTH" "Iniciando health check (PID: $$)"
    
    while true; do
        check_system_resources
        check_connectivity
        check_critical_processes
        check_idle_time
        
        sleep $HEALTH_CHECK_INTERVAL
    done
}

# =============================================================================
# MÓDULO DE CONTROLE
# =============================================================================

# Verificar se processo está rodando
is_process_running() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p "$pid" >/dev/null 2>&1; then
            return 0
        else
            rm -f "$pid_file"
            return 1
        fi
    fi
    return 1
}

# Iniciar keep-alive
start_keep_alive() {
    if is_process_running "$KEEP_ALIVE_PID"; then
        print_warning "Keep-alive já está rodando"
        return 1
    fi
    
    print_info "Iniciando keep-alive..."
    keep_alive_loop &
    echo $! > "$KEEP_ALIVE_PID"
    print_success "Keep-alive iniciado (PID: $!)"
}

# Iniciar health check
start_health_check() {
    if is_process_running "$HEALTH_PID"; then
        print_warning "Health check já está rodando"
        return 1
    fi
    
    print_info "Iniciando health check..."
    health_check_loop &
    echo $! > "$HEALTH_PID"
    print_success "Health check iniciado (PID: $!)"
}

# Parar processo
stop_process() {
    local pid_file="$1"
    local name="$2"
    
    if is_process_running "$pid_file"; then
        local pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
        print_success "$name parado"
    else
        print_warning "$name não está rodando"
    fi
}

# Instalar dependências
install_dependencies() {
    print_info "Verificando dependências..."
    
    # bc para cálculos matemáticos
    if ! command -v bc >/dev/null 2>&1; then
        print_info "Instalando bc..."
        sudo apt-get update >/dev/null 2>&1
        sudo apt-get install -y bc >/dev/null 2>&1
        print_success "bc instalado"
    fi
    
    # curl para requisições HTTP
    if ! command -v curl >/dev/null 2>&1; then
        print_info "Instalando curl..."
        sudo apt-get install -y curl >/dev/null 2>&1
        print_success "curl instalado"
    fi
}

# Configurar auto-start
setup_autostart() {
    print_info "Configurando auto-start..."
    
    # Criar script de startup
    cat > ~/.codespace-startup.sh << 'EOF'
#!/bin/bash
sleep 30
cd "$CODESPACE_VSCODE_FOLDER" 2>/dev/null || cd ~
if [ -f "all-codespace-active.sh" ]; then
    chmod +x all-codespace-active.sh
    ./all-codespace-active.sh start
fi
EOF
    
    chmod +x ~/.codespace-startup.sh
    
    # Adicionar ao .bashrc se não existir
    if ! grep -q "codespace-startup.sh" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# Auto-start Codespace Keep-Alive" >> ~/.bashrc
        echo "if [ -f ~/.codespace-startup.sh ]; then" >> ~/.bashrc
        echo "    ~/.codespace-startup.sh &" >> ~/.bashrc
        echo "fi" >> ~/.bashrc
    fi
    
    print_success "Auto-start configurado"
}

# Monitor principal
start_monitor() {
    if is_process_running "$MONITOR_PID"; then
        print_warning "Monitor já está rodando"
        return 1
    fi
    
    print_info "Iniciando monitor principal..."
    
    (
        while true; do
            # Verificar e reiniciar keep-alive se necessário
            if ! is_process_running "$KEEP_ALIVE_PID"; then
                log_message "MONITOR" "Keep-alive parado, reiniciando..."
                start_keep_alive
            fi
            
            # Verificar e reiniciar health check se necessário
            if ! is_process_running "$HEALTH_PID"; then
                log_message "MONITOR" "Health check parado, reiniciando..."
                start_health_check
            fi
            
            sleep 60  # Verificar a cada minuto
        done
    ) &
    
    echo $! > "$MONITOR_PID"
    print_success "Monitor iniciado (PID: $!)"
}

# =============================================================================
# FUNÇÕES DE COMANDO
# =============================================================================

# Comando: start
cmd_start() {
    print_header
    print_info "Iniciando sistema completo Codespace 24h..."
    
    setup_directories
    install_dependencies
    
    start_keep_alive
    sleep 2
    start_health_check
    sleep 2
    start_monitor
    
    print_success "Sistema Codespace 24h iniciado com sucesso!"
    print_info "Use '$0 status' para verificar o status"
}

# Comando: stop
cmd_stop() {
    print_header
    print_info "Parando sistema Codespace 24h..."
    
    stop_process "$MONITOR_PID" "Monitor"
    stop_process "$KEEP_ALIVE_PID" "Keep-alive"
    stop_process "$HEALTH_PID" "Health check"
    
    # Limpar processos órfãos
    pkill -f "keep_alive_loop" 2>/dev/null
    pkill -f "health_check_loop" 2>/dev/null
    
    print_success "Sistema Codespace 24h parado!"
}

# Comando: status
cmd_status() {
    print_header
    echo ""
    
    # Status dos serviços
    echo -e "${BLUE}📊 STATUS DOS SERVIÇOS${NC}"
    echo "========================"
    
    if is_process_running "$KEEP_ALIVE_PID"; then
        local pid=$(cat "$KEEP_ALIVE_PID")
        echo -e "🔄 Keep-Alive: ${GREEN}RODANDO${NC} (PID: $pid)"
    else
        echo -e "🔄 Keep-Alive: ${RED}PARADO${NC}"
    fi
    
    if is_process_running "$HEALTH_PID"; then
        local pid=$(cat "$HEALTH_PID")
        echo -e "🏥 Health Check: ${GREEN}RODANDO${NC} (PID: $pid)"
    else
        echo -e "🏥 Health Check: ${RED}PARADO${NC}"
    fi
    
    if is_process_running "$MONITOR_PID"; then
        local pid=$(cat "$MONITOR_PID")
        echo -e "👁️  Monitor: ${GREEN}RODANDO${NC} (PID: $pid)"
    else
        echo -e "👁️  Monitor: ${RED}PARADO${NC}"
    fi
    
    echo ""
    
    # Recursos do sistema
    echo -e "${BLUE}📈 RECURSOS DO SISTEMA${NC}"
    echo "======================"
    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}' 2>/dev/null || echo "N/A")
    local memory=$(free -h | grep "Mem:" | awk '{print $3 "/" $2}' 2>/dev/null || echo "N/A")
    local disk=$(df -h / | tail -1 | awk '{print $5}' 2>/dev/null || echo "N/A")
    local load=$(uptime | awk -F'load average:' '{print $2}' 2>/dev/null || echo "N/A")
    local processes=$(ps aux | grep -v grep | grep -c "$(whoami)")
    
    echo "💻 CPU: ${cpu}%"
    echo "🧠 Memory: $memory"
    echo "💾 Disk: $disk"
    echo "⚖️  Load: $load"
    echo "🔢 User Processes: $processes"
    
    echo ""
    
    # Conectividade
    echo -e "${BLUE}🌐 CONECTIVIDADE${NC}"
    echo "================"
    
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "🌍 Internet: ${GREEN}OK${NC}"
    else
        echo -e "🌍 Internet: ${RED}FALHA${NC}"
    fi
    
    if curl -s --max-time 5 https://api.github.com/zen >/dev/null 2>&1; then
        echo -e "🐙 GitHub: ${GREEN}OK${NC}"
    else
        echo -e "🐙 GitHub: ${RED}FALHA${NC}"
    fi
    
    echo ""
    
    # Logs recentes
    echo -e "${BLUE}📋 LOGS RECENTES${NC}"
    echo "================"
    if [ -f "$MAIN_LOG" ]; then
        tail -5 "$MAIN_LOG"
    else
        echo "Nenhum log encontrado"
    fi
}

# Comando: logs
cmd_logs() {
    print_header
    echo ""
    
    case "${2:-main}" in
        "keep-alive"|"ka")
            if [ -f "$KEEP_ALIVE_LOG" ]; then
                echo -e "${BLUE}📋 LOGS KEEP-ALIVE${NC}"
                echo "=================="
                tail -f "$KEEP_ALIVE_LOG"
            else
                print_error "Log keep-alive não encontrado"
            fi
            ;;
        "health"|"hc")
            if [ -f "$HEALTH_LOG" ]; then
                echo -e "${BLUE}📋 LOGS HEALTH CHECK${NC}"
                echo "===================="
                tail -f "$HEALTH_LOG"
            else
                print_error "Log health check não encontrado"
            fi
            ;;
        "main"|*)
            if [ -f "$MAIN_LOG" ]; then
                echo -e "${BLUE}📋 LOGS PRINCIPAIS${NC}"
                echo "=================="
                tail -f "$MAIN_LOG"
            else
                print_error "Log principal não encontrado"
            fi
            ;;
    esac
}

# Comando: setup
cmd_setup() {
    print_header
    print_info "Configurando sistema Codespace 24h..."
    
    setup_directories
    install_dependencies
    setup_autostart
    
    # Criar arquivo de configuração
    cat > codespace-config.conf << EOF
# Configuração Codespace 24h
KEEP_ALIVE_INTERVAL=$KEEP_ALIVE_INTERVAL
HEALTH_CHECK_INTERVAL=$HEALTH_CHECK_INTERVAL
AUTO_START=true
LOG_LEVEL=INFO
EOF
    
    print_success "Configuração concluída!"
    print_info "O sistema iniciará automaticamente na próxima sessão"
    print_info "Para iniciar agora: $0 start"
}

# Comando: test
cmd_test() {
    print_header
    print_info "Executando testes do sistema..."
    
    # Teste de dependências
    echo -e "${BLUE}🔧 Testando dependências...${NC}"
    command -v bc >/dev/null 2>&1 && print_success "bc disponível" || print_error "bc não encontrado"
    command -v curl >/dev/null 2>&1 && print_success "curl disponível" || print_error "curl não encontrado"
    
    # Teste de conectividade
    echo -e "${BLUE}🌐 Testando conectividade...${NC}"
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && print_success "Internet OK" || print_error "Internet falhou"
    curl -s --max-time 5 https://api.github.com/zen >/dev/null 2>&1 && print_success "GitHub OK" || print_error "GitHub falhou"
    
    # Teste de atividades
    echo -e "${BLUE}🎯 Testando atividades...${NC}"
    cpu_activity && print_success "CPU activity OK"
    memory_activity && print_success "Memory activity OK"
    disk_activity && print_success "Disk activity OK"
    
    print_success "Testes concluídos!"
}

# =============================================================================
# FUNÇÃO PRINCIPAL
# =============================================================================

# Mostrar ajuda
show_help() {
    print_header
    echo ""
    echo -e "${BLUE}COMANDOS DISPONÍVEIS:${NC}"
    echo ""
    echo -e "${GREEN}$0 start${NC}     - Iniciar sistema completo"
    echo -e "${GREEN}$0 stop${NC}      - Parar sistema completo"
    echo -e "${GREEN}$0 status${NC}    - Verificar status dos serviços"
    echo -e "${GREEN}$0 logs${NC}      - Ver logs principais (use 'ka' ou 'hc' para específicos)"
    echo -e "${GREEN}$0 setup${NC}     - Configurar auto-start"
    echo -e "${GREEN}$0 test${NC}      - Executar testes do sistema"
    echo -e "${GREEN}$0 restart${NC}   - Reiniciar sistema completo"
    echo ""
    echo -e "${BLUE}EXEMPLOS:${NC}"
    echo "  $0 start           # Iniciar tudo"
    echo "  $0 status          # Ver status"
    echo "  $0 logs ka         # Ver logs keep-alive"
    echo "  $0 logs hc         # Ver logs health check"
    echo ""
    echo -e "${YELLOW}NOTA:${NC} Execute '$0 setup' primeiro para configurar auto-start"
}

# Função principal
main() {
    # Verificar se estamos no Codespace
    if [ ! -z "$CODESPACE_NAME" ]; then
        log_message "INFO" "Executando no Codespace: $CODESPACE_NAME"
    fi
    
    case "${1:-}" in
        "start")
            cmd_start
            ;;
        "stop")
            cmd_stop
            ;;
        "restart")
            cmd_stop
            sleep 3
            cmd_start
            ;;
        "status")
            cmd_status
            ;;
        "logs")
            cmd_logs "$@"
            ;;
        "setup")
            cmd_setup
            ;;
        "test")
            cmd_test
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"