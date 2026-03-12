---
name: electron-remote-debugging
description: Debug live Electron apps through process inspection, runtime-path verification, and systematic renderer/main-process investigation. Use this whenever the user asks to remote debug an Electron app, mentions Electron white screen/blank page/runtime crash/HMR not taking effect, wants inspection of the actual running app instead of static code review, or suspects the edited code is not the code being loaded.
---

# Electron Remote Debugging

Use this skill when the problem is in the running Electron app, not just in source code on disk.

## Goals

- Find the root cause of live Electron failures
- Debug the actual loaded app, not the assumed repo copy
- Separate renderer, main-process, preload, IPC, gateway, and dev-server issues
- Prevent guess-fixes by gathering runtime evidence first

## Core rule

Do not propose or apply fixes until you know which running process, port, and source tree the app is actually using.

In Electron projects, a surprising amount of wasted effort comes from editing the wrong checkout, wrong worktree, wrong build output, or wrong process.

## When to use

Trigger on requests like:
- "remote debug 一下我的 electron 应用"
- "Electron 安装完首页白屏"
- "控制台报错，但前台是空白"
- "npm run dev 下改了代码没效果"
- "帮我看实际运行的 renderer / main 进程"
- "HMR 没生效"
- "想调试 live app，不要只看代码"

## Workflow

### 1. Lock onto the real runtime

First establish the actual runtime target before reading lots of code.

Gather:
- how the app is started (`npm run dev`, packaged app, custom script)
- current working directory of the running app if discoverable
- Electron process command line
- Vite/Webpack/dev-server process command line if present
- listening ports used by renderer/dev server/backend/gateway
- whether a worktree, original repo, or build artifact is being loaded

Typical checks:
- process list for Electron, node, vite, webpack
- open ports and which process owns them
- dev server URL actually loaded by Electron
- filesystem path embedded in process args

The key question is always:

**Which files on disk are driving the live app right now?**

### 2. Reproduce and collect the first concrete failure

Before fixing anything:
- capture the exact error text
- identify whether it is from renderer, main, preload, dev server, or backend/gateway
- note the first stack frame that points into project code
- record whether the issue is deterministic

If the renderer is white-screening, do not assume the visible page tells you anything. The app may be crashing during first render.

### 3. Map the failing boundary

Determine which boundary is breaking:
- **Renderer render path**: React/Vue/Svelte render crash, bad props, invalid child, routing failure
- **Main process**: startup crash, spawn failure, missing resources, preload registration failure
- **Preload / IPC**: exposed APIs missing, channel mismatch, serialization issue
- **Dev server / asset loading**: HMR mismatch, 404s, wrong origin, stale bundle
- **Backend / gateway**: returned shape differs from what UI renders

For multi-component flows, log or inspect data at each boundary rather than guessing.

### 4. Trace runtime data into the UI

For renderer problems:
- read the actual root render path (`App`, router, shell layout, first mounted page)
- inspect the earliest component likely mounted during the failure
- search for values rendered directly into JSX/template output
- normalize suspicious runtime data crossing boundaries, especially objects shown as labels or text

Common Electron/React white-screen causes:
- rendering objects as children
- undefined APIs from preload
- route redirect loops
- async initialization deadlocks
- crashes inside sidebar/layout components mounted on every page

### 5. If needed, add temporary visibility—not speculative fixes

When the renderer crashes too early to inspect comfortably, add small diagnostics that expose the real failure, for example:
- an Error Boundary around the main app shell
- narrowly scoped console logging at process boundaries
- temporary display-safe normalization around suspicious values

These changes are diagnostic aids. Keep them minimal and directly tied to the observed failure.

### 6. Verify that edits hit the live app

After each code change:
- confirm the edited file belongs to the live source tree from step 1
- confirm whether HMR should reload it or a full restart is required
- if nothing changes, re-check path mismatch before changing more code

If you edited a worktree but the running app uses the main repo, stop and switch to the loaded tree.

### 7. Fix the root cause

Only once the failing boundary is proven:
- make the smallest fix that addresses the source of failure
- avoid unrelated cleanup
- if the backend returns a different shape than the UI expects, normalize at the boundary or align the contract

### 8. Verify in the live runtime

Before claiming success, verify using the running app:
- the previous error no longer appears
- the target screen renders
- no nearby page now renders the same bad shape elsewhere
- if a temporary diagnostic was added, decide whether it should remain as protection or be removed

## Practical heuristics

### White screen after install or first launch

Prioritize:
1. root route / first mounted component
2. auth/bootstrap flow
3. sidebar/layout components that always render
4. preload availability
5. backend data rendered as labels/text

### "Code changed but nothing happened"

Prioritize:
1. wrong repo/worktree/build output
2. dev server pointing to another directory
3. packaged app still running instead of dev build
4. HMR not covering the changed file
5. restart required for main/preload changes

### Runtime object-shape mismatch

If the error looks like "Objects are not valid as a React child" or equivalent:
- identify the exact field crossing into UI
- inspect API/websocket/IPC payload shape
- normalize to a display-safe string at the boundary
- search for sibling render sites of the same field

## Safety

- Stay within the user's local app and authorized environment
- Prefer read-only investigation first
- Ask before destructive actions, shared-system changes, or anything visible to others
- Do not claim remote GUI control you do not actually have; use available local process, log, port, and file inspection tools

## Output format

Keep responses short and operational.

Use this structure:
1. **Observed** — concrete runtime facts
2. **Root cause hypothesis** — one sentence
3. **Next evidence / fix** — exact next action
4. **Verification** — what proves the issue is resolved

## Example outcomes

### Example 1: wrong tree loaded
- Observed: Electron and Vite processes point to `/repo/apps/desktop`, while edits were made under `.claude/worktrees/...`
- Root cause hypothesis: fixes were applied to files not used by the live app
- Next evidence / fix: edit the files under the loaded repo path and let HMR reload
- Verification: renderer output changes immediately and prior error disappears

### Example 2: renderer child object crash
- Observed: runtime payload contains `{kind, expr, tz}` and JSX renders it directly as a label
- Root cause hypothesis: API shape is valid for transport but invalid for direct rendering
- Next evidence / fix: normalize the field to a display string at the UI boundary and inspect sibling render sites
- Verification: target page renders and no equivalent object-child error remains
