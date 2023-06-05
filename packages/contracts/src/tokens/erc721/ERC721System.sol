// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "@latticexyz/world/src/System.sol";
import  "./interfaces/IERC721.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { BalanceTable } from "../common/BalanceTable.sol";
import { AllowanceTable} from "../common/AllowanceTable.sol";
import { MetadataTable } from "../common/MetadataTable.sol";
import { ERC721Table } from "./ERC721Table.sol";

import { ERC721Proxy } from "./ERC721Proxy.sol"; 
import {IERC721Receiver} from "./interfaces/IERC721Receiver.sol";
import {nameToBytes16, tokenToTable, Token} from "../common/utils.sol";
import {METADATA_T, ERC721_T, BALANCE_T, ALLOWANCE_T} from "../common/constants.sol";
import {ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { console } from "forge-std/console.sol";


contract ERC721System is System {

    bytes32 immutable private metadataTableId;
    bytes32 immutable balanceTableId;
    bytes32 immutable allowanceTableId;
    bytes32 immutable ERC721TableId;
    bytes16 immutable namespace;
    
    constructor(string memory _name ) {
      namespace = nameToBytes16(_name);
      metadataTableId = from(METADATA_T);
      balanceTableId = from(BALANCE_T);
      allowanceTableId = from(ALLOWANCE_T);
      ERC721TableId = from(ERC721_T);
    }

    function from(bytes16 name) public view returns (bytes32){
      return ResourceSelector.from(namespace, name);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns(bool) {return false;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        console.log('owner:', owner);
        return BalanceTable.get(balanceTableId, owner);
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _ownerOf(_tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function proxy() public view virtual returns (address){
      return MetadataTable.getProxy(metadataTableId);
    }

    function totalSupply() public view returns (uint256) {
      return MetadataTable.getTotalSupply( metadataTableId);
    }

    function name() public view  returns (string memory) {
        return MetadataTable.getName( metadataTableId);
    }

    function symbol() public view  returns (string memory) {
        return MetadataTable.getSymbol( metadataTableId);
    }

    function getAddress() public view returns (address) {
      return address(this);
    }

    function tokenURI(uint256 tokenId) public view  returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = ERC721Table.getUri( ERC721TableId, tokenId);

        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }
        return "";
    }
   
    function approve(address to, uint256 tokenId) public  {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view  returns (address) {
        _requireMinted(tokenId);

        return ERC721Table.getTokenApproval( ERC721TableId, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view  returns (bool) {
        return AllowanceTable.get( allowanceTableId, owner, operator) != 0;
    }

    function transferFrom(address from, address to, uint256 tokenId) public  {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public  {
        safeTransferFromWithData(from, to, tokenId, "");
    }

    function safeTransferFromWithData(address from, address to, uint256 tokenId, bytes memory data) public  {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return ERC721Table.getOwner( ERC721TableId, tokenId);
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual { 
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        ERC721Table.setUri( ERC721TableId, tokenId, _tokenURI);
    }

   function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        uint256 balance = BalanceTable.get(balanceTableId, to);
        BalanceTable.set(balanceTableId, to, balance + 1);
        
        uint256 _totalSupply = MetadataTable.getTotalSupply( metadataTableId);
        MetadataTable.setTotalSupply( metadataTableId, _totalSupply + 1);

        ERC721Table.setOwner( ERC721TableId, tokenId, to);

        // emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        // Clear approvals
        ERC721Table.setTokenApproval( ERC721TableId, tokenId, address(0));
        uint256 balance = BalanceTable.get( balanceTableId, owner);
        BalanceTable.set( balanceTableId, owner, balance - 1);


        uint256 _totalSupply = MetadataTable.getTotalSupply( metadataTableId);
        require(_totalSupply > 0, "ERC721: no tokens to burn");
        MetadataTable.setTotalSupply( balanceTableId, _totalSupply - 1);
        ERC721Table.setOwner( ERC721TableId, tokenId, address(0));

        // emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        ERC721Table.setTokenApproval( ERC721TableId, tokenId, address(0));
        uint256 balance = BalanceTable.get( balanceTableId, from);
        BalanceTable.set( balanceTableId, from, balance - 1);
       
        balance = BalanceTable.get( balanceTableId, to);
        BalanceTable.set( balanceTableId, to, balance + 1);

        ERC721Table.setOwner( ERC721TableId, tokenId, to);

        // emit Transfer(from, to, tokenId);
    }
    
    function _approve(address to, uint256 tokenId) internal virtual {

        ERC721Table.setTokenApproval( ERC721TableId, tokenId, to);
        // emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        AllowanceTable.set( allowanceTableId, owner, operator, approved ? 1 : 0);
        // emit ApprovalForAll(owner, operator, approved);
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function unsafe_increase_balance(address account, uint256 amount) internal virtual {
      uint256 balance = BalanceTable.get( balanceTableId, account);
      BalanceTable.set( balanceTableId, account, balance + amount);
    }

    function emitTransfer(address from, address to, uint256 amount) internal { 
      ERC721Proxy(proxy()).emitTransfer(from, to, amount);
    }

    function emitApproval(address from, address to, uint256 amount) internal { 
      ERC721Proxy(proxy()).emitApproval(from, to, amount);
    }
    
    function emitApprovalForAll(address from, address to, bool approved) internal { 
      ERC721Proxy(proxy()).emitApprovalForAll(from, to, approved);
    }
}