# IG-XL Debug installation troubleshooting

These settings paths and recovery steps are specific to GitHub Copilot CLI.

## Marketplace "igxl-debug" already registered

The marketplace was added during a previous installation attempt. If the existing
registration is working, continue with component installation. To remove a broken
registration and retry:

1. Open `C:\Users\<username>\.copilot\settings.json` and disable the plugin entries:

   ```json
   "enabledPlugins": {
     "igxl-flow-manager@igxl-debug": false,
     "igxl-api-execution@igxl-debug": false,
     "igxl-api-reference@igxl-debug": false
   }
   ```

2. Remove each plugin, then the marketplace, at the assistant prompt:

   ```text
   /plugin remove igxl-flow-manager@igxl-debug
   /plugin remove igxl-api-execution@igxl-debug
   /plugin remove igxl-api-reference@igxl-debug
   /plugin marketplace remove igxl-debug
   ```

3. Retry adding the marketplace and installing the components.

## Failed to uninstall plugin: Access is denied (os error 5)

A running Copilot session may have locked the installed plugin files.

1. Disable the three entries under `enabledPlugins` as shown above.
2. Close all running Copilot CLI sessions so the locks are released.
3. Start a new PowerShell terminal and remove the affected plugin, for example:

   ```powershell
   copilot plugin remove igxl-flow-manager@igxl-debug
   ```

Repeat for the other components as needed, then retry installation.
