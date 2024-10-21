// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenMinable is IERC20 {
    function mint(address to, uint256 value) external;
    function decimals() pure external returns (uint8);
}

contract TronPuppy is ERC20, ERC20Capped, Ownable, ITokenMinable {

    uint256 public constant MAX_SUPPLY = 1_000_000_000_000;
    uint8 public constant PRE_MINE_PERCENT = 10;

    address public minter;

    event MinterChanged(address indexed newMinter);

    error OnlyMinter(address account);

    modifier onlyMinter() {
        if (minter != _msgSender()) {
            revert OnlyMinter(_msgSender());
        }
        _;
    }

    constructor()
        ERC20("TronPuppy", "TPUPPY")
        ERC20Capped(MAX_SUPPLY * (10 ** uint256(decimals())))
        Ownable(_msgSender())
    {
        _mint(msg.sender, PRE_MINE_PERCENT * MAX_SUPPLY * (10 ** uint256(decimals())) / 100);
    }

    function decimals() public pure override(ERC20, ITokenMinable) returns (uint8) {
        return 18;
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }

    function mint(address to, uint256 value) public onlyMinter {
        _mint(to, value);
    }

    function setMinter(address _minter) public onlyOwner {
        minter = _minter;
        emit MinterChanged(minter);
    }
}
