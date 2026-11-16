[CmdletBinding()]
param(
    [string]$ProjectPath = '.',
    [string]$Ref = 'main',
    [string]$Repository = 'https://github.com/StarryXYJ/project-workflow-skills.git'
)

$ErrorActionPreference = 'Stop'
$skillNames = @('project-workflow', 'project-docs-sync', 'project-lessons', 'project-git-init')
$project = (Resolve-Path -LiteralPath $ProjectPath).ProviderPath
if (-not (Test-Path -LiteralPath $project -PathType Container)) { throw 'ProjectPath must be an existing directory.' }
$destination = Join-Path $project '.agents/skills'
foreach ($name in $skillNames) {
    if (Test-Path -LiteralPath (Join-Path $destination $name)) {
        throw "Installation stopped: $name already exists in $destination. No existing skill was overwritten."
    }
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is required.' }
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$tempDir = Join-Path $tempBase ('project-workflow-skills-' + [guid]::NewGuid().ToString('N'))
try {
    & git clone --quiet --no-checkout -- $Repository $tempDir
    if ($LASTEXITCODE -ne 0) { throw 'Could not clone the skills repository.' }
    & git -C $tempDir checkout --quiet --detach $Ref
    if ($LASTEXITCODE -ne 0) { throw "Could not checkout ref: $Ref" }
    $commit = (& git -C $tempDir rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not resolve installed commit.' }
    foreach ($name in $skillNames) {
        if (-not (Test-Path -LiteralPath (Join-Path $tempDir "skills/$name/SKILL.md") -PathType Leaf)) {
            throw "Skill missing from repository: $name"
        }
        if (Test-Path -LiteralPath (Join-Path $destination $name)) {
            throw "Installation stopped: $name appeared in $destination."
        }
    }
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    foreach ($name in $skillNames) {
        Copy-Item -LiteralPath (Join-Path $tempDir "skills/$name") -Destination $destination -Recurse
    }
    Write-Host "Installed 4 skills into $destination"
    Write-Host "Source commit: $commit"
} finally {
    if ((Test-Path -LiteralPath $tempDir -PathType Container) -and
        ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($tempDir)).TrimEnd([IO.Path]::DirectorySeparatorChar) -eq $tempBase.TrimEnd([IO.Path]::DirectorySeparatorChar))) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force
    }
}
