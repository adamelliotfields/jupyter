python_path := $(shell command -v python 2>/dev/null)
pipenv_path := $(shell command -v pipenv 2>/dev/null)
npm_path := $(shell command -v npm 2>/dev/null)
npx_path := $(shell command -v npx 2>/dev/null)

# Setting the token to an empty string disables authentication and thus makes the redirect file unnecessary.
# When running in a Codespace, it will still be behind GitHub authentication unless you explicitly make it public.
# https://docs.github.com/en/codespaces/developing-in-codespaces/forwarding-ports-in-your-codespace
jupyter_opts := --IdentityProvider.token='' --ServerApp.use_redirect_file=False --ServerApp.root_dir="${PWD}/notebooks"
jupyter_opts_codespace := --ServerApp.allow_origin='*' --ServerApp.custom_display_url="https://${CODESPACE_NAME}-8888.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}" --ip=0.0.0.0 --no-browser

.PHONY: all pip npm tslab jupyter

all: pip npm tslab

# requires ~/.local/bin to be in your $PATH
pip:
ifdef pipenv_path
	@pipenv install
else
	@python -m pip install --user pipenv
	@pipenv install
endif

npm:
ifdef npm_path
	@npm install
else
	$(error npm is not installed)
endif

tslab:
ifdef npx_path
	@npx tslab install --python="${python_path}" --binary="${PWD}/node_modules/.bin/tslab"
else
	$(error npx is not installed)
endif

jupyter:
ifeq ($(CODESPACES), true)
	@pipenv run jupyter lab $(jupyter_opts) $(jupyter_opts_codespace)
else
	@pipenv run jupyter lab $(jupyter_opts)
endif