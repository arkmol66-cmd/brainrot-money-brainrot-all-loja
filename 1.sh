#!/bin/bash

# =============================================================================
# SERVE BRAINROTS MONEY - Servidor Web 24/7
# Script para servir a aplicação HTML e manter ativa
# =============================================================================

# Configurações
PORT=8000
BACKUP_PORT=3000
LOG_DIR="logs"
SERVER_LOG="$LOG_DIR/server.log"
PID_DIR="pids"
SERVER_PID="$PID_DIR/server.pid"
HEALTH_PID="$PID_DIR/server-health.pid"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Criar diretórios
setup_directories() {
    mkdir -p "$LOG_DIR" "$PID_DIR"
}

# Logging
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$SERVER_LOG"
}

# Print colorido
print_header() {
    echo -e "${PURPLE}💰 =================================="
    echo -e "🧠 BRAINROTS MONEY SERVER 24/7"
    echo -e "💰 ==================================${NC}"
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

print_server() {
    echo -e "${CYAN}🌐 $1${NC}"
    log_message "SERVER" "$1"
}

# Verificar se porta está disponível
check_port() {
    local port=$1
    if command -v lsof >/dev/null 2>&1; then
        lsof -i :$port >/dev/null 2>&1
        return $?
    elif command -v netstat >/dev/null 2>&1; then
        netstat -ln | grep ":$port " >/dev/null 2>&1
        return $?
    else
        # Tentar conectar na porta
        timeout 1 bash -c "</dev/tcp/localhost/$port" >/dev/null 2>&1
        return $?
    fi
}

# Encontrar porta disponível
find_available_port() {
    local start_port=$1
    local port=$start_port
    
    while [ $port -le $((start_port + 100)) ]; do
        if ! check_port $port; then
            echo $port
            return 0
        fi
        port=$((port + 1))
    done
    
    echo $start_port
    return 1
}

# Verificar se processo está rodando
is_server_running() {
    if [ -f "$SERVER_PID" ]; then
        local pid=$(cat "$SERVER_PID")
        if ps -p "$pid" >/dev/null 2>&1; then
            return 0
        else
            rm -f "$SERVER_PID"
            return 1
        fi
    fi
    return 1
}

# Criar arquivo index.php para melhor compatibilidade
create_php_server() {
    cat > server.php << 'EOF'
<?php
// Servidor PHP simples para Brainrots Money
$request = $_SERVER['REQUEST_URI'];
$path = parse_url($request, PHP_URL_PATH);

// Roteamento simples
switch ($path) {
    case '/':
    case '/index.html':
        if (file_exists('index.html')) {
            readfile('index.html');
        } else {
            http_response_code(404);
            echo "index.html não encontrado";
        }
        break;
        
    case '/style.css':
        if (file_exists('style.css')) {
            header('Content-Type: text/css');
            readfile('style.css');
        } else {
            http_response_code(404);
        }
        break;
        
    case '/script.js':
        if (file_exists('script.js')) {
            header('Content-Type: application/javascript');
            readfile('script.js');
        } else {
            http_response_code(404);
        }
        break;
        
    case '/users.json':
        if (file_exists('users.json')) {
            header('Content-Type: application/json');
            readfile('users.json');
        } else {
            http_response_code(404);
            echo '{}';
        }
        break;
        
    default:
        // Tentar servir arquivo estático
        $file = ltrim($path, '/');
        if (file_exists($file) && is_file($file)) {
            $ext = pathinfo($file, PATHINFO_EXTENSION);
            switch ($ext) {
                case 'css':
                    header('Content-Type: text/css');
                    break;
                case 'js':
                    header('Content-Type: application/javascript');
                    break;
                case 'json':
                    header('Content-Type: application/json');
                    break;
                case 'html':
                    header('Content-Type: text/html');
                    break;
            }
            readfile($file);
        } else {
            http_response_code(404);
            echo "Arquivo não encontrado: $path";
        }
        break;
}
?>
EOF
}

# Iniciar servidor Python
start_python_server() {
    local port=$1
    
    print_server "Tentando iniciar servidor Python na porta $port..."
    
    # Python 3
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server $port > "$SERVER_LOG" 2>&1 &
        local pid=$!
        echo $pid > "$SERVER_PID"
        sleep 2
        
        if ps -p $pid >/dev/null 2>&1; then
            print_success "Servidor Python3 iniciado (PID: $pid, Porta: $port)"
            return 0
        fi
    fi
    
    # Python 2
    if command -v python2 >/dev/null 2>&1; then
        python2 -m SimpleHTTPServer $port > "$SERVER_LOG" 2>&1 &
        local pid=$!
        echo $pid > "$SERVER_PID"
        sleep 2
        
        if ps -p $pid >/dev/null 2>&1; then
            print_success "Servidor Python2 iniciado (PID: $pid, Porta: $port)"
            return 0
        fi
    fi
    
    # Python genérico
    if command -v python >/dev/null 2>&1; then
        python -m http.server $port > "$SERVER_LOG" 2>&1 &
        local pid=$!
        echo $pid > "$SERVER_PID"
        sleep 2
        
        if ps -p $pid >/dev/null 2>&1; then
            print_success "Servidor Python iniciado (PID: $pid, Porta: $port)"
            return 0
        fi
    fi
    
    return 1
}

# Iniciar servidor PHP
start_php_server() {
    local port=$1
    
    if command -v php >/dev/null 2>&1; then
        print_server "Tentando iniciar servidor PHP na porta $port..."
        
        create_php_server
        php -S localhost:$port server.php > "$SERVER_LOG" 2>&1 &
        local pid=$!
        echo $pid > "$SERVER_PID"
        sleep 2
        
        if ps -p $pid >/dev/null 2>&1; then
            print_success "Servidor PHP iniciado (PID: $pid, Porta: $port)"
            return 0
        fi
    fi
    
    return 1
}

# Iniciar servidor Node.js
start_node_server() {
    local port=$1
    
    if command -v node >/dev/null 2>&1; then
        print_server "Tentando iniciar servidor Node.js na porta $port..."
        
        # Criar servidor Node.js simples
        cat > server.js << EOF
const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
    let filePath = req.url === '/' ? '/index.html' : req.url;
    filePath = path.join(__dirname, filePath);
    
    const ext = path.extname(filePath);
    let contentType = 'text/html';
    
    switch (ext) {
        case '.css': contentType = 'text/css'; break;
        case '.js': contentType = 'application/javascript'; break;
        case '.json': contentType = 'application/json'; break;
    }
    
    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404);
            res.end('Arquivo não encontrado');
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(data);
        }
    });
});

