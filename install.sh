#!/bin/bash
#=====================================================================
# NextDoorMonkey v4.0 - Core Installer
# Установка только ядра системы
#=====================================================================

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

NDM_ROOT="/opt/nextdoormonkey"
NDM_BIN="/usr/local/bin"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🐒 NextDoorMonkey v4.0 - Установка ядра                  ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен запускаться от root${NC}"
   exit 1
fi

# Создание структуры
echo -e "${GREEN}→${NC} Создание структуры ядра..."
mkdir -p "$NDM_ROOT"/{core/bin,core/lib,core/modules/{available,enabled},core/config}
mkdir -p /etc/ndm

# Копирование файлов ядра
echo -e "${GREEN}→${NC} Копирование файлов ядра..."
cp -r core/* "$NDM_ROOT/core/"

# Установка главной команды
echo -e "${GREEN}→${NC} Установка команды 'ndm'..."
cp "$NDM_ROOT/core/bin/ndm" "$NDM_BIN/ndm"
chmod +x "$NDM_BIN/ndm"

# Инициализация конфигурации
echo -e "${GREEN}→${NC} Инициализация конфигурации..."
source "$NDM_ROOT/core/lib/config.sh"
init_config

# Создание симлинков для модулей
mkdir -p "$NDM_MODULES/enabled"

# Настройка автодополнения
echo -e "${GREEN}→${NC} Настройка автодополнения..."
cat > /etc/bash_completion.d/ndm << 'EOF'
_ndm_completion() {
    local cur prev words cword
    _init_completion || return
    
    commands="status info setup config ports modules start stop restart logs check doctor backup restore help version"
    subcommands="list enable disable install remove"
    
    case $prev in
        modules)
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return 0
            ;;
        enable|disable|install|remove|start|stop|restart|logs)
            COMPREPLY=($(compgen -W "$(ndm modules list 2>/dev/null | grep -oE '[a-z]+')" -- "$cur"))
            return 0
            ;;
        *)
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
    esac
}
complete -F _ndm_completion ndm
EOF

# Завершение
echo ""
echo -e "${GREEN}✅ Ядро NextDoorMonkey v4.0 установлено!${NC}"
echo ""
echo -e "${CYAN}📋 Дальнейшие действия:${NC}"
echo -e "  1. Запустите настройку:     ${GREEN}ndm setup${NC}"
echo -e "  2. Посмотрите доступные модули: ${GREEN}ndm modules list${NC}"
echo -e "  3. Установите нужные модули: ${GREEN}ndm modules install amneziawg${NC}"
echo -e "  4. Включите модуль:         ${GREEN}ndm modules enable amneziawg${NC}"
echo -e "  5. Запустите сервисы:        ${GREEN}ndm start all${NC}"
echo ""
echo -e "${CYAN}📖 Справка:${NC} ndm help"