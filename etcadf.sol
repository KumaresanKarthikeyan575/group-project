// SPDX-License-Identifier:MIT

pragma solidity 0.8.26;

import "./adf.sol";
//at solidity inheritance is apply when apply the two contract which mean import the contract which you want at another file and create the new contract and make it as child contract of the imported contract and perform inheritance operation and modifies the code of parent contract through the child contract and add the extra code at the child contract
contract etcadf is adf{ // this the line makes new contact as child contract of the imported contract
    //override
    //virtual
    function store(uint b)public override{ // if you want to modifies the code of parent contract through child contract copy the function of parent contract and it will act as ovverride to modify and add the line override after public keyword and go to parent function add the virtual keyword after the public keyword at the parent contract not child contract it makes error 
       a=b+5;
    }
}



