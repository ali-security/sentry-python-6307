SHELL = /bin/bash

VENV_PATH = .venv

help:
	@echo "Thanks for your interest in the Sentry Python SDK!"
	@echo
	@echo "make lint: Run linters"
	@echo "make test: Run basic tests (not testing most integrations)"
	@echo "make test-all: Run ALL tests (slow, closest to CI)"
	@echo "make format: Run code formatters (destructive)"
	@echo "make aws-lambda-layer: Build AWS Lambda layer directory for serverless integration"
	@echo
	@echo "Also make sure to read ./CONTRIBUTING.md"
	@false

.venv:
	virtualenv -ppython3 $(VENV_PATH)
	$(VENV_PATH)/bin/pip install --index-url 'https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' tox

dist: .venv
	rm -rf dist dist-serverless build
	$(VENV_PATH)/bin/python setup.py sdist bdist_wheel
.PHONY: dist

format: .venv
	$(VENV_PATH)/bin/tox -e linters --notest
	.tox/linters/bin/black .
.PHONY: format

test: .venv
	@$(VENV_PATH)/bin/tox -e py3.9
.PHONY: test

test-all: .venv
	@TOXPATH=$(VENV_PATH)/bin/tox sh ./scripts/runtox.sh
.PHONY: test-all

check: lint test
.PHONY: check

lint: .venv
	@set -e && $(VENV_PATH)/bin/tox -e linters || ( \
		echo "================================"; \
		echo "Bad formatting? Run: make format"; \
		echo "================================"; \
		false)
.PHONY: lint

apidocs: .venv
	@$(VENV_PATH)/bin/pip install --index-url 'https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' --editable .
	@$(VENV_PATH)/bin/pip install --index-url 'https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' -U -r ./docs-requirements.txt
	@$(VENV_PATH)/bin/sphinx-build -W -b html docs/ docs/_build
.PHONY: apidocs

apidocs-hotfix: apidocs
	@$(VENV_PATH)/bin/pip install --index-url 'https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' ghp-import
	@$(VENV_PATH)/bin/ghp-import -pf docs/_build
.PHONY: apidocs-hotfix

aws-lambda-layer: dist
	$(VENV_PATH)/bin/pip install --index-url 'https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' urllib3
	$(VENV_PATH)/bin/pip install --index-url 'https://:2023-03-16T15:53:34.069817Z@time-machines-pypi.sealsecurity.io/' certifi
	$(VENV_PATH)/bin/python -m scripts.build_aws_lambda_layer
.PHONY: aws-lambda-layer
