# Koose -- AI Assistant

**MEST Africa Tech Assignment**

**Created by:** Koose (EIT)

---

## What is Koose?

Koose is a personal AI assistant that can:

- **Summarize articles** from a pasted URL link
- **Summarize PDF documents** uploaded directly
- **Chat with personality** -- Koose has its own voice and character

Built on [OpenClaw](https://github.com/openclaw/openclaw) -- an open-source AI agent framework that handles LLM integration, PDF parsing, session management, error handling, and logging out of the box. This lets us focus on Koose's personality and capabilities instead of reinventing infrastructure.

## Why OpenClaw?

| What we need       | Without OpenClaw        | With OpenClaw                |
| ------------------ | ----------------------- | ---------------------------- |
| PDF summarization  | Build custom PDF parser | Built-in media pipeline      |
| Link summarization | Write web scraper + LLM | Native URL fetching          |
| Personality        | Build prompt system     | Drop a `SOUL.md` file        |
| Error handling     | Write retry/fallback    | Production-grade, built in   |
| Logging            | Build logging framework | Structured logs, `--verbose` |
| Web UI             | Build from scratch      | WebChat included             |
| Deployment         | Custom Docker + scripts | One startup script           |

## Use cases at MEST

- **Research** -- paste article links, get summaries in seconds
- **PDF digest** -- upload lecture PDFs, business plans, case studies
- **Study buddy** -- explain concepts, break down readings
- **Meeting prep** -- summarize agendas and background docs
- **Post-assignment** -- keep running, add skills, connect WhatsApp

---

## Quick start (3 steps)

### 1. Clone and build

```bash
git clone https://github.com/YOUR_USERNAME/openclaw.git koose-ai
cd koose-ai
pnpm install
pnpm build && pnpm ui:build
```

### 2. Set your API key

```bash
cp koose/.env.example .env
```

Edit `.env` and paste your Anthropic API key:

```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Get a key at https://console.anthropic.com if you don't have one.

### 3. Start Koose

```bash
source .env && bash koose/start.sh
```

That's it. Open `http://localhost:3000` in your browser. Koose is ready.

No wizard. No interactive prompts. The startup script reads your API key from `.env`, sets up the config, copies Koose's personality, and starts the web UI automatically.

---

## How to test Koose

### Test 1: Summarize an article link

In the WebChat, send:

```
Summarize this article: https://techcrunch.com/2024/01/15/example-article
```

Koose will fetch the article and return a structured summary.

### Test 2: Summarize a PDF

1. Open `http://localhost:3000`
2. Click the attachment/upload button
3. Upload any PDF (lecture note, business plan, research paper)
4. Send: `Summarize this PDF`

Koose reads the PDF and returns the key points.

### Test 3: Personality check

Send: `Who are you?`

Koose responds with its personality as defined in `koose/SOUL.md`.

---

## Project structure

```
koose-ai/
  koose/                 # Koose-specific files
    SOUL.md              # Koose personality (baked in)
    start.sh             # Zero-prompt startup script
    .env.example         # Environment variables template
  src/                   # OpenClaw core source (TypeScript)
    cli/                 # CLI commands
    commands/            # Command handlers
    infra/               # Logging, errors, config
    media/               # PDF, images, audio pipeline
  Dockerfile             # Production Docker image
  fly.toml               # Fly.io deployment config
  .env                   # Your local env vars (gitignored)
```

## How it works

```
.env (ANTHROPIC_API_KEY)
  |
  v
koose/start.sh
  |-- validates env vars
  |-- runs non-interactive onboarding (no prompts)
  |-- copies koose/SOUL.md into workspace
  |-- starts gateway with WebChat
  v
http://localhost:3000  (ready to chat)
```

## Koose's personality

The file `koose/SOUL.md` defines how Koose talks. You can edit it anytime:

```markdown
You are Koose, a sharp and friendly AI assistant created by Koose, an EIT at MEST Africa.
You speak clearly, with a warm and slightly witty tone.
When summarizing, you are concise but never leave out the important parts.
```

The startup script copies this into the OpenClaw workspace automatically.

---

## Exception handling

Koose handles errors gracefully -- no crashes, just clear messages:

- **Bad URLs** -- tells the user the link is unreachable
- **Corrupt PDFs** -- tells the user and suggests re-uploading
- **API failures** -- retries automatically with backoff
- **Session errors** -- user can reset with `/new`
- **Network issues** -- channel disconnects are retried

## Logging

- **Verbose mode** is enabled by default in `koose/start.sh`
- **Log levels:** errors, warnings, info, debug -- all captured to stdout
- **Production:** `flyctl logs` to view live logs on Fly.io
- **Chat commands:** `/status` (session info), `/usage full` (token usage)

---

## Deploying to Fly.io

The Dockerfile and fly.toml are already configured. Deploy in 3 commands:

### 1. Install Fly CLI and log in

```bash
curl -L https://fly.io/install.sh | sh
flyctl auth login
```

### 2. Set your API key as a secret

```bash
flyctl secrets set ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### 3. Deploy

```bash
flyctl launch --name koose-ai
flyctl deploy
```

Koose is now live at **https://koose-ai.fly.dev**

No Dockerfile changes needed. No wizard. The startup script reads the API key from Fly secrets and starts everything automatically.

### Check deployment

```bash
flyctl status     # is it running?
flyctl logs       # what's happening?
```

---

## Useful commands

| Command                              | What it does           |
| ------------------------------------ | ---------------------- |
| `source .env && bash koose/start.sh` | Start Koose locally    |
| `pnpm openclaw doctor`               | Diagnose config issues |
| `flyctl deploy`                      | Deploy to Fly.io       |
| `flyctl logs`                        | View production logs   |
| `flyctl secrets set KEY=value`       | Update secrets         |

## Chat commands

| Command       | What it does                       |
| ------------- | ---------------------------------- |
| `/status`     | Session info (model, tokens, cost) |
| `/new`        | Start a fresh conversation         |
| `/compact`    | Compress session context           |
| `/usage full` | Per-response usage stats           |

---

## Links

- **Anthropic API key:** https://console.anthropic.com
- **Fly.io:** https://fly.io
- **OpenClaw docs:** https://docs.openclaw.ai
- **OpenClaw repo:** https://github.com/openclaw/openclaw
