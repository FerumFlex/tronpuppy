SHARKJS = /Users/pomeschenkoanton/Library/pnpm/nodejs_current/bin/snarkjs
LEVEL = 10
NAME = mining

.PHONY: all
all: clean compile generate setup export proof call

.PHONY: clean
clean:
	rm -f ./tmp/*

.PHONY: compile
compile:
	circom $(NAME).circom --r1cs --wasm --sym --c -o $(NAME)/

.PHONY: generate
generate:
	node $(NAME)/$(NAME)_js/generate_witness.js $(NAME)/$(NAME)_js/$(NAME).wasm input.json ./tmp/witness_$(LEVEL).wtns

.PHONY: info
info:
	$(SHARKJS) r1cs info $(NAME)/$(NAME).r1cs

.PHONY: verify
verify:
	$(SHARKJS) zkey verify $(NAME)/$(NAME).r1cs ./tmp/pot$(LEVEL)_final.ptau ./tmp/level_$(LEVEL)_final.zkey

.PHONY: setup
setup:
	$(SHARKJS) powersoftau new bn128 $(LEVEL) ./tmp/pot$(LEVEL)_0000.ptau -v
	$(SHARKJS) powersoftau contribute ./tmp/pot$(LEVEL)_0000.ptau ./tmp/pot$(LEVEL)_0001.ptau --name="First contribution" -v
	$(SHARKJS) powersoftau prepare phase2 ./tmp/pot$(LEVEL)_0001.ptau ./tmp/pot$(LEVEL)_final.ptau -v
	$(SHARKJS) groth16 setup $(NAME)/$(NAME).r1cs ./tmp/pot$(LEVEL)_final.ptau ./tmp/level_$(LEVEL).zkey
	$(SHARKJS) zkey contribute ./tmp/level_$(LEVEL).zkey ./tmp/level_$(LEVEL)_final.zkey --name="1st Contributor Name" -v

.PHONY: export
export:
	$(SHARKJS) zkey export verificationkey ./tmp/level_$(LEVEL)_final.zkey ./tmp/verification_key_$(LEVEL).json
	$(SHARKJS) zkey export solidityverifier ./tmp/level_$(LEVEL)_final.zkey ./forge/src/verifier.sol
	cp ./tmp/level_$(LEVEL)_final.zkey ./src/circuit/final.zkey
	cp ./tmp/verification_key_$(LEVEL).json ./src/circuit/verification_key.json
	cp ./$(NAME)/$(NAME)_js/$(NAME).wasm ./src/circuit/circuit.wasm

.PHONY: proof
proof:
	$(SHARKJS) groth16 prove ./tmp/level_$(LEVEL)_final.zkey ./tmp/witness_$(LEVEL).wtns ./tmp/proof_$(LEVEL).json ./tmp/public_$(LEVEL).json
	$(SHARKJS) groth16 verify ./tmp/verification_key_$(LEVEL).json ./tmp/public_$(LEVEL).json ./tmp/proof_$(LEVEL).json

.PHONY: call
call:
	$(SHARKJS) zkey export soliditycalldata ./tmp/public_$(LEVEL).json ./tmp/proof_$(LEVEL).json
