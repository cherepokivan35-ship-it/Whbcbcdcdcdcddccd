FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    RNS_CONFIG_DIR=/config

RUN pip install --no-cache-dir rns

COPY reticulum/config /defaults/config
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 4242/tcp

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["rnsd", "--config", "/config", "-v"]
