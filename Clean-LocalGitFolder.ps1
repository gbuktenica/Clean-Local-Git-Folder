<#
.SYNOPSIS
    This PowerShell script will recursively loop through all folders in a path and remove local Git Branches that have been removed from the remote.

.PARAMETER LocalGitFolder
    The path of the root folder that is used to store local Git repositories.

.EXAMPLE
    Clean-LocalGitFolder.ps1
    Prompt the Operator for a folder with a GUI prompt.
    Search for git repositories in the selected folder up to a depth of 2 subfolders
    e.g. it will search and find:
    C:\users\glen\source\ProjectA
    C:\users\glen\source\repos\ProjectB
    C:\users\glen\source\repos\PrivateProjects\ProjectC

.EXAMPLE
    Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit"
    Search for git repositories in "C:\MyGit" up to a depth of 2 subfolders
    e.g. it will search and find:
    C:\MyGit\ProjectA
    C:\MyGit\repos\ProjectB
    C:\MyGit\repos\PrivateProjects\ProjectC

.EXAMPLE
    Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit" -Depth 1
    Search for git repositories in "C:\MyGit" up to a depth of 1 subfolder
    e.g. it will search and find:
    C:\MyGit\ProjectA
    C:\MyGit\repos\ProjectB

    But it will not find
    C:\MyGit\repos\PrivateProjects\ProjectC

.NOTES
    License      : MIT License
    Copyright (c): 2021 Glen Buktenica
    Release      : v2.0.1 2021 11 05
#>
[CmdletBinding()]
Param(
    [Parameter(Position=0)]
    [string]
    $LocalGitFolder,
    [int]
    $Depth = 2
)

if ($LocalGitFolder.length -eq 0) {
    Write-Verbose "`$LocalGitFolder is null so prompt operator for folder path."
    # Check that GUI dependencies are installed.
    # If dependencies are missing and can be installed then do so.
    if (-not (Get-Module -Name "FileSystemForms")) {
        if (((Get-PackageProvider -Name nuget -ErrorAction SilentlyContinue).version) -lt [version]"2.8.5.201") {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        }
        if (-not (Get-PSRepository -Name PSGallery)) {
            Register-PSRepository -Default
        }
        Install-Module -Name FileSystemForms -ErrorAction Stop
    }
    $LocalGitFolder = Select-FileSystemForm -Start "$env:USERPROFILE\source"
}

Write-Verbose "LocalGitFolder = $LocalGitFolder"
if (!(Test-Path $LocalGitFolder)) {
    Write-Error "Path: $LocalGitFolder - Not found" -ErrorAction Stop
}

$LocalGitProjects = @($LocalGitFolder)
if ($PSVersionTable.PSVersion.Major -ge 5 -and $Depth -ge 1) {
    $LocalGitProjects += (Get-ChildItem -Path $LocalGitFolder -Directory -Depth $Depth -ErrorAction SilentlyContinue).FullName
} else {
    $LocalGitProjects += (Get-ChildItem -Path $LocalGitFolder -Directory -ErrorAction SilentlyContinue).FullName
}


foreach ($LocalGitProject in $LocalGitProjects) {
    $Git = Get-ChildItem -Path $LocalGitProject -Directory -Force -Name ".git" -ErrorAction SilentlyContinue
    if ($Git) {
        Set-Location -Path $LocalGitProject
        Write-Host "-------------------------------------------------"
        Write-Host  $LocalGitProject

        # Switch to default branch
        $DefaultBranch = git symbolic-ref refs/remotes/origin/HEAD
        if ($null -ne $DefaultBranch) {
            git checkout ($DefaultBranch).Split("/")[-1]
            git pull
        }

        # Delete remote branches that have been removed from the remote repository.
        $Remotes = git remote
        if ($null -ne $Remotes) {
            foreach ($Remote in $Remotes) {
                git remote prune $Remote
            }
        }

        # Delete local branches that do not have a remote.
        $LocalBranches = git branch -vv
        foreach ($LocalBranch in $LocalBranches) {
            # If Branch output has gone
            if ($LocalBranch -match "gone") {
                # Get Branch Name only and delete it
                $BranchName = $LocalBranch.Split(" ")[2]
                if (0 -ne ($BranchName).length) {
                    git branch -D $BranchName
                }
            }
        }
    }
}
Set-Location $PSScriptRoot