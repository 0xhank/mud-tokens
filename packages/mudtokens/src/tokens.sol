// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// common
import { AllowanceTable, BalanceTable, MetadataTable, ERC721Table, ERC1155ApprovalTable, ERC1155BalanceTable, ERC1155MetadataTable } from "./codegen/tables.sol";
import "./common/constants.sol";

// erc721
import { ERC721Proxy } from "./erc721/ERC721Proxy.sol";
import { ERC721Registration } from "./erc721/ERC721Registration.sol";
import { LibERC721 } from "./erc721/LibERC721.sol";

// erc1155
import { ERC1155Proxy } from "./erc1155/ERC1155Proxy.sol";
import { ERC1155Registration } from "./erc1155/ERC1155Registration.sol";
import { LibERC1155 } from "./erc1155/LibERC1155.sol";

// erc20
import { ERC20Proxy } from "./erc20/ERC20Proxy.sol";
import { ERC20Registration } from "./erc20/ERC20Registration.sol";
import { LibERC20 } from "./erc20/LibERC20.sol";
