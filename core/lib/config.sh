#!/bin/bash
# Библиотека работы с конфигурациями

NDM_CONFIG_DIR="/etc/ndm"
CORE_CONFIG="$NDM_CONFIG_DIR/core.conf"
MODULES_CONFIG="$NDM_CONFIG_DIR/modules.conf"

# Инициализация конфигурации
init_config() {
    mkdir -p "$NDM_CONFIG_DIR"
    
    if [ ! -f "$CORE_CONFIG" ]; then
        cat > "$CORE_CONFIG" << EOF
# NextDoorMonkey Core Configuration
# Created: $(date)

# Server settings
SERVER_NAME=""
SERVER_IP=""
SERVER_PORT_RANGE_START=10000
SERVER_PORT_RANGE_END=65535

# Network settings
IP_FORWARDING=true
FIREWALL_ENABLED=true

# Docker settings
DOCKER_NETWORK="ndm_network"
DOCKER_SUBNET="172.20.0.0/24"

# Security
AUTO_UPDATE=false
BACKUP_ENABLED=true
BACKUP_DAYS=30

# Logging
LOG_LEVEL="info"
LOG_RETENTION_DAYS=7
EOF
    fi
    
    if [ ! -f "$MODULES_CONFIG" ]; then
        cat > "$MODULES_CONFIG" << EOF
# Modules Configuration
# Format: module_name:enabled:port:config

EOF
    fi
}

# Получить значение из конфига
get_config() {
    local key=$1
    local file=${2:-$CORE_CONFIG}
    grep "^$key=" "$file" | cut -d'=' -f2- | tail -1
}

# Установить значение в конфиг
set_config() {
    local key=$1
    local value=$2
    local file=${3:-$CORE_CONFIG}
    
    if grep -q "^$key=" "$file"; then
        sed -i "s|^$key=.*|$key=$value|" "$file"
    else
        echo "$key=$value" >> "$file"
    fi
}

# Получить все модули
get_modules() {
    local status=${1:-all}  # all, enabled, disabled
    local modules=()
    
    if [ -f "$MODULES_CONFIG" ]; then
        while IFS=: read -r name enabled port config; do
            if [ "$status" = "all" ]; then
                modules+=("$name")
            elif [ "$status" = "enabled" ] && [ "$enabled" = "1" ]; then
                modules+=("$name")
            elif [ "$status" = "disabled" ] && [ "$enabled" = "0" ]; then
                modules+=("$name")
            fi
        done < "$MODULES_CONFIG"
    fi
    
    echo "${modules[@]}"
}

# Сохранить модуль в конфиг
save_module() {
    local name=$1
    local enabled=$2
    local port=$3
    local config=$4
    
    # Удалить старую запись
    sed -i "/^$name:/d" "$MODULES_CONFIG"
    
    # Добавить новую
    echo "$name:$enabled:$port:$config" >> "$MODULES_CONFIG"
}

# Получить порт модуля
get_module_port() {
    local name=$1
    grep "^$name:" "$MODULES_CONFIG" | cut -d':' -f3
}

# Проверить, включен ли модуль
is_module_enabled() {
    local name=$1
    local enabled=$(grep "^$name:" "$MODULES_CONFIG" | cut -d':' -f2)
    [ "$enabled" = "1" ]
}