# Makefile for Ansible Project

# Variables
PLAYBOOK_DIR := playbooks
MAIN_PLAYBOOK := $(PLAYBOOK_DIR)/site.yml
# INVENTORY is defined in ansible.cfg, but can be overridden:
# INVENTORY := inventory/hosts.yml
ANSIBLE_PLAYBOOK := ansible-playbook
ANSIBLE_LINT := ansible-lint

# Default target
.PHONY: all
all: run

# Lint the entire project
.PHONY: lint
lint:
	@echo "==> Linting Ansible project..."
	$(ANSIBLE_LINT) .

# Check playbook syntax
.PHONY: syntax-check
syntax-check:
	@echo "==> Checking syntax for $(MAIN_PLAYBOOK)..."
	$(ANSIBLE_PLAYBOOK) --syntax-check $(MAIN_PLAYBOOK)

# Run the main playbook
.PHONY: run
run: syntax-check
	@echo "==> Running main playbook: $(MAIN_PLAYBOOK)..."
	$(ANSIBLE_PLAYBOOK) $(MAIN_PLAYBOOK) $(EXTRA_ARGS)

# Run a specific playbook (e.g., make playbook PB=playbooks/deploy_app.yml)
.PHONY: playbook
playbook:
	@echo "==> Checking syntax for $(PB)..."
	$(ANSIBLE_PLAYBOOK) --syntax-check $(PB)
	@echo "==> Running playbook: $(PB)..."
	$(ANSIBLE_PLAYBOOK) $(PB) $(EXTRA_ARGS)

# Run the main playbook with specific tags (e.g., make tags TAGS=docker,nginx)
.PHONY: tags
tags: syntax-check
	@echo "==> Running main playbook with tags: $(TAGS)..."
	$(ANSIBLE_PLAYBOOK) $(MAIN_PLAYBOOK) --tags "$(TAGS)" $(EXTRA_ARGS)

# Clean up retry files
.PHONY: clean
clean:
	@echo "==> Cleaning up *.retry files..."
	@find . -name "*.retry" -type f -delete

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  lint				: Lint the Ansible project using ansible-lint."
	@echo "  syntax-check		: Check the syntax of the main playbook ($(MAIN_PLAYBOOK))."
	@echo "  run (or all)		: Run the main playbook ($(MAIN_PLAYBOOK))."
	@echo "  playbook PB=<path>	: Run a specific playbook (e.g., make playbook PB=playbooks/other.yml)."
	@echo "  tags TAGS=<tags>	: Run the main playbook with specific tags (e.g., make tags TAGS=docker,nginx)."
	@echo "  Clean				: Remove *.retry files."
	@echo "  help				: Show this help message."
	@echo ""
	@echo "You can pass extra arguments to ansible-playbook using EXTRA_ARGS="
	@echo "Example: make run EXTRA_ARGS=\"--limit myhost -vv\""
