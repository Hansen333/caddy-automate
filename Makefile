# Title: Caddy Build Automation Makefile
# Purpose: This Makefile automates the process of building, testing, installing, and restoring the Caddy server with custom plugins.
#          It provides an easy way to modify build options for Caddy plugins and ensures the configuration is valid before installation.

# Variables
XCADDY := xcaddy
CADDY_BINARY := /usr/bin/caddy
BACKUP_FILE := ./caddy_$(shell date +%Y%m%d_%H%M%S)
NEW_BINARY := ./caddy
CADDY_CONFIG := /etc/caddy/Caddyfile
PLUGINS ?= --with github.com/caddy-dns/cloudflare --with github.com/caddy-dns/route53 --with github.com/caddyserver/replace-response

# Default target: Help menu
.PHONY: help
help:
	@echo "------------------------------------------"
	@echo " Caddy Build Automation Makefile"
	@echo "------------------------------------------"
	@echo ""
	@echo "Purpose:"
	@echo "  This Makefile automates the process of building, testing,"
	@echo "  installing, and restoring the Caddy server with custom plugins."
	@echo "  It ensures the Caddy configuration is valid before installing"
	@echo "  a new version."
	@echo ""
	@echo "Usage: make [TARGET] [VARIABLES]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?#"} /^[a-zA-Z_-]+:.*?#/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@echo "  PLUGINS=\"<plugin-list>\"  Custom plugins to include in the Caddy build."
	@echo "                            Default: $(PLUGINS)"
	@echo "  CONFIG=\"<path-to-config>\" Caddy configuration file path."
	@echo "                            Default: $(CADDY_CONFIG)"
	@echo ""
	@echo "Examples:"
	@echo "  make build PLUGINS=\"--with github.com/caddyserver/replace-response\""
	@echo "  make install CONFIG=/etc/caddy/other-caddyfile"
	@echo ""

# Default target, equivalent to 'make all'
.PHONY: all
all: build test install restart  # Build, test, install, and restart Caddy

# Build Caddy binary with specified plugins
.PHONY: build
build:  # Build the Caddy binary with specified plugins
	@echo "Building Caddy with plugins: $(PLUGINS)"
	$(XCADDY) build $(PLUGINS)

# Test the new Caddy binary with the current live config
.PHONY: test
test:  # Test the new Caddy binary with the current live config before installing
	@echo "Testing new Caddy binary with current config..."
	@if $(NEW_BINARY) validate --config $(CADDY_CONFIG); then \
		echo "Test passed! New Caddy binary is valid."; \
	else \
		echo "Test failed! Caddy config or binary is invalid."; \
		exit 1; \
	fi

# Install Caddy binary after backing up the old one
.PHONY: install
install: build test  # Backup old Caddy binary and install new one
	@echo "Backing up existing Caddy binary to $(BACKUP_FILE)..."
	@if [ -f $(CADDY_BINARY) ]; then \
		cp $(CADDY_BINARY) $(BACKUP_FILE); \
		echo "Backup complete: $(BACKUP_FILE)"; \
	else \
		echo "No existing Caddy binary found, skipping backup."; \
	fi

	@echo "Installing new Caddy binary..."
	@install -m 755 $(NEW_BINARY) $(CADDY_BINARY)

	@echo "Installation complete! Caddy is now updated."

# Restore Caddy binary from backup and restart
.PHONY: restore
restore:  # Restore a previously backed-up Caddy binary and restart the service
	@if [ -z "$(file)" ]; then \
		echo "Error: You must specify a backup file to restore (e.g., make restore file=./caddy_20241015_190900)"; \
		exit 1; \
	fi
	@if [ ! -f $(file) ]; then \
		echo "Error: Backup file '$(file)' not found."; \
		exit 1; \
	fi
	@echo "Restoring Caddy binary from $(file)..."
	@sudo cp $(file) $(CADDY_BINARY)
	@echo "Caddy binary restored from backup."

	@echo "Restarting Caddy service..."
	@sudo systemctl restart caddy
	@echo "Caddy service restarted."

# Restart the Caddy service
.PHONY: restart
restart:  # Restart the Caddy service
	@echo "Restarting Caddy service..."
	@sudo systemctl restart caddy
	@echo "Caddy service restarted."

# Clean up build artifacts (if any), including backups
.PHONY: clean
clean:  # Clean up build artifacts and backups
	@echo "Cleaning up build artifacts..."
	@rm -f caddy
	@echo "Cleaning up backup files..."
	@rm -f ./caddy_*
	@echo "Cleanup complete."

