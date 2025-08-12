# Linting & Quality Targets
# =========================

.PHONY: lint lint-python lint-ansible lint-samba-template

lint: pip-install-dev lint-python lint-ansible lint-samba-template ## Run all linting
	@echo "✅ All linting passed"

lint-python: pip-install-dev ## Lint Python files with ruff
	@ruff check configure.py
	@echo "✅ Python lint passed"

lint-ansible: collections ## Run ansible-lint validation
	@ansible-lint $(ANSIBLE_DIR)
	@echo "✅ Ansible lint passed"

lint-samba-template: ## Validate Samba configuration template
	@cd $(ANSIBLE_DIR) && python3 -c "from jinja2 import Template; import sys; t=Template(open('roles/samba/templates/smb.conf.j2').read()); t.render(samba_enabled=True, user_name='testuser', user_home='/home/testuser', ansible_hostname='testhost', samba_share_name='testhost-shared', samba_share_path='/home/testuser/shared', samba_share_comment='test', samba_browseable=True, samba_guest_ok=False, samba_writable=True, samba_create_mask='0644', samba_directory_mask='0755', samba_force_user='testuser', samba_force_group='testuser', samba_inherit_owner=True, samba_inherit_permissions=True)" > /dev/null 2>&1 && echo "✅ Samba template syntax valid" || (echo "❌ Samba template syntax error" && exit 1)
