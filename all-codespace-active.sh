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
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}$timestamp [INFO]${NC} $message" | tee -a "$MAIN_LOG" ;;
        "SUCCESS") echo -e "${GREEN}$timestamp [SUCCESS]${NC} $message" | tee -a "$MAIN_LOG" ;;
        "WARNING") echo -e "${YELLOW}$timestamp [WARNING]${NC} $message" | tee -a "$MAIN_LOG" ;;
        "ERROR") echo -e "${RED}$timestamp [ERROR]${NC} $message" | tee -a "$MAIN_LOG" ;;
        "SYSTEM") echo -e "${PURPLE}$timestamp [SYSTEM]${NC} $message" | tee -a "$MAIN_LOG" ;;
        *) echo "$timestamp $message" | tee -a "$MAIN_LOG" ;;
    esa