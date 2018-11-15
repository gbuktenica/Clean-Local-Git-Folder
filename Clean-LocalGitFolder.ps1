<#
.SYNOPSIS
    This PowerShell script will recursively loop through all folders in a path and tidy up old Git Branches.

.PARAMETER [string] LocalGitFolder
    The path of the folder that is used to store local Git repositories.

.EXAMPLE
    Clean-LocalGitFolder.ps1 -LocalGitFolder "C:\MyGit"

.NOTES
    Author     : Glen Buktenica
    Requires   : PowerShell 3
    Change Log : 20181115 Initial Build
#>
Param(
    [Parameter(Position=0)] [string]$LocalGitFolder = "$env:USERPROFILE\.source"
)
$LocalGitProjects = Get-ChildItem -Path $LocalGitFolder -Directory

foreach ($LocalGitProject in $LocalGitProjects) {
    $Git = Get-ChildItem -Path ($LocalGitProject).FullName -Directory -Force -Name ".git" -Recurse
    if ($Git) {
        Set-Location -Path ($LocalGitProject).FullName
        # Delete remote branchs that have been removed from the remote repository.
        #git remote prune origin
        # Delete local branchs that do not have a remote.
        $LocalBranches = git branch -vv
        foreach ($LocalBranch in $LocalBranches) {
            # If Branch output has gone
            If ($LocalBranch -match "gone") {
                # Switch to default branch
                #$ TODO
                # git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
                # Get Branch Name only and delete it
                git branch -d $LocalBranch.Split(" ")[1]
            }
        }
    }
}
