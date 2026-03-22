---
url: https://code.claude.com/docs/en/setup
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/setup/docs/en/overview)

![US](https://d3gk2c5xim1je2.cloudfront.net/flags/US.svg)

English

Search...

⌘KAsk AI

* [Claude Developer Platform](https://platform.claude.com/)
* [Claude Code on the Web](https://claude.ai/code)
* [Claude Code on the Web](https://claude.ai/code)

Search...

Navigation

Administration

Advanced setup

[Getting started](https://code.claude.com/docs/en/setup/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/setup/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/setup/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/setup/docs/en/setup)[Configuration](https://code.claude.com/docs/en/setup/docs/en/settings)[Reference](https://code.claude.com/docs/en/setup/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/setup/docs/en/legal-and-compliance)

##### Administration

* [Advanced setup](https://code.claude.com/docs/en/setup/docs/en/setup)
* [Authentication](https://code.claude.com/docs/en/setup/docs/en/authentication)
* [Security](https://code.claude.com/docs/en/setup/docs/en/security)
* [Server-managed settings (beta)](https://code.claude.com/docs/en/setup/docs/en/server-managed-settings)
* [Data usage](https://code.claude.com/docs/en/setup/docs/en/data-usage)
* [Zero data retention](https://code.claude.com/docs/en/setup/docs/en/zero-data-retention)
* [Monitoring](https://code.claude.com/docs/en/setup/docs/en/monitoring-usage)
* [Costs](https://code.claude.com/docs/en/setup/docs/en/costs)
* [Track team usage with analytics](https://code.claude.com/docs/en/setup/docs/en/analytics)
* [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/setup/docs/en/plugin-marketplaces)

On this page

* [System requirements](#system-requirements)
* [Additional dependencies](#additional-dependencies)
* [Install Claude Code](#install-claude-code)
* [Set up on Windows](#set-up-on-windows)
* [Alpine Linux and musl-based distributions](#alpine-linux-and-musl-based-distributions)
* [Verify your installation](#verify-your-installation)
* [Authenticate](#authenticate)
* [Update Claude Code](#update-claude-code)
* [Auto-updates](#auto-updates)
* [Configure release channel](#configure-release-channel)
* [Disable auto-updates](#disable-auto-updates)
* [Update manually](#update-manually)
* [Advanced installation options](#advanced-installation-options)
* [Install a specific version](#install-a-specific-version)
* [Deprecated npm installation](#deprecated-npm-installation)
* [Migrate from npm to native](#migrate-from-npm-to-native)
* [Install with npm](#install-with-npm)
* [Binary integrity and code signing](#binary-integrity-and-code-signing)
* [Uninstall Claude Code](#uninstall-claude-code)
* [Native installation](#native-installation)
* [Homebrew installation](#homebrew-installation)
* [WinGet installation](#winget-installation)
* [npm](#npm)
* [Remove configuration files](#remove-configuration-files)

Administration

# Advanced setup

Copy page

System requirements, platform-specific installation, version management, and uninstallation for Claude Code.

Copy page

This page covers system requirements, platform-specific installation details, updates, and uninstallation. For a guided walkthrough of your first session, see the [quickstart](https://code.claude.com/docs/en/setup/docs/en/quickstart). If you’ve never used a terminal before, see the [terminal guide](https://code.claude.com/docs/en/setup/docs/en/terminal-guide). 

## 

[​](#system-requirements)

System requirements

Claude Code runs on the following platforms and configurations: 
* **Operating system**:  
   * macOS 13.0+  
   * Windows 10 1809+ or Windows Server 2019+  
   * Ubuntu 20.04+  
   * Debian 10+  
   * Alpine Linux 3.19+
* **Hardware**: 4 GB+ RAM
* **Network**: internet connection required. See [network configuration](https://code.claude.com/docs/en/setup/docs/en/network-config#network-access-requirements).
* **Shell**: Bash, Zsh, PowerShell, or CMD. On Windows, [Git for Windows](https://git-scm.com/downloads/win) is required.
* **Location**: [Anthropic supported countries](https://www.anthropic.com/supported-countries)

### 

[​](#additional-dependencies)

Additional dependencies

* **ripgrep**: usually included with Claude Code. If search fails, see [search troubleshooting](https://code.claude.com/docs/en/setup/docs/en/troubleshooting#search-and-discovery-issues).

## 

[​](#install-claude-code)

Install Claude Code

Prefer a graphical interface? The [Desktop app](https://code.claude.com/docs/en/setup/docs/en/desktop-quickstart) lets you use Claude Code without the terminal. Download it for [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect?utm%5Fsource=claude%5Fcode&utm%5Fmedium=docs) or [Windows](https://claude.ai/api/desktop/win32/x64/exe/latest/redirect?utm%5Fsource=claude%5Fcode&utm%5Fmedium=docs).New to the terminal? See the [terminal guide](https://code.claude.com/docs/en/setup/docs/en/terminal-guide) for step-by-step instructions.

To install Claude Code, use one of the following methods: 

* Native Install (Recommended)
* Homebrew
* WinGet

**macOS, Linux, WSL:**

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.sh | bash

```

**Windows PowerShell:**

Report incorrect code

Copy

Ask AI

```
irm https://claude.ai/install.ps1 | iex

```

**Windows CMD:**

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd

```

**Windows requires [Git for Windows](https://git-scm.com/downloads/win).** Install it first if you don’t have it.

Native installations automatically update in the background to keep you on the latest version.

Report incorrect code

Copy

Ask AI

```
brew install --cask claude-code

```

Homebrew installations do not auto-update. Run `brew upgrade claude-code` periodically to get the latest features and security fixes.

Report incorrect code

Copy

Ask AI

```
winget install Anthropic.ClaudeCode

```

WinGet installations do not auto-update. Run `winget upgrade Anthropic.ClaudeCode` periodically to get the latest features and security fixes.

After installation completes, open a terminal in the project you want to work in and start Claude Code: 

Report incorrect code

Copy

Ask AI

```
claude

```

If you encounter any issues during installation, see the [troubleshooting guide](https://code.claude.com/docs/en/setup/docs/en/troubleshooting). 

### 

[​](#set-up-on-windows)

Set up on Windows

Claude Code on Windows requires [Git for Windows](https://git-scm.com/downloads/win) or WSL. You can launch `claude` from PowerShell, CMD, or Git Bash. Claude Code uses Git Bash internally to run commands. You do not need to run PowerShell as Administrator. **Option 1: Native Windows with Git Bash** Install [Git for Windows](https://git-scm.com/downloads/win), then run the install command from PowerShell or CMD. If Claude Code can’t find your Git Bash installation, set the path in your [settings.json file](https://code.claude.com/docs/en/setup/docs/en/settings): 

Report incorrect code

Copy

Ask AI

```
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}

```

**Option 2: WSL** Both WSL 1 and WSL 2 are supported. WSL 2 supports [sandboxing](https://code.claude.com/docs/en/setup/docs/en/sandboxing) for enhanced security. WSL 1 does not support sandboxing. 

### 

[​](#alpine-linux-and-musl-based-distributions)

Alpine Linux and musl-based distributions

The native installer on Alpine and other musl/uClibc-based distributions requires `libgcc`, `libstdc++`, and `ripgrep`. Install these using your distribution’s package manager, then set `USE_BUILTIN_RIPGREP=0`. This example installs the required packages on Alpine: 

Report incorrect code

Copy

Ask AI

```
apk add libgcc libstdc++ ripgrep

```

Then set `USE_BUILTIN_RIPGREP` to `0` in your [settings.json](https://code.claude.com/docs/en/setup/docs/en/settings#available-settings) file: 

Report incorrect code

Copy

Ask AI

```
{
  "env": {
    "USE_BUILTIN_RIPGREP": "0"
  }
}

```

## 

[​](#verify-your-installation)

Verify your installation

After installing, confirm Claude Code is working: 

Report incorrect code

Copy

Ask AI

```
claude --version

```

For a more detailed check of your installation and configuration, run [claude doctor](https://code.claude.com/docs/en/setup/docs/en/troubleshooting#get-more-help): 

Report incorrect code

Copy

Ask AI

```
claude doctor

```

## 

[​](#authenticate)

Authenticate

Claude Code requires a Pro, Max, Teams, Enterprise, or Console account. The free Claude.ai plan does not include Claude Code access. You can also use Claude Code with a third-party API provider like [Amazon Bedrock](https://code.claude.com/docs/en/setup/docs/en/amazon-bedrock), [Google Vertex AI](https://code.claude.com/docs/en/setup/docs/en/google-vertex-ai), or [Microsoft Foundry](https://code.claude.com/docs/en/setup/docs/en/microsoft-foundry). After installing, log in by running `claude` and following the browser prompts. See [Authentication](https://code.claude.com/docs/en/setup/docs/en/authentication) for all account types and team setup options. 

## 

[​](#update-claude-code)

Update Claude Code

Native installations automatically update in the background. You can [configure the release channel](#configure-release-channel) to control whether you receive updates immediately or on a delayed stable schedule, or [disable auto-updates](#disable-auto-updates) entirely. Homebrew and WinGet installations require manual updates. 

### 

[​](#auto-updates)

Auto-updates

Claude Code checks for updates on startup and periodically while running. Updates download and install in the background, then take effect the next time you start Claude Code. 

Homebrew and WinGet installations do not auto-update. Use `brew upgrade claude-code` or `winget upgrade Anthropic.ClaudeCode` to update manually.**Known issue:** Claude Code may notify you of updates before the new version is available in these package managers. If an upgrade fails, wait and try again later.Homebrew keeps old versions on disk after upgrades. Run `brew cleanup claude-code` periodically to reclaim disk space.

### 

[​](#configure-release-channel)

Configure release channel

Control which release channel Claude Code follows for auto-updates and `claude update` with the `autoUpdatesChannel` setting: 
* `"latest"`, the default: receive new features as soon as they’re released
* `"stable"`: use a version that is typically about one week old, skipping releases with major regressions
Configure this via `/config` → **Auto-update channel**, or add it to your [settings.json file](https://code.claude.com/docs/en/setup/docs/en/settings): 

Report incorrect code

Copy

Ask AI

```
{
  "autoUpdatesChannel": "stable"
}

```

For enterprise deployments, you can enforce a consistent release channel across your organization using [managed settings](https://code.claude.com/docs/en/setup/docs/en/permissions#managed-settings). 

### 

[​](#disable-auto-updates)

Disable auto-updates

Set `DISABLE_AUTOUPDATER` to `"1"` in the `env` key of your [settings.json](https://code.claude.com/docs/en/setup/docs/en/settings#available-settings) file: 

Report incorrect code

Copy

Ask AI

```
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}

```

### 

[​](#update-manually)

Update manually

To apply an update immediately without waiting for the next background check, run: 

Report incorrect code

Copy

Ask AI

```
claude update

```

## 

[​](#advanced-installation-options)

Advanced installation options

These options are for version pinning, migrating from npm, and verifying binary integrity. 

### 

[​](#install-a-specific-version)

Install a specific version

The native installer accepts either a specific version number or a release channel (`latest` or `stable`). The channel you choose at install time becomes your default for auto-updates. See [configure release channel](#configure-release-channel) for more information. To install the latest version (default): 

* macOS, Linux, WSL
* Windows PowerShell
* Windows CMD

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.sh | bash

```

Report incorrect code

Copy

Ask AI

```
irm https://claude.ai/install.ps1 | iex

```

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd

```

To install the stable version: 

* macOS, Linux, WSL
* Windows PowerShell
* Windows CMD

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.sh | bash -s stable

```

Report incorrect code

Copy

Ask AI

```
& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable

```

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd stable && del install.cmd

```

To install a specific version number: 

* macOS, Linux, WSL
* Windows PowerShell
* Windows CMD

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.sh | bash -s 1.0.58

```

Report incorrect code

Copy

Ask AI

```
& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) 1.0.58

```

Report incorrect code

Copy

Ask AI

```
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd 1.0.58 && del install.cmd

```

### 

[​](#deprecated-npm-installation)

Deprecated npm installation

npm installation is deprecated. The native installer is faster, requires no dependencies, and auto-updates in the background. Use the [native installation](#install-claude-code) method when possible. 

#### 

[​](#migrate-from-npm-to-native)

Migrate from npm to native

If you previously installed Claude Code with npm, switch to the native installer: 

Report incorrect code

Copy

Ask AI

```
# Install the native binary
curl -fsSL https://claude.ai/install.sh | bash

# Remove the old npm installation
npm uninstall -g @anthropic-ai/claude-code

```

You can also run `claude install` from an existing npm installation to install the native binary alongside it, then remove the npm version. 

#### 

[​](#install-with-npm)

Install with npm

If you need npm installation for compatibility reasons, you must have [Node.js 18+](https://nodejs.org/en/download) installed. Install the package globally: 

Report incorrect code

Copy

Ask AI

```
npm install -g @anthropic-ai/claude-code

```

Do NOT use `sudo npm install -g` as this can lead to permission issues and security risks. If you encounter permission errors, see [troubleshooting permission errors](https://code.claude.com/docs/en/setup/docs/en/troubleshooting#permission-errors-during-installation).

### 

[​](#binary-integrity-and-code-signing)

Binary integrity and code signing

You can verify the integrity of Claude Code binaries using SHA256 checksums and code signatures. 
* SHA256 checksums for all platforms are published in the release manifests at `https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/{VERSION}/manifest.json`. Replace `{VERSION}` with a version number such as `2.0.30`.
* Signed binaries are distributed for the following platforms:  
   * **macOS**: signed by “Anthropic PBC” and notarized by Apple  
   * **Windows**: signed by “Anthropic, PBC”

## 

[​](#uninstall-claude-code)

Uninstall Claude Code

To remove Claude Code, follow the instructions for your installation method. 

### 

[​](#native-installation)

Native installation

Remove the Claude Code binary and version files: 

* macOS, Linux, WSL
* Windows PowerShell

Report incorrect code

Copy

Ask AI

```
rm -f ~/.local/bin/claude
rm -rf ~/.local/share/claude

```

Report incorrect code

Copy

Ask AI

```
Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force
Remove-Item -Path "$env:USERPROFILE\.local\share\claude" -Recurse -Force

```

### 

[​](#homebrew-installation)

Homebrew installation

Remove the Homebrew cask: 

Report incorrect code

Copy

Ask AI

```
brew uninstall --cask claude-code

```

### 

[​](#winget-installation)

WinGet installation

Remove the WinGet package: 

Report incorrect code

Copy

Ask AI

```
winget uninstall Anthropic.ClaudeCode

```

### 

[​](#npm)

npm

Remove the global npm package: 

Report incorrect code

Copy

Ask AI

```
npm uninstall -g @anthropic-ai/claude-code

```

### 

[​](#remove-configuration-files)

Remove configuration files

Removing configuration files will delete all your settings, allowed tools, MCP server configurations, and session history.

To remove Claude Code settings and cached data: 

* macOS, Linux, WSL
* Windows PowerShell

Report incorrect code

Copy

Ask AI

```
# Remove user settings and state
rm -rf ~/.claude
rm ~/.claude.json

# Remove project-specific settings (run from your project directory)
rm -rf .claude
rm -f .mcp.json

```

Report incorrect code

Copy

Ask AI

```
# Remove user settings and state
Remove-Item -Path "$env:USERPROFILE\.claude" -Recurse -Force
Remove-Item -Path "$env:USERPROFILE\.claude.json" -Force

# Remove project-specific settings (run from your project directory)
Remove-Item -Path ".claude" -Recurse -Force
Remove-Item -Path ".mcp.json" -Force

```

Was this page helpful?

YesNo

[Authentication](https://code.claude.com/docs/en/setup/docs/en/authentication)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/setup/docs/en/overview)

[x](https://x.com/AnthropicAI)[linkedin](https://www.linkedin.com/company/anthropicresearch)

Company

[Anthropic](https://www.anthropic.com/company)[Careers](https://www.anthropic.com/careers)[Economic Futures](https://www.anthropic.com/economic-futures)[Research](https://www.anthropic.com/research)[News](https://www.anthropic.com/news)[Trust center](https://trust.anthropic.com/)[Transparency](https://www.anthropic.com/transparency)

Help and security

[Availability](https://www.anthropic.com/supported-countries)[Status](https://status.anthropic.com/)[Support center](https://support.claude.com/)

Learn

[Courses](https://www.anthropic.com/learn)[MCP connectors](https://claude.com/partners/mcp)[Customer stories](https://www.claude.com/customers)[Engineering blog](https://www.anthropic.com/engineering)[Events](https://www.anthropic.com/events)[Powered by Claude](https://claude.com/partners/powered-by-claude)[Service partners](https://claude.com/partners/services)[Startups program](https://claude.com/programs/startups)

Terms and policies

[Privacy policy](https://www.anthropic.com/legal/privacy)[Disclosure policy](https://www.anthropic.com/responsible-disclosure-policy)[Usage policy](https://www.anthropic.com/legal/aup)[Commercial terms](https://www.anthropic.com/legal/commercial-terms)[Consumer terms](https://www.anthropic.com/legal/consumer-terms)

Assistant

Responses are generated using AI and may contain mistakes.