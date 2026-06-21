# RNS/Reticulum TCP узел для RatSpeak

Этот репозиторий — готовый минимальный шаблон, чтобы поднять публичную точку входа в Reticulum Network Stack (RNS) для клиентов RatSpeak/Nomad Network/LXMF и других приложений Reticulum.

> Важно: Reticulum — это не HTTP-сайт и не Express.js API. Для аналога `rns.moskow` нужен долгоживущий TCP-порт, на котором работает `rnsd`. Vercel и GitHub Actions для этого не подходят: Vercel принимает в основном HTTP/serverless-запросы, а Actions завершаются и не предназначены для постоянного сервера.

## Что здесь есть

- `Dockerfile` — контейнер с Reticulum и запуском `rnsd`.
- `reticulum/config` — конфиг публичного TCP Server Interface на порту `4242`.
- `docker-compose.yml` — локальный запуск или запуск на VPS.
- `client-config-example` — пример настройки клиента, который подключается к вашему `IP:порт`.

## Быстрый локальный запуск

```bash
docker compose up --build
```

После запуска узел слушает TCP-порт `4242` на всех интерфейсах контейнера/хоста.

Проверка с другого устройства:

```bash
nc -vz YOUR_SERVER_IP 4242
```

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
  target_host = YOUR_SERVER_IP
  target_port = 4242
```

Где `YOUR_SERVER_IP` — публичный IP сервера. Домен не обязателен.

## Где разместить бесплатно или почти бесплатно

### Подходит

1. **Старый ПК / Raspberry Pi дома**
   - Бесплатно, если есть устройство и интернет.
   - Нужно открыть/пробросить порт `4242` на роутере.
   - Если нет белого IP, можно использовать IPv6, VPN-сеть или туннель с TCP-forwarding.

2. **Oracle Cloud Free Tier VM**
   - Часто используют для бесплатной маленькой Linux VM.
   - Подходит, потому что это полноценный сервер с долгоживущим TCP-портом.
   - Нужно открыть порт `4242` в firewall/security list.

3. **Бесплатные/дешёвые VPS с Docker**
   - Подходит любой хостинг, где разрешён входящий TCP-порт и постоянный процесс.
   - Домен не нужен: клиентам достаточно `IP:4242`.

### Обычно не подходит

- **Vercel** — не держит произвольный долгоживущий TCP-сервер для RNS, Express.js там не поможет.
- **GitHub Actions** — job не является постоянным сервером, отключается по времени и не даёт нормальную публичную точку входа.
- **Статический хостинг** — не умеет слушать Reticulum TCP.

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
- Этот шаблон создаёт открытый TCP-вход в вашу Reticulum-сеть. Если хотите закрытую сеть, настройте connectable peers и доверенные интерфейсы отдельно.