server.listen($port, () => {
    console.log('Servidor rodando na porta $port');
});
EOF
        
        node server.js > "$SERVER_LOG" 2>&1 &
        local pid=$!
        echo $pid > "$SERVER_PID"
        sleep 2
        
        if ps -p $pid >/dev/null 2>&1; then
            print_success "Servidor Node.js iniciado (PID: $pid, Porta: $port)"
            return 0
        fi
    fi
    
    return 1
}

# Iniciar servidor
start_server() {
    if is_server_running; then
        print_warning "Servidor já está rodando"
        return 1
    fi
    
    # Verificar se arquivos existem
    if [ ! -f "index.html" ]; then
        print_error "index.html não encontrado!"
        return 1
    fi
    
    # Encontrar porta disponível
    local available_port=$(find_available_port $PORT)
    
    print_info "Iniciando servidor web para Brainrots Money..."
    print_info "Porta selecionada: $available_port"
    
    # Tentar diferentes servidores
    if start_python_server $available_port; then
        SERVER_TYPE="Python"
    elif start_php_server $available_port; then
        SERVER_TYPE="PHP"
    elif start_node_server $available_port; then
        SERVER_TYPE="Node.js"
    else
        print_error "Nenhum servidor disponível (Python, PHP, Node.js)"
        return 1
    fi
    
    # Verificar se está funcionando
    sleep 3
    if check_port $available_port; then
        print_success "Servidor $SERVER_TYPE funcionando!"
        print_info "Acesse: http://localhost:$available_port"
        
        # Se estiver no Codespace, mostrar URL pública
        if [ ! -z "$CODESPACE_NAME" ]; then
            local public_url="https://$CODESPACE_NAME-$available_port.app.github.dev"
            print_success "URL Pública: $public_url"
            echo "$public_url" > .server-url
        fi
        
        # Iniciar health check do servidor
        start_server_health_check $available_port
        
    else
        print_error "Servidor não está respondendo"
        stop_server
        return 1
    fi
}

# Health check do servidor
server_health_check() {
    local port=$1
    
    while true; do
        if is_server_running; then
            # Verificar se porta está respondendo
            if check_port $port; then
                log_message "HEALTH" "Servidor OK na porta $port"
                
                # Fazer requisição de teste
                if command -v curl >/dev/null 2>&1; then
                    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/ 2>/dev/null)
                    if [ "$response" = "200" ]; then
                        log_message "HEALTH" "HTTP 200 OK"
                    else
                        log_message "WARNING" "HTTP response: $response"
                    fi
                fi
            else
                log_message "ERROR" "Porta $port não está respondendo"
                print_warning "Servidor parou de responder, reiniciando..."
                stop_server
                sleep 5
                start_server
            fi
        else
            log_message "ERROR" "Processo do servidor morreu"
            print_warning "Processo do servidor morreu, reiniciando..."
            start_server
        fi
        
        sleep 30  # Verificar a cada 30 segundos
    done
}

# Iniciar health check do servidor
start_server_health_check() {
    local port=$1
    
    if [ -f "$HEALTH_PID" ]; then
        local pid=$(cat "$HEALTH_PID")
        if ps -p "$pid" >/dev/null 2>&1; then
            print_warning "Health check já está rodando"
            return 1
        else
            rm -f "$HEALTH_PID"
        fi
    fi
    
    print_info "Iniciando health check do servidor..."
    server_health_check $port &
    echo $! > "$HEALTH_PID"
    print_success "Health check iniciado (PID: $!)"
}

