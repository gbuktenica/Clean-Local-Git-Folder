# Clean Local Git Folder

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Copyright Glen Buktenica](https://img.shields.io/badge/Copyright-Glen_Buktenica-blue.svg)](http://buktenica.com)

## Overview

This PowerShell script will recursively loop through all folders in a path and remove local Git Branches that have been removed from the remote.

## Usage

```powershell
Clean-LocalGitFolder.ps1
```

Finds sub directories of "$env:USERPROFILE\source" up to a depth of 2 subfolders and prunes Git branches if those directories have a .git directory and have been removed from the remote.

```powershell
Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit"
```

Finds sub directories of "C:\MyGit" up to a depth of 2 subfolders and prunes Git branches if those directories have a .git directory and have been removed from the remote.

```powershell
Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit" -Depth 1
```

Finds sub directories of "C:\MyGit" up to a depth of 1 subfolder and prunes Git branches if those directories have a .git directory and have been removed from the remote.
