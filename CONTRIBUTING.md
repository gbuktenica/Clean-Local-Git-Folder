# Contributing

Note that commits to master are prevented in the remote. A precommit hook is located in .githooks that will stop commits to the local master.

To activate it run:

```bash
git config --local core.hooksPath .githooks/
```

To confirm that it is set run:

```bash
git config --local --get core.hooksPath
```
