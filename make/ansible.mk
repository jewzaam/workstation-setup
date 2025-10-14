# Ansible Operations Targets
# ==========================

.PHONY: collections run run-debug run-cursor run-ntpd

collections: pip-install-dev ## Install required Ansible collections locally
	@ansible-galaxy collection install -r $(ANSIBLE_DIR)/requirements.yml -p $(COLLECTIONS_DIR)
	@echo "✅ Collections installed"

run: collections ## Run setup using current configuration selections
	@ansible-playbook --syntax-check -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK)
	@$(PYTHON) -c "import yaml; config=yaml.safe_load(open('config.yml')); tags=[k.replace('_', '-') for k,v in config.items() if v and k not in ['component_descriptions', 'default_selections']]; print('ansible-playbook -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --ask-become-pass ' + ('--tags ' + ','.join(tags) if tags else ''))" | bash
	@echo ""
	@echo "✅ Setup complete!"
	@$(PYTHON) configure.py --reminders

run-debug: collections ## Run setup with verbose debugging output
	@ansible-playbook --syntax-check -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK)
	@$(PYTHON) -c "import yaml; config=yaml.safe_load(open('config.yml')); tags=[k.replace('_', '-') for k,v in config.items() if v and k not in ['component_descriptions', 'default_selections']]; print('ansible-playbook -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --ask-become-pass -vvv ' + ('--tags ' + ','.join(tags) if tags else ''))" | bash
	@echo ""
	@echo "✅ Debug run complete!"
	@$(PYTHON) configure.py --reminders

run-cursor: collections ## Run only the cursor role for Cursor installation
	@ansible-playbook --syntax-check -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --tags cursor
	@ansible-playbook -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --tags cursor --ask-become-pass
	@echo ""
	@echo "✅ Cursor setup complete!"

run-ntpd: collections ## Run only the ntpd role for NTP configuration
	@ansible-playbook --syntax-check -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --tags ntpd
	@ansible-playbook -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --tags ntpd --ask-become-pass
	@echo ""
	@echo "✅ NTP daemon setup complete!"
