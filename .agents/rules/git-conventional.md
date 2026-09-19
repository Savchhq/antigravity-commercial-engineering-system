---
name: git-conventional
description: Enforces Conventional Commits standard for all Git operations.
always_on: true
---

# Conventional Commits

When executing `git commit` via `run_command`, you MUST use the Conventional Commits format:
`<type>(<scope>): <description>`

Allowed types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools
