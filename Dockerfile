# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.12.3

# Base stage
FROM python:${PYTHON_VERSION}-slim as base

ENV RYE_HOME="/opt/rye"
ENV PATH="$RYE_HOME/shims:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED True

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]

RUN curl -sSf https://rye-up.com/get | RYE_INSTALL_OPTION="--yes" bash && \
    rye config --set-bool behavior.global-python=true

COPY pyproject.toml requirements* .python-version ./

RUN rye sync --no-dev --no-lock

# Development stage
FROM base AS development

WORKDIR /app

COPY . .

RUN rye sync --no-lock

EXPOSE 8080

CMD rye run uvicorn 'main:app' --host=0.0.0.0 --port=8080

# Production image
FROM base as production

WORKDIR /app

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

USER appuser

COPY . .

EXPOSE 8080

CMD rye run uvicorn 'main:app' --host=0.0.0.0 --port=8080
