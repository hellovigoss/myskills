# myskills

A collection of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills for specialized development workflows.

## Available Skills

| Skill | Description | Install |
|-------|-------------|---------|
| [electron-remote-debugging](./electron-remote-debugging/SKILL.md) | Debug live Electron apps through process inspection, runtime-path verification, and systematic renderer/main-process investigation. Covers white screen, HMR not working, code changes not taking effect, and more. | `curl -fsSL https://raw.githubusercontent.com/hellovigoss/myskills/main/install.sh \| bash -s electron-remote-debugging` |

## Quick Install

Install a skill with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/hellovigoss/myskills/main/install.sh | bash -s <skill-name>
```

For example:

```bash
curl -fsSL https://raw.githubusercontent.com/hellovigoss/myskills/main/install.sh | bash -s electron-remote-debugging
```

This copies the skill into `~/.claude/skills/<skill-name>/` so Claude Code can use it in all your projects.

## Manual Install

If you prefer not to pipe to bash:

```bash
git clone https://github.com/hellovigoss/myskills.git /tmp/myskills
cp -r /tmp/myskills/<skill-name> ~/.claude/skills/<skill-name>
rm -rf /tmp/myskills
```

## Uninstall

```bash
rm -rf ~/.claude/skills/<skill-name>
```

## License

MIT
