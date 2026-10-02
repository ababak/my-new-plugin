You are generating release notes for the next version of this project. The
project keeps its changelog in `CHANGELOG.md` in the repository root, following
the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) convention with
`### Added / Changed / Fixed / Removed` sections.

The "Run context" block at the end tells you the changelog state, the latest
tag and the commit range to summarize. Use it as given.

## Workflow

1. **Read `CHANGELOG.md`** if it exists, to learn the existing style and the
   latest released version (the highest dated `## [X.Y.Z] - YYYY-MM-DD`
   heading). Ignore the `## [Unreleased]` entry; that is what you fill in.
2. **Run `git log <range> --no-merges --pretty=format:'%h %s'`** with the
   range from the Run context to list the commits to summarize.
3. **Categorize each commit** by its subject. The project does not use
   conventional-commit prefixes, so go by the leading verb and meaning:
   - "Add", "Introduce", "Support" → **Added**
   - "Fix", "Correct", "Resolve" → **Fixed**
   - "Remove", "Drop", "Delete" → **Removed**
   - everything else user-visible (update, refactor, split, document) →
     **Changed**
   Skip pure housekeeping that does not matter to users of the project: log
   or LOG.md updates, editor/workspace settings, `.gitignore` tweaks. Merge
   commits are already excluded.
   Rewrite each subject as a short, readable bullet, and merge commits that
   describe one change into a single bullet.
4. **Write `CHANGELOG.md`:**
   - If it does not exist, create it with a `# Changelog` title, a one-line
     note that it follows Keep a Changelog, then the `## [Unreleased]`
     section.
   - Otherwise replace the contents of the `## [Unreleased]` section with the
     new entries. Keep the `## [Unreleased]` heading and all released
     sections untouched.
5. (Optional) **Re-read `CHANGELOG.md`** to confirm the edit applied cleanly
   and the formatting matches earlier entries.

## Constraints

- **Do not commit or push.** Edits stay in the working tree as a suggestion;
  a human reviewer applies them.
- **Only touch `CHANGELOG.md`.** Do not read or edit any other file.
- Each bullet is one line, no trailing period.
- Use exactly these section titles: `Added`, `Changed`, `Fixed`, `Removed`.
  Skip sections with no entries; never emit empty sections.
- Put a blank line after each `###` heading and use `-` bullets.

## Final output

Return a JSON object describing what you wrote, matching the requested
schema:

- `version`: the next semver you would suggest. With no previous release,
  use `0.1.0`. Otherwise bump the minor version if anything was **Added**,
  else the patch version. Format `"X.Y.Z"`, no leading `v`.
- `release_date`: today's date from the Run context, as `YYYY-MM-DD`.
- `sections`: array of `{title, items[]}` in the order
  `Added → Changed → Fixed → Removed` (omit empty ones).

The JSON must mirror the bullets you wrote into `CHANGELOG.md`. A reviewer
will compare them, so they must agree.
