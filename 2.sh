#!/bin/bash

# =============================================================================
# BRAINROTS MONEY COMPLETE - Sistema Completo 24/7
# Servidor web + Keep-alive + Aplicacao funcionando
# =============================================================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${PURPLE}💰🧠 =================================="
    echo -e "🚀 BRAINROTS MONEY COMPLETE 24/7"
    echo -e "💰🧠 ==================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_server() {
    echo -e "${CYAN}🌐 $1${NC}"
}

# Verificar arquivos necessarios
check_files() {
    local missing_files=()
    
    if [ ! -f "index.html" ]; then missing_files+=("index.html"); fi
    if [ ! -f "style.css" ]; then missing_files+=("style.css"); fi
    if [ ! -f "script.js" ]; then missing_files+=("script.js"); fi
    if [ ! -f "all-codespace-active.sh" ]; then missing_files+=("all-codespace-active.sh"); fi
    if [ ! -f "1.sh" ]; then missing_files+=("1.sh"); fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_warning "Arquivos nao encontrados: ${missing_files[*]}"
        return 1
    fi
    
    return 0
}

# Tornar scripts executaveis
make_executable() {
    chmod +x all-codespace-active.sh 2>/dev/null
    chmod +x 1.sh 2>/dev/null
    chmod +x 2.sh 2>/dev/null
}

# Iniciar sistema completo
start_complete() {
    print_header
    print_info "🚀 Iniciando Sistema Completo Brainrots Money..."
    echo ""
    
    # Verificar arquivos
    if ! check_files; then
        print_warning "Alguns arquivos estao faltando, mas continuando..."
    fi
    
    # Tornar executaveis
    make_executable
    
    # 1. Iniciar Keep-Alive (manter Codespace ativo)
    print_info "1️⃣ Iniciando sistema Keep-Alive 24/7..."
    if [ -f "all-codespace-active.sh" ]; then
        ./all-codespace-active.sh start
        sleep 2
    else
        print_warning "all-codespace-active.sh nao encontrado"
    fi
    
    # 2. Iniciar servidor web
    print_info "2️⃣ Iniciando servidor web para aplicacao..."
    if [ -f "1.sh" ]; then
        ./1.sh start
        sleep 3
    else
        print_warning "1.sh nao encontrado"
    fi
    
    echo ""
    print_success "🎉 Sistema Completo Iniciado!"
    echo ""
    
    # Mostrar URLs
    show_urls
}

# Parar sistema completo
stop_complete() {
    print_header
    print_info "🛑 Parando Sistema Completo..."
    echo ""
    
    # Parar servidor web
    if [ -f "1.sh" ]; then
        print_info "Parando servidor web..."
        ./1.sh stop
    fi
    
    # Parar keep-alive
    if [ -f "all-codespace-active.sh" ]; then
        print_info "Parando sistema keep-alive..."
        ./all-codespace-active.sh stop
    fi
    
    print_success "Sistema parado!"
}

# Status completo
status_complete() {
    print_header
    print_info "📊 Status do Sistema Completo"
    echo ""
    
    # Status Keep-Alive
    echo -e "${BLUE}🔄 SISTEMA KEEP-ALIVE${NC}"
    echo "===================="
    if [ -f "all-codespace-active.sh" ]; then
        ./all-codespace-active.sh status | grep -E "(Keep-Alive|Health Check|Monitor|CPU|Memory|Internet|GitHub)" | head -10
    else
        print_warning "Keep-alive nao disponivel"
    fi
    
    echo ""
    
    # Status Servidor Web
    echo -e "${BLUE}🌐 SERVIDOR WEB${NC}"
    echo "==============="
    if [ -f "1.sh" ]; then
        ./1.sh status | grep -E "(Servidor|Porta|URL|Health Check)" | head -10
    else
        print_warning "Servidor web nao disponivel"
    fi
    
    echo ""
    show_urls
}

