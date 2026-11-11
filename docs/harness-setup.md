# Harness setup

Install one supported assistant before adding a marketplace.

## GitHub Copilot CLI

### Prerequisites

- Windows 10 version 1809 or later, or Windows 11.
- PowerShell 6 or later (PowerShell 7 recommended).
- An active GitHub Copilot license, with Copilot CLI enabled for the organization.
- Network access to github.com.

### Install and sign in

Run in PowerShell:

```powershell
winget install GitHub.Copilot
```

Close and reopen PowerShell so the updated `PATH` is loaded, then verify:

```powershell
copilot --version
```

Launch `copilot`. If you are not signed in, enter `/login` at its prompt and
follow the browser instructions.

### WinGet is unavailable

WinGet is part of the Windows App Installer package. Check that it is installed
and that its executable exists:

```powershell
Get-AppxPackage Microsoft.DesktopAppInstaller | Select-Object Name, Version
Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
```

If the executable exists, try its full path:

```powershell
& "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe" --version
```

If that works, add its folder to your user `PATH`, then reopen PowerShell:

```powershell
[Environment]::SetEnvironmentVariable("Path",
    [Environment]::GetEnvironmentVariable("Path","User") +
    ";$env:LOCALAPPDATA\Microsoft\WindowsApps", "User")
```

If App Installer needs re-registering, run:

```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage `
    Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

If WinGet still does not run, open an administrator PowerShell and run these
commands individually:

```powershell
Install-PackageProvider -Name NuGet -Force
Install-Module Microsoft.WinGet.Client -Force -Repository PSGallery
Repair-WinGetPackageManager -AllUsers
```

See the [official Copilot CLI installation guide](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)
for alternative installation methods.

## Claude Code

See the [official setup guide](https://code.claude.com/docs/en/setup) for
requirements, alternative installers, and authentication options.

On Windows 10 version 1809 or later, or Windows 11, run:

```powershell
winget install Anthropic.ClaudeCode
```

If WinGet is unavailable, see the
[native Windows instructions](https://code.claude.com/docs/en/setup#install-claude-code).
Close and reopen PowerShell, then verify:

```powershell
claude --version
```

Launch `claude` and follow the browser prompts to sign in with an account that
has Claude Code access. If needed, enter `/login` at the Claude prompt.
For WinGet installations, run `winget upgrade Anthropic.ClaudeCode` periodically.
