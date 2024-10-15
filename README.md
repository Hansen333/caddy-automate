# Caddy Build Automation

This repository contains a `Makefile` that automates the process of building, testing, installing, and restoring the Caddy server with custom plugins. It simplifies the steps needed to manage your Caddy installation, ensuring that the configuration is valid before making any live changes.

## Features

- **Custom Plugin Management**: Easily add or remove plugins for the Caddy build by modifying a single variable.
- **Automated Testing**: The `Makefile` validates the Caddy configuration before installation, ensuring no downtime due to configuration issues.
- **Backup and Restore**: The `Makefile` automatically backs up the existing Caddy binary before installing a new version and provides a restore option in case of issues.
- **Flexibility**: You can override the default configuration file and plugin list using environment variables or command-line arguments.

## Requirements

This project builds on [Caddy](https://github.com/caddyserver/caddy), a powerful, extensible, and easy-to-use web server written in Go.

- **xcaddy**: Used to build the Caddy server with custom plugins. Follow the installation instructions for `xcaddy` in the official [xcaddy GitHub repository](https://github.com/caddyserver/xcaddy?tab=readme-ov-file#install).

## Usage

### Download the Makefile

You can download the `Makefile` using `curl` or `wget`:

```bash
# Using curl
curl -O https://raw.githubusercontent.com/Hansen333/caddy-automate/refs/heads/main/Makefile
```

```bash
# Using wget
wget https://raw.githubusercontent.com/Hansen333/caddy-automate/refs/heads/main/Makefile
```

### Available Targets

| Target      | Description                                                                                          |
|-------------|------------------------------------------------------------------------------------------------------|
| `help`      | Displays usage instructions and available targets.                                                    |
| `build`     | Builds the Caddy binary with the specified plugins. You can customize the plugin list using `PLUGINS`.|
| `test`      | Tests the newly built Caddy binary against the current configuration to ensure validity.              |
| `install`   | Installs the new Caddy binary after backing up the old one.                                           |
| `restore`   | Restores a previously backed-up Caddy binary and restarts the service. Requires a `file` parameter.   |
| `restart`   | Restarts the Caddy service.                                                                           |
| `clean`     | Cleans up build artifacts and backups.                                                                |

### Variables

- **PLUGINS**: Custom plugins to include in the Caddy build. Defaults to:
  ```bash
  --with github.com/caddy-dns/cloudflare --with github.com/caddy-dns/route53 --with github.com/caddyserver/replace-response
  ```
  
  Example:
  ```bash
  make build PLUGINS="--with github.com/caddyserver/replace-response"
  ```

- **CONFIG**: Path to the Caddy configuration file. Defaults to `/etc/caddy/Caddyfile`.

  Example:
  ```bash
  make install CONFIG=/etc/caddy/other-caddyfile
  ```

### Examples

1. **Build Caddy with Custom Plugins**:
   ```bash
   make build PLUGINS="--with github.com/caddyserver/replace-response"
   ```

2. **Install Caddy Using a Different Configuration File**:
   ```bash
   make install CONFIG=/etc/caddy/other-caddyfile
   ```

3. **Restore a Previous Caddy Binary**:
   If you need to restore a previous version of the Caddy binary, you can use the `restore` target:

   ```bash
   make restore file=./caddy_20241015_190900
   ```

4. **Clean Up Artifacts**:
   To remove build artifacts and backup files, run:
   ```bash
   make clean
   ```

## How It Works

1. **Building Caddy**:
   The `build` target compiles the Caddy binary using the specified plugins, which you can modify via the `PLUGINS` variable.

2. **Testing**:
   The `test` target ensures that the new Caddy binary is compatible with the current configuration file before installation. If the configuration is invalid, the build process will stop.

3. **Installing**:
   The `install` target backs up the existing Caddy binary before installing the new version. The backup is stored with a timestamp, allowing for easy restoration.

4. **Restoring**:
   The `restore` target lets you revert to a previous version of Caddy by specifying the backup file.

5. **Restarting**:
   The `restart` target restarts the Caddy service to apply changes or for troubleshooting.

6. **`make all`:**
   The `all` target runs the entire process in sequence: 
   
   - **Build**: It compiles the Caddy binary with the specified plugins.
   - **Test**: It validates the new binary against the current configuration to ensure it’s functional.
   - **Install**: If the test passes, the new binary is installed, and the old one is backed up.
   - **Restart**: Finally, the Caddy service is restarted to apply the changes.
   
   `make all` ensures that every step is performed in order and no installation happens if the configuration test fails.

## Related Projects

This project is built upon the [Caddy Web Server](https://github.com/caddyserver/caddy) and makes use of the [xcaddy](https://github.com/caddyserver/xcaddy) tool for building custom versions of Caddy with plugins.

Caddy is a powerful, extensible, and easy-to-use web server written in Go. For more information about Caddy, check out the official [Caddy repository](https://github.com/caddyserver/caddy).

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

