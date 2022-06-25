//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyToken721A is ERC721AUpgradeable, OwnableUpgradeable {
    // Take note of the initializer modifiers.
    // - `initializerERC721A` for `ERC721AUpgradeable`.
    // - `initializer` for OpenZeppelin's `OwnableUpgradeable`.
    function initialize() public initializerERC721A initializer {
        __ERC721A_init("Something", "SMTH");
        __Ownable_init();
    }

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }
}