# Parar servidor
stop_server() {
    print_info "Parando servidor..."
    
    # Parar health check
    if [ -f "$HEALTH_PID" ]; then
        local health_pid=$(cat "$HEALTH_PID")
        kill $health_pid 2>/dev/null
        rm -f "$HEALTH_PID"
        print_success "Health check parado"
    fi
    
    # Parar servidor
    if [ -f "$SERVER_PID" ]; then
        local pid=$(cat "$SERVER_PID")
        kill $pid 2>/dev/null
        rm -f "$SERVER_PID"
        print_success "Servidor parado"
    else
        print_warning "Servidor não está rodando"
    fi
    
    # Limpar arquivos temporários
    rm -f server.php server.js .server-url 2>/dev/null
}

# Status do servidor
server_status() {
    print_header
    echo ""
    
    echo -e "${BLUE}🌐 STATUS DO SERVIDOR${NC}"
    echo "====================="
    
    if is_server_running; then
        local pid=$(cat "$SERVER_PID")
        echo -e "🌐 Servidor: ${GREEN}RODANDO${NC} (PID: $pid)"
        
        # Verificar porta
        local port_found=""
        for port in $(seq 8000 8100); do
            if check_port $port; then
                port_found=$port
                break
            fi
        done
        
        if [ ! -z "$port_found" ]; then
            echo -e "🔌 Porta: ${GREEN}$port_found${NC}"
            echo -e "🔗 URL Local: ${CYAN}http://localhost:$port_found${NC}"
            
            if [ -f ".server-url" ]; then
                local public_url=$(cat .server-url)
                echo -e "🌍 URL Pública: ${CYAN}$public_url${NC}"
            fi
        else
            echo -e "🔌 Porta: ${RED}NÃO ENCONTRADA${NC}"
        fi
    else
        echo -e "🌐 Servidor: ${RED}PARADO${NC}"
    fi
    
    # Health check status
    if [ -f "$HEALTH_PID" ]; then
        local health_pid=$(cat "$HEALTH_PID")
        if ps -p "$health_pid" >/dev/null 2>&1; then
            echo -e "🏥 Health Check: ${GREEN}RODANDO${NC} (PID: $health_pid)"
        else
            echo -e "🏥 Health Check: ${RED}PARADO${NC}"
            rm -f "$HEALTH_PID"
        fi
    else
        echo -e "🏥 Health Check: ${RED}PARADO${NC}"
    fi
    
    echo ""
    
    # Arquivos da aplicação
    echo -e "${BLUE}📁 ARQUIVOS DA APLICAÇÃO${NC}"
    echo "========================"
    
    local files=("index.html" "style.css" "script.js" "users.json")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local size=$(ls -lh "$file" | awk '{print $5}')
            echo -e "✅ $file (${size})"
        else
            echo -e "❌ $file (não encontrado)"
        fi
    done
    
    echo ""
    
    # Logs recentes
    echo -e "${BLUE}📋 LOGS RECENTES${NC}"
    echo "================"
    if [ -f "$SERVER_LOG" ]; then
        tail -5 "$SERVER_LOG"
    else
        echo "Nenhum log encontrado"
    fi
}

# Abrir no navegador
open_browser() {
    local url="http://localhost:$PORT"
    
    if [ -f ".server-url" ]; then
        url=$(cat .server-url)
    fi
    
    print_info "Tentando abrir $url no navegador..."
    
    # Diferentes comandos para abrir navegador
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url" 2>/dev/null &
    elif command -v open >/dev/null 2>&1; then
        open "$url" 2>/dev/null &
    elif command -v start >/dev/null 2>&1; then
        start "$url" 2>/dev/null &
    else
        print_info "Copie e cole no navegador: $url"
    fi
}

# Mostrar ajuda
show_help() {
    print_header
    echo ""
    echo -e "${BLUE}COMANDOS DISPONÍVEIS:${NC}"
    echo ""
    echo -e "${GREEN}$0 start${NC}     - Iniciar servidor web"
    echo -e "${GREEN}$0 stop${NC}      - Parar servidor web"
    echo -e "${GREEN}$0 restart${NC}   - Reiniciar servidor web"
    echo -e "${GREEN}$0 status${NC}    - Ver status do servidor"
    echo -e "${GREEN}$0 open${NC}      - Abrir no navegador"
    echo -e "${GREEN}$0 logs${NC}      - Ver logs do servidor"
    echo ""
    echo -e "${BLUE}EXEMPLOS:${NC}"
    echo "  $0 start           # Iniciar servidor"
    echo "  $0 status          # Ver status"
    echo "  $0 open            # Abrir aplicação"
    echo ""
}

# Função principal
main() {
    setup_directories
    
    case "${1:-}" in
        "start")
            start_server
            ;;
        "stop")
            stop_server
            ;;
        "restart")
            stop_server
            sleep 2
            start_server
            ;;
        "status")
            server_status
            ;;
        "open")
            open_browser
            ;;
        "logs")
            if [ -f "$SERVER_LOG" ]; then
                tail -f "$SERVER_LOG"
            else
                print_error "Log não encontrado"
            fi
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

# Executar
main "$@"