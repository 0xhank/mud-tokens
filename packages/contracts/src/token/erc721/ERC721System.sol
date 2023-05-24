// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import {IERC721} from "../interfaces/IERC721.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { AllowanceTable } from "../../codegen/Tables.sol";
import { MetadataTable } from "../../codegen/Tables.sol";
import { BalanceTable } from "../../codegen/Tables.sol";
import { ERC721Table } from "../../codegen/Tables.sol";
import {IERC721Receiver} from "../interfaces/IERC721Receiver.sol";
import { toString} from "../../utils.sol";
import {nameToBytes16} from "../../utils.sol";
import { console } from "forge-std/console.sol";

bytes16 constant SYSTEM_NAME = bytes16('erc721_system');

contract ERC721System is  System {
    IWorld immutable world;
    address proxy;
    bytes32 immutable metadataTableId;
    bytes32 immutable balanceTableId;
    bytes32 immutable allowanceTableId;
    bytes32 immutable ERC721TableId;

    constructor(IWorld _world, address _proxy, string memory _name, string memory _symbol) {
      world = _world;
      proxy = _proxy;
      bytes16 namespace = nameToBytes16(_name);

      world.registerSystem(namespace, SYSTEM_NAME, this, true);
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "balanceOf", "(address)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "ownerOf", "(uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "name", "()");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "symbol", "()");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "tokenURI", "(uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "baseURI", "()");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "approve", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "getApproved", "(uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "setApprovalForAll", "(address, bool)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "isApprovedForAll", "(address, address)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "transfer", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "transferFrom", "(address, address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "safeTransferFrom", "(address, address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "safeTransferFromData", "(address, address, uint256, bytes memory)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "decreaseAllowance", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "mintBypass", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "burnBypass", "(uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "transferBypass", "(address, address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "approveBypass", "(address, uint256)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "setApprovalForAllBypass", "(address, address, bool)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "setTokenURIBypass", "(uint256, string memory)");
      world.registerFunctionSelector(namespace, SYSTEM_NAME, "unsafe_increase_balance", "(address, uint256)");

      metadataTableId = world.registerTable(namespace, bytes16('metadata'), MetadataTable.getSchema(), MetadataTable.getKeySchema());
      balanceTableId = world.registerTable(namespace, bytes16('balance'), BalanceTable.getSchema(), BalanceTable.getKeySchema());
      allowanceTableId = world.registerTable(namespace, bytes16('allowance'), AllowanceTable.getSchema(), AllowanceTable.getKeySchema());
      ERC721TableId = world.registerTable(namespace, bytes16('erc721'), ERC721Table.getSchema(), ERC721Table.getKeySchema());

      MetadataTable.setName(world, metadataTableId, _name);
      MetadataTable.setSymbol(world, metadataTableId, _symbol);
      MetadataTable.setProxy(world, metadataTableId, proxy);
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return BalanceTable.get(world, balanceTableId, owner);
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _ownerOf(_tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function totalSupply() public view returns (uint256) {
      return MetadataTable.getTotalSupply(world, metadataTableId);
    }

    function name() public view  returns (string memory) {
        return MetadataTable.getName(world, metadataTableId);
    }

    function symbol() public view  returns (string memory) {
        return MetadataTable.getSymbol(world, metadataTableId);
    }

    function tokenURI(uint256 tokenId) public view  returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = ERC721Table.getUri(world, ERC721TableId, tokenId);
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return "";
    }
   
    function baseURI() public view virtual returns (string memory) {
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

        return ERC721Table.getTokenApproval(world, ERC721TableId, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view  returns (bool) {
        return AllowanceTable.get(world, allowanceTableId, owner, operator) != 0;
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
        return ERC721Table.getOwner(world, ERC721TableId, tokenId);
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual { 
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        ERC721Table.setUri(world, ERC721TableId, tokenId, _tokenURI);
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

        uint256 balance = BalanceTable.get(world, balanceTableId, to);
        BalanceTable.set(world, balanceTableId, to , balance + 1);
        
        uint256 _totalSupply = MetadataTable.getTotalSupply(world, metadataTableId);
        MetadataTable.setTotalSupply(world, metadataTableId, _totalSupply + 1);

        ERC721Table.setOwner(world, ERC721TableId, tokenId, to);

        // emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        // Clear approvals
        ERC721Table.setTokenApproval(world, ERC721TableId, tokenId, address(0));
        uint256 balance = BalanceTable.get(world, balanceTableId, owner);
        BalanceTable.set(world, balanceTableId, owner, balance - 1);


        uint256 _totalSupply = MetadataTable.getTotalSupply(world, metadataTableId);
        require(_totalSupply > 0, "ERC721: no tokens to burn");
        MetadataTable.setTotalSupply(world, balanceTableId, _totalSupply - 1);
        ERC721Table.setOwner(world, ERC721TableId, tokenId, address(0));

        // emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        ERC721Table.setTokenApproval(world, ERC721TableId, tokenId, address(0));
        uint256 balance = BalanceTable.get(world, balanceTableId, from);
        BalanceTable.set(world, balanceTableId, from, balance - 1);
       
        balance = BalanceTable.get(world, balanceTableId, to);
        BalanceTable.set(world, balanceTableId, to, balance + 1);

        ERC721Table.setOwner(world, ERC721TableId, tokenId, to);

        // emit Transfer(from, to, tokenId);
    }
    
    function _approve(address to, uint256 tokenId) internal virtual {

        ERC721Table.setTokenApproval(world, ERC721TableId, tokenId, to);
        // emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        AllowanceTable.set(world, allowanceTableId, owner, operator, approved ? 1 : 0);
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

    function mintBypass(address to, uint256 tokenId) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _mint(to, tokenId);
    }

    function burnBypass(uint256 tokenId) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _burn(tokenId);
    }

    function transferBypass(address from, address to, uint256 tokenId) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _transfer(from, to, tokenId);
    }

    function approveBypass(address to, uint256 tokenId) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _approve(to, tokenId);
    }

    function setApprovalForAllBypass(address owner, address operator, bool approved) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _setApprovalForAll(owner, operator, approved);
    }

    function setTokenURIBypass(uint256 tokenId, string memory _tokenURI) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _setTokenURI(tokenId, _tokenURI);
    }

    function unsafe_increase_balance(address account, uint256 amount) public virtual {
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      uint256 balance = BalanceTable.get(world, balanceTableId, account);
      BalanceTable.set(world, balanceTableId, account, balance + amount);
    }
}