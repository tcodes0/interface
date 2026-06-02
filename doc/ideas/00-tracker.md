# Ideas inbox

<!-- header ------------------------------------------------------------------------------------------------------------------  -->

## format

> newer on top

> - [ ] **[UNIQUE NUMBER] [IMPORTANCE] [POINTS]** [file-if-large](../file-if-large.md) \<description\>

importance according to [focus.md](../focus.md): [LOW] [MED] [HGH]

| point | technical   |
| ----- | ----------- |
| 1     | trivial     |
| 2     | simple      |
| 3     | decent      |
| 5     | challenging |
| 8     | large       |
| 13    | project     |

largest number: 24

<!--ideas ------------------------------------------------------------------------------------------------------------------  -->

## current

- [ ] **[24] [MED] [5]** [mcp-gcp-integration.md](./mcp-gcp-integration.md) integrate GCP (Cloud Build + BigQuery) into API Key MCP; builds on [21] auth layer, subsumes [09] and enables [17]
- [ ] **[23] [LOW] [3]** cronjob backup of lga/chatui to Google Drive via rclone (same setup as secret server backup)
- [ ] **[22] [MED] [2]** filer refactor: add a `copy` command alongside the existing link command; use it for `etc/` installs so systemd units and other files land directly in `/etc` — avoids timer/service failures caused by BTRFS `home-vacation` subvolume not being mounted early enough at boot
- [ ] **[21] [MED] [3]** keys v2: GCP — add `google_service_account` secret type (service account JSON → JWT → token exchange → cached bearer with refresh); unlocks BigQuery, GCS, Drive, Sheets, Pub/Sub, Vertex AI, Cloud Logging in a single implementation
- [ ] **[08] [HGH] [13]** [stt-server.md](./stt-server.md)
- [ ] **[01] [MED] [2]** review obra/superpowers skills, already cloned
- [ ] **[09] [MED] [2]** [bigquery-mcp.md](./bigquery-mcp.md) implemented by keys v2 [21]; requires `google_service_account` secret type
- [ ] **[02] [LOW] [2]** diff-to-html: a skill/tool/script that receives a unified diff as input and renders it as formatted HTML (syntax-highlighted, red/green lines), so it can be dropped directly into an artifact
- [ ] **[03] [LOW] [3]** refactor interface bash scripts take a look at bash env and lib.sh and make the whole thing less magical. see [open-questions.md](./open-questions.md)
- [ ] **[04] [LOW] [2]** [code-review-agent.md](./code-review-agent.md)
- [ ] **[07] [LOW] []** [google-drive-unify.md](./google-drive-unify.md)
- [ ] **[10] [LOW] [1]** [tmp-dir-in-context.md](./tmp-dir-in-context.md)

#### april 2026

- [ ] **[11] [MED] [1]** copy the good bits (like the white space linter) from go repo
- [ ] **[13] [LOW] [2]** git pull cronjob
- [ ] **[14] [LOW] [2]** update tests to use Expecter struct
- [ ] **[15] [LOW] [2]** refine jj shell prompt. if the first detected branch = main, omit the second. any ideas worth adding to the prompt
- [ ] **[16] [LOW] [2]** get cspell config looked at
- [ ] **[17] [LOW] [3]** cloud build failures post a comment on gh on the PR with logs
- [ ] **[18] [LOW] [5]** vite+ replace everything
- [ ] **[19] [LOW] [5]** go linter called nolo "no \_" to flag helper functions that have std lib replacements
- [ ] **[20] [LOW] [8]** hypeclaw (public openclaw repo)

<!--done------------------------------------------------------------------------------------------------------------------  -->

## done

> newer on top

- [x] **[05] [HGH] [3]** [auth-injection-mcp.md](./auth-injection-mcp.md) renamed to `keys`; config-driven named tools, one per API; static bearer/header injection; v1 targets GitHub + Datadog
- [x] **[06] [MED] [1]** [datadog-logs-mcp.md](./datadog-logs-mcp.md) implemented by keys [05]; no separate server needed
- [x] **[12] [LOW] [2]** review and write in go https://github.com/twn39/pgsql-mcp-server/blob/main/src/pgsql_mcp_server/app.py improve flags config and permissions — separate MCP server; Postgres is a wire protocol, not HTTP; credential model (DSN, SSL) and tool surface (`query`, `explain`, `list_tables`) are both different from keys; only shared concern is keeping credentials off the model
- [x] [git-workflow-clone-docs.md](./git-workflow-clone-docs.md)
- [x] [mise-version-pruning.md](./mise-version-pruning.md)
- [x] [unlock.md](./unlock.md)
- [x] **[LOW]** jail mcp: Start collecting data on which tools are called with which arguments and dump it on an SQLite file for analysis later. do clever statistics with it.
- [x] **[LOW]** secret server needs a backup routine to my google drive or something
- [x] librepatches simple git patches to fix annoying quirks of the libre UI. Apply diff on top of images to minimize maintenance and avoid a fork.
- [x] github token visible to woody is a bad pattern, does ssh key resolve go private deps? if so agent may not need token. worst case make token read only and scoped if possible
- [x] compose agents.md
- [x] encrypt .2fa files, include decrypt of ~/.pass.gpg
- [x] consolidate bin/setup scripts somewhere and just download to consumer repos
- [x] script to decrypt my pw file and automatically load keys

#### april 2026

- [x] go-common: finish https://github.com/eleanorhealth/comms/pull/47 with a simple reflect struct tag loop, use in clients
- [x] update go-common env pkg to have a private type that is returned by setenv and necessary for env.Is\* methods, the ideia is to cause a compile time fail instead of a runtime panic on env.parse
- [x] "The `get_review_comments` response doesn't include the GraphQL thread node IDs — only comment `html_url`s with comment IDs (e.g. `r3040882588`). The `resolve_review_thread` tool needs the thread node ID (format: `PRRT_kwDO...`), which isn't surfaced in the response."
- [x] gh api way for claude to resolve comments
- [x] mise root warnings
- [x] update deps gh action
- [x] jail mcp: how to find tools not under mise, like shfmt. exec sync and background could accept command arrays.
- [x] bin/setup for interface (shfmt)
- [x] try whisper for tts
- [x] youtube sets
- [x] lg fix
- [x] mise
- [x] claude cowork
- [x] test more models for coding perf
- [x] continue testing local models for coding performance
- [x] some voice to text local tool I can use in any platform
- [x] some more challenging personal project? with containers? jail mcp, openclaw

<!--wont do------------------------------------------------------------------------------------------------------------------  -->

## wont do

- [-] [librechat-mongo-mcp.md](./librechat-mongo-mcp.md)
- [-] try busting claude desktop cache to see if mcp server bug is fixed
- [-] **[LOW]** mise no versions set for <tool> It's some type of mismatch between the local requested version and the global version.
