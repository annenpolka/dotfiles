# Report the shell's cwd to herdr as the $cwd pane token shown in the sidebar
# agent rows (see [ui.sidebar.agents] in config.windows.toml).
# Dot-source it from the PowerShell 7 profile ($PROFILE), after starship init,
# because it wraps whatever prompt function is defined at that point:
#   . "<dotfiles>\.config\herdr\scripts\report-cwd.ps1"

if (-not $env:HERDR_PANE_ID -or $global:HerdrCwdInnerPrompt) { return }

$global:HerdrCwdInnerPrompt = $function:prompt
$global:HerdrCwdLast = $null

function global:prompt {
    # Run the original prompt first so it still sees the last command's $?
    $out = & $global:HerdrCwdInnerPrompt

    if ($PWD.Provider.Name -eq 'FileSystem' -and $PWD.ProviderPath -ne $global:HerdrCwdLast) {
        $global:HerdrCwdLast = $PWD.ProviderPath
        $cwd = $PWD.ProviderPath
        if ($cwd.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
            $cwd = '~' + $cwd.Substring($HOME.Length)
        }
        $herdr = if ($env:HERDR_BIN_PATH) { $env:HERDR_BIN_PATH } else { 'herdr' }
        $exitCode = $global:LASTEXITCODE
        & $herdr pane report-metadata $env:HERDR_PANE_ID --source user:cwd --token "cwd=$cwd" *> $null
        $global:LASTEXITCODE = $exitCode
    }

    $out
}