# Mostrar URLs de acesso
show_urls() {
    echo -e "${CYAN}🔗 LINKS DE ACESSO${NC}"
    echo "=================="
    
    # Verificar portas ativas
    local ports=()
    for port in $(seq 8000 8010) $(seq 3000 3010); do
        if command -v lsof >/dev/null 2>&1; then
            if lsof -i :$port >/dev/null 2>&1; then
                ports+=($port)
            fi
        elif timeout 1 bash -c "</dev/tcp/localhost/$port" >/dev/null 2>&1; then
            ports+=($port)
        fi
    done
    
    if [ ${#ports[@]} -gt 0 ]; then
        for port in "${ports[@]}"; do
            echo -e "🔗 Local: ${CYAN}http://localhost:$port${NC}"
            
            # URL publica do Codespace
            if [ ! -z "$CODESPACE_NAME" ]; then
                local public_url="https://$CODESPACE_NAME-$port.app.github.dev"
                echo -e "🌍 Publico: ${GREEN}$public_url${NC}"
            fi
        done
    else
        print_warning "Nenhum servidor ativo encontrado"
    fi
    
    echo ""
}

# Abrir aplicacao
open_app() {
    print_header
    print_info "🌐 Abrindo Brainrots Money..."
    
    if [ -f "1.sh" ]; then
        ./1.sh open
    else
        show_urls
        print_info "Copie uma das URLs acima para acessar a aplicacao"
    fi
}

# Logs combinados
view_logs() {
    print_header
    print_info "📋 Logs do Sistema (Ctrl+C para sair)"
    echo ""
    
    case "${2:-all}" in
        "server"|"web")
            if [ -f "1.sh" ]; then
                ./1.sh logs
            else
                print_warning "Logs do servidor nao disponiveis"
            fi
            ;;
        "keepalive"|"ka")
            if [ -f "all-codespace-active.sh" ]; then
                ./all-codespace-active.sh logs
            else
                print_warning "Logs do keep-alive nao disponiveis"
            fi
            ;;
        "all"|*)
            print_info "Mostrando logs combinados..."
            
            # Mostrar logs recentes de ambos
            echo -e "${BLUE}📋 LOGS KEEP-ALIVE (ultimas 5 linhas)${NC}"
            if [ -f "logs/codespace-active.log" ]; then
                tail -5 logs/codespace-active.log
            fi
            
            echo ""
            echo -e "${BLUE}📋 LOGS SERVIDOR (ultimas 5 linhas)${NC}"
            if [ -f "logs/server.log" ]; then
                tail -5 logs/server.log
            fi
            
            echo ""
            print_info "Para logs em tempo real use:"
            echo "  $0 logs server    # Logs do servidor"
            echo "  $0 logs ka        # Logs do keep-alive"
            ;;
    esac
}

# Configuracao rapida
quick_setup() {
    print_header
    print_info "⚡ Configuracao Rapida do Sistema"
    echo ""
    
    # Verificar se estamos no Codespace
    if [ -z "$CODESPACE_NAME" ]; then
        print_warning "Nao detectado como GitHub Codespace"
        print_info "Continuando configuracao local..."
    else
        print_success "GitHub Codespace detectado: $CODESPACE_NAME"
    fi
    
    # Tornar executaveis
    make_executable
    print_success "Scripts tornados executaveis"
    
    # Configurar keep-alive
    if [ -f "all-codespace-active.sh" ]; then
        print_info "Configurando auto-start do keep-alive..."
        ./all-codespace-active.sh setup >/dev/null 2>&1
        print_success "Keep-alive configurado"
    fi
    
    # Verificar dependencias
    print_info "Verificando dependencias..."
    local deps_ok=true
    
    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1 && ! command -v php >/dev/null 2>&1 && ! command -v node >/dev/null 2>&1; then
        print_warning "Nenhum servidor web disponivel (Python, PHP, Node.js)"
        deps_ok=false
    else
        print_success "Servidor web disponivel"
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        print_warning "curl nao encontrado (recomendado)"
    else
        print_success "curl disponivel"
    fi
    
    echo ""
    if [ "$deps_ok" = true ]; then
        print_success "✅ Sistema pronto para uso!"
        echo ""
        print_info "Para iniciar: $0 start"
        print_info "Para status: $0 status"
    else
        print_warning "⚠️ Algumas dependencias estao faltando"
        print_info "Tente instalar Python, PHP ou Node.js"
    fi
}

