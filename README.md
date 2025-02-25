# Development flakes

For some reason, flakes either need to be in a repo, or will cache everything in the current folder. Including files that we want to ignore (such as build artifacts).

This is poor design to say the least, and there are no reasonable workarounds for some reason, every possible solution is a mess of scripts to `stash` / `unstash` the flake, or use `--intent-to-add` options on git or stuff like that.

A somewhat decent option is to use a dedicated repo to store the flakes, and call those flakes with `nix develop`. It’s still annoying, but somewhat reasonable.

# Usage

Place a `.envrc` file in the root of your working directory. To use the Redox kernel flake for example, set it as:
```direnv
use flake "github:vincentberthier/flakes?dir=redox/kernel"
```
