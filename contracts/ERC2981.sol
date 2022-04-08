/***
 *    ███████╗██████╗  ██████╗██████╗  █████╗  █████╗  ██╗
 *    ██╔════╝██╔══██╗██╔════╝╚════██╗██╔══██╗██╔══██╗███║
 *    █████╗  ██████╔╝██║      █████╔╝╚██████║╚█████╔╝╚██║
 *    ██╔══╝  ██╔══██╗██║     ██╔═══╝  ╚═══██║██╔══██╗ ██║
 *    ███████╗██║  ██║╚██████╗███████╗ █████╔╝╚█████╔╝ ██║
 *    ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝ ╚════╝  ╚════╝  ╚═╝
 * Written by MaxflowO2
 * You can follow along at https://github.com/MaxflowO2/ERC2981
 */
pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT
import "./IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";


abstract contract ERC2981 is IERC2981, ERC165Storage {

  // Bytes4 Code for EIP-2981
  bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

  // Mappings _tokenID -> values
  address receiver;
  uint256 royaltyPercentage;

  constructor() {

    // Using ERC165Storage set EIP-2981
    _registerInterface(_INTERFACE_ID_ERC2981);

  }

  // Set to be internal function _setReceiver
  function _setReceiver(address _address) internal {
    receiver = _address;
  }

  // Set to be internal function _setRoyaltyPercentage
  function _setRoyaltyPercentage(uint256 _royaltyPercentage) internal {
    royaltyPercentage = _royaltyPercentage;
  }

  // Override for royaltyInfo(uint256, uint256)
  // uses SafeMath for uint256
  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override(IERC2981) returns (address Receiver, uint256 royaltyAmount) {
    Receiver = receiver;
    royaltyAmount = _salePrice / 100 * royaltyPercentage;
  }
}