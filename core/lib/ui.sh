#!/bin/bash
# Библиотека пользовательского интерфейса

# Цвета
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export WHITE='\033[1;37m'
export NC='\033[0m'

# Функции вывода
print_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}  $1${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}→${NC} $1"
}

# Функции ввода
ask_yes_no() {
    local prompt=$1
    local default=${2:-n}
    
    while true; do
        read -p "$prompt [y/N]: " answer
        answer=${answer:-$default}
        case $answer in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Пожалуйста, ответьте y или n" ;;
        esac
    done
}

ask_port() {
    local module=$1
    local default=$2
    
    while true; do
        read -p "Введите порт для $module [$default]: " port
        port=${port:-$default}
        
        if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
            echo "$port"
            return 0
        else
            echo "Неверный порт. Введите число от 1 до 65535"
        fi
    done
}

# Показать статус системы
show_status() {
    print_header "СТАТУС СИСТЕМЫ"
    
    if check_docker; then
        print_success "Docker: работает"
    else
        print_error "Docker: не работает"
    fi
    
    echo ""
    echo -e "${CYAN}МОДУЛИ:${NC}"
    
    local enabled_modules=$(get_modules "enabled")
    if [ -n "$enabled_modules" ]; then
        for module in $enabled_modules; do
            local status=$(module_status "$module")
            case $status in
                running)
                    print_success "$module: запущен"
                    ;;
                stopped)
                    print_warning "$module: остановлен"
                    ;;
                *)
                    print_error "$module: не установлен"
                    ;;
            esac
        done
    else
        print_info "Нет включенных модулей"
    fi
}

# Список модулей
list_modules() {
    print_header "ДОСТУПНЫЕ МОДУЛИ"
    
    echo -e "${CYAN}Установленные:${NC}"
    for module in $(get_modules "all"); do
        if is_module_enabled "$module"; then
            echo "  ✓ $module (включен, порт: $(get_module_port "$module"))"
        else
            echo "  ○ $module (выключен)"
        fi
    done
    
    echo ""
    echo -e "${CYAN}Доступные для установки:${NC}"
    for module in $(ls "$NDM_MODULES/available" 2>/dev/null); do
        if ! grep -q "^$module:" "$MODULES_CONFIG" 2>/dev/null; then
            echo "  + $module"
        fi
    done
}

# Показать информацию для подключения
show_connection_info() {
    print_header "ИНФОРМАЦИЯ ДЛЯ ПОДКЛЮЧЕНИЯ"
    
    local server_ip=$(get_server_ip)
    echo -e "${GREEN}Сервер:${NC} $server_ip"
    echo ""
    
    local enabled_modules=$(get_modules "enabled")
    for module in $enabled_modules; do
        if [ -f "$NDM_ENABLED/$module/info.sh" ]; then
            source "$NDM_ENABLED/$module/info.sh"
            show_module_info "$module" "$server_ip"
        fi
    done
}