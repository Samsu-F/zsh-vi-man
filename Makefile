.PHONY: test test-load test-keybinding test-config test-all check clean help

# Default target
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

test: ## Run pattern matching tests
	@echo "Running pattern tests..."
	@zsh test_patterns.zsh

test-load: ## Test plugin loading
	@echo "Testing plugin loading..."
	@zsh -c 'source ./zsh-vi-man.plugin.zsh && \
		if (( $${+functions[zvm-man]} )); then \
			echo "PASS: Plugin loaded successfully"; \
		else \
			echo "FAIL: Plugin failed to load"; \
			exit 1; \
		fi'

test-keybinding: ## Test keybinding configuration
	@echo "Testing keybindings..."
	@zsh -c 'bindkey -v && \
		source ./zsh-vi-man.plugin.zsh && \
		if bindkey -M vicmd | grep -q "\"K\" zvm-man"; then \
			echo "PASS: Keybinding configured correctly"; \
		else \
			echo "FAIL: Keybinding not found"; \
			exit 1; \
		fi'

test-config: ## Test custom configuration
	@echo "Testing custom configuration..."
	@zsh -c 'export ZVM_MAN_KEY="?" && \
		bindkey -v && \
		source ./zsh-vi-man.plugin.zsh && \
		if bindkey -M vicmd | grep -q "\"?\" zvm-man"; then \
			echo "PASS: Custom configuration works"; \
		else \
			echo "FAIL: Custom configuration failed"; \
			exit 1; \
		fi'

test-all: test test-load test-keybinding test-config ## Run all tests
	@echo ""
	@echo "All tests completed successfully"

check: test-all ## Run all tests (alias for test-all)
	@echo ""
	@echo "All checks passed"

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@rm -f test_*.zsh 2>/dev/null || true
	@echo "Cleanup complete"

install-local: ## Install to local zsh config
	@echo "Installing to ~/.zsh-vi-man..."
	@mkdir -p ~/.zsh-vi-man
	@cp -r *.zsh ~/.zsh-vi-man/
	@echo "Installed to ~/.zsh-vi-man"
	@echo ""
	@echo "Add this to your .zshrc:"
	@echo "  source ~/.zsh-vi-man/zsh-vi-man.plugin.zsh"

demo: ## Show a quick demo of the plugin
	@echo "==================================="
	@echo "  zsh-vi-man Demo"
	@echo "==================================="
	@echo ""
	@echo "1. Type a command:    ls -la"
	@echo "2. Press Escape:      (enter vi normal mode)"
	@echo "3. Move cursor:       to 'ls' or '-la'"
	@echo "4. Press K:           opens man page"
	@echo ""
	@echo "Try it yourself!"
	@echo ""
	@echo "To test the plugin interactively:"
	@echo "  zsh"
	@echo "  source ./zsh-vi-man.plugin.zsh"
	@echo "  # Now type commands and press Esc, then K"

