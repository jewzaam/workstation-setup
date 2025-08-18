# Environment Setup Targets
# ========================

.PHONY: venv uv pip-install-dev clean

venv: ## Create Python virtual environment
	@if [ ! -d "$(VENV_DIR)" ]; then \
		printf "$(BLUE)Creating virtual environment...$(RESET)\n"; \
		python3 -m venv $(VENV_DIR); \
		printf "$(GREEN)✅ Virtual environment created$(RESET)\n"; \
	fi

uv: venv ## Install uv package manager
	@if [ ! -f "$(VENV_DIR)/bin/uv" ]; then \
		printf "$(BLUE)Installing uv...$(RESET)\n"; \
		$(PYTHON) -m ensurepip --upgrade; \
		$(PYTHON) -m pip install uv; \
		printf "$(GREEN)✅ uv installed$(RESET)\n"; \
	fi

pip-install-dev: uv ## Install development/test dependencies (e.g., ansible-lint) in venv
	@$(UV) pip install --upgrade pip >/dev/null
	@$(UV) pip install -r requirements-dev.txt
	@echo "✅ Dev/test dependencies installed in $(VENV_DIR)"

clean: ## Remove temporary and backup files
	# Python caches
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	# Ansible retry/logs and ansible temp dirs
	@find . -name "*.retry" -delete 2>/dev/null || true
	@rm -f $(ANSIBLE_DIR)/ansible.log 2>/dev/null || true
	@rm -rf .ansible 2>/dev/null || true
	# Local collections cache
	@rm -rf collections 2>/dev/null || true
	# Python virtual environment
	@rm -rf $(VENV_DIR) 2>/dev/null || true
	# Misc ignored artifacts
	@rm -rf dist build *.egg-info/ docs/_build site .pytest_cache .coverage htmlcov .tox local scratch logs 2>/dev/null || true
	@echo "✅ Cleanup completed"
