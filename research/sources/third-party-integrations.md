---
url: https://code.claude.com/docs/en/third-party-integrations
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/third-party-integrations/docs/en/overview)

![US](https://d3gk2c5xim1je2.cloudfront.net/flags/US.svg)

English

Search...

⌘KAsk AI

* [Claude Developer Platform](https://platform.claude.com/)
* [Claude Code on the Web](https://claude.ai/code)
* [Claude Code on the Web](https://claude.ai/code)

Search...

Navigation

Deployment

Enterprise deployment overview

[Getting started](https://code.claude.com/docs/en/third-party-integrations/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/third-party-integrations/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/third-party-integrations/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/third-party-integrations/docs/en/setup)[Configuration](https://code.claude.com/docs/en/third-party-integrations/docs/en/settings)[Reference](https://code.claude.com/docs/en/third-party-integrations/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/third-party-integrations/docs/en/legal-and-compliance)

##### Deployment

* [Overview](https://code.claude.com/docs/en/third-party-integrations/docs/en/third-party-integrations)
* [Amazon Bedrock](https://code.claude.com/docs/en/third-party-integrations/docs/en/amazon-bedrock)
* [Google Vertex AI](https://code.claude.com/docs/en/third-party-integrations/docs/en/google-vertex-ai)
* [Microsoft Foundry](https://code.claude.com/docs/en/third-party-integrations/docs/en/microsoft-foundry)
* [Network configuration](https://code.claude.com/docs/en/third-party-integrations/docs/en/network-config)
* [LLM gateway](https://code.claude.com/docs/en/third-party-integrations/docs/en/llm-gateway)
* [Development containers](https://code.claude.com/docs/en/third-party-integrations/docs/en/devcontainer)

On this page

* [Compare deployment options](#compare-deployment-options)
* [Configure proxies and gateways](#configure-proxies-and-gateways)
* [Amazon Bedrock](#amazon-bedrock)
* [Microsoft Foundry](#microsoft-foundry)
* [Google Vertex AI](#google-vertex-ai)
* [Best practices for organizations](#best-practices-for-organizations)
* [Invest in documentation and memory](#invest-in-documentation-and-memory)
* [Simplify deployment](#simplify-deployment)
* [Start with guided usage](#start-with-guided-usage)
* [Pin model versions for cloud providers](#pin-model-versions-for-cloud-providers)
* [Configure security policies](#configure-security-policies)
* [Leverage MCP for integrations](#leverage-mcp-for-integrations)
* [Next steps](#next-steps)

Deployment

# Enterprise deployment overview

Copy page

Learn how Claude Code can integrate with various third-party services and infrastructure to meet enterprise deployment requirements.

Copy page

Organizations can deploy Claude Code through Anthropic directly or through a cloud provider. This page helps you choose the right configuration. 

## 

[​](#compare-deployment-options)

Compare deployment options

For most organizations, Claude for Teams or Claude for Enterprise provides the best experience. Team members get access to both Claude Code and Claude on the web with a single subscription, centralized billing, and no infrastructure setup required. **Claude for Teams** is self-service and includes collaboration features, admin tools, and billing management. Best for smaller teams that need to get started quickly. **Claude for Enterprise** adds SSO and domain capture, role-based permissions, compliance API access, and managed policy settings for deploying organization-wide Claude Code configurations. Best for larger organizations with security and compliance requirements. Learn more about [Team plans](https://support.claude.com/en/articles/9266767-what-is-the-team-plan) and [Enterprise plans](https://support.claude.com/en/articles/9797531-what-is-the-enterprise-plan). If your organization has specific infrastructure requirements, compare the options below: 

| Feature                | Claude for Teams/Enterprise                                                                                                                                                                               | Anthropic Console                                                    | Amazon Bedrock                                                                                   | Google Vertex AI                                                                              | Microsoft Foundry                                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Best for               | Most organizations (recommended)                                                                                                                                                                          | Individual developers                                                | AWS-native deployments                                                                           | GCP-native deployments                                                                        | Azure-native deployments                                                                                      |
| Billing                | **Teams:** $150/seat (Premium) with PAYG available**Enterprise:** [Contact Sales](https://claude.com/contact-sales?utm%5Fsource=claude%5Fcode&utm%5Fmedium=docs&utm%5Fcontent=third%5Fparty%5Fenterprise) | PAYG                                                                 | PAYG through AWS                                                                                 | PAYG through GCP                                                                              | PAYG through Azure                                                                                            |
| Regions                | Supported [countries](https://www.anthropic.com/supported-countries)                                                                                                                                      | Supported [countries](https://www.anthropic.com/supported-countries) | Multiple AWS [regions](https://docs.aws.amazon.com/bedrock/latest/userguide/models-regions.html) | Multiple GCP [regions](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/locations) | Multiple Azure [regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/) |
| Prompt caching         | Enabled by default                                                                                                                                                                                        | Enabled by default                                                   | Enabled by default                                                                               | Enabled by default                                                                            | Enabled by default                                                                                            |
| Authentication         | Claude.ai SSO or email                                                                                                                                                                                    | API key                                                              | API key or AWS credentials                                                                       | GCP credentials                                                                               | API key or Microsoft Entra ID                                                                                 |
| Cost tracking          | Usage dashboard                                                                                                                                                                                           | Usage dashboard                                                      | AWS Cost Explorer                                                                                | GCP Billing                                                                                   | Azure Cost Management                                                                                         |
| Includes Claude on web | Yes                                                                                                                                                                                                       | No                                                                   | No                                                                                               | No                                                                                            | No                                                                                                            |
| Enterprise features    | Team management, SSO, usage monitoring                                                                                                                                                                    | None                                                                 | IAM policies, CloudTrail                                                                         | IAM roles, Cloud Audit Logs                                                                   | RBAC policies, Azure Monitor                                                                                  |

Select a deployment option to view setup instructions: 
* [Claude for Teams or Enterprise](https://code.claude.com/docs/en/third-party-integrations/docs/en/authentication#claude-for-teams-or-enterprise)
* [Anthropic Console](https://code.claude.com/docs/en/third-party-integrations/docs/en/authentication#claude-console-authentication)
* [Amazon Bedrock](https://code.claude.com/docs/en/third-party-integrations/docs/en/amazon-bedrock)
* [Google Vertex AI](https://code.claude.com/docs/en/third-party-integrations/docs/en/google-vertex-ai)
* [Microsoft Foundry](https://code.claude.com/docs/en/third-party-integrations/docs/en/microsoft-foundry)

## 

[​](#configure-proxies-and-gateways)

Configure proxies and gateways

Most organizations can use a cloud provider directly without additional configuration. However, you may need to configure a corporate proxy or LLM gateway if your organization has specific network or management requirements. These are different configurations that can be used together: 
* **Corporate proxy**: Routes traffic through an HTTP/HTTPS proxy. Use this if your organization requires all outbound traffic to pass through a proxy server for security monitoring, compliance, or network policy enforcement. Configure with the `HTTPS_PROXY` or `HTTP_PROXY` environment variables. Learn more in [Enterprise network configuration](https://code.claude.com/docs/en/third-party-integrations/docs/en/network-config).
* **LLM Gateway**: A service that sits between Claude Code and the cloud provider to handle authentication and routing. Use this if you need centralized usage tracking across teams, custom rate limiting or budgets, or centralized authentication management. Configure with the `ANTHROPIC_BASE_URL`, `ANTHROPIC_BEDROCK_BASE_URL`, or `ANTHROPIC_VERTEX_BASE_URL` environment variables. Learn more in [LLM gateway configuration](https://code.claude.com/docs/en/third-party-integrations/docs/en/llm-gateway).
The following examples show the environment variables to set in your shell or shell profile (`.bashrc`, `.zshrc`). See [Settings](https://code.claude.com/docs/en/third-party-integrations/docs/en/settings) for other configuration methods. 

### 

[​](#amazon-bedrock)

Amazon Bedrock

* Corporate proxy
* LLM Gateway

Route Bedrock traffic through your corporate proxy by setting the following [environment variables](https://code.claude.com/docs/en/third-party-integrations/docs/en/env-vars):

Report incorrect code

Copy

Ask AI

```
# Enable Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# Configure corporate proxy
export HTTPS_PROXY='https://proxy.example.com:8080'

```

Route Bedrock traffic through your LLM gateway by setting the following [environment variables](https://code.claude.com/docs/en/third-party-integrations/docs/en/env-vars):

Report incorrect code

Copy

Ask AI

```
# Enable Bedrock
export CLAUDE_CODE_USE_BEDROCK=1

# Configure LLM gateway
export ANTHROPIC_BEDROCK_BASE_URL='https://your-llm-gateway.com/bedrock'
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1  # If gateway handles AWS auth

```

### 

[​](#microsoft-foundry)

Microsoft Foundry

* Corporate proxy
* LLM Gateway

Route Foundry traffic through your corporate proxy by setting the following [environment variables](https://code.claude.com/docs/en/third-party-integrations/docs/en/env-vars):

Report incorrect code

Copy

Ask AI

```
# Enable Microsoft Foundry
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource
export ANTHROPIC_FOUNDRY_API_KEY=your-api-key  # Or omit for Entra ID auth

# Configure corporate proxy
export HTTPS_PROXY='https://proxy.example.com:8080'

```

Route Foundry traffic through your LLM gateway by setting the following [environment variables](https://code.claude.com/docs/en/third-party-integrations/docs/en/env-vars):

Report incorrect code

Copy

Ask AI

```
# Enable Microsoft Foundry
export CLAUDE_CODE_USE_FOUNDRY=1

# Configure LLM gateway
export ANTHROPIC_FOUNDRY_BASE_URL='https://your-llm-gateway.com'
export CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1  # If gateway handles Azure auth

```

### 

[​](#google-vertex-ai)

Google Vertex AI

* Corporate proxy
* LLM Gateway

Route Vertex AI traffic through your corporate proxy by setting the following [environment variables](https://code.claude.com/docs/en/third-party-integrations/docs/en/env-vars):

Report incorrect code

Copy

Ask AI

```
# Enable Vertex
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=your-project-id

# Configure corporate proxy
export HTTPS_PROXY='https://proxy.example.com:8080'

```

Route Vertex AI traffic through your LLM gateway by setting the following [environment variables](https://code.claude.com/docs/en/third-party-integrations/docs/en/env-vars):

Report incorrect code

Copy

Ask AI

```
# Enable Vertex
export CLAUDE_CODE_USE_VERTEX=1

# Configure LLM gateway
export ANTHROPIC_VERTEX_BASE_URL='https://your-llm-gateway.com/vertex'
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1  # If gateway handles GCP auth

```

Use `/status` in Claude Code to verify your proxy and gateway configuration is applied correctly.

## 

[​](#best-practices-for-organizations)

Best practices for organizations

### 

[​](#invest-in-documentation-and-memory)

Invest in documentation and memory

We strongly recommend investing in documentation so that Claude Code understands your codebase. Organizations can deploy CLAUDE.md files at multiple levels: 
* **Organization-wide**: Deploy to system directories like `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) for company-wide standards
* **Repository-level**: Create `CLAUDE.md` files in repository roots containing project architecture, build commands, and contribution guidelines. Check these into source control so all users benefit
Learn more in [Memory and CLAUDE.md files](https://code.claude.com/docs/en/third-party-integrations/docs/en/memory). 

### 

[​](#simplify-deployment)

Simplify deployment

If you have a custom development environment, we find that creating a “one click” way to install Claude Code is key to growing adoption across an organization. 

### 

[​](#start-with-guided-usage)

Start with guided usage

Encourage new users to try Claude Code for codebase Q&A, or on smaller bug fixes or feature requests. Ask Claude Code to make a plan. Check Claude’s suggestions and give feedback if it’s off-track. Over time, as users understand this new paradigm better, then they’ll be more effective at letting Claude Code run more agentically. 

### 

[​](#pin-model-versions-for-cloud-providers)

Pin model versions for cloud providers

If you deploy through [Bedrock](https://code.claude.com/docs/en/third-party-integrations/docs/en/amazon-bedrock), [Vertex AI](https://code.claude.com/docs/en/third-party-integrations/docs/en/google-vertex-ai), or [Foundry](https://code.claude.com/docs/en/third-party-integrations/docs/en/microsoft-foundry), pin specific model versions using `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, and `ANTHROPIC_DEFAULT_HAIKU_MODEL`. Without pinning, Claude Code aliases resolve to the latest version, which can break users when Anthropic releases a new model that isn’t yet enabled in your account. See [Model configuration](https://code.claude.com/docs/en/third-party-integrations/docs/en/model-config#pin-models-for-third-party-deployments) for details. 

### 

[​](#configure-security-policies)

Configure security policies

Security teams can configure managed permissions for what Claude Code is and is not allowed to do, which cannot be overwritten by local configuration. [Learn more](https://code.claude.com/docs/en/third-party-integrations/docs/en/security). 

### 

[​](#leverage-mcp-for-integrations)

Leverage MCP for integrations

MCP is a great way to give Claude Code more information, such as connecting to ticket management systems or error logs. We recommend that one central team configures MCP servers and checks a `.mcp.json` configuration into the codebase so that all users benefit. [Learn more](https://code.claude.com/docs/en/third-party-integrations/docs/en/mcp). At Anthropic, we trust Claude Code to power development across every Anthropic codebase. We hope you enjoy using Claude Code as much as we do. 

## 

[​](#next-steps)

Next steps

Once you’ve chosen a deployment option and configured access for your team: 
1. **Roll out to your team**: Share installation instructions and have team members [install Claude Code](https://code.claude.com/docs/en/third-party-integrations/docs/en/setup) and authenticate with their credentials.
2. **Set up shared configuration**: Create a [CLAUDE.md file](https://code.claude.com/docs/en/third-party-integrations/docs/en/memory) in your repositories to help Claude Code understand your codebase and coding standards.
3. **Configure permissions**: Review [security settings](https://code.claude.com/docs/en/third-party-integrations/docs/en/security) to define what Claude Code can and cannot do in your environment.

Was this page helpful?

YesNo

[Amazon Bedrock](https://code.claude.com/docs/en/third-party-integrations/docs/en/amazon-bedrock)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/third-party-integrations/docs/en/overview)

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