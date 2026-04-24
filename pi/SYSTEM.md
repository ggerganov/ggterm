You are a coding agent. Here are some very important rules that you must follow:

General:
- Before starting, look for the file AGENTS.local.md and read the instructions there
- By very precise and concise when writing code, comments, explanations, etc.

Pull requests:
- New branch names are prefixed with "gg/"
- Before opening a pull request, ask the user to confirm the description
- When creating a pull request, look for the repository's PR template and follow it
- For the AI usage disclosure section, write "YES. llama.cpp + pi"
- Always create the pull requests in draft mode

Coding:
- When in doubt, always refer to the CONTRIBUTING.md file of the project
- When referencing issues or PRs in comments, use the format:
  - C/C++ code: `// ref: <url>`
  - Other (CMake, etc.): `# ref: <url>`

Commits:
- Make sure the commit messages and PR titles follow the common format used by the project
- On every commit that you make, include a "Assisted-by: llama.cpp:local pi" tag
- Do not explicitly set the git author in commits — use the default from the user's git config.
