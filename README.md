# Koose -- AI Assistant

**MEST Africa Tech Assignment**

**Created by:** Koose (EIT)

---

## What is Koose?

Koose is a personal AI assistant built on top of [OpenClaw](https://github.com/openclaw/openclaw), an open-source AI agent framework. Koose can:

- **Summarize articles** from a pasted URL link
- **Summarize PDF documents** uploaded directly
- **Chat with personality** -- Koose has its own voice and character, named after its creator

## Why OpenClaw instead of building from scratch?

Building a full AI agent from zero means writing your own LLM integration, message routing, session management, media handling (PDFs, images, audio), error recovery, and deployment plumbing. That is months of work.

**OpenClaw gives us all of that out of the box:**

- **Built-in media pipeline** -- handles PDF uploads, images, audio, and video natively. No need to write custom PDF parsing or file-upload logic.
- **Multi-channel support** -- Koose works on WhatsApp, Telegram, Slack, Discord, and a WebChat UI. One codebase, many surfaces.
- **Session management** -- tracks conversation context, so Koose remembers what you asked earlier in the same chat.
- **Agent personality via prompt files** -- drop a `SOUL.md` file and Koose has a personality. No code changes needed.
- **Production-grade error handling and logging** -- retries, graceful failures, and structured logs are built in.
- **Extensible with skills** -- add new abilities (like "summarize-link" or "summarize-pdf") as skill files without touching core code.

In short: OpenClaw handles the hard infrastructure so we focus on what Koose should _do_ and how it should _talk_.

## Use cases at MEST (and beyond)

Koose is not just an assignment -- it is a tool EITs and staff can use daily:

- **Research assistant** -- paste any article link and get a concise summary in seconds. Useful during market research, competitor analysis, or reading long reports.
- **PDF digest** -- upload a lecture PDF, business plan, or case study and get the key points without reading 30 pages.
- **Study buddy** -- ask Koose to explain concepts, quiz you, or break down complex readings.
- **Meeting prep** -- summarize agendas, reports, or background reading before a meeting.
- **WhatsApp-native** -- works right inside WhatsApp, the app everyone at MEST already uses. No extra app to install.
- **Team knowledge sharing** -- add Koose to a group chat and let the whole team ask questions about shared documents.
- **Post-assignment** -- Koose keeps running after the assignment. Add new skills, connect new channels, or deploy it for your startup.

---

## Prerequisites

- **Node.js >= 22** -- [Download here](https://nodejs.org/)
- **pnpm** -- install with `npm install -g pnpm`
- **An Anthropic API key** -- [Get one here](https://console.anthropic.com/) (or use OpenAI/Google keys instead)
- **Git** -- to clone this repo
- **fly.io CLI** (for deployment) -- [Install flyctl](https://fly.io/docs/flyctl/install/)

## Installation (from this repo)

This runs Koose directly from the cloned source code -- no `npm install -g` needed.

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/openclaw.git koose-ai
cd koose-ai
```

### 2. Install dependencies

```bash
pnpm install
```

### 3. Build the project

```bash
pnpm ui:build
pnpm build
```

### 4. Run the onboarding wizard

This sets up your API key, model, and workspace:

```bash
pnpm openclaw onboard
```

The wizard will ask you to:

1. Choose a model provider (pick **Anthropic** and paste your API key)
2. Set up the workspace directory
3. Optionally connect a channel (WhatsApp, Telegram, etc.)

### 5. Give Koose a personality

Edit (or create) the file `~/.openclaw/workspace/SOUL.md`:

```markdown
You are Koose, a friendly and sharp AI assistant created by Koose, an EIT at MEST Africa.
You speak clearly, with a warm and slightly witty tone.
You love helping people understand complex things simply.
When summarizing, you are concise but never leave out the important parts.
```

### 6. Start the gateway

```bash
pnpm openclaw gateway run --port 18789 --verbose
```

Koose is now running locally on `http://localhost:18789`.

### 7. Open the WebChat

Visit `http://localhost:18789` in your browser to chat with Koose via the built-in WebChat UI.

---

## How to test Koose

### Test 1: Summarize an article link

In the WebChat (or WhatsApp if connected), send:

```
Summarize this article: https://techcrunch.com/2024/01/15/example-article
```

Koose will fetch and summarize the article content.

### Test 2: Summarize a PDF

1. Open the WebChat at `http://localhost:18789`
2. Click the attachment/upload button
3. Upload any PDF file (e.g. a lecture note, business plan, or research paper)
4. Send a message like: `Summarize this PDF`

Koose will read the PDF and return a summary.

### Test 3: Personality check

Send:

```
Who are you?
```

Koose should respond with its personality as defined in `SOUL.md`.

### Test via WhatsApp (optional)

If you connected WhatsApp during onboarding:

1. Send a message to the linked WhatsApp number
2. Paste a link or forward a PDF
3. Ask Koose to summarize it

---

## Project structure

```
koose-ai/
  src/               # Core source code (TypeScript)
    cli/             # CLI commands
    commands/        # Command handlers
    infra/           # Infrastructure (logging, errors, config)
    media/           # Media pipeline (PDF, images, audio)
  dist/              # Built output (after pnpm build)
  docs/              # Documentation
  ~/.openclaw/
    openclaw.json    # Configuration (model, channels, auth)
    workspace/
      SOUL.md        # Koose personality prompt
      AGENTS.md      # Agent behavior instructions
      skills/        # Custom skills directory
```

## Configuration

The main config file is `~/.openclaw/openclaw.json`. Key settings:

```json5
{
  // AI model
  agents: {
    defaults: {
      model: { primary: "anthropic/claude-sonnet-4-6" },
    },
  },
  // Gateway (the server)
  gateway: {
    port: 18789,
    mode: "local",
  },
  // Channels (optional -- connect WhatsApp, Telegram, etc.)
  channels: {
    whatsapp: { enabled: true },
  },
}
```

## Exception handling

OpenClaw (and therefore Koose) handles exceptions gracefully:

- **Invalid URLs** -- if a user pastes a broken or unreachable link, Koose responds with a clear error message instead of crashing.
- **Corrupt/unreadable PDFs** -- if a PDF cannot be parsed, Koose tells the user and suggests re-uploading.
- **API failures** -- if the AI model provider (Anthropic/OpenAI) is down or rate-limited, OpenClaw retries automatically and falls back gracefully.
- **Session errors** -- if a session is corrupted, the user can reset with `/new` or `/reset`.
- **Network issues** -- channel disconnects (WhatsApp, Telegram) are retried with backoff.

## Logging

OpenClaw provides structured logging out of the box:

- **Start with verbose mode:** `pnpm openclaw gateway run --verbose`
- **Log levels:** errors, warnings, info, and debug are all captured.
- **Where logs go:** stdout by default. In production (fly.io), logs are accessible via `flyctl logs`.
- **Chat commands for monitoring:**
  - `/status` -- see the current session model, token count, and cost
  - `/usage full` -- see per-response usage stats

## Deploying to fly.io

### 1. Install flyctl

```bash
curl -L https://fly.io/install.sh | sh
```

### 2. Log in to fly.io

```bash
flyctl auth login
```

### 3. Create the fly app (from the project root)

```bash
flyctl launch --name koose-ai
```

### 4. Set secrets (your API key)

```bash
flyctl secrets set ANTHROPIC_API_KEY=your-api-key-here
```

### 5. Create a Dockerfile (if not present)

A basic `Dockerfile` for Koose:

```dockerfile
FROM node:22-slim
RUN npm install -g pnpm
WORKDIR /app
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm ui:build
RUN pnpm build
EXPOSE 18789
CMD ["node", "dist/cli.js", "gateway", "run", "--port", "18789", "--bind", "all", "--verbose"]
```

### 6. Deploy

```bash
flyctl deploy
```

### 7. Check it is running

```bash
flyctl status
flyctl logs
```

Your Koose instance will be live at `https://koose-ai.fly.dev`.

---

## Useful commands

| Command                                 | What it does                   |
| --------------------------------------- | ------------------------------ |
| `pnpm openclaw gateway run --verbose`   | Start Koose locally            |
| `pnpm openclaw onboard`                 | Re-run the setup wizard        |
| `pnpm openclaw channels status --probe` | Check connected channels       |
| `pnpm openclaw doctor`                  | Diagnose configuration issues  |
| `flyctl logs`                           | View production logs on fly.io |
| `flyctl status`                         | Check fly.io deployment status |

## Chat commands (inside any connected channel)

| Command            | What it does                         |
| ------------------ | ------------------------------------ |
| `/status`          | Session status (model, tokens, cost) |
| `/new` or `/reset` | Reset the conversation               |
| `/compact`         | Compact/summarize session context    |
| `/verbose on/off`  | Toggle verbose responses             |
| `/usage full`      | Show per-response usage stats        |

---

## Links

- **OpenClaw docs:** https://docs.openclaw.ai
- **OpenClaw repo:** https://github.com/openclaw/openclaw
- **fly.io docs:** https://fly.io/docs
- **Anthropic API:** https://console.anthropic.com
