# AGENTS.md — Rules for AI coding agents on this project

This is an existing **iOS app written in Swift** (UIKit + storyboards, Core Data, CocoaPods).
These rules apply to **every** task. Follow them without being reminded.

---

## 1. Scope discipline (most important)

- Make **ONLY** the changes required by the current task. Nothing else.
- **Before editing anything**, list the exact files you intend to change and one line on why each is needed. **Wait for my approval** before touching any file outside that list.
- If, while working, you discover another file seems to need changing, **STOP and ask me first**. Do not edit it on your own.
- **Prefer creating new files over modifying existing ones** whenever reasonable.
- When you finish, output the final list of changed files with a one-line reason for each, so I can verify scope.

## 2. Never do these without explicit permission

- Do **not** refactor, restructure, or "clean up" code that is unrelated to the task.
- Do **not** rename classes, methods, variables, files, or outlets.
- Do **not** reformat, re-indent, or reorder existing code.
- Do **not** convert storyboard / XIB / `@IBOutlet` UI into programmatic UI, or vice versa.
- Do **not** change existing UI, layout, colors, fonts, or behavior that the task didn't ask for.
- Do **not** upgrade, add, or remove dependencies (Pods/SPM) unless the task explicitly requires it.
- Do **not** modify project settings, build configs, schemes, `Info.plist`, or entitlements unless explicitly asked.
- Do **not** touch `Podfile`, `Podfile.lock`, or `Pods/`.

## 3. Match the existing project

- Mirror the existing architecture, naming conventions, file organization, and code style.
- Reuse existing components, helpers, theme tokens, networking, and the existing Core Data storage layer.
- Respect the active theme system — new UI must use existing theme tokens (colors, fonts, spacing), not hardcoded values.
- Keep new user-facing strings localizable if the app already supports localization.

## 4. Secrets & security

- Never hardcode API keys, tokens, or secrets in source files that get committed.
- Keep any secret in a single dedicated source (e.g. `Secrets.swift`) that is listed in `.gitignore`, accessed through one small abstraction so it can be swapped later.
- Never commit `Secrets.swift`, `GoogleService-Info.plist` keys, or anything sensitive.

## 5. Build & verify

- After changes, build with the **`.xcodeproj`/`.xcworkspace` that actually exists** in the repo (check first — don't assume).
- Fix only the compile errors caused by your own changes. Do not "fix" unrelated warnings or errors.
- If a build fails for a reason unrelated to your task, report it — do not start changing unrelated files to make it pass.

## 6. Plan first

- For any non-trivial task, give me a short plan and the file list **before** writing code.
- Ask clarifying questions when anything is ambiguous instead of guessing.

---

**Summary:** Smallest possible additive change. List files before editing. Ask before going outside scope. Never refactor or rewrite unrelated code.
