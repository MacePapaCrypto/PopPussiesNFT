// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract PopPussiesPopPopMoreTests is ERC721Enumerable, Ownable, ERC2981 {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  address public oldContract = 0x4cE9Ba897Ceed455B167EdA9ED8973e882B35768;
  //Will be used for randomness using balances
  address private spiritContract = 0x5Cc61A78F164885776AA610fb0FE1257df78E59B;
  address private booContract = 0x841FAD6EAe12c286d1Fd18d1d525DFfA75C7EFFE;
  address private brushContract = 0x85dec8c4B2680793661bCA91a8F129607571863d;
  //Team wallets
  address[] private team = [
    0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, //5% - MacePapa - contract dev
    0x6EFF42A5Cbb01CEf1F3e1b8Cc714a6d62731A013, //5% - Munchies - frontend dev
    0x056abd53a55C187d738B4A982D36b4dFa506326A  //90% - Cinn - Artist
  ];
  uint256 public costFTM = 1000000;
  address private oathToken = 0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6;
  uint256 public costOATH = 200 ether;
  uint256 public maxSupply = 750;
  uint256 public maxMintAmount = 5;
  bool public publicPaused = true;
  address public giveawayAddr = 0x056abd53a55C187d738B4A982D36b4dFa506326A;
  uint256 constant private ROYALTIES_PERCENTAGE = 6;
  uint16[750] private ids;
  uint16 private index = 0;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    _setReceiver(address(giveawayAddr));
    _setRoyaltyPercentage(ROYALTIES_PERCENTAGE);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function getRandomBalances() private view returns (uint256 balances) {
      IERC20 _spirit = IERC20(spiritContract);
      IERC20 _boo = IERC20(booContract);
      IERC20 _brush = IERC20(brushContract);
      //Get balances of each Masterchef/Pair
      balances = (_spirit.balanceOf(
          0x9083EA3756BDE6Ee6f27a6e996806FBD37F6F093
      ) +
          _boo.balanceOf(0x2b2929E785374c651a81A63878Ab22742656DcDd) +
          _brush.balanceOf(0x452590b8Aa292b963a9d0f2B5E71bC7c927859b3));
  }

  function _pickRandomUniqueId(uint256 _random) private returns (uint256 id) {
      uint256 len = ids.length - index++;
      require(len > 0, "no ids left");
      uint256 randomIndex = _random % len;
      if(randomIndex < 375) {
        randomIndex += 375;
      }
      id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
      ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
      ids[len - 1] = 0;
  }


  // public
  function mintFTM(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    uint256 totalPayout = 0;
    require(!publicPaused, 'Mint is currently paused');
    require(_mintAmount > 0, 'Cannot mint 0');
    require(_mintAmount <= maxMintAmount, 'Amount to mint larger than max allowed');
    require(supply + _mintAmount <= maxSupply, 'Not enough mints left');

    if (msg.sender != owner()) {
      require(msg.value >= costFTM * _mintAmount);
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      uint256 _random = uint256(
          keccak256(
              abi.encodePacked(
                  //getRandomBalances(),
                  index,
                  msg.sender,
                  block.timestamp,
                  blockhash(block.number - 1)
              )
          )
      );
      _safeMint(msg.sender, _pickRandomUniqueId(_random) + 1);
      supply++;
    }

    /*for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }*/
    totalPayout = msg.value;
    //First payout to wallet in team 0 index
    //5% payout
    payable(team[0]).transfer(totalPayout * 5 / 100);
    //5% payout
    payable(team[1]).transfer(totalPayout * 5 / 100);
    //90% payout
    payable(team[2]).transfer(totalPayout * 90 / 100);
  }

  // public
  function mintOATH(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    uint256 totalPayout = 0;
    require(!publicPaused, 'Mint is currently paused');
    require(_mintAmount > 0, 'Cannot mint 0');
    require(_mintAmount <= maxMintAmount, 'Amount to mint larger than max allowed');
    require(supply + _mintAmount <= maxSupply, 'Not enough mints left');

    totalPayout = costOATH * _mintAmount;
    uint256 amountTeamZero = totalPayout * 5 / 100;
    uint256 amountTeamOne = totalPayout * 5 / 100;
    uint256 amountTeamTwo = totalPayout * 90 / 100;

    IERC20(oathToken).transferFrom(msg.sender, team[0], amountTeamZero);
    IERC20(oathToken).transferFrom(msg.sender, team[1], amountTeamOne);
    IERC20(oathToken).transferFrom(msg.sender, team[2], amountTeamTwo);

    for (uint256 i = 1; i <= _mintAmount; i++) {
      uint256 _random = uint256(
          keccak256(
              abi.encodePacked(
                  //getRandomBalances(),
                  index,
                  msg.sender,
                  block.timestamp,
                  blockhash(block.number - 1)
              )
          )
      );
      _safeMint(msg.sender, _pickRandomUniqueId(_random) + 1);
      supply++;
    }

    /*for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }*/

  }

  //Will have to call this function 15 times. Not sure how to make it more gas efficient
  function mintFirstHalf(address[] memory _addresses) public onlyOwner {
    uint256 supply = totalSupply();
    require(supply <= 375);
    uint256 tokenIdForAddress;
    for(uint256 i = 1; i <= 25; i++) {
      tokenIdForAddress = ERC721Enumerable(oldContract).tokenOfOwnerByIndex(_addresses[i], supply + 1);
      _safeMint(_addresses[supply], supply + 1);
      supply++;
    }
  }


  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
  
  function setCostFTM(uint256 _newCost) public onlyOwner {
    costFTM = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pausePublic(bool _state) public onlyOwner {
    publicPaused = _state;
  }
 
  function withdraw() public payable onlyOwner {    
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}
