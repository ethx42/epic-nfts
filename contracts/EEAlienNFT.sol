// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import 'base64-sol/base64.sol';

string constant baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
string constant closingSvg = "</text></svg>";
uint8 constant maxTokensAllowance = 70;

contract EEALienNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string[] firstWords = ["Countermand", "Prompt", "Luminesce", "Miscount", "Synchronize", "Burlesque", "Overdraw", "Scold", "Cocainize", "Admit", "Ice", "Derange", "Jockey", "Centralise", "Assume", "Ventilate", "Redouble", "Tug", "Rafter", "Commingle", "Bobble", "Bespatter", "Verdigris", "Clerk", "expostulate", "Cluck", "Punish", "Probate", "Regorge", "Mature"];
  string[] secondWords = ["Contextual", "Hearable", "Handicapped", "Yogic", "Projecting", "Sanguine", "Utterable", "Nonunionized", "Fourscore", "Frontal", "Virtuous", "Pressing", "Citified", "Alary", "Stinky", "Tedious", "Neuronic", "Highborn", "Annelidan", "Jaded", "Smooth", "Nee", "Veensy", "Resigned", "Tulticellular", "Reamanlike", "Biagonalizable", "Oedheaded", "Atherosclerotic", "Hypophysial"];
  string[] thirdWords = ["Instructorship", "Peddling", "Inventor", "Subspecies", "Greed", "Eighty", "Kvass", "Finance", "Replenishment", "Deserter", "Bel", "Waistcoat", "Cager", "Katharsis", "Poop", "Unacceptability", "Setoff", "Gerbium", "Cradlesong", "Advantage", "Nonmetal", "Annunciator", "Doorkeeper", "Gentombment", "Dysphoria", "Rote", "Foreskin", "Inexorableness", "Disguise", "Caddy"];

  struct Collector {
    address ownerAddress;
    address contractAddress;
    uint256[] itemIds;
  }

  mapping(address => Collector) internal owners;

  event NewEEALienNFTMinted(address sender, uint256 tokenId, string tokenSvg);
  event TotalMintedTokens(uint256 totalMintedTokens);
  event NoMoreTokens(string message);
  event OwnedItemsByAddress(uint256[] items);
  event GetMetadata(string metadata);

  constructor() ERC721 ("EEAlien", "EEA") {
    console.log("This is my EEAlien NFT contract. Woah!");
  }

  function pickRandomWord(uint256 tokenId, string memory keyword, string[] memory arrayOfWords) internal pure returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(keyword, Strings.toString(tokenId))));
    rand = rand % arrayOfWords.length;
    return arrayOfWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function mintAnNFT() public {
    if (_tokenIds.current() >= maxTokensAllowance) {
      emit TotalMintedTokens(_tokenIds.current());
      emit NoMoreTokens("There are not more available Tokens. 10/10 have been minted");
      return;
    }

    uint256 newItemId = _tokenIds.current();

    string memory first = pickRandomWord(newItemId, "MURMUR", firstWords);
    string memory second = pickRandomWord(newItemId, "FORNEUS", secondWords);
    string memory third = pickRandomWord(newItemId, "STOLAS", thirdWords);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, closingSvg));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            combinedWord,
            '", "description": "Minimal squared NFTs.", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

    string memory metadata = string(
        abi.encodePacked(
          "https://nftpreview.0xdev.codes/?code=",
          finalTokenUri
        )
      );

    console.log("\n--------------------");
    console.log(metadata);
    console.log("--------------------\n");
    
    emit GetMetadata(metadata);
    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);

    owners[msg.sender].itemIds.push(newItemId); 

  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEEALienNFTMinted(msg.sender, newItemId, finalSvg);
    emit TotalMintedTokens(_tokenIds.current());
  }

  function getMyOwnedTokens() public returns (uint256[] memory) {    
    emit OwnedItemsByAddress(owners[msg.sender].itemIds);
   
    return owners[msg.sender].itemIds;
  }

  function getTotalNFTsMintedSoFar() public returns (uint256) {
    emit TotalMintedTokens(_tokenIds.current());

    return _tokenIds.current();
  }
}
