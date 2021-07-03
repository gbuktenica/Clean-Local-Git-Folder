# Contributing

## Pre-commit Hook

Note that commits to master and main are prevented in the remote. A precommit hook is located in .githooks that will stop commits to the local master and main.

To activate it run:

```bash
git config --local core.hooksPath .githooks/
```

To confirm that it is set run:

```bash
git config --local --get core.hooksPath
```

If you are reading this after a failed commit to master/main run the following to restore the local branch to be the same as the remote:

```bash
# Save to a new branch just in case
git commit -a -m "commit before hard reset"
git checkout -b branch-before-hard-reset

# Reset to the remote
git fetch origin
git checkout origin/main # checkout origin/master
git reset --hard origin/main # or git reset --hard origin/master 
```
