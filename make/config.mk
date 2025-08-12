# Configuration & Info Targets
# =============================

.PHONY: configure show-config

configure: pip-install-dev ## Interactive configuration picker
	@$(PYTHON) configure.py

show-config: pip-install-dev ## Show current configuration
	@echo "Current configuration:"
	@$(PYTHON) configure.py --show

reminders: pip-install-dev ## Show post-setup reminders
	@$(PYTHON) configure.py --reminders