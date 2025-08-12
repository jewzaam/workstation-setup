# Ansible Operations Targets
# ==========================

.PHONY: collections run

collections: pip-install-dev ## Install required Ansible collections locally
	@ansible-galaxy collection install -r $(ANSIBLE_DIR)/requirements.yml -p $(COLLECTIONS_DIR)
	@echo "✅ Collections installed"

run: collections ## Run setup using current configuration selections
	@ansible-playbook --syntax-check -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK)
	@$(PYTHON) -c "import yaml; config=yaml.safe_load(open('config.yml')); tags=[k.replace('_', '-') for k,v in config.items() if v and k not in ['component_descriptions', 'default_selections']]; print('ansible-playbook -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK) --ask-become-pass ' + ('--tags ' + ','.join(tags) if tags else ''))" | bash
	@echo ""
	@echo "✅ Setup complete!"
	@$(PYTHON) configure.py --reminders
