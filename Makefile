npm_path := $(shell command -v npm 2>/dev/null)

# Setting the token to an empty string disables authentication and thus makes the redirect file unnecessary.
# When running in a Codespace, it will still be behind GitHub authentication unless you explicitly make it public.
# https://docs.github.com/en/codespaces/developing-in-codespaces/forwarding-ports-in-your-codespace
jupyter_opts := --IdentityProvider.token='' --ServerApp.password='' --ServerApp.disable_check_xsrf=True --ServerApp.use_redirect_file=False --ServerApp.root_dir="${PWD}/notebooks"
jupyter_opts_codespace := --ServerApp.allow_origin='*' --ServerApp.custom_display_url="https://${CODESPACE_NAME}-8888.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}" --ip=0.0.0.0 --no-browser

.PHONY: jupyter tslab npm venv pip

# Running `make` without specifying a target runs the first (this one).
jupyter:
ifeq ($(CODESPACES), true)
	@jupyter lab $(jupyter_opts) $(jupyter_opts_codespace)
else
	@jupyter lab $(jupyter_opts)
endif

tslab: npm
ifdef npm_path
	@rm -rf "${HOME}/.local/share/jupyter/kernels/jslab"
	@rm -rf "${HOME}/.local/share/jupyter/kernels/tslab"
	@python "${PWD}/node_modules/tslab/python/install.py" --tslab="${PWD}/node_modules/.bin/tslab"
endif

npm:
ifdef npm_path
	@npm install
endif

venv:
	@python -m venv venv

pip:
	@python -m pip install -r requirements.txt
