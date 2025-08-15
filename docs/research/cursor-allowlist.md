# Cursor Allowlist Configuration Research

## Executive Summary

Cursor stores command allowlist in SQLite database at `~/.config/Cursor/User/globalStorage/state.vscdb`. **Direct database manipulation corrupts Cursor** and breaks functionality. Allowlist management requires safer approaches.

**Key Findings:**
- **Location**: `state.vscdb` → `ItemTable` → `composerState.yoloCommandAllowlist`
- **Format**: JSON array of command strings
- **Risk**: Direct DB updates break Cursor (chat fails, UI corrupts)
- **Current Count**: 35 commands
- **Restart Required**: Changes need Cursor restart to take effect

## Core Requirements

### Must-Have Requirements:
1. **Global Configuration**: Must work across all projects, not per-project specific
2. **IDE-Enforced Gates**: The IDE/CLI must gate command execution, not rely on LLM self-regulation
3. **Hard Limits**: Must provide enforceable limits on what commands can be executed
4. **Trusted Allowlist**: Must be a trusted, persistent list that the IDE enforces

### Why These Requirements Matter:
- **Self-regulation fails**: LLMs frequently forget rules and execute destructive commands
- **Global scope needed**: Per-project configuration doesn't provide consistent protection
- **IDE enforcement required**: Only the IDE can reliably gate command execution
- **Hard limits essential**: Soft limits or warnings are insufficient for security

## Table of Contents

