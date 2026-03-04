FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /app

# Dependency-Dateien zuerst kopieren (besseres Layer-Caching)
COPY pyproject.toml uv.lock* ./
RUN uv venv .venv && \
    . .venv/bin/activate && \
    uv pip install -e .

# Production Stage
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ARG PORT=8152

WORKDIR /app

# Dependencies aus Builder-Stage übernehmen
COPY --from=builder /app/.venv ./.venv

# App-Code kopieren
COPY . .

# Non-root User anlegen und Berechtigungen setzen
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

ENV PATH="/app/.venv/bin:$PATH"
ENV CONTAINER_MODE="true"

EXPOSE ${PORT}

CMD ["uv", "run", "server.py"]
