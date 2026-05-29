#!/bin/bash
#=====================================================================
# NextDoorMonkey v4.0 - Uninstaller
# Полное удаление системы
#=====================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

NDM_ROOT="/opt/nextdoormonkey"
NDM_BIN="/usr/local/bin/ndm"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🐒 NextDoorMonkey v4.0 - Удаление                        ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен запускаться от root${NC}"
   exit 1
fi

# Подтверждение
echo -e "${YELLOW}ВНИМАНИЕ! Это удалит все компоненты NextDoorMonkey.${NC}"
read -p "Вы уверены? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Удаление отменено"
    exit 0
fi

# Остановка всех модулей
echo -e "${GREEN}→${NC} Остановка всех модулей..."
if [ -f "$NDM_BIN" ]; then
    $NDM_BIN stop all 2>/dev/null || true
fi

# Удаление Docker контейнеров
echo -e "${GREEN}→${NC} Удаление Docker контейнеров..."
docker ps -a --filter "name=ndm-" -q | xargs -r docker rm -f

# Удаление файлов
echo -e "${GREEN}→${NC} Удаление файлов..."
rm -rf "$NDM_ROOT"
rm -f "$NDM_BIN"
rm -rf "/etc/ndm"
rm -f "/etc/bash_completion.d/ndm"

echo ""
echo -e "${GREEN}✅ NextDoorMonkey полностью удален${NC}"