# VM-Isolated OpenCode + VT ARC Setup Guide

A sandboxed version of the [OpenCode + ARC setup guide](https://github.com/dalepike/opencode-arc-guide) that runs OpenCode inside a Docker container. Your API key, config, and all AI interactions are isolated from your host system.

> **Status:** Early development
> **Companion project:** [opencode-arc-guide](https://github.com/dalepike/opencode-arc-guide) (standard guide)

---

## Why Isolate?

The [standard guide](https://github.com/dalepike/opencode-arc-guide) installs OpenCode directly on your machine and stores the API key in your shell config. That works well for most users. This project adds a layer of isolation:

- **API key containment.** The key lives only inside the container, not in your host shell config.
- **Filesystem isolation.** OpenCode can only see files you explicitly share into the container.
- **Disposability.** Destroy and recreate the environment at will. Nothing persists on your host.
- **Reproducibility.** The same image works identically on any machine with Docker.

---

## Two Images

| Image | Command | What It Is |
|-------|---------|------------|
| **Base** | `docker compose run --rm opencode` | Clean OpenCode + VT ARC. No opinions about workflow. |
| **Harness** | `docker compose run --rm opencode-harness` | Same, plus a structured workflow (plan before coding, verify after changes). |

Both prompt for your API key on first run if not provided via `.env`.

---

## Quick Start

### Prerequisites

- Docker Desktop (macOS/Windows) or Docker Engine (Linux)
- VT ARC API key from [llm.arc.vt.edu](https://llm.arc.vt.edu/)
- VT campus network or VPN connection

### Setup

```bash
# 1. Clone this repo
git clone https://github.com/dalepike/vm-opencode-arc-guide.git
cd vm-opencode-arc-guide

# 2. (Optional) Pre-set your API key
cp .env.example .env
# Edit .env and replace sk-your-key-here with your actual key

# 3. Create a project folder (this is what OpenCode can see)
mkdir -p projects

# 4. Build and launch
docker compose run --rm opencode
```

If you skipped step 2, the container will prompt you for your API key at launch. It tests the connection before starting OpenCode.

### With the Harness

```bash
docker compose run --rm opencode-harness
```

This includes an AGENTS.md that instructs OpenCode to follow a structured workflow: understand, plan, confirm, then execute one change at a time.

---

## Project Structure

```
vm-opencode-arc-guide/
  README.md              # This file
  Dockerfile             # Base image: OpenCode + VT ARC
  Dockerfile.harness     # Harness image: adds structured workflow
  docker-compose.yml     # Both services defined here
  .env.example           # Template for API key
  .env                   # Your actual API key (gitignored)
  config/
    opencode.json        # VT ARC provider config (baked into images)
  scripts/
    entrypoint.sh        # Handles API key prompt + connectivity check
  harness/
    AGENTS.md            # Structured workflow instructions for OpenCode
  projects/              # Shared folder mounted into the container
```

---

## How It Works

1. The container starts and runs `entrypoint.sh`
2. If `VT_ARC_API_KEY` is not set, it prompts you to paste it
3. It tests connectivity to `llm-api.arc.vt.edu`
4. If connected, it launches OpenCode
5. OpenCode reads the ARC config from `/root/.config/opencode/opencode.json`
6. Your `projects/` folder is mounted at `/work` (read-write)

---

## Customizing the Harness

Edit `harness/AGENTS.md` to change the instructions OpenCode follows. Rebuild after changes:

```bash
docker compose build opencode-harness
docker compose run --rm opencode-harness
```

The AGENTS.md is copied into the image at `/work/AGENTS.md`. When you mount `projects/` over `/work`, you can either:
- Let the AGENTS.md from the image be used (if projects/ doesn't contain one)
- Override it by placing your own AGENTS.md in `projects/`

---

## Related Projects

| Project | Description |
|---------|-------------|
| [opencode-arc-guide](https://github.com/dalepike/opencode-arc-guide) | Standard (non-isolated) setup guide |
| [OpenCode](https://github.com/anomalyco/opencode) | The OpenCode project itself |
| [VT ARC LLM API](https://docs.arc.vt.edu/ai/011_llm_api_arc_vt_edu.html) | ARC API documentation |

---

*Created: February 17, 2026*
