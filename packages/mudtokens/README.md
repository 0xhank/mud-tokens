# MUD Tokens

PRs welcome at [Github](https://github.com/0xhank/mud-tokens)

This package allows builders of [MUD](https://mud.dev) to integrate fully conformant tokens that can exist in Autonomous Worlds and traditional NFT platforms and exchanges.

## Installation

```
npm install mudtokens
```

## Notes

- You can only have one of each type of token per namespace (for now).
- A token's data and functionality is fully exposed in the namespace it exists in, so you can spread a token's functionality across any system in a namespace.
- You can manually define a token's namespace in library parameters, or exclude the namespace parameter to create a token in the ROOT_NAMESPACE.

## Quickstart

1. Add mudtokens to your `remappings.txt` file:

   ```
   mudtokens/=node_modules/mudtokens/
   ```

1. Register your token to the World in the Post Deploy script (`PostDeploy.s.sol`):

   ```
   import { ERC721Registration } from "mudtokens/src/erc721/ERC721Registration.sol";
   import { ERC1155Registration } from "mudtokens/src/tokens.sol";
   import { ERC20Registration } from "mudtokens/src/tokens.sol";

   library TestScript {
       function run(address worldAddress) internal {
           IBaseWorld world = IBaseWorld(worldAddress);

           ERC721Registration.install(world, "Test", "TST");
           ERC20Registration.install(world, "Test", "TST");
           ERC1155Registration.install(world, "Test");
       }
   }
   ```

1. Gain full access to the suite of ERC20, 721, and 1155 token methods using token libraries.

- ERC20:

  ```
  import { LibERC20 } from "mudtokens/src/tokens.sol";

  contract ERC20TestToken is System {
      function mint20(uint256 amount) public {
          LibERC20._mint(_msgSender(), amount);
      }
  }
  ```

- ERC721:

  ```
  import { LibERC721 } from "mudtokens/src/tokens.sol";
  contract ERC721TestToken is System {
      function mint721(uint256 tokenId) public {
          LibERC721._safeMint(_msgSender(), _msgSender(), tokenId);
      }
  }
  ```

- ERC1155:

  ```
  import { LibERC1155 } from "mudtokens/src/tokens.sol";
  contract ERC1155TestToken is System {
      function mint1155(uint256 tokenId, uint256 amount) public {
          LibERC1155._mint(_msgSender(), _msgSender(), tokenId, amount, "");
      }
  }
  ```

## API

### LibERC20

Name: returns the token's name.

```

name(IBaseWorld world, bytes16 namespace) => string
name(IBaseWorld world) => string
name(bytes16 namespace) => string
name() => string

```

Symbol: returns the token's symbol.

```

symbol(IBaseWorld world, bytes16 namespace) => string
symbol(IBaseWorld world) => string
symbol(bytes16 namespace) => string
symbol() => string

```

Proxy: returns the token's proxy address.

```

proxy(IBaseWorld world, bytes16 namespace) => address
proxy(IBaseWorld world) => address
proxy(bytes16 namespace) => address
proxy() => address

```

totalSupply: returns the token's total supply.

```

totalSupply(IBaseWorld world, bytes16 namespace) => uint256
totalSupply(IBaseWorld world) => uint256
totalSupply(bytes16 namespace) => uint256
totalSupply() => uint256

```

balanceOf: returns the balance of the given address.

```

balanceOf(IBaseWorld world, bytes16 namespace, address account) => uint256
balanceOf(IBaseWorld world, address account) => uint256
balanceOf(bytes16 namespace, address account) => uint256
balanceOf(address account) => uint256

```

transfer: transfers from a user to a user. the msg.Sender must be passed in as a parameter.

```

transfer(IBaseWorld world, bytes16 namespace, address msgSender, address to, uint256 amount) => bool
transfer(IBaseWorld world, address msgSender, address to, uint256 amount) => uint256
transfer(bytes16 namespace, address msgSender, address to, uint256 amount) => uint256
transfer(address msgSender, address to, uint256 amount) => uint256

```

allowance: returns the number of tokens an address is allowed to spend for another address

```

allowance(IBaseWorld world, bytes16 namespace, address owner, address spender) => bool
allowance(IBaseWorld world, address owner, address spender) => uint256
allowance(bytes16 namespace, address owner, address spender) => uint256
allowance(address owner, address spender) => uint256

```

increaseAllowance: Increases the allowance of a user.

```

increaseAllowance(IBaseWorld world, bytes16 namespace, address msgSender, address spender, uint256 addedValue) => bool
increaseAllowance(IBaseWorld world, address msgSender, address spender, uint256 addedValue) => bool
increaseAllowance(bytes16 namespace, address msgSender, address spender, uint256 addedValue) => bool
increaseAllowance(address msgSender, address spender, uint256 addedValue) => bool

```

decreaseAllowance: decreases the allowance of a user.

```

decreaseAllowance(IBaseWorld world, bytes16 namespace, address msgSender, address spender, uint256 addedValue) => bool
decreaseAllowance(IBaseWorld world, address msgSender, address spender, uint256 addedValue) => bool
decreaseAllowance(bytes16 namespace, address msgSender, address spender, uint256 addedValue) => bool
decreaseAllowance(address msgSender, address spender, uint256 addedValue) => bool

```

\_mint: mints tokens

```

\_mint(IBaseWorld world, bytes16 namespace, address account, uint256 amount) => void
\_mint(IBaseWorld world, address account, uint256 amount) => void
\_mint(bytes16 namespace, address account, uint256 amount) => void
\_mint(address account, uint256 amount) => void

```

\_burn: mints tokens

```

\_burn(IBaseWorld world, bytes16 namespace, address account, uint256 amount) => void
\_burn(IBaseWorld world, address account, uint256 amount) => void
\_burn(bytes16 namespace, address account, uint256 amount) => void
\_burn(address account, uint256 amount) => void

```

### LibERC721

Name: returns the token's name.

```

name(IBaseWorld world, bytes16 namespace) => string
name(IBaseWorld world) => string
name(bytes16 namespace) => string
name() => string

```

Symbol: returns the token's symbol.

```

symbol(IBaseWorld world, bytes16 namespace) => string
symbol(IBaseWorld world) => string
symbol(bytes16 namespace) => string
symbol() => string

```

Proxy: returns the token's proxy address.

```

proxy(IBaseWorld world, bytes16 namespace) => address
proxy(IBaseWorld world) => address
proxy(bytes16 namespace) => address
proxy() => address

```

totalSupply: returns the token's total supply.

```

totalSupply(IBaseWorld world, bytes16 namespace) => uint256
totalSupply(IBaseWorld world) => uint256
totalSupply(bytes16 namespace) => uint256
totalSupply() => uint256

```

balanceOf: returns the balance of the given address.

```

balanceOf(IBaseWorld world, bytes16 namespace, address account) => uint256
balanceOf(IBaseWorld world, address account) => uint256
balanceOf(bytes16 namespace, address account) => uint256
balanceOf(address account) => uint256

```

ownerOf: returns the owner of the given token.

```

ownerOf(IBaseWorld world, bytes16 namespace, uint256 tokenId) => address
ownerOf(IBaseWorld world, uint256 tokenId) => address
ownerOf(bytes16 namespace, uint256 tokenId) => address
ownerOf(uint256 tokenId) => address

```

tokenURI: returns the token's URI

```

tokenURI(IBaseWorld world, bytes16 namespace, uint256 tokenId) => string
tokenURI(IBaseWorld world, uint256 tokenId) => string
tokenURI(bytes16 namespace, uint256 tokenId) => string
tokenURI(uint256 tokenId) => string

```

transferFrom: transfers from a user to a user. the msg.Sender must be passed in as a parameter.

```

transferFrom(IBaseWorld world, bytes16 namespace, address msgSender, address from, address to, uint256 tokenId) => void
transferFrom(IBaseWorld world, address msgSender, address from, address to, uint256 tokenId) => void
transferFrom(bytes16 namespace, address msgSender, address from, address to, uint256 tokenId) => void
transferFrom(address msgSender, address from, address to, uint256 tokenId) => void

```

safeTransferFrom: transfers from a user to a user, safely.

```

safeTransferFrom(IBaseWorld world, bytes16 namespace, address msgSender, address from, address to, uint256 tokenId) => void
safeTransferFrom(IBaseWorld world, address msgSender, address from, address to, uint256 tokenId) => void
safeTransferFrom(bytes16 namespace, address msgSender, address from, address to, uint256 tokenId) => void
safeTransferFrom(address msgSender, address from, address to, uint256 tokenId) => void

```

getApproved: returns the approved token amount for the given owner and operator.

```

getApproved(IBaseWorld world, bytes16 namespace, uint256 tokenId) => address
getApproved(IBaseWorld world, uint256 tokenId) => address
getApproved(bytes16 namespace, uint256 tokenId) => address
getApproved(uint256 tokenId) => address

```

isApprovedForAll: returns if the operator is approved for all.

```

isApprovedForAll(IBaseWorld world, bytes16 namespace, address owner, address operator) => uint256
isApprovedForAll(IBaseWorld world, address owner, address operator) => uint256
isApprovedForAll(bytes16 namespace, address owner, address operator) => uint256
isApprovedForAll(address owner, address operator) => uint256

```

\_setTokenURI: sets the URI of the token

```

\_setTokenURI(IBaseWorld world, bytes16 namespace, uint256 tokenId, string memory \_tokenURI) => uint256
\_setTokenURI(IBaseWorld world, uint256 tokenId, string memory \_tokenURI) => uint256
\_setTokenURI(bytes16 namespace, uint256 tokenId, string memory \_tokenURI) => uint256
\_setTokenURI(uint256 tokenId, string memory \_tokenURI) => uint256

```

\_safeMint: safely mints new tokens

```

\_safeMint(IBaseWorld world, bytes16 namespace, address to, uint256 tokenId) => void
\_safeMint(IBaseWorld world, address to, uint256 tokenId) => void
\_safeMint(bytes16 namespace, address to, uint256 tokenId) => void
\_safeMint(address to, uint256 tokenId) => void

```

\_mint: mints a new token

```

\_mint(IBaseWorld world, bytes16 namespace, address to, uint256 tokenId) => void
\_mint(IBaseWorld world, address to, uint256 tokenId) => void
\_mint(bytes16 namespace, address to, uint256 tokenId) => void
\_mint(address to, uint256 tokenId) => void

```

\_burn: returns the balance of the given address.

```

\_burn(IBaseWorld world, bytes16 namespace, uint256 tokenId) => uint256
\_burn(IBaseWorld world, uint256 tokenId) => uint256
\_burn(bytes16 namespace, uint256 tokenId) => uint256
\_burn(uint256 tokenId) => uint256

```

\_approve: returns the balance of the given address.

```

\_approve(IBaseWorld world, bytes16 namespace, address to, uint256 tokenId) => void
\_approve(IBaseWorld world, address to, uint256 tokenId) => void
\_approve(bytes16 namespace, address to, uint256 tokenId) => void
\_approve(address to, uint256 tokenId) => void

```

\_setApprovalForAll: returns the balance of the given address.

```

\_setApprovalForAll(IBaseWorld world, bytes16 namespace, address operator, bool approved) => void
\_setApprovalForAll(IBaseWorld world, address operator, bool approved) => void
\_setApprovalForAll(bytes16 namespace, address operator, bool approved) => void
\_setApprovalForAll(address operator, bool approved) => void

```

### LibERC1155

name(IBaseWorld? world, bytes16? namespace) => string memory: Retrieves the name metadata of a token, specific to a namespace within a given world.

symbol(IBaseWorld? world, bytes16? namespace) => string memory: Retrieves the symbol metadata of a token, specific to a namespace within a given world.

proxy(IBaseWorld? world, bytes16? namespace) => address: Retrieves the address of the proxy contract for a given namespace within a specific world.

totalSupply(IBaseWorld? world, bytes16? namespace) => uint256: Retrieves the total supply of tokens for a given namespace within a specific world.

balanceOf(IBaseWorld? world, bytes16? namespace, address account) => uint256: Retrieves the token balance of a specific account in a given namespace within a specific world.

allowance(IBaseWorld? world, bytes16? namespace, address owner, address spender) => uint256: Gets the current allowance the owner has provided for the spender, for a specific namespace within a world.

transfer(IBaseWorld? world, bytes16? namespace, address msgSender, address to, uint256 amount) => bool: Transfers tokens between two addresses within a specific namespace in a given world.

transferFrom(IBaseWorld? world, bytes16? namespace, address msgSender, address \_from, address to, uint256 amount) => bool: Executes a token transfer on behalf of another address within a given world and namespace.

increaseAllowance(IBaseWorld? world, bytes16? namespace, address msgSender, address spender, uint256 addedValue) => bool: Increases the spending allowance of spender by addedValue within a given world and namespace.

decreaseAllowance(IBaseWorld? world, bytes16? namespace, address msgSender, address spender, uint256 subtractedValue) => bool: Decreases the spending allowance of spender by subtractedValue within a given world and namespace.

\_transfer(IBaseWorld? world, bytes16? namespace, address \_from, address to, uint256 amount) => void: Internal function to handle token transfers within a specific world and namespace.

\_mint(IBaseWorld? world, bytes16? namespace, address account, uint256 amount) => void: Internal function to mint new tokens to an account within a specific world and namespace.

\_burn(IBaseWorld? world, bytes16? namespace, address account, uint256 amount) => void: Internal function to burn tokens from an account within a specific world and namespace.

\_approve(IBaseWorld? world, bytes16? namespace, address owner, address spender, uint256 amount) => void: Internal function to set the allowance of tokens that the spender can spend from the owner’s account, specific to a namespace within a given world.

\_spendAllowance(IBaseWorld? world, bytes16? namespace, address owner, address spender, uint256 amount) => void: Internal function to decrement the allowance after spending, for a specific namespace within a given world.

```

```

```

```

```

```
