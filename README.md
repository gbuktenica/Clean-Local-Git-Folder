# Clean Local Git Folder

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Copyright Glen Buktenica](https://img.shields.io/badge/Copyright-Glen_Buktenica-blue.svg)](http://buktenica.com)

## Overview

This PowerShell script will recursively loop through all folders in a path and tidy up old Git Branches.

## Usage

```powershell
Clean-LocalGitFolder.ps1
```

Finds sub directories of "$env:USERPROFILE\source" and prune old Git branches if those directoies have a .git directory.

```powershell
Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit"
```

Finds sub directories of "C:\MyGit" and prune old Git branches if those directoies have a .git directory.
