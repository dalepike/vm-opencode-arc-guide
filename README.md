# VM-Isolated OpenCode + VT ARC Setup Guide

A sandboxed version of the [OpenCode + ARC setup guide](https://github.com/dalepike/opencode-arc-guide) that runs OpenCode inside a lightweight virtual machine. Your API key, config, and all AI interactions are isolated from your host system.

> **Status:** Early development
> **Companion project:** [opencode-arc-guide](https://github.com/dalepike/opencode-arc-guide) (standard guide)

---

## Why Isolate?

The [standard guide](https://github.com/dalepike/opencode-arc-guide) installs OpenCode directly on your machine and stores the API key in your shell config. That works well for most users. This project adds a layer of isolation for situations where you want stronger boundaries:

- **API key containment.** The key lives only inside the VM, not in your host shell config.
- **Filesystem isolation.** OpenCode can only see files you explicitly share into the VM, not your entire home directory.
- **Disposability.** Destroy and recreate the environment at will. Nothing persists on your host.
- **Reproducibility.** The same VM image works identically on any machine.

---

## Architecture Options

This project is evaluating three approaches. The right choice depends on the balance between security, usability, and setup complexity.

### Option A: Lima VM (lightweight, macOS/Linux native)

```
┌─────────────────────────────┐
│  Host (macOS/Linux)         │
│                             │
│  ┌───────────────────────┐  │
│  │  Lima VM (Ubuntu)     │  │
│  │  - OpenCode installed │  │
│  │  - API key stored     │  │
│  │  - Config file        │  │
│  │  - Shared project dir │  │
│  └───────────────────────┘  │
│                             │
│  ~/projects/ ←──mounted──→ /work/  │
└─────────────────────────────┘
```

- **Pros:** Already available on Dale's system (Lima 2.0.3). Native macOS Virtualization.framework. Full Linux environment. Can mount specific project folders read-write while keeping the rest of the host isolated.
- **Cons:** macOS/Linux only. Heavier than a container. Requires Lima knowledge.
- **Best for:** Individual developers who want strong isolation with near-native performance.

### Option B: Docker container

```
┌─────────────────────────────┐
│  Host (any OS)              │
│                             │
│  ┌───────────────────────┐  │
│  │  Docker container     │  │
│  │  - OpenCode installed │  │
│  │  - API key via env    │  │
│  │  - Config baked in    │  │
│  │  - Volume mount       │  │
│  └───────────────────────┘  │
│                             │
│  ~/projects/ ←──volume──→ /work/  │
└─────────────────────────────┘
```

- **Pros:** Cross-platform. Familiar to more users. Dockerfile is self-documenting. Easy to distribute.
- **Cons:** TUI rendering in Docker can be tricky (requires `-it` and proper terminal allocation). Docker Desktop required on macOS/Windows. Less isolation than a VM (shares the host kernel).
- **Best for:** Teams who want a reproducible, distributable setup. CI/CD integration.

### Option C: Lima VM + Docker inside (maximum isolation)

```
┌──────────────────────────────────┐
│  Host (macOS/Linux)              │
│                                  │
│  ┌────────────────────────────┐  │
│  │  Lima VM (Ubuntu)          │  │
│  │                            │  │
│  │  ┌──────────────────────┐  │  │
│  │  │  Docker container    │  │  │
│  │  │  - OpenCode          │  │  │
│  │  │  - API key           │  │  │
│  │  │  - Config            │  │  │
│  │  └──────────────────────┘  │  │
│  │                            │  │
│  └────────────────────────────┘  │
│                                  │
│  ~/projects/ ←──mounted──→ /work/     │
└──────────────────────────────────┘
```

- **Pros:** Maximum isolation (VM + container). Network policies at VM level. Docker manages the application layer while VM manages the security boundary.
- **Cons:** Most complex setup. Double the overhead. Harder to debug.
- **Best for:** High-security environments, shared research computing.

---

## Current Direction

**Starting with Option B (Docker)** because:
1. Cross-platform (works on macOS, Linux, and Windows)
2. Dockerfile serves as executable documentation
3. Easiest to distribute and reproduce
4. Can layer Option A on top later for users who want VM-level isolation

---

## Project Structure

```
vm-opencode-arc-guide/
├── README.md              # This file
├── Dockerfile             # OpenCode + VT ARC in a container
├── docker-compose.yml     # One-command launch with volume mounts
├── .env.example           # Template for API key
├── config/
│   └── opencode.json      # VT ARC provider config (baked into image)
└── scripts/
    ├── start.sh           # Launch script with TUI support
    └── setup-lima.sh      # (Future) Lima VM setup for Option A
```

---

## Quick Start (coming soon)

```bash
# 1. Clone this repo
git clone https://github.com/dalepike/vm-opencode-arc-guide.git
cd vm-opencode-arc-guide

# 2. Add your API key
cp .env.example .env
# Edit .env and add your key from https://llm.arc.vt.edu/

# 3. Launch
docker compose run --rm opencode

# You're now in an isolated OpenCode session connected to VT ARC.
# Only the ./projects/ folder is shared with the container.
```

---

## Related Projects

| Project | Description |
|---------|-------------|
| [opencode-arc-guide](https://github.com/dalepike/opencode-arc-guide) | Standard (non-isolated) setup guide |
| [OpenCode](https://github.com/anomalyco/opencode) | The OpenCode project itself |
| [VT ARC LLM API](https://docs.arc.vt.edu/ai/011_llm_api_arc_vt_edu.html) | ARC API documentation |

---

*Created: February 17, 2026*
