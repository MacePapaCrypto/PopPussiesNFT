// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "./IWrappedFantom.sol";

/* Custom Error Section - Use with ethers.js for custom errors */
// Public Mint is Paused
error PublicMintPaused();

// Cannot mint zero NFTs
error AmountLessThanOne();

// Cannot mint more than maxMintAmount
error AmountOverMax(uint256 amtMint, uint256 maxMint);

// Token not in Auth List
error TokenNotAuthorized();

// Not enough mints left for mint amount
error NotEnoughMintsLeft(uint256 supplyLeft, uint256 amtMint);

// Not enough ftm sent to mint
error InsufficientFTM(uint256 totalCost, uint256 amtFTM);

contract PopPussiesPopPopV2Test is ERC721Enumerable, Ownable, ERC2981 {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";

  address public lpPair; // = 0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c; - usdcftm pair
  IWrappedFantom wftm = IWrappedFantom(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
  //Team wallets
  address[] private team = [
    0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13, //5% - MacePapa - contract dev
    0x6EFF42A5Cbb01CEf1F3e1b8Cc714a6d62731A013, //5% - Munchies - frontend dev
    0x056abd53a55C187d738B4A982D36b4dFa506326A  //90% - Cinn - Artist
  ];

  //@audit cost too low?
  mapping(address => uint) public acceptedCurrencies;

  uint256 public immutable maxSupply; //750
  uint256 public immutable maxMintAmount; //5

  bool public publicPaused = true;
  uint16[750] private ids;
  uint16 private index = 0;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    address _lpPair,
    uint _royaltiesPercentage,
    uint _maxSupply,
    uint _maxMintAmount
  ) ERC721(_name, _symbol) {

        maxSupply = _maxSupply;
        maxMintAmount = _maxMintAmount;
        lpPair = _lpPair;

        setBaseURI(_initBaseURI);
        _setRoyaltyPercentage(_royaltiesPercentage);
  }

  //address oath = 0x21Ada0D2aC28C3A5Fa3cD2eE30882dA8812279B6;
  //address wftm = 0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83;
  function addCurrency(address[] calldata acceptedCurrenciesInput, uint256[] calldata prices) external onlyOwner {
    require(acceptedCurrenciesInput.length == prices.length, "improper length");
    uint len = prices.length;
    for(uint i; i < len; ++i) {
        if (acceptedCurrenciesInput[i] == address(wftm)) {
            acceptedCurrencies[address(0)] = prices[i];
        }
        acceptedCurrencies[acceptedCurrenciesInput[i]] = prices[i];
    }
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function _pickRandomUniqueId(uint256 _random) private returns (uint256 id) {
      uint256 len = ids.length - index++;
      require(len > 0, "no ids left");
      uint256 randomIndex = _random % len;
      //If statement added for special use-case
      if(randomIndex < 375) {
        randomIndex += 375;
      }
      id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
      ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
      ids[len - 1] = 0;
  }

    function mint(address token, uint amount) external payable {
        if(publicPaused)
          revert PublicMintPaused();
        //require(!publicPaused, 'Mint is currently paused');
        if(amount <= 0)
          revert AmountLessThanOne();
        //require(amount > 0, 'Cannot mint 0');
        if(amount > maxMintAmount) {
          revert AmountOverMax({
            amtMint: amount,
            maxMint: maxMintAmount
          });
        }
        //require(amount <= maxMintAmount, 'Amount to mint larger than max allowed');
        if(acceptedCurrencies[token] <= 0)
          revert TokenNotAuthorized();
        //require(acceptedCurrencies[token] > 0, "token not authorized");

        uint256 supply = totalSupply();
        if(supply + amount > maxSupply) {
          revert NotEnoughMintsLeft({
            supplyLeft: maxSupply - supply,
            amtMint: amount
          });
        }
        //require(supply + amount <= maxSupply, 'Not enough mints left');
        uint amountFromSender = msg.value;
        if (token == address(0)) {
            if(amountFromSender != amount * acceptedCurrencies[address(wftm)])
              revert InsufficientFTM({
                totalCost: amount * acceptedCurrencies[address(wftm)],
                amtFTM: amountFromSender
              });
            //require(msg.value == amount * acceptedCurrencies[address(wftm)], "insufficient ftm");
            wftm.deposit{ value: amountFromSender }();
            _mintInternal(address(wftm), amount);
        } else {
            require(IERC20(token).transferFrom(msg.sender, address(this), amount * acceptedCurrencies[token]), "Payment not successful");
            _mintInternal(token, amount);
        }
    }

    //Need way to send tokens to contract?
    function _mintInternal(address _token, uint _amount) internal {
        for (uint256 i = 1; i <= _amount; ++i) {
            _safeMint(msg.sender, _pickRandomUniqueId(_getRandom()) +1);
        }
    }

    function _getRandom() internal returns (uint) {
       (uint token0, uint token1) = _getRandomNumbers();
        return uint(keccak256(abi.encodePacked(
            token0, token1
        )));
    }

    function _getRandomNumbers() internal returns (uint, uint) {
        (uint token0, uint token1, uint timestamp) = IUniswapV2Pair(lpPair).getReserves();
        return (token0, token1);
    }

  //Will have to call this function 37 times. Not sure how to make it more gas efficient
  function mintFirstHalf_N89(address[] calldata _addresses, uint[] calldata _ids) external onlyOwner {
    require(_addresses.length == _ids.length, "bad input");
    uint256 supply = totalSupply();
    require(supply <= 375);
    // This method will work if we order the arrays in ASC order by tokenID
    // Unchecked gives savings of 30-40 gas per loop
    for(uint256 i = 1; i <= 25; i++) {
      _safeMint(_addresses[supply], _ids[supply]);
      supply++;
    }
  }

  /*//Will have to call this function 1 time. Not sure how to make it more gas efficient
  function mintFirstHalf(address[] calldata _addresses, uint[] calldata _ids) external onlyOwner {
    require(_addresses.length == _ids.length, "bad input");
    uint256 supply = totalSupply();
    require(supply <= 375);
    // This method will work if we order the arrays in ASC order by tokenID
    // Unchecked gives savings of 30-40 gas per loop
    for(uint256 i = 1; i <= 5; i++) {
      _safeMint(_addresses[supply], _ids[supply]);
      supply++;
    }
  }*/


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

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pausePublic(bool _state) public onlyOwner {
    publicPaused = _state;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, IERC165, ERC165Storage) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function withdraw(address token) external onlyOwner {
    require(acceptedCurrencies[token] > 0, "token not authorized");
    uint amount = IERC20(token).balanceOf(address(this));
    require(amount > 0);

    IERC20(token).transfer(team[0], amount * 5 / 100);
    IERC20(token).transfer(team[1], amount * 5 / 100);
    IERC20(token).transfer(team[2], amount * 90 / 100);
  }
}