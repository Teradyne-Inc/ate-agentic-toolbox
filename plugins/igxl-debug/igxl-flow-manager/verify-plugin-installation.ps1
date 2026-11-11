$dir = 'C:\Program Files (x86)\Teradyne\Applications\FlowManagement'

function Show-Runtime {
  $hk = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine','Registry64')
  $rt = $hk.OpenSubKey('Software\Teradyne\FlowTool\Runtime')
  if (-not $rt) { 'Runtime: NOT INSTALLED'; return }
  "Runtime $($rt.GetValue('Version')) contract $($rt.GetValue('ContractMajor'))"
  $c = $rt.OpenSubKey('Consumers'); foreach ($n in $c.GetSubKeyNames()) { "  consumer $n -> $($c.OpenSubKey($n).GetValue('Path'))" }
  $p = $hk.OpenSubKey('Software\Teradyne\FlowTool\Plugins')
  foreach ($n in $p.GetSubKeyNames()) { "  plugin $n Enabled=$($p.OpenSubKey($n).GetValue('Enabled'))" }
  "Plugins dir: $(Test-Path "$dir\WebAPI\Plugins")  uninstaller: $(Test-Path "$dir\uninstall-plugin-runtime.exe")"
}

Show-Runtime
