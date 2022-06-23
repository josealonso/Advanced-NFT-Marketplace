//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./DataStructures.sol";

contract OurERC721Contract is ERC721, Ownable {
    using Counters for Counters.Counter;
    // generate a unique token id for each token we mint
    Counters.Counter private _tokenIdTracker;

    // name and symbol values should be retrieved from the proxy contract
    constructor() ERC721("", "") {}

    // only the contract owner will be allowed to mint tokens.
    function mint(address _to) public onlyOwner {
        super._mint(_to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://mydomain/metadata/"; // To be changed
    }
}
