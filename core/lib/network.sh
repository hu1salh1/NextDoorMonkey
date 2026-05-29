#!/bin/bash
# Библиотека сетевых функций

# Получить внешний IP
get_server_ip() {
    local ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null)
    if [ -z "$ip" ]; then
        ip=$(curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null)
    fi
    if [ -z "$ip" ]; then
        ip=$(curl -s --connect-timeout 5 icanhazip.com 2>/dev/null)
    fi
    echo "${ip:-НЕ ОПРЕДЕЛЕН}"
}

# Проверка порта
check_port() {
    local port=$1
    if ss -tlnp 2>/dev/null | grep -q ":$port "; then
        return 1  # Порт занят
    fi
    return 0  # Порт свободен
}

# Настройка IP forwarding
enable_ip_forwarding() {
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
    grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
}