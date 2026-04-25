# claude-consultant-kr

> 🇰🇷 An unofficial Claude Code agent package for business strategy analysis in Korean market context
>
> *Embeds McKinsey/BCG-style thinking frameworks into Claude Code, generating executable strategies tailored to Korean SaaS, startups, and enterprises.*

> **npm package**: [`consultant-kr-cli`](https://www.npmjs.com/package/consultant-kr-cli) · **Repo**: `gaebalai/claude-consultant-kr`
> This is an unofficial tool. "Claude" is a trademark of Anthropic, PBC.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://docs.claude.com/en/docs/claude-code)
[![npm](https://img.shields.io/badge/npm-consultant--kr--cli-cb3837)](https://www.npmjs.com/package/consultant-kr-cli)
[![Made by gaebalai](https://img.shields.io/badge/Made%20by-gaebalai-purple)](https://github.com/gaebalai)

🇰🇷 [한국어 README](./README.md) | 🇺🇸 English

---

## 🎯 The Problem It Solves

When using Claude Code for business analysis, you hit recurring friction:

- You have to re-prompt "analyze like McKinsey" every time
- Global references (Wix, Stripe, Slack) leak into Korean market analysis
- Pricing suggestions come out as USD/JPY conversions that miss local reality
- Answers end with vague "both options are valid"

**`claude-consultant-kr`** solves this with three layers, plus optional external integration.

| Layer | Role | Location |
|---|---|---|
| **Agent** | Sub-agent with McKinsey-style thinking + Korean market context | `agents/consultant-kr.md` |
| **Slash Commands** | Business analysis, pricing design, competitor benchmarking, feature prioritization | `commands/*.md` |
| **Hooks** | Auto-load prior context, KakaoWork/Slack notifications, auto-generate Velog drafts | `hooks/` |
| **External integration** *(optional)* | Humanize Korean AI-style draft into natural prose — dynamic fetch | `scripts/install-humanize.sh` |

---

## ⚡ Quick Start

### Option 1: `npx` one-liner (recommended)

No clone, no download. Requires Node.js 14+.

```bash
# Project-local install (places into ./.claude/)
npx consultant-kr-cli@latest --local

# Global install (places into ~/.claude/, available across projects)
npx consultant-kr-cli@latest --global

# Check status / uninstall
npx consultant-kr-cli@latest --check
npx consultant-kr-cli@latest --uninstall
```

> **Supported platforms**: macOS / Linux / WSL2. Native Windows PowerShell or CMD is **not** supported.
>
> <details>
> <summary>🪟 Windows users (expand)</summary>
>
> This package uses bash-based install and hook scripts, so it does not run on native Windows shells. We recommend **WSL2 + Ubuntu** (Microsoft's officially recommended Windows development environment).
>
> ```powershell
> # PowerShell as Administrator
> wsl --install -d Ubuntu
> # Reboot, then launch Ubuntu and create your user account
> ```
>
> Inside WSL, npx works exactly as it does on Linux:
>
> ```bash
> # Inside WSL Ubuntu
> sudo apt update && sudo apt install -y nodejs npm
> npx consultant-kr-cli@latest --local
> ```
>
> Note: WSL's `~` (user home) is separate from Windows' `C:\Users\xxx`. The `--global` install lands in the WSL user's home (`/home/<user>/.claude/`).
>
> </details>
>

### Option 2: Clone the repo

```bash
git clone https://github.com/gaebalai/claude-consultant-kr.git
cd claude-consultant-kr

./scripts/install.sh --local    # project-local
./scripts/install.sh --global   # global
```

Verify:

```bash
claude
/agents          # should list consultant-kr
```

First run:

```text
/analyze-business
```

---

## 📦 What's Included

### 1. Agent (`agents/consultant-kr.md`)

A business consultant injected with McKinsey/BCG thinking frameworks.

- **Sora-Ame-Kasa framework**: Facts (空) → Interpretation (雨) → Proposal (傘)
- Built-in **MECE, Pyramid Structure, 3C, SWOT, 4P** frameworks
- **Korean market context tables**: 10 categories covering no-code builders, payments, cloud, blogs, etc.
- **Pricing band re-mapping**: prevents naive currency conversion; Korean Won baselines for B2C/B2B
- **Regulatory context**: PIPA, ISMS-P, CSAP, Electronic Financial Transactions Act
- **Permission scoping**: Read/Grep/Glob/WebFetch/WebSearch only (no Edit/Write)

#### 🆕 Industry-specialized derivatives (`agents/industry/`)

Inheriting the base agent while embedding each industry's regulatory, competitive, and revenue context:

| Agent | Domain | Embedded context |
|---|---|---|
| `consultant-kr-fintech` | Fintech, e-finance, virtual assets | Electronic Financial Transactions Act, Specific Financial Information Act, Korea Financial Telecommunications & Clearings Institute, regulatory sandbox |
| `consultant-kr-healthcare` | DTx, medical devices, telemedicine | Medical Service Act, SaMD classes, HIRA reimbursement, "early entry, post-evaluation" |
| `consultant-kr-construction` | Smart construction, BIM, construction safety | Framework Act on the Construction Industry, Serious Accidents Punishment Act, KCS, public procurement |
| `consultant-kr-ecommerce` | D2C, open markets, cross-border | E-Commerce Act, open-market commission structures, fulfillment ecosystem |

Selective install:

```bash
# npx
npx consultant-kr-cli@latest industry --local --fintech --healthcare
npx consultant-kr-cli@latest industry --local    # interactive

# clone
./scripts/install-industry.sh --local --fintech --healthcare
./scripts/install-industry.sh --local               # interactive
```

See [`agents/industry/README.md`](./agents/industry/README.md) for details.

#### 🔌 External integration: Humanize KR (optional)

Optionally install the [gaebalai/im-not-ai](https://github.com/gaebalai/im-not-ai) "Korean AI-tell remover" (MIT, fork of `epoko77-ai/im-not-ai`) alongside this package. Useful for polishing analysis report drafts into natural Korean prose, with automatic integration into our 4 analysis commands.

Installs: 6 agents + 6 slash commands (`/humanize`, `/humanize-detect`, `/humanize-redo`, `/humanize-status`, `/humanize-list`, `/humanize-web`) + 1 skill (`humanize-korean`) + LICENSE copy.

```bash
npx consultant-kr-cli@latest humanize --local      # project-local
npx consultant-kr-cli@latest humanize --global     # global
npx consultant-kr-cli@latest humanize --check      # status
npx consultant-kr-cli@latest humanize --uninstall

# Non-interactive (CI etc.): auto-accept license notice
npx consultant-kr-cli@latest humanize --local --yes
```

After install, you can use it in two ways:

**1. Automatic integration** — When you call `/analyze-business` and other analysis commands, Korean refinement is applied to the output automatically (only if the skill is installed).

**2. Direct invocation** — Slash commands or natural language:

```text
> /humanize <text or file path>
> /humanize-detect <text>         # detection only
> /refine-report                   # refine the most recent report
> AI 티 없애줘                     # natural-language trigger
```

> ℹ **License**: The upstream repo [`gaebalai/im-not-ai`](https://github.com/gaebalai/im-not-ai) is distributed under the **MIT License**. This package does not redistribute the upstream content; the install script downloads files directly from the upstream GitHub raw URLs into the user's environment at install time, and also fetches the upstream LICENSE file as a local copy.
>
> ⚠ **Upstream tracking note**: The installer fetches the `main` branch of `gaebalai/im-not-ai`. Any future upstream change will land in the user's environment on the next install/reinstall. For production use, review upgrades carefully after the initial install. (Pinning to a specific commit is planned for a 0.4.0+ milestone.)

### 2. Slash Commands (`commands/`)

| Command | Purpose | Example Argument |
|---|---|---|
| `/analyze-business` | Full strategy analysis + auto report save + (optional) Korean refinement | `MVP launch prep 2-week tasks` |
| `/design-pricing` | 3-tier pricing with KRW, VAT, annual discount + (optional) Korean refinement | `SMB B2C SaaS` |
| `/benchmark-competitors` | Korean competitor benchmark (3C + SWOT) + (optional) Korean refinement | `No-code website builders` |
| `/prioritize-features` | RICE + Pareto-based prioritization + (optional) Korean refinement | `Select 3 of 7 features` |
| `/refine-report` 🆕 | Post-process an existing report through humanize-korean (saves `*-refined.md`) | (defaults to most recent report) |

> The "Korean refinement" step only runs if the `humanize-korean` skill is installed; otherwise a one-line hint is shown and the step is skipped. Install: `npx consultant-kr-cli@latest humanize --local`

### 3. Hooks (`hooks/`)

| Hook Event | Script | Action |
|---|---|---|
| `SessionStart` | `load-context.sh` | Auto-inject previous report's issue & recommendations |
| `UserPromptSubmit` | `inject-date.sh` | Inject KST current time for accurate relative-time parsing |
| `PostToolUse:Write` | `notify-on-report.sh` | KakaoWork/Slack webhook on report save |
| `Stop` | `generate-blog-draft.sh` | Auto-convert today's report to Velog blog draft on session end |

---

## 🌏 Why Korean-Localized Matters

Global tools treat non-US markets as afterthoughts. This package treats Korean market as the default:

- **Competitors**: Imweb, Sixshop, Cafe24 (not just Wix/Shopify)
- **Payments**: TossPayments, PortOne, KakaoPay (not just Stripe)
- **Collaboration**: Jandi, KakaoWork, Dooray (not just Slack)
- **Location services**: Naver Place, KakaoMap (not Google Business Profile)
- **Cloud**: AWS Seoul `ap-northeast-2`, NCP, KT Cloud
- **Blog platforms**: Velog, Tistory (not just Medium)
- **Compliance**: PIPA, ISMS-P (not just GDPR)
- **Pricing**: KRW with VAT handling and 17-20% annual discount norms

---

## 📖 Documentation

- [Installation Guide](./docs/INSTALL.md)
- [Usage Examples](./docs/USAGE.md)
- [Hook Configuration](./docs/HOOKS.md)
- [Customization](./docs/CUSTOMIZING.md)
- [FAQ](./docs/FAQ.md)

---

## 🤝 Contributing

PRs, issues, and discussions welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md).

Especially appreciated:
- Korean competitor mapping updates
- Industry-specific agents (`consultant-kr-{industry}.md`)
- Real-world usage examples (`examples/`)
- Multilingual README translations

---

## 📜 License

MIT © [gaebalai](https://github.com/gaebalai)

The optional Humanize KR integration is **not** covered by this license — see the notice in the External integration section above.

---

**Made with ❤️ by [gaebalai](https://github.com/gaebalai) — AI-fluent liberal arts Engineer**