# Teste completo
test_system() {
    print_header
    print_info "🧪 Testando Sistema Completo"
    echo ""
    
    # Teste 1: Arquivos
    echo -e "${BLUE}📁 Teste de Arquivos${NC}"
    local files=("index.html" "style.css" "script.js" "users.json")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            print_success "$file encontrado"
        else
            print_warning "$file nao encontrado"
        fi
    done
    
    echo ""
    
    # Teste 2: Scripts
    echo -e "${BLUE}🔧 Teste de Scripts${NC}"
    local scripts=("all-codespace-active.sh" "1.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            print_success "$script executavel"
        elif [ -f "$script" ]; then
            print_warning "$script nao executavel"
            chmod +x "$script" 2>/dev/null && print_success "$script tornado executavel"
        else
            print_warning "$script nao encontrado"
        fi
    done
    
    echo ""
    
    # Teste 3: Dependencias
    echo -e "${BLUE}⚙️ Teste de Dependencias${NC}"
    
    if command -v python3 >/dev/null 2>&1; then
        print_success "Python3 disponivel"
    elif command -v python >/dev/null 2>&1; then
        print_success "Python disponivel"
    else
        print_warning "Python nao encontrado"
    fi
    
    if command -v php >/dev/null 2>&1; then
        print_success "PHP disponivel"
    else
        print_warning "PHP nao encontrado"
    fi
    
    if command -v node >/dev/null 2>&1; then
        print_success "Node.js disponivel"
    else
        print_warning "Node.js nao encontrado"
    fi
    
    echo ""
    
    # Teste 4: Conectividade
    echo -e "${BLUE}🌐 Teste de Conectividade${NC}"
    
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_success "Internet OK"
    else
        print_warning "Internet com problemas"
    fi
    
    if command -v curl >/dev/null 2>&1 && curl -s --max-time 5 https://api.github.com/zen >/dev/null 2>&1; then
        print_success "GitHub API OK"
    else
        print_warning "GitHub API com problemas"
    fi
    
    echo ""
    print_success "🧪 Testes concluidos!"
}

# Ajuda
show_help() {
    print_header
    echo -e "${BLUE}COMANDOS DISPONIVEIS:${NC}"
    echo ""
    echo -e "${GREEN}$0 start${NC}      - Iniciar sistema completo (keep-alive + servidor)"
    echo -e "${GREEN}$0 stop${NC}       - Parar sistema completo"
    echo -e "${GREEN}$0 restart${NC}    - Reiniciar sistema completo"
    echo -e "${GREEN}$0 status${NC}     - Ver status de todos os componentes"
    echo -e "${GREEN}$0 open${NC}       - Abrir aplicacao no navegador"
    echo -e "${GREEN}$0 logs${NC}       - Ver logs (use 'server' ou 'ka' para especificos)"
    echo -e "${GREEN}$0 setup${NC}      - Configuracao rapida inicial"
    echo -e "${GREEN}$0 test${NC}       - Testar sistema completo"
    echo ""
    echo -e "${BLUE}FLUXO RECOMENDADO:${NC}"
    echo "1. $0 setup     # Primeira vez"
    echo "2. $0 start     # Iniciar tudo"
    echo "3. $0 status    # Verificar"
    echo "4. $0 open      # Abrir app"
    echo ""
    echo -e "${YELLOW}NOTA:${NC} Este script combina keep-alive + servidor web"
    echo "      Seu Codespace ficara ativo 24/7 com a aplicacao rodando!"
}

# Funcao principal
main() {
    case "${1:-}" in
        "start")
            start_complete
            ;;
        "stop")
            stop_complete
            ;;
        "restart")
            stop_complete
            sleep 3
            start_complete
            ;;
        "status")
            status_complete
            ;;
        "open")
            open_app
            ;;
        "logs")
            view_logs "$@"
            ;;
        "setup")
            quick_setup
            ;;
        "test")
            test_system
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