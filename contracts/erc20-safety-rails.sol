// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.7.2/access/Ownable.sol";

contract SafeRailsToken is ERC20, Ownable {

    mapping(address => bool) public frozenAccounts;

    // When accounts are frozen or unfrozen
    event AccountFrozen(address indexed _addr);
    event AccountThawed(address indexed _addr);       

    constructor() ERC20("SafeRailsToken", "SAFE") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual
        override(ERC20)
    {
        super._beforeTokenTransfer(from, to, amount);

        require(to != address(this), "Can't send tokens to the contract address");

        bool isToContract;
        assembly {
           isToContract := gt(extcodesize(to), 0)              
        }
        require(to.balance != 0 || isToContract, "Can't send tokens to an empty address");

        require(!frozenAccounts[from], "The account is frozen");           
    }   // _beforeTokenTransfer


    function freezeAccount(address addr) 
      public
      onlyOwner
    {
      require(!frozenAccounts[addr], "Account already frozen");        
      frozenAccounts[addr] = true;        
      emit AccountFrozen(addr);        
    }  // freezeAccount      


    function thawAccount(address addr) 
      public
      onlyOwner
    {
      require(frozenAccounts[addr], "Account not frozen");        
      frozenAccounts[addr] = false;        
      emit AccountThawed(addr);        
    }  // thawAccount   

    function cleanupERC20(
        address erc20,
        address dest
    )
        public
        onlyOwner
    {
        IERC20 token = IERC20(erc20);
        uint balance = token.balanceOf(address(this));
        token.transfer(dest, balance);
    }   // cleanupERC20            

}
