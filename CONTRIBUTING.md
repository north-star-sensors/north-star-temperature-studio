# Contributing to North Star Temperature Studio

Thanks for your interest in contributing! This project is licensed under **[AGPL-3.0-or-later](LICENSE)**. By contributing, you help keep it free software — and you let us evolve the project responsibly over time.

## TL;DR

1. Fork the repo, branch from `main`, open a pull request.
2. The first time you open a PR, [CLA Assistant](https://cla-assistant.io/) will ask you to sign our [Contributor License Agreement](CLA.md). One click, once per GitHub account.
3. Once your CLA is on file and review passes, we merge.

## The CLA — what it is and why

We require contributors to sign a [Contributor License Agreement](CLA.md) (based on the [Harmony Individual CLA v1.0](http://harmonyagreements.org/), Option 5). In plain English:

- **You keep the copyright** to your contribution. We don't take ownership.
- **You grant us a broad license** to use, modify, sublicense, and relicense your contribution.
- **We promise that your contribution will always be available under AGPL-3.0-or-later** — the license in effect on the day you submit it. That guarantee is irrevocable.
- **We retain the option to also offer the project under other licenses** in the future (e.g., a commercial license alongside AGPL). This is what's known as dual-licensing or open-core.

If that arrangement isn't acceptable to you, please don't submit a contribution. You're still welcome to fork the project under AGPL-3.0-or-later and develop independently.

### Why we ask for this

AGPL-3.0 is a strong copyleft license, which is great for keeping the project free — but it also makes the project hard to embed in environments that can't comply with AGPL (some enterprises, some downstream commercial users). Holding broad rights to every contribution gives us the flexibility to offer alternative licensing terms to those users later, without re-litigating consent from every past contributor. We may never exercise that option — but we want to keep it open.

## How to contribute

### Code

1. **Open an issue first** for non-trivial changes — it's much faster than a rejected PR.
2. **Fork** the repository and create a branch off `main`:
   ```bash
   git checkout -b your-feature-name
   ```
3. **Make your changes.** Keep commits focused; write clear commit messages.
4. **Open a pull request** against `main`.
5. **Sign the CLA** when CLA Assistant prompts you on the PR.
6. **Respond to review feedback.** We'll merge once everything's green.

### Bug reports, ideas, documentation

Issues and discussions don't require a CLA — only contributions of copyrightable material (code, docs in the repo, etc.) do. Open an issue any time.

### Non-owner contributions

If you want to contribute code that **you don't fully own the copyright to** (e.g., it comes from another project, your employer holds rights, it's a collaborative work with someone who hasn't signed), don't submit it as your own. Open an issue describing the work and its origin so we can figure out the right path together.

## Maintainer setup notes

> *This section is for project maintainers, not contributors.*

CLA enforcement runs via [`.github/workflows/cla.yml`](.github/workflows/cla.yml) using the [contributor-assistant/github-action](https://github.com/contributor-assistant/github-action) (the self-hosted variant — no third-party service). Signatures are stored as JSON on a dedicated `cla-signatures` branch inside this repo.

Before going live:

1. **Lawyer review** of [`CLA.md`](CLA.md). Governing law is set to California (§6.1); media-license choice is CC BY-SA 4.0 (§2.3) — adjust if needed.
2. **Create the `cla-signatures` branch.** The action will populate it, but it must exist:
   ```bash
   git checkout --orphan cla-signatures
   git rm -rf .
   echo '{"signedContributors":[]}' > signatures/version1/cla.json  # may need mkdir -p first
   git add signatures/version1/cla.json
   git commit -m "Initialize CLA signatures"
   git push origin cla-signatures
   git checkout main
   ```
3. **Enable workflow permissions** in *Settings → Actions → General → Workflow permissions* → "Read and write permissions" so the action can commit signatures.
4. **Test on a throwaway PR** from a second GitHub account before announcing the project.

How it works for contributors:
- Open a PR → bot posts a comment listing unsigned contributors with a link to [`CLA.md`](CLA.md).
- They reply with the comment phrase `I have read the CLA Document and I hereby sign the CLA`.
- Bot records their GitHub username + signing PR/commit on the `cla-signatures` branch and re-checks the PR.
- Future PRs from the same account pass the check automatically.
