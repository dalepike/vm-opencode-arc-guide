FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      git \
      python3 \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install -o /tmp/install.sh && \
    bash /tmp/install.sh && \
    rm /tmp/install.sh

# Copy VT ARC provider config
RUN mkdir -p /root/.config/opencode
COPY config/opencode.json /root/.config/opencode/opencode.json

# Working directory for mounted project files
RUN mkdir -p /work
WORKDIR /work

# API key is passed via environment variable at runtime (not baked in)
# docker compose reads it from .env

ENTRYPOINT ["/root/.opencode/bin/opencode"]
