# Repo Env Checker

## Overview
A BASH script for checking a provided git repo for .env and .env.* files not in .gitignore.

## Files
* **repo_env_checker.sh**, BASH script for a provided git repo for .env and .env.* files not in .gitignore. <br>
  - Script supports the following arguments: <br>
  - **check**, Checking a provided git repo filepath for .env and .env.* files not in .gitignore.
    Provided filepath must be a git repo. Script will fail otherwise. <br>
    Usage, `./repoEnvChecker.sh check /path/to/git/repo` <br>
  - **help**, List script functions and exit.
