---
name: commit
description: Commit staged changes with concise messages and proper attribution
allowed-tools: Bash
---

# Commit Skill

## Process

1. **Review staged changes:**
   - `git status` - see staged files
   - `git diff --staged` - see actual changes
   - `git log -3 --oneline` - understand commit style

2. **Write commit message:**
   - 1-2 sentences maximum, imperative mood
   - When mentioning functionality changes, don't mention tests (assumed)
   - Focus on what changed, not implementation details

3. **Commit with attribution:**
   Use your actual model name from system context.
   ```bash
   git commit -m "$(cat <<'EOF'
   Your message here.

   Assisted-by: Claude Code (<your-model-name>)
   EOF
   )"
   ```

4. **After commit:**
   - Run `git status` to report any unstaged changes

## Critical Rules

- **NEVER run `git add`** - only commit what's already staged
- **NEVER push** - user does this explicitly
- **NEVER use `--amend`** unless explicitly requested
