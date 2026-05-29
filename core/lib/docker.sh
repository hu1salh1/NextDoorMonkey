#!/bin/bash
# Библиотека работы с Docker

# Проверка Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        return 1
    fi
    if ! docker ps &> /dev/null; then
        return 1
    fi
    return 0
}

# Запуск модуля
start_module() {
    local module=$1
    local module_dir="$NDM_ENABLED/$module"
    
    if [ ! -d "$module_dir" ]; then
        echo -e "${RED}Модуль $module не найден${NC}"
        return 1
    fi
    
    if [ -f "$module_dir/scripts/start.sh" ]; then
        "$module_dir/scripts/start.sh"
    elif [ -f "$module_dir/docker-compose.yml" ]; then
        cd "$module_dir"
        docker-compose up -d
    else
        echo -e "${RED}Нет способа запустить модуль $module${NC}"
        return 1
    fi
}

# Остановка модуля
stop_module() {
    local module=$1
    local module_dir="$NDM_ENABLED/$module"
    
    if [ ! -d "$module_dir" ]; then
        echo -e "${RED}Модуль $module не найден${NC}"
        return 1
    fi
    
    if [ -f "$module_dir/scripts/stop.sh" ]; then
        "$module_dir/scripts/stop.sh"
    elif [ -f "$module_dir/docker-compose.yml" ]; then
        cd "$module_dir"
        docker-compose down
    else
        echo -e "${RED}Нет способа остановить модуль $module${NC}"
        return 1
    fi
}

# Статус модуля
module_status() {
    local module=$1
    local container_name="ndm-$module"
    
    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "running"
    elif docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "stopped"
    else
        echo "not_installed"
    fi
}