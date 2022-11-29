// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage  {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => SuperSoldier) public tokenIdToSuperSoldier;

    struct SuperSoldier {
        uint256 level;
        uint256 speed;
        uint256 energy;
        uint256 society;
    }
   

    
    constructor() ERC721 ("Chain Battles", "CBTLS"){
    }

    function random(uint256 number) public view returns(uint256[4] memory){
        uint256[4] memory  numbers;
        for (uint256 i = 0; i < 4; i++){
            numbers[i] =uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number; 
        }
        return numbers; 
    }

    function mint() public {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    uint256[4] memory rns = random(20);
    tokenIdToSuperSoldier[newItemId].level = 1;
    tokenIdToSuperSoldier[newItemId].speed = 40 + rns[0];
    tokenIdToSuperSoldier[newItemId].energy = rns[2];
    tokenIdToSuperSoldier[newItemId].society = rns[1]*2;
    _setTokenURI(newItemId, getTokenURI(newItemId));
}

function train(uint256 tokenId) public {
    require(_exists(tokenId), "Please use an existing token");
    require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
    SuperSoldier memory currentSuperSoldier = tokenIdToSuperSoldier[tokenId];
    //tokenIdToSuperSoldier[tokenId] = currentSuperSoldier +1 ;
    _setTokenURI(tokenId, getTokenURI(tokenId));
}

function generateCharacter(uint256 tokenId) public view returns(string memory){

    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Super Soldier",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed ",getSpeed(tokenId),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Energy ",getEnergy(tokenId),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Society ",getSociety(tokenId),'</text>','</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );
    }

function getLevels(uint256 tokenId) public view returns (string memory) {
    uint256 levels = tokenIdToSuperSoldier[tokenId].level;
    return levels.toString();
}
function getSpeed(uint256 tokenId) public view returns (string memory) {
    uint256 speed = tokenIdToSuperSoldier[tokenId].speed;
    return speed.toString();
}
function getEnergy(uint256 tokenId) public view returns (string memory) {
    uint256 energy = tokenIdToSuperSoldier[tokenId].energy;
    return energy.toString();
}
function getSociety(uint256 tokenId) public view returns (string memory) {
    uint256 society = tokenIdToSuperSoldier[tokenId].society;
    return society.toString();
}



function getTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Chain Battles #2', tokenId.toString(), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
}





}
