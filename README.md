# 🐒 NextDoorMonkey v4.0

**Модульная система для обхода ограничений интернета**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-4.0-blue.svg)](https://github.com/hu1salh1/NextDoorMonkey)

## 🌟 Особенности

- **Модульная архитектура** - устанавливайте только нужные компоненты
- **Центральное управление** - единая команда `ndm` для всего
- **Гибкая настройка** - интерактивный мастер установки
- **Единая точка входа** - управляйте из любого места системы

## 📦 Доступные модули

| Модуль | Описание | Порт по умолчанию |
|--------|----------|-------------------|
| amneziawg | Обфусцированный WireGuard | 51820/udp |
| vless | VLESS+Reality прокси | 8443/tcp |
| socks5 | SOCKS5 прокси | 1080/tcp |
| mtproto | Telegram MTProto прокси | 443/tcp |
| fail2ban | Защита от брутфорса | - |
| warp | Cloudflare WARP | - |

## 🚀 Быстрая установка

```bash
curl -sL https://raw.githubusercontent.com/hu1salh1/NextDoorMonkey/main/install.sh | sudo bash