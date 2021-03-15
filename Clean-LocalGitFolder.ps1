<#
.SYNOPSIS
    This PowerShell script will recursively loop through all folders in a path and remove local Git Branches that have been removed from the remote.

.PARAMETER LocalGitFolder
    The path of the root folder that is used to store local Git repositories.

.EXAMPLE
    Clean-LocalGitFolder.ps1
    Seach for git repositories in <USERPROFILE>\source up to a depth of 2 subfolders
    e.g. it will search and find:
    C:\users\glen\source\ProjectA
    C:\users\glen\source\repos\ProjectB
    C:\users\glen\source\repos\PrivateProjects\ProjectC

.EXAMPLE
    Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit"
    Seach for git repositories in "C:\MyGit" up to a depth of 2 subfolders
    e.g. it will search and find:
    C:\MyGit\ProjectA
    C:\MyGit\repos\ProjectB
    C:\MyGit\repos\PrivateProjects\ProjectC

.EXAMPLE
    Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit" -Depth 1
    Seach for git repositories in "C:\MyGit" up to a depth of 1 subfolder
    e.g. it will search and find:
    C:\MyGit\ProjectA
    C:\MyGit\repos\ProjectB

    But it will not find
    C:\MyGit\repos\PrivateProjects\ProjectC

.NOTES
    Author     : Glen Buktenica
    Requires   : PowerShell 3
    Change Log : 20210315 CmdletBinding
#>
[CmdletBinding()]
Param(
    [Parameter(Position=0)]
    [string]
    $LocalGitFolder = "$env:USERPROFILE\source",
    [int]
    $Depth = 2
)
$LocalGitProjects = @($LocalGitFolder)
if ($PSVersionTable.PSVersion.Major -ge 5 -and $Depth -ge 1) {
    $LocalGitProjects += (Get-ChildItem -Path $LocalGitFolder -Directory -Depth $Depth).FullName
} else {
    $LocalGitProjects += (Get-ChildItem -Path $LocalGitFolder -Directory).FullName
}


foreach ($LocalGitProject in $LocalGitProjects) {
    $Git = Get-ChildItem -Path $LocalGitProject -Directory -Force -Name ".git"
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

        # Delete remote branchs that have been removed from the remote repository.
        $Remotes = git remote
        if ($null -ne $Remotes) {
            foreach ($Remote in $Remotes) {
                git remote prune $Remote
            }
        }

        # Delete local branchs that do not have a remote.
        $LocalBranches = git branch -vv
        foreach ($LocalBranch in $LocalBranches) {
            # If Branch output has gone
            If ($LocalBranch -match "gone") {
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