pragma circom 2.0.0;

include "./circomlib/circuits/poseidon.circom";

template Mining() {
    // Input signals
    signal input blockHash[8];
    signal input address[5];
    signal input nonce;

    // Output signal
    signal output difficulty;

    // Intermediate signals
    signal hashed;

    component poseidon = Poseidon(14);

    for (var i = 0; i < 8; i++) {
        poseidon.inputs[i] <== blockHash[i];
    }
    for (var i = 0; i < 5; i++) {
        poseidon.inputs[i + 8] <== address[i];
    }
    poseidon.inputs[13] <== nonce;

    hashed <== poseidon.out;

    component poseidon2 = Poseidon(1);
    poseidon2.inputs[0] <== hashed;

    difficulty <== poseidon2.out;
}

component main { public [blockHash, address]} = Mining();
