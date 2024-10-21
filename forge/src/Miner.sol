// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "forge-std/console.sol";

import "./verifier.sol";
import "./TronPuppy.sol";

contract Miner is Groth16Verifier, Ownable, ReentrancyGuard {

    uint256 public constant NUM_BLOCKS_PER_EPOCH = 4320;
    uint256 public constant BLOCK_REWARD = 100_000_000;
    uint256 public constant MAX_INT = 2**256 - 1;
    uint256 public constant ADJUST_DIFFICULTY_PERIOD = 10;
    uint256 public constant ADJUST_DIFFICULTY_PERIOD_TRON = 3600;

    uint256 public numBlobksMined = 0;
    uint256 public periodStartBlockNumber = 0;
    uint256 public countInPeriod = 0;

    bytes32 public currentBlockHash;
    uint256 public currentDifficulty;
    ITokenMinable public token;

    constructor()
        Ownable(_msgSender())
    {
        currentBlockHash = 0xe84f37f7b15e9169d18ed0e80e4e8f3b80c9afc0fa11c842781fb59e7d3ae1b4;
        currentDifficulty = 1;
        periodStartBlockNumber = block.number;
        countInPeriod = 0;
    }

    function bytesToBool(bytes memory data) public pure returns (bool) {
        bool result;
        assembly {
            // Load the first byte of data, which is stored at the first 32-byte word of the bytes array
            result := mload(add(data, 0x20))
        }
        return result;
    }

    function mine(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256[14] calldata pubSignals
    ) public nonReentrant {
        // use external call, because verifier use low level code to return result
        bytes memory payload = abi.encodeWithSignature(
            "verifyProof(uint256[2],uint256[2][2],uint256[2],uint256[14])",
            pA, pB, pC, pubSignals
        );
        (bool success, bytes memory returnData) = address(this).call(payload);
        require(success && bytesToBool(returnData), "Invalid proof");

        uint256 target = pubSignals[0];
        bytes32 blockHash = bytes32(pubSignals[1] | pubSignals[2] << 32 | pubSignals[3] << 64 | pubSignals[4] << 96 | pubSignals[5] << 128 | pubSignals[6] << 160 | pubSignals[7] << 192 | pubSignals[8] << 224);
        address receiver = address(uint160(pubSignals[9] | pubSignals[10] << 32 | pubSignals[11] << 64 | pubSignals[12] << 96 | pubSignals[13] << 128));
        require(currentBlockHash == blockHash, "Invalid block hash");

        require(target <= currentTarget(), "Target is too high");

        currentBlockHash = keccak256(abi.encodePacked(blockHash, receiver, target));
        numBlobksMined += 1;

        // mint tokens
        token.mint(receiver, minePerBlock());

        if (countInPeriod >= ADJUST_DIFFICULTY_PERIOD) {
            uint256 actualTotalBlocks = block.number - periodStartBlockNumber;
            uint256 adjustmentFactor = 10000 * ADJUST_DIFFICULTY_PERIOD_TRON / actualTotalBlocks;

            currentDifficulty = currentDifficulty * adjustmentFactor / 10000;
            if (currentDifficulty <= 1) {
                currentDifficulty = 1;
            }

            periodStartBlockNumber = block.number;
            countInPeriod = 0;
        } else {
            countInPeriod += 1;
        }
    }

    function setToken(address _token) public onlyOwner {
        token = ITokenMinable(_token);
    }

    function getEpoch() public view returns (uint256) {
        return (numBlobksMined / NUM_BLOCKS_PER_EPOCH) + 1;
    }

    function minePerBlock() public view returns (uint256) {
        return BLOCK_REWARD * (10 ** token.decimals()) / (2 ** getEpoch());
    }

    function currentTarget() public view returns (uint256) {
        return MAX_INT / currentDifficulty;
    }

    function getParams() public view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bytes32
    ) {
        return (
            currentDifficulty,
            getEpoch(),
            minePerBlock(),
            currentTarget(),
            countInPeriod,
            numBlobksMined,
            periodStartBlockNumber,
            currentBlockHash
        );
    }
}