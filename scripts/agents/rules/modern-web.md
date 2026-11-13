When you write or change HTML, CSS or client-side JavaScript in a code
repository, load the `modern-web-guidance` skill before you write the code.
This covers UI components, layout, animation, forms, accessibility, Core Web
Vitals, and browser APIs inside any framework. Skip it for backend, infra,
build tooling, tests, renames and copy edits, and for vault or note work.

- Run the globally installed `modern-web-guidance` binary (declared in
  `scripts/npm/npm_packages.txt`), not `npx -y modern-web-guidance@latest`.
  The `@latest` form downloads and executes whatever version is newest on npm
  at every call. Keep the skill's other arguments, such as `--skill-version`.
- Follow the skill's search, retrieve and verify steps. Treat a retrieved guide
  as the default unless the repo states its own browser support policy.
- Replace the skill's "Disclose Skill Usage" step. Do not add a
  `### Modern Web Guidance` section. Name a guide id in your reply only when it
  changed the code, in one line with the reason.
- If you deliberately skip the skill for a web task, say so.
