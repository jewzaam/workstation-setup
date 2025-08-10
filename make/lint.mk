# Linting & Quality Targets
# =========================

.PHONY: lint lint-python lint-ansible

lint: pip-install-dev lint-python lint-ansible ## Run all linting
	@echo "✅ All linting passed"

lint-python: pip-install-dev ## Lint Python files with ruff
	@ruff check configure.py
	@echo "✅ Python lint passed"

lint-ansible: collections ## Run ansible-lint validation
	@ansible-lint $(ANSIBLE_DIR)
	@echo "✅ Ansible lint passed"
