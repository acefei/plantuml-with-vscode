.PHONY: help
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

NAME := plantuml-server
IMAGE := plantuml/$(NAME):tomcat
SERVER_IP := $(shell ip a s `ip r | sed -n '/^default/s/.*\(dev [^ ]*\).*/\1/p'` | sed -n '/inet/s/.*inet \([^\/]*\).*/\1/p')
SERVER_PORT := 8080
VSCODE_SETTING := $(PWD)/.vscode/settings.json

up: ## setup plantuml server
	@docker run --name=$(NAME) -d -p $(SERVER_PORT):8080 $(IMAGE) 
	@sed -i 's!www.plantuml.com/plantuml!$(SERVER_IP):$(SERVER_PORT)!' $(VSCODE_SETTING)
	@echo "The plantuml server is now listing to http://$(SERVER_IP):$(SERVER_PORT)"

log: ## check plantuml server log
	@docker logs $(NAME)

stop: ## stop & rm plantuml server
	@docker stop $(NAME) && docker rm $(NAME) >/dev/null
	@sed -i 's!$(SERVER_IP):$(SERVER_PORT)!www.plantuml.com/plantuml!' $(VSCODE_SETTING)