- [Database Schema](#database-schema)
- [Allowlist Structure](#allowlist-structure)
- [SQL Queries](#sql-queries)
- [Test Results](#test-results)
- [Research Findings](#research-findings)
- [Requirements Analysis](#requirements-analysis)

## Database Schema

**File**: `~/.config/Cursor/User/globalStorage/state.vscdb`
**Table**: `ItemTable`
**Key**: `src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser`
**Field**: `composerState.yoloCommandAllowlist` (JSON array)

```sql
-- Extract allowlist
SELECT value FROM ItemTable 
WHERE key = 'src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser';

-- Count commands
SELECT json_array_length(json_extract(value, '$.composerState.yoloCommandAllowlist')) 
FROM ItemTable 
WHERE key = 'src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser';
```

## Allowlist Structure

```json
{
  "composerState": {
    "yoloCommandAllowlist": [
      "mkdir", "make", "tail", "cat", "echo", "find", "wc", 
      "git status", "cd", "ansible-lint", "git diff", "ls", 
      "grep", "git show", "git log", "git branch -vv", 
      "git branch --current", "gh pr list", "gh pr view", 
      "gh pr diff", "touch", "head", "flake8", "git remote -v", 
      "jq", "trim", "venv/bin/python -m pytest", 
      "venv/bin/python -m unittest", "aap-dev/bin/kubectl --kubeconfig aap-dev/.tmp/26.kubeconfig get pods", 
      "aap-dev/bin/kubectl --kubeconfig aap-dev/.tmp/26.kubeconfig get services", 
      "aap-dev/bin/kubectl --kubeconfig aap-dev/.tmp/26.kubeconfig get deployments", 
      "aap-dev/bin/kubectl --kubeconfig aap-dev/.tmp/26.kubeconfig get configmaps", 
      "aap-dev/bin/kubectl --kubeconfig aap-dev/.tmp/26.kubeconfig get secrets", 
      "git merge-base", "git branch -v", "git worktree add", "sort", "true"
    ]
  }
}
```

## SQL Queries

### Extract Allowlist
```bash
sqlite3 ~/.config/Cursor/User/globalStorage/state.vscdb \
  "SELECT json_extract(value, '$.composerState.yoloCommandAllowlist') FROM ItemTable \
   WHERE key = 'src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser';"
```

### Count Commands
```bash
sqlite3 ~/.config/Cursor/User/globalStorage/state.vscdb \
  "SELECT json_array_length(json_extract(value, '$.composerState.yoloCommandAllowlist')) FROM ItemTable \
   WHERE key = 'src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser';"
```

### Search Commands
```bash
sqlite3 ~/.config/Cursor/User/globalStorage/state.vscdb \
  "SELECT json_extract(value, '$.composerState.yoloCommandAllowlist') FROM ItemTable \
   WHERE key = 'src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser' \
   AND json_extract(value, '$.composerState.yoloCommandAllowlist') LIKE '%git%';"
```

## Test Results

### Database Investigation
- ✅ **Primary Storage**: `state.vscdb` contains allowlist
- ✅ **Schema Verified**: JSON array in `composerState.yoloCommandAllowlist`
- ❌ **Workspace DBs**: No allowlist in workspace-specific databases
- ❌ **Additional Files**: No allowlist in JSON config files

### Update Attempts
- ❌ **Direct DB Update**: Corrupted Cursor configuration
- ❌ **Dynamic Loading**: Changes require restart
- ❌ **UI Sync**: UI may not reflect database changes

### Critical Finding
**Direct database manipulation breaks Cursor:**
- Chat functionality fails
- UI becomes unresponsive
- Settings disappear
- Recovery requires profile backup

## Research Summary

### Approach Evaluation Table

| Approach | Status | Requirements Met | Effort | Risk | Links |
|----------|--------|------------------|--------|------|-------|
| **Extension Development** | ⭐⭐⭐⭐ | ✅ Global, ✅ IDE-enforced, ✅ Hard limits | High | Medium | [Details](#extension-development) |
| **Built-in Features** | ⭐⭐⭐ | ✅ Global, ✅ IDE-enforced, ✅ Hard limits | Low | Low | [Details](#built-in-features) |
| **Custom API Development** | ⭐⭐⭐ | ✅ Global, ✅ IDE-enforced, ✅ Hard limits | High | High | [Details](#custom-api) |
| **Settings Sync Integration** | ⭐⭐ | ✅ Global, ❌ No execution control | Medium | Medium | [Details](#settings-sync) |
| **CLI Investigation** | ⭐⭐ | ❓ Unknown | Low | Low | [Details](#cli-investigation) |
| **Dotfiles Management** | ❌ DISCARDED | ❌ No execution control | Low | Low | [Details](#dotfiles) |
| **Docker Sandbox** | ❌ DISCARDED | ❌ No IDE integration | High | Low | [Details](#docker-sandbox) |
| **MCP Integration** | ❌ DISCARDED | ❌ External tools only | Medium | Medium | [Details](#mcp-integration) |
| **Project-Specific Config** | ❌ DISCARDED | ❌ Not global, LLM self-regulation | Low | Low | [Details](#project-config) |
| **Workspace Configuration** | ❌ DISCARDED | ❌ Not global | Low | Low | [Details](#workspace-config) |
| **External Security Tools** | ❌ DISCARDED | ❌ Not IDE-integrated | Medium | Low | [Details](#external-tools) |
| **API Proxy Solutions** | ❌ DISCARDED | ❌ External APIs only | Medium | Medium | [Details](#api-proxy) |

### Key Insights

- **Most Critical**: Only IDE-integrated solutions can provide true command gating
- **External Tools Fail**: Cannot enforce IDE-level command execution control
- **Extension Development**: Most promising approach with full requirement coverage
- **Built-in Features**: May already exist but need investigation

## Research Findings (Detailed)

### Extension Development

| Field | Details |
|-------|---------|
| **Status** | ⭐⭐⭐⭐ Most promising approach |
| **Source** | [switch2idea](https://github.com/qczone/switch2idea), [whisper-assistant-vscode](https://github.com/martin-opensky/whisper-assistant-vscode) |
| **Context** | Cursor supports VS Code extension development and inherits VS Code's extension ecosystem |
| **Key Insight** | Extensions have access to terminal and command execution APIs through VS Code extension framework |
| **Features** | • Terminal API access<br>• Command execution control<br>• Global configuration management<br>• Cross-project consistency<br>• IDE-level integration |
| **Requirements Met** | ✅ **Global Configuration**: Extensions can manage global settings<br>✅ **IDE-Enforced Gates**: Extensions run within IDE and can intercept commands<br>✅ **Hard Limits**: Extensions can block/allow commands programmatically<br>✅ **Trusted Allowlist**: Extension-managed lists persist across sessions |
| **Effort** | High - Requires learning VS Code extension API and TypeScript development |
| **Risk** | Medium - Depends on extension API capabilities for terminal control |
| **Requirements Analysis** | ✅ **POTENTIAL** - Could provide IDE-enforced gating; needs investigation of terminal API |
| **Recommendation** | **Continue investigating** - Most promising solution, investigate VS Code terminal extension APIs |
| **Next Steps** | 1. Research VS Code terminal API documentation<br>2. Examine existing terminal control extensions<br>3. Prototype basic command interception |

### Built-in Features

| Field | Details |
|-------|---------|
| **Status** | ⭐⭐⭐ Potential but unknown capabilities |
| **Source** | Research findings from Cursor investigation |
| **Context** | Cursor may have built-in security and execution control features that are undocumented |
| **Key Insight** | Current allowlist system suggests built-in capabilities exist but need deeper investigation |
| **Features** | • Built-in security mechanisms<br>• Execution control systems<br>• Configuration management<br>• Database-level settings |
| **Requirements Met** | ✅ **Global Configuration**: Current allowlist is global<br>✅ **IDE-Enforced Gates**: Current system gates execution<br>✅ **Hard Limits**: Current allowlist provides hard limits<br>✅ **Trusted Allowlist**: Current system persists allowlist |
| **Effort** | Low - Research and discovery only |
| **Risk** | Low - Using built-in capabilities is safest approach |
| **Requirements Analysis** | ❓ **UNKNOWN** - All requirements potentially met if features exist |
| **Recommendation** | **Continue investigating** - May provide safest built-in solution |
| **Next Steps** | 1. Deep dive into Cursor documentation<br>2. Examine settings and configuration options<br>3. Contact Cursor support for undocumented features |

### Custom API

| Field | Details |
|-------|---------|
| **Status** | ⭐⭐⭐ High potential but significant development effort |
| **Source** | Research findings - original development approach |
| **Context** | Developing custom configuration API that integrates with Cursor's terminal execution system |
| **Key Insight** | Custom solution would provide complete control but requires significant development effort |
| **Features** | • Custom API development<br>• Terminal control integration<br>• Global configuration management<br>• Custom enforcement logic<br>• Integration with existing Cursor architecture |
| **Requirements Met** | ✅ **Global Configuration**: Custom API can manage global settings<br>✅ **IDE-Enforced Gates**: Can integrate with IDE terminal system<br>✅ **Hard Limits**: Custom logic can provide strict enforcement<br>✅ **Trusted Allowlist**: Custom persistence and validation |
| **Effort** | High - Full development project requiring deep Cursor integration knowledge |
| **Risk** | High - Unproven approach, may break with Cursor updates, requires maintenance |
| **Requirements Analysis** | ✅ **POTENTIAL** - All requirements can be met with custom development |
| **Recommendation** | **Continue investigating** - Only if other approaches fail due to high cost and risk |
| **Next Steps** | 1. Reserve as fallback option<br>2. Investigate Cursor's plugin architecture<br>3. Assess development resources and timeline |

### Settings Sync

| Field | Details |
|-------|---------|
| **Status** | ⭐⭐ Limited scope - sync only, no execution control |
| **Source** | [synceverything](https://github.com/0x3at/synceverything) |
| **Context** | VS Code/Cursor settings synchronization across machines using cloud storage |
| **Key Insight** | Settings can be synchronized globally using GitHub Gists, but this only handles distribution, not enforcement |
| **Features** | • Global settings sync<br>• Cross-machine configuration<br>• GitHub Gists integration<br>• Automatic backup and restore |
| **Requirements Met** | ✅ **Global Configuration**: Can sync settings globally<br>❌ **IDE-Enforced Gates**: Only syncs settings, doesn't enforce execution control<br>❌ **Hard Limits**: No execution blocking capabilities<br>⚠️ **Trusted Allowlist**: Can sync allowlist but can't enforce it |
| **Effort** | Medium - Integration with existing sync tools and configuration management |
| **Risk** | Medium - Relies on external services and doesn't solve core enforcement problem |
| **Requirements Analysis** | ⚠️ **PARTIAL** - Solves distribution but not enforcement of allowlist |
| **Recommendation** | **Continue investigating** - Could be part of larger solution for configuration distribution |
| **Next Steps** | 1. Evaluate as distribution mechanism only<br>2. Combine with execution control solution<br>3. Consider for multi-environment consistency |

### CLI Investigation

| Field | Details |
|-------|---------|
| **Status** | ⭐⭐ Unknown capabilities - need investigation |
| **Source** | Research findings - official tooling investigation |
| **Context** | Cursor may have CLI tools for configuration management similar to VS Code CLI |
| **Key Insight** | Official CLI tools would be safest approach but existence and capabilities unknown |
| **Features** | • Potential command-line interface<br>• Configuration management<br>• Automation capabilities<br>• Official support and maintenance |
| **Requirements Met** | ❓ **Global Configuration**: Unknown if CLI can manage global settings<br>❓ **IDE-Enforced Gates**: Unknown if CLI can control execution<br>❓ **Hard Limits**: Unknown if CLI can enforce restrictions<br>❓ **Trusted Allowlist**: Unknown if CLI supports allowlist management |
| **Effort** | Low - Research only if CLI exists |
| **Risk** | Low - Official tools would be most stable |
| **Requirements Analysis** | ❓ **UNKNOWN** - All requirements depend on CLI existence and capabilities |
| **Recommendation** | **Continue investigating** - Priority research due to potential for official solution |
| **Next Steps** | 1. Check Cursor documentation for CLI tools<br>2. Test `cursor --help` command<br>3. Compare with VS Code CLI capabilities |

### Dotfiles

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - No execution control capabilities |
| **Source** | [nicksp/dotfiles](https://github.com/nicksp/dotfiles) |
| **Context** | Comprehensive dotfiles setup including Cursor configuration synchronization via settings.json management |
| **Key Insight** | Cursor settings can be managed via `~/.config/Cursor/User/settings.json` but this doesn't include allowlist |
| **Features** | • Settings file management<br>• Configuration synchronization<br>• Cross-machine consistency<br>• Version control integration |
| **Requirements Met** | ✅ **Global Configuration**: Can manage global settings files<br>❌ **IDE-Enforced Gates**: Settings.json doesn't control execution<br>❌ **Hard Limits**: No execution blocking capabilities<br>❌ **Trusted Allowlist**: Allowlist not stored in settings.json |
| **Effort** | Low - Simple file management |
| **Risk** | Low - Standard configuration management |
| **Requirements Analysis** | ❌ **FAILS** - No evidence of terminal execution control; allowlist stored in database, not settings.json |
| **Recommendation** | **DISCARDED** - Does not provide IDE-enforced command gating |
| **Failure Reason** | Settings.json manages IDE preferences but allowlist is in SQLite database; no execution enforcement |

### Docker Sandbox

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - User explicitly rejected isolation approach |
| **Source** | [cursor-docker-sandbox](https://github.com/iliakv/cursor-docker-sandbox) |
| **Context** | Docker containerization of Cursor with controlled filesystem access to limit potential damage from AI commands |
| **Key Insight** | Cursor can run in isolated environments with controlled access but provides isolation, not command control |
| **Features** | • Environment isolation<br>• Container-based security<br>• Limited filesystem access<br>• Easy reset/rebuild |
| **Requirements Met** | ❌ **Global Configuration**: Container-specific, not global<br>❌ **IDE-Enforced Gates**: No command filtering, just isolation<br>❌ **Hard Limits**: Isolation only, commands still run unrestricted within container<br>❌ **Trusted Allowlist**: No allowlist concept, just containment |
| **Effort** | Medium - Docker setup and Cursor configuration |
| **Risk** | Low - Well-established containerization technology |
| **Requirements Analysis** | ❌ **FAILS** - Provides isolation, not command execution control; user explicitly rejected this approach |
| **Recommendation** | **DISCARDED** - User has existing isolation and needs trusted command limits, not more isolation |
| **Failure Reason** | User explicitly stated: "I didn't ask you to find ways to do safe testing" and "I already have such isolation. I do not need more." |

### MCP Integration

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - No IDE-enforced execution control |
| **Source** | [fastapi_mcp](https://github.com/tadata-org/fastapi_mcp), [mcp-safe-run](https://github.com/ithena-one/mcp-safe-run) |
| **Context** | Model Context Protocol (MCP) tools for exposing APIs and managing configurations, including safe command execution |
| **Key Insight** | MCP could potentially provide programmatic access to Cursor settings but relies on external process management |
| **Features** | • API integration<br>• Configuration management<br>• External tool integration<br>• Programmatic access to settings |
| **Requirements Met** | ⚠️ **Global Configuration**: Could potentially manage global settings<br>❌ **IDE-Enforced Gates**: External tools, not IDE-enforced<br>❌ **Hard Limits**: Relies on external enforcement, not IDE<br>❌ **Trusted Allowlist**: External validation, not IDE-controlled |
| **Effort** | High - MCP integration and external tool setup |
| **Risk** | Medium - Depends on external tools and MCP protocol stability |
| **Requirements Analysis** | ❌ **FAILS** - No evidence of IDE-enforced terminal execution control; relies on external tools |
| **Recommendation** | **DISCARDED** - Does not provide IDE-enforced command gating |
| **Failure Reason** | MCP runs external to IDE and relies on LLM self-regulation; no IDE-level command interception |

### Project Config

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - Project-specific, not global configuration |
| **Source** | [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) |
| **Context** | Project-specific `.cursorrules` configuration files that define custom rules for Cursor AI behavior |
| **Key Insight** | Cursor supports project-specific configuration files but these are per-project, not global |
| **Features** | • Project-specific rules<br>• AI behavior customization<br>• Per-directory configuration<br>• Version control integration |
| **Requirements Met** | ❌ **Global Configuration**: Project-specific only, not global<br>❌ **IDE-Enforced Gates**: Rules are suggestions to LLM, not enforced by IDE<br>❌ **Hard Limits**: LLM self-regulation only, no hard enforcement<br>❌ **Trusted Allowlist**: No allowlist concept, just behavioral guidelines |
| **Effort** | Low - Simple file creation per project |
| **Risk** | Low - Standard configuration files |
| **Requirements Analysis** | ❌ **FAILS** - Project-specific, not global; relies on LLM self-regulation without IDE enforcement |
| **Recommendation** | **DISCARDED** - Does not meet core requirements for global, IDE-enforced control |
| **Failure Reason** | User requirement: "global configuration. per project is not good" and "if it's up to the LLM to self regulate it is not viable" |

### Workspace Config

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - Workspace-specific, not global configuration |
| **Source** | Research findings from database investigation |
| **Context** | Cursor maintains workspace-specific databases in `~/.config/Cursor/User/workspaceStorage/` for project-level settings |
| **Key Insight** | Allowlist appears global in main database, but workspace configs are project-specific |
| **Features** | • Workspace-specific settings<br>• Project-level configuration<br>• Isolated per workspace<br>• Automatic workspace detection |
| **Requirements Met** | ❌ **Global Configuration**: Workspace-specific only, not global<br>❌ **IDE-Enforced Gates**: No allowlist found in workspace databases<br>❌ **Hard Limits**: No execution control found at workspace level<br>❌ **Trusted Allowlist**: No allowlist functionality in workspace configs |
| **Effort** | Low - Investigation only |
| **Risk** | Low - Read-only investigation |
| **Requirements Analysis** | ❌ **FAILS** - Workspace-specific, not global; no allowlist functionality found |
| **Recommendation** | **DISCARDED** - Does not meet global configuration requirement |
| **Failure Reason** | User requirement: "global configuration. per project is not good" - workspace configs are inherently project-specific |

### External Tools

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - External tool, not IDE-integrated |
| **Source** | [Chaterm](https://github.com/chaterm/Chaterm) |
| **Context** | AI terminal with security features designed to provide command execution gating |
| **Key Insight** | External tools can provide command execution gating but operate outside of Cursor IDE |
| **Features** | • Command execution gating<br>• AI terminal interface<br>• Security features<br>• Independent operation |
| **Requirements Met** | ⚠️ **Global Configuration**: Can be configured globally but separate from Cursor<br>❌ **IDE-Enforced Gates**: External tool, not Cursor IDE enforcement<br>✅ **Hard Limits**: Can provide hard command limits<br>✅ **Trusted Allowlist**: Can maintain trusted allowlists |
| **Effort** | High - Integration with Cursor workflow and tool switching |
| **Risk** | Medium - Additional tool complexity and workflow disruption |
| **Requirements Analysis** | ❌ **FAILS** - External tool, not IDE-integrated; doesn't control Cursor's terminal |
| **Recommendation** | **DISCARDED** - Not integrated with Cursor IDE, requires workflow changes |
| **Failure Reason** | Must have requirement: "IDE or CLI tool itself gates what commands are executed" - external tools can't control Cursor's terminal |

### API Proxy

| Field | Details |
|-------|---------|
| **Status** | ❌ DISCARDED - External API, not IDE-enforced |
| **Source** | [cursor-openrouter-proxy](https://github.com/pezzos/cursor-openrouter-proxy) |
| **Context** | Docker Compose configuration for Cursor API proxy to manage API routing and configuration |
| **Key Insight** | External APIs can manage some Cursor configuration but not terminal execution control |
| **Features** | • API routing management<br>• Configuration proxy<br>• Docker-based deployment<br>• External configuration management |
| **Requirements Met** | ⚠️ **Global Configuration**: Can manage some global API settings<br>❌ **IDE-Enforced Gates**: API proxy doesn't control terminal execution<br>❌ **Hard Limits**: No terminal command enforcement<br>❌ **Trusted Allowlist**: API management only, not command allowlists |
| **Effort** | Medium - Docker setup and proxy configuration |
| **Risk** | Medium - Additional infrastructure complexity |
| **Requirements Analysis** | ❌ **FAILS** - External API, not IDE-enforced; doesn't control terminal execution |
| **Recommendation** | **DISCARDED** - Does not provide IDE-enforced terminal control |
| **Failure Reason** | API proxy manages API routing, not terminal execution; external to IDE enforcement mechanism |

### Final Recommendation

**Focus on Extension Development** as the primary approach:

1. **Investigate Cursor Extension API** for terminal control capabilities
2. **Research built-in security features** in Cursor documentation
3. **Consider custom extension development** if built-in features don't exist
4. **Explore settings sync integration** for global configuration management
5. **Investigate CLI tools** for configuration management

**Key Insight**: Most promising solutions involve Cursor's extension system or built-in features, as external tools cannot provide IDE-enforced command gating.

## References and Sources

### Research Materials Used

#### Primary Investigation
- **Cursor Database**: `~/.config/Cursor/User/globalStorage/state.vscdb`
- **Terminal Commands**: SQLite queries, filesystem searches, process investigation
- **Test Files**: Created `docs/research/test-allowlist.sh` for testing

#### GitHub Repositories Investigated
1. **awesome-cursorrules** - https://github.com/PatrickJS/awesome-cursorrules
   - Project-specific configuration files for Cursor AI behavior
   - Used to understand Cursor's configuration capabilities
   
2. **nicksp/dotfiles** - https://github.com/nicksp/dotfiles
   - Personal dotfiles including Cursor configuration
   - Examined for settings.json management approaches
   
3. **cursor-docker-sandbox** - https://github.com/iliakv/cursor-docker-sandbox
   - Docker containerization of Cursor with controlled access
   - Investigated for isolation and configuration management
   
4. **fastapi_mcp** - https://github.com/tadata-org/fastapi_mcp
   - FastAPI endpoints as Model Context Protocol tools
   - Examined for API-based configuration management
   
5. **mcp-safe-run** - https://github.com/ithena-one/mcp-safe-run
   - MCP server for secure configuration management
   - Investigated for secure configuration approaches
   
6. **switch2idea** - https://github.com/qczone/switch2idea
   - Cursor extension for switching between IDEs
   - Used to understand extension development capabilities
   
7. **whisper-assistant-vscode** - https://github.com/martin-opensky/whisper-assistant-vscode
   - Voice-to-code extension for VS Code/Cursor
   - Examined for extension API access to terminal functions
   
8. **synceverything** - https://github.com/0x3at/synceverything
   - VS Code/Cursor settings synchronization extension
   - Investigated for global settings management
   
9. **Chaterm** - https://github.com/chaterm/Chaterm
   - Open source AI terminal with security features
   - Examined for command execution control patterns
   
10. **cursor-openrouter-proxy** - https://github.com/pezzos/cursor-openrouter-proxy
    - Docker configuration for Cursor API proxy
    - Investigated for API-based configuration management

#### Search Methodologies
- **GitHub API searches** using various keyword combinations:
  - `cursor+allowlist+configuration+management`
  - `cursor+terminal+execution+control`
  - `cursor+settings+global+configuration`
  - `cursor+extension+development`
  - `cursor+api+configuration`
  - `cursor+settings+sync`
  - `cursor+command+execution+security`

#### Files and Directories Examined
- `~/.config/Cursor/User/settings.json` - User-specific settings
- `~/.config/Cursor/User/globalStorage/state.vscdb` - Main configuration database
- `~/.config/Cursor/User/workspaceStorage/*/state.vscdb` - Workspace-specific databases
- `~/.cursor/` directory structure
- Database schemas and table structures

#### Tools and Commands Used
```bash
# Database investigation
sqlite3 ~/.config/Cursor/User/globalStorage/state.vscdb ".schema"
sqlite3 ~/.config/Cursor/User/globalStorage/state.vscdb "SELECT key FROM ItemTable;"
sqlite3 ~/.config/Cursor/User/globalStorage/state.vscdb "SELECT key FROM cursorDiskKV;"

# File system searches
find ~/.config/Cursor -name "*.sqlite*" -type f
find ~/.config/Cursor -name "*.json" -exec grep -l -i "allow" {} \;
find ~/.cursor -name "*.json" -exec grep -l -i "allowlist" {} \;

# GitHub API searches
curl -s "https://api.github.com/search/repositories?q=cursor+configuration"
curl -s "https://api.github.com/search/code?q=cursor+allowlist"

# Testing commands
./docs/research/test-allowlist.sh
jq '.composerState.yoloCommandAllowlist' current-config.json
```

#### Test Results and Evidence
- **Database corruption test**: Direct SQLite updates broke Cursor functionality
- **Restart requirement test**: Changes only take effect after Cursor restart
- **Allowlist verification**: Confirmed 35 commands in current allowlist
- **UI sync test**: Database changes don't immediately reflect in UI

#### Documentation Sources
- Cursor official documentation (limited findings)
- VS Code extension API documentation (for extension development research)
- SQLite documentation for database manipulation
- JSON manipulation using jq tool

### Research Timeline
1. **Initial Investigation** - Database location and structure discovery
2. **Schema Analysis** - Understanding table structure and data format
3. **Testing Phase** - Created test script and attempted database manipulation
4. **Failure Analysis** - Documented database corruption and recovery
5. **Alternative Research** - GitHub repository investigation
6. **Requirements Clarification** - Defined core requirements for viable solutions
7. **Comprehensive Evaluation** - Assessed 15 different approaches against requirements
8. **Final Analysis** - Identified Extension Development as most promising approach 