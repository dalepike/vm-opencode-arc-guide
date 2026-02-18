# VM OpenCode ARC Guide — Development Plan

> Cold-start context for anyone picking up this project with zero conversation history.

---

## 1. Project Background

This repository is the **Docker-isolated companion** to [`opencode-arc-guide`](https://github.com/dalepike/opencode-arc-guide), which covers a standard (non-Docker) install of OpenCode on macOS/Linux with Virginia Tech's ARC LLM API.

**Purpose:** Provide a one-command Docker workflow so security-conscious VT employees can run OpenCode without installing anything on the host beyond Docker.

**Target audience:** Moderately technical VT employee (comfortable with a terminal, not necessarily a developer).

**Success criterion:** `docker compose run --rm opencode` works on the first try, connects to ARC, and provides a usable TUI session.

---

## 2. Verified Technical Facts

These were verified against live systems during initial development. Re-verify if anything breaks.

| Fact | Value |
|------|-------|
| OpenCode binary install path | `~/.opencode/bin/opencode` |
| OpenCode version (at time of writing) | **1.2.6** (not 0.x) |
| ARC API base URL | `https://llm-api.arc.vt.edu/api/v1` |
| Available models | `Kimi-K2.5`, `gpt-oss-120b` |
| Auth mechanism | Env var `VT_ARC_API_KEY` referenced as `{env:VT_ARC_API_KEY}` in `opencode.json` |
| Config file path inside container | `~/.config/opencode/opencode.json` |
| VPN required? | **Yes** — VT VPN must be active on the host for ARC API access |

---

## 3. Current State of Every File

All files are scaffolded but **untested** unless noted otherwise.

| File | Status | Notes |
|------|--------|-------|
| `Dockerfile` | Scaffolded, untested | Base image — installs OpenCode, copies config |
| `Dockerfile.harness` | Scaffolded, untested | Adds harness project with `AGENTS.md` |
| `Dockerfile.superpowers` | Scaffolded, untested | Adds superpowers methodology `AGENTS.md` |
| `docker-compose.yml` | Scaffolded, untested | Three services: `opencode`, `opencode-harness`, `opencode-superpowers` |
| `config/opencode.json` | **Verified correct** | Tested against ARC API schema |
| `scripts/entrypoint.sh` | Scaffolded, untested | Base entrypoint |
| `scripts/entrypoint-harness.sh` | Scaffolded, untested | Harness variant |
| `scripts/entrypoint-superpowers.sh` | Scaffolded, untested | Superpowers variant |
| `harness/AGENTS.md` | Written | Agent instructions for harness mode |
| `harness/AGENTS.superpowers.md` | Written | Agent instructions for superpowers mode |
| `.env.example` | Done | Template for `VT_ARC_API_KEY` |
| `.gitignore` | Done | Ignores `.env` and common artifacts |
| `README.md` | Written, **references untested flows** | Needs rewrite after testing |
| `projects/` | Directory exists | Mount point for user project files |

---

## 4. Development Phases

### Phase 1: Build and Test All Three Docker Images

**Goal:** Every `docker build` succeeds and every `docker compose run` produces a working OpenCode TUI.

- [ ] Build `Dockerfile` → verify OpenCode binary is at expected path
- [ ] Build `Dockerfile.harness` → verify `AGENTS.md` is mounted/copied correctly
- [ ] Build `Dockerfile.superpowers` → verify superpowers `AGENTS.md` is in place
- [ ] Run each service with a real `VT_ARC_API_KEY` and confirm ARC connectivity
- [ ] Verify TUI renders correctly (colors, input, scrolling)
- [ ] Document any fixes needed

### Phase 2: Harden

**Goal:** Production-quality images that follow Docker best practices.

- [ ] Switch from root to a non-root user in all Dockerfiles
- [ ] Create `.dockerignore` (exclude `.git`, `.env`, `PLAN.md`, etc.)
- [ ] Minimize image size (multi-stage build or smaller base image if feasible)
- [ ] Pin base image versions for reproducibility
- [ ] DRY up entrypoint scripts (shared base + per-variant overrides)

### Phase 3: Rewrite README with Tested Commands

**Goal:** README reflects reality, not aspirations.

- [ ] Rewrite all setup instructions based on tested Phase 1 results
- [ ] Add troubleshooting section (common errors and fixes)
- [ ] Add architecture diagram or explanation of the three images
- [ ] Verify every command in the README works copy-paste
- [ ] Add "Verify it works" section with expected output

### Phase 4: Lima VM Option (Future / Optional)

**Goal:** For users who want even stronger isolation (full VM, not just containers).

- [ ] Research Lima VM setup for macOS
- [ ] Create `lima.yaml` config that runs Docker inside the VM
- [ ] Document trade-offs (performance, setup complexity)
- [ ] This phase is optional and can be deferred

### Phase 5: End-to-End Verification

**Goal:** Fresh-machine test of the entire flow.

- [ ] Clone repo on a clean machine (or clean Docker environment)
- [ ] Follow README from scratch with no prior context
- [ ] Confirm all three modes work
- [ ] Tag a release

---

## 5. Known Issues to Investigate

These were identified during scaffolding but not yet resolved:

| Issue | Risk | Notes |
|-------|------|-------|
| TUI rendering in Docker | Medium | May need `TERM=xterm-256color`, ncurses libs, and proper locale (`en_US.UTF-8`) set in Dockerfile |
| Entrypoint binary path | Medium | Scripts reference `/root/.opencode/bin/opencode` — needs verification after build |
| Running as root | Medium | Current Dockerfiles run as root; should switch to non-root user in Phase 2 |
| No `.dockerignore` | Low | Could leak `.env` or `.git` into image context |
| Entrypoint script duplication | Low | Three scripts share ~80% logic; DRY opportunity in Phase 2 |
| README accuracy | High | Currently references untested flows; must not ship until Phase 3 |

---

## 6. Execution Order

```
Phase 1 (Build & Test)
  └── Fix any build/runtime issues discovered
       └── Phase 2 (Harden)
            └── Phase 3 (README Rewrite)
                 └── Phase 5 (E2E Verification)

Phase 4 (Lima VM) — independent, can happen anytime or never
```

**Start here:** Phase 1, first task: `docker build -t opencode-arc .` and see what happens.
