.PHONY: test
test:
	forge test -vvvv

.PHONY: compile
compile:
	forge compile

.PHONY: network
network:
	anvil

.PHONY: deploy-local
deploy-local:
	forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

.PHONY: deploy-nile
deploy-nile:
	$(MAKE) compile
	set -o allexport; source .env.nile; set +o allexport; . ../.venv/bin/activate; python script/deploy_tron_puppy.py
	$(MAKE) export

.PHONY: export
export:
	cp artifacts/TronPuppy.json ../src/src/contracts/TronPuppy.json
	cp artifacts/Miner.json ../src/src/contracts/Miner.json