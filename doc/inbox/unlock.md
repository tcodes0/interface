# Unlock at login

### Tier B — Auto at KDE login (upgrade path, same script)

1. Install `pam-gnupg` from AUR
2. Set GPG passphrase == login password (one-time)
3. Configure `~/.pam_gnupg`:
   ```
   AD651305BA6ED38931D70713EAA24FC72CD1728B
   9945CA56E213041B873D5A27874FCBD529C580D0
   ```
4. Re-encrypt `~/.pass.gpg` **asymmetrically** to your GPG key (so `gpg --decrypt` goes through the agent silently — no passphrase prompt)
5. Write a systemd **user service** that runs `unlock` at session start — it now decrypts `~/.pass.gpg` silently, loads SSH via `SSH_ASKPASS`

`unlock` script **does not change** between tiers — it just stops prompting because gpg-agent already has the passphrase from PAM.

## The passwords situation

For Tier B you'd need **one master password to rule them all**:

> login password = GPG passphrase(s) = SSH passphrase

That means three one-time changes:

1. `passwd` — change login password from PIN to master password
2. `gpg --passwd` × 2 — re-key both GPG keys to master password
3. `ssh-keygen -p` — re-key `id_rsa` to master password

This is clean and desirable regardless — a 4-digit PIN login is genuinely weak even with a touch key.

---

## The touch key complication

**This is the honest catch with pam_gnupg:** it intercepts the PAM authentication event and forwards the password you typed to gpg-agent. If you log in via touch key, no password string is ever passed — pam_gnupg gets nothing and does nothing silently. Same limitation applies to `pam_ssh`.

So the behavior would be:

| Login method         | GPG auto-preset?       | SSH auto-loaded? |
| -------------------- | ---------------------- | ---------------- |
| Type master password | ✅ pam_gnupg + pam_ssh | ✅               |
| Touch key            | ❌                     | ❌               |

On touch-key logins you'd still run `unlock` manually — but `unlock` now decrypts `~/.pass.gpg` **silently** (it's asymmetric, agent already has the GPG passphrase... wait, no — agent doesn't have it yet on touch login). So touch key + full auto is not achievable without either skipping the passphrase on the keys entirely or other tricks.

**Practical verdict:** Tier B is worth building but you'd get full automation only on password logins. Touch key logins get the same experience as today — run `unlock` once. That's probably acceptable since touch-key login is the fast/convenience path anyway.

---

## SSH in Tier B — the cleanest approach

Rather than `pam_ssh`, I'd recommend a **systemd user service** that runs `unlock` after login:

```
graphical-session.target
  └─ unlock.service (After=graphical-session.target, only if agent is empty)
      └─ unlock (decrypts ~/.pass.gpg via agent → loads SSH)
```

- On **password login**: pam_gnupg presets GPG → service runs `unlock` → `unlock` decrypts pass.gpg silently (agent already has passphrase) → SSH loaded
- On **touch key login**: GPG not preset → service runs `unlock` → `unlock` needs passphrase → **prompts via a desktop dialog** (kdialog or pinentry-qt) rather than a terminal
- Manual `unlock` in terminal always available as fallback

This means `unlock` needs one small adaptation: detect if it's being run from a terminal vs a service (check `$TERM` / `tty`), and use `kdialog --password` instead of `read -rsp` when headless.

---

## Proposed decision (done)

**Ship Tier A first** (manual `unlock`, as planned), then Tier B is a separate follow-up task that involves:

- Changing the three passphrases
- Installing `pam-gnupg` (AUR)
- Re-encrypting `~/.pass.gpg` asymmetrically
- Adding the systemd user service + kdialog fallback to `unlock`

1. **Boot → first login → type master password** → pam_gnupg presets GPG → unlock service loads SSH → everything cached in agents
2. **Screen lock → touch key** → agents are still alive with everything already loaded → nothing to do

Screen lock/unlock doesn't tear down your user session or the agents. They persist the entire uptime. Touch key just re-authenticates you to the display manager, it doesn't reset agent state. The design is sound.

## Summary: what we're building

- **Tier A (done):** `bin/unlock` (manual), `bin/2fa`, `bin/2fa-migrate`
- **Tier B later:** change 3 passphrases to master password, install `pam-gnupg`, add systemd user service — separate task
