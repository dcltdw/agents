---
name: garmin-release
description: Use when releasing a Garmin Connect IQ app or watch face — cutting a store release, building or signing the .iq store package, updating store copy, or tagging a release.
---

# Garmin Connect IQ store release

Shared release process for dcltdw's Garmin apps (watch faces / apps).
Project specifics (signing-key path, device list, store-copy location,
quirks) live in each repo's CLAUDE.md release supplement — read it
alongside this skill.

Don't cut a release unless asked. Uploading to the store is
outward-facing and done by the human, not by Claude.

## Pre-release checklist
1. **Confirm scope.** Diff `main` against the last release tag; ship only
   intended, reviewed work — no stray/diagnostic branches riding along.
2. **Compile-verify.** Clean `monkeyc` build (`BUILD SUCCESSFUL`) with the right
   SDK + `JAVA_HOME`. Monkey C is type-checked at compile, so this is the
   cheapest real check. Sweep the targets / do the `-e` export rather than one
   device. Behavior beyond "it compiles" needs a simulator/device check (there
   is typically no CI or test suite).
3. **Signing key — verify, don't assume.** The Connect IQ store binds an app to
   its first version's key pair and rejects any build signed with a different
   key. Use the project's key and **verify it by RSA-modulus match** against the
   already-published `.prg` before building:
   `openssl pkey -inform DER -in <key> -pubout | openssl rsa -pubin -modulus -noout`
   then grep the hex modulus in the published `.prg`.
4. **Build the store package.** `-e` export → the `.iq` with all products,
   signed with the verified key. Confirm the device count and size.
5. **Re-verify the artifact.** Modulus-match the `.iq` you are about to ship,
   not just the key you intended to use. Step 3 checked a key file; this checks
   the bytes that leave the machine, and it is a separate act.

   A `.iq` is a **7-zip** container, not a zip: `unzip` fails on it, and no
   7-zip extractor is installed on this machine — so don't plan on opening it,
   and don't downgrade this step because you can't. You don't need to open it.
   The modulus is greppable in the raw bytes:

   ```bash
   MOD=$(openssl pkey -inform DER -in "$KEY" -pubout \
         | openssl rsa -pubin -modulus -noout | sed 's/^Modulus=//')
   xxd -p bin/<App>.iq | tr -d '\n' | grep -qi "$MOD" \
     && echo "ARTIFACT KEY OK" || echo "STOP — wrong key in the shipped .iq"
   ```

   `-i` because `xxd` emits lowercase hex and `openssl` uppercase. On NO MATCH,
   stop and upload nothing: the store will not let a wrong-key build be undone.
   The same grep works on a built `.prg`.
6. **Store documents.** Update the store description, the store README, and any
   changelog — accurate to the real changes. The description has three parts and
   all three are actions:
   - Add a **"What's new in X.Y.Z"** block for this version.
   - **Move** the previous version's block down into the version-history list as
     a one-liner. It stops being "what's new".
   - **Check the 4000-char cap** — `wc -c <description file>` — and print the
     number. It is a hard store limit, it is not enforced by anything you run,
     and moving a block down is what usually pushes the file over it. If it's
     tight, drop the oldest history line.
7. **Secret scan — two scans, not one.** The diff and the built artifacts are
   different surfaces and neither scan covers the other.
   - **The diff:** `gitleaks git` over the release range, or the pre-push hook /
     a manual read of `git diff` per `AGENTS.md`.
   - **The built artifacts:** the build directory is normally **git-ignored**, so
     git-mode gitleaks (`gitleaks git`, `gitleaks detect`, `protect --staged`)
     never reads a single byte of it. Naming the artifact as your reason for
     scanning and then running a git-mode command is the standard way to miss
     this. Scan the filesystem, and scan the package itself:

     ```bash
     gitleaks dir bin/ --redact -v      # reads the text dropped beside the
                                        # package (*-settings.json, *.debug.xml)
     ```

     `gitleaks dir` **skips binaries**, so it does not read the `.iq` or `.prg`.
     Check those directly. The signing key's *public* modulus is expected inside
     the package — that's the certificate. Its *private* exponent must not be:

     ```bash
     PRIV=$(openssl pkey -inform DER -in "$KEY" -noout -text \
            | awk '/privateExponent/{f=1;next}/^prime1/{f=0}f' | tr -d ' :\n')
     xxd -p bin/<App>.iq | tr -d '\n' | grep -qi "${PRIV:0:64}" \
       && echo "STOP — private key material in the package" \
       || echo "package clean of private key"
     ```
8. **Board + PR hygiene** — board move and PR body via `dcltdw:opening-a-pr` /
   `dcltdw:cleaning-up-after-pr-merge`, commits stamped per `AGENTS.md`.
9. **Tag** the release commit `vX.Y.Z`.
10. **Hand off.** Two separate things, and the second is the one that gets
    dropped:
    - **The human uploads.** Hand over the `.iq`, the store copy and any
      screenshots; you do not submit to the portal.
    - **The release is unconfirmed until the wild says otherwise.** A green
      build, a published GitHub Release and a `gh release view` that lists the
      asset are all evidence that you shipped, not that it works. For a fix,
      confirmation is the error dashboard or a reporter. Say so in the hand-off
      rather than closing on the artifact.
