PUBKEY_PATH = ~/.ssh/sas.pub
PRIVKEY_PATH = ~/.ssh/sas

# target: help - Display callable targets
help:
	@echo "This makefile expects you to have terraform and docker installed"
	@echo "and DIGITALOCEAN_TOKEN env var (with a valid digital ocean api token) set\n"
	@echo "Available targets:"
	@egrep "^# target:" Makefile

# target: setup - Do basic setup
setup:
	cd terraform && terraform init

# target: build_app - Build the elixir app
build_app:
	bin/release build

# target: apply_cluster - Run terraform apply
apply_cluster:
	@PUBLIC_KEY_PATH=${PUBKEY_PATH} \
	 PRIVATE_KEY_PATH=${PRIVKEY_PATH} bin/cluster apply

# target: deploy - Build the app and then deploy
deploy: | build_app bootstrap_cluster

# target: destroy_cluster - Destroy the cluster via terraform
destroy_cluster:
	@cd terraform && terraform destroy -auto-approve \
		-var do_token=${DIGITALOCEAN_TOKEN} \
		-var private_key_path=${PRIVKEY_PATH}
