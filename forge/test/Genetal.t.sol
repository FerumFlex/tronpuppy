// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/TronPuppy.sol";
import "src/Miner.sol";

contract TestContract is Test {
    TronPuppy token;
    Miner miner;

    address recipient = 0x85Dc978949A3F8E26cCd5DACB5a047796f8F2e1f;

    function setUp() public {
        token = new TronPuppy();

        miner = new Miner();

        token.setMinter(address(miner));
        miner.setToken(address(token));
    }

    function testGeneral() public {
        assertEq(token.decimals(), 18);

        uint256 selfBalance = token.balanceOf(address(this));
        assertEq(selfBalance, token.totalSupply());

        uint256 cap = token.cap();
        assertEq(cap, selfBalance * 10);
    }

    function testMine() public {
        uint256 balanceBefore = token.balanceOf(recipient);

        uint256 numBlobksMinedBefore = miner.numBlobksMined();
        assertEq(numBlobksMinedBefore, 0);

        uint256 epoch = miner.getEpoch();
        assertEq(epoch, 1);

        uint256 minePerBlock = miner.minePerBlock();
        assertEq(minePerBlock, 5_000_000 * 10 ** token.decimals());

        miner.mine(
            [
                0x0322e1ced929835745b02551a9189c6aae1ce2010a43bfa96263fc3f558743c3,
                0x0949b58e31f2ccb50b66126ad6792f26164add1faf06e32adbd71f0b35bb0035
            ],
            [
                [
                    0x136f7c03dfee20fa8653c61c6bc31f0b3186dff66d6428adff5e5d384994cf40,
                    0x22c098cdf83fc8677145c2a2c4bbbed1e95606056e4bc25d1e290ea68a3bcd35
                ],
                [
                    0x14bc07b9d61794facc393611b5a84e27c3026d1a1feefff4a792773aba5475a8,
                    0x183c4bb1e649558b0e40b889f997493d394e6078053e6a7d2cc825686fb04f03
                ]
            ],
            [
                0x1d927cdd47e7c3c3e250e46dc9e914fe5e306bf8b2d940877b46f5f980d97fa8,
                0x0ca0a0cbef35202c7dd5b4901466622064ba953f236ca0dea47ccea7db153993
            ],
            [
                0x2697839f8a7401e8352fee6e52f4dc33e5304a36d232c655de4aec9764ad4e6c,
                0x000000000000000000000000000000000000000000000000000000007d3ae1b4,
                0x00000000000000000000000000000000000000000000000000000000781fb59e,
                0x00000000000000000000000000000000000000000000000000000000fa11c842,
                0x0000000000000000000000000000000000000000000000000000000180c9afc0,
                0x000000000000000000000000000000000000000000000000000000000e4e8f3b,
                0x00000000000000000000000000000000000000000000000000000001d18ed0e8,
                0x00000000000000000000000000000000000000000000000000000001b15e9169,
                0x00000000000000000000000000000000000000000000000000000000e84f37f7,
                0x000000000000000000000000000000000000000000000000000000016f8f2e1f,
                0x00000000000000000000000000000000000000000000000000000000b5a04779,
                0x000000000000000000000000000000000000000000000000000000006ccd5dac,
                0x0000000000000000000000000000000000000000000000000000000149a3f8e2,
                0x0000000000000000000000000000000000000000000000000000000185dc9789
            ]
        );

        uint256 balanceAfter = token.balanceOf(recipient);
        assertEq(balanceAfter, balanceBefore + minePerBlock);

        uint256 numBlobksMinedAfter = miner.numBlobksMined();
        assertEq(numBlobksMinedAfter, numBlobksMinedBefore + 1);
    }

    function testMineWrongProof() public {
        uint256 numBlobksMinedBefore = miner.numBlobksMined();
        assertEq(numBlobksMinedBefore, 0);

        vm.expectRevert("Invalid proof");
        miner.mine(
            [
                0x0322e1ced929835745b02551a9189c6aae1ce2010a43bfa96263fc3f558743c3,
                0x0949b58e31f2ccb50b66126ad6792f26164add1faf06e32adbd71f0b35bb0035
            ],
            [
                [
                    0x136f7c03dfee20fa8653c61c6bc31f0b3186dff66d6428adff5e5d384994cf40,
                    0x22c098cdf83fc8677145c2a2c4bbbed1e95606056e4bc25d1e290ea68a3bcd35
                ],
                [
                    0x14bc07b9d61794facc393611b5a84e27c3026d1a1feefff4a792773aba5475a8,
                    0x183c4bb1e649558b0e40b889f997493d394e6078053e6a7d2cc825686fb04f03
                ]
            ],
            [
                0x1d927cdd47e7c3c3e250e46dc9e914fe5e306bf8b2d940877b46f5f980d97fa8,
                0x0ca0a0cbef35202c7dd5b4901466622064ba953f236ca0dea47ccea7db153993
            ],
            [
                0x2697839f8a7401e8352fee6e52f4dc33e5304a36d232c655de4aec9764ad4e6a,
                0x000000000000000000000000000000000000000000000000000000007d3ae1b4,
                0x00000000000000000000000000000000000000000000000000000000781fb59e,
                0x00000000000000000000000000000000000000000000000000000000fa11c842,
                0x0000000000000000000000000000000000000000000000000000000180c9afc0,
                0x000000000000000000000000000000000000000000000000000000000e4e8f3b,
                0x00000000000000000000000000000000000000000000000000000001d18ed0e8,
                0x00000000000000000000000000000000000000000000000000000001b15e9169,
                0x00000000000000000000000000000000000000000000000000000000e84f37f7,
                0x000000000000000000000000000000000000000000000000000000016f8f2e1f,
                0x00000000000000000000000000000000000000000000000000000000b5a04779,
                0x000000000000000000000000000000000000000000000000000000006ccd5dac,
                0x0000000000000000000000000000000000000000000000000000000149a3f8e2,
                0x0000000000000000000000000000000000000000000000000000000185dc9789
            ]
        );

        uint256 numBlobksMinedAfter = miner.numBlobksMined();
        assertEq(numBlobksMinedAfter, numBlobksMinedBefore);
    }
}
