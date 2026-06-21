# RNS/Reticulum TCP узел для RatSpeak

Это **полный минимальный проект**, а не просто скелет: в нём есть Docker-запуск, локальный запуск без Docker, готовый конфиг Reticulum, пример клиентского конфига и бесплатный обходной вариант через TCP-туннель.

> Важно: Reticulum — это не HTTP-сайт и не Express.js API. Для аналога `rns.moskow` нужен долгоживущий TCP-порт, на котором работает `rnsd`. Vercel, GitHub Pages и обычные serverless-функции не подходят для настоящего публичного RNS-узла.

## Что здесь есть

- `Dockerfile` — контейнер с Reticulum и запуском `rnsd`.
- `reticulum/config` — конфиг публичного TCP Server Interface на порту `4242`.
- `docker-compose.yml` — локальный запуск или запуск на VPS.
- `scripts/run-local.sh` — запуск на Linux/Termux/VM без Docker.
- `scripts/tunnel-pinggy.sh` — бесплатный временный TCP-туннель наружу, если нет белого IP/VPS.
- `client-config-example` — пример настройки клиента, который подключается к вашему `IP:порт` или tunnel `host:port`.
- `docs/free-hosting-ru.md` — честный список бесплатных вариантов и ограничений.

## Вариант A: запуск через Docker

```bash
docker compose up --build
```

После запуска узел слушает TCP-порт `4242` на всех интерфейсах контейнера/хоста.

Проверка с другого устройства:

```bash
nc -vz YOUR_SERVER_IP 4242
```

## Вариант B: запуск без Docker

Подходит для Ubuntu, Debian, Termux, PythonAnywhere-консоли для тестов и похожих окружений, где можно поставить Python-пакет `rns`.

```bash
python3 -m pip install --user rns
./scripts/run-local.sh
```

Скрипт создаст локальный каталог `.reticulum`, скопирует туда `reticulum/config` и запустит `rnsd`.

## Вариант C: бесплатно без белого IP — Pinggy TCP tunnel

Если у вас нет VPS, Visa/Mastercard и белого IP, оставьте RNS работать у себя на ПК/ноутбуке/Termux и пробросьте порт через бесплатный временный TCP-туннель:

```bash
./scripts/run-local.sh
```

Во втором терминале:

```bash
./scripts/tunnel-pinggy.sh 4242
```

Pinggy напечатает публичный адрес и порт. Их надо вставить клиентам вместо `YOUR_SERVER_IP` и `4242`. Минус: на бесплатном варианте адрес/порт может меняться, а терминал должен оставаться открытым.

## Как подключиться клиенту

На клиентском устройстве откройте конфиг Reticulum. Обычно он находится в одном из путей:

- Linux: `~/.reticulum/config`
- Android/Termux: `~/.reticulum/config`
- Если приложение использует свой каталог — смотрите настройки приложения.

Добавьте интерфейс:

```ini
[[My RNS Gateway]]
  type = TCPClientInterface
  enabled = yes
  target_host = YOUR_SERVER_IP_OR_TUNNEL_HOST
  target_port = 4242
```

Где `YOUR_SERVER_IP_OR_TUNNEL_HOST` — публичный IP сервера или host из туннеля. Домен не обязателен.

## Где разместить бесплатно

1. **Свой ПК/ноутбук/Termux + Pinggy TCP tunnel** — самый рабочий вариант без карты. Временный, зато бесплатный и не требует белого IP.
2. **Домашний белый IP или IPv6** — бесплатно, если провайдер разрешает входящие соединения. Нужно открыть `4242/tcp` на роутере/firewall.
3. **Koyeb/похожие PaaS с Docker** — можно пробовать, если регистрация доступна и есть TCP routes. Следите за sleep-режимом и лимитами.
4. **Fly.io** — технически подходит для TCP Docker-приложения, но это не гарантированно бесплатный/no-card вариант; файл `fly.toml.example` добавлен только как пример.

Отдельный подробный разбор: `docs/free-hosting-ru.md`.

## Что обычно не подходит

- **Vercel** — не держит произвольный долгоживущий TCP-сервер для RNS, Express.js там не поможет.
- **GitHub Actions** — job не является постоянным сервером, отключается по времени и не даёт нормальную публичную точку входа.
- **GitHub Pages/статический хостинг** — не умеет слушать Reticulum TCP.
- **PythonAnywhere Free** — хорош для Python-сайтов/консолей, но не как стабильный публичный TCP listener `IP:4242`.
- **Playit.gg Free** — проверьте текущие ограничения: произвольный TCP может требовать Premium.

## Запуск на обычной Ubuntu VM

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker

git clone YOUR_REPO_URL rns-node
cd rns-node
docker compose up -d --build
```

Откройте порт в firewall VM:

```bash
sudo ufw allow 4242/tcp
```

Проверьте логи:

```bash
docker compose logs -f rnsd
```

## Настройки

По умолчанию узел:

- включает транспорт Reticulum;
- слушает `0.0.0.0:4242`;
- использует persistent data volume `reticulum-data`, чтобы identity не менялась после перезапуска контейнера.

Если хотите другой порт, поменяйте его в двух местах:

- `reticulum/config` → `listen_port`;
- `docker-compose.yml` → секция `ports`.

## Безопасность и ограничения

- Не публикуйте private identity/key-файлы Reticulum.
- Не храните реальные приватные ключи в Git.
- Этот проект создаёт открытый TCP-вход в вашу Reticulum-сеть. Если хотите закрытую сеть, настройте connectable peers и доверенные интерфейсы отдельно.
- Бесплатные туннели удобны для теста и маленького сообщества, но не гарантируют постоянный адрес как полноценный VPS.
