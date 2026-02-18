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

## Three Images

| Image | Command | What It Is |
|-------|---------|------------|
| **Base** | `docker compose run --rm opencode` | Clean OpenCode + VT ARC. No opinions about workflow. |
| **Harness** | `docker compose run --rm opencode-harness` | Lightweight structured workflow (plan, confirm, verify). |
| **Superpowers** | `docker compose run --rm opencode-superpowers` | Full [superpowers](https://github.com/obra/superpowers) methodology: mandatory design-plan-implement-verify phases, TDD, systematic debugging. |

All three prompt for your API key on first run if not provided via `.env`.

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

# 4. Build and launch (pick one)
docker compose run --rm opencode              # base
docker compose run --rm opencode-harness      # lightweight harness
docker compose run --rm opencode-superpowers  # full superpowers methodology
```

If you skipped step 2, the container will prompt you for your API key at launch. It tests the connection before starting OpenCode.

---

## Image Details

### Base

Clean OpenCode connected to VT ARC. No workflow opinions. Good for exploration and general use.

### Harness

Adds a lightweight AGENTS.md that instructs OpenCode to: understand before modifying, plan before coding, confirm before non-trivial changes, verify after changes.

### Superpowers

Adapted from [obra/superpowers](https://github.com/obra/superpowers) (42k+ stars), the most popular agentic coding methodology. Enforces:

- **Four mandatory phases:** Design, Plan, Implement, Verify. No skipping.
- **TDD as non-negotiable:** Red-green-refactor for every change. No code without a failing test first.
- **Evidence-based verification:** Every claim requires command output, not assertions.
- **Systematic debugging:** Root cause investigation before any fix. Three failed fixes trigger architectural review.
- **Quality gates:** Specific evidence required for each type of claim (tests pass, build succeeded, bug fixed, etc.)

---

## Project Structure

```
vm-opencode-arc-guide/
  README.md                    # This file
  Dockerfile                   # Base image: OpenCode + VT ARC
  Dockerfile.harness           # Harness image: lightweight workflow
  Dockerfile.superpowers       # Superpowers image: full methodology
  docker-compose.yml           # All three services
  .env.example                 # Template for API key
  .env                         # Your actual API key (gitignored)
  config/
    opencode.json              # VT ARC provider config (baked into images)
  scripts/
    entrypoint.sh              # Base entrypoint
    entrypoint-harness.sh      # Harness entrypoint
    entrypoint-superpowers.sh  # Superpowers entrypoint
  harness/
    AGENTS.md                  # Lightweight workflow instructions
    AGENTS.superpowers.md      # Full superpowers methodology
  projects/                    # Shared folder mounted into the container
```

---

## How It Works

1. The container starts and runs its entrypoint script
2. For harness/superpowers images: copies the AGENTS.md into `/work` if none exists
3. If `VT_ARC_API_KEY` is not set, prompts you to paste it
4. Tests connectivity to `llm-api.arc.vt.edu`
5. If connected, launches OpenCode
6. OpenCode reads the ARC config and the AGENTS.md from the working directory
7. Your `projects/` folder is mounted at `/work` (read-write)

---

## Customizing

Edit the AGENTS.md files in `harness/` to change the instructions OpenCode follows. Rebuild after changes:

```bash
docker compose build opencode-superpowers
docker compose run --rm opencode-superpowers
```

You can also override per-project by placing your own AGENTS.md in `projects/`. The entrypoint only copies the built-in AGENTS.md if none already exists in the working directory.

---

## Related Projects

| Project | Description |
|---------|-------------|
| [opencode-arc-guide](https://github.com/dalepike/opencode-arc-guide) | Standard (non-isolated) setup guide |
| [OpenCode](https://github.com/anomalyco/opencode) | The OpenCode project itself |
| [VT ARC LLM API](https://docs.arc.vt.edu/ai/011_llm_api_arc_vt_edu.html) | ARC API documentation |
| [obra/superpowers](https://github.com/obra/superpowers) | Original superpowers framework (Claude Code) |

---

*Created: February 17, 2026*
