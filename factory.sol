// SPDX-License-Identifier:MIT

pragma solidity 0.8.26;

import "./adf.sol";

//through the fake account we deploy the transaction from fake account to the created smart contract named as 'adf' and through deploy the transaction we perform the operation which is present in the smart contract like arrays,mapping,struct etc , to store and view the data by the several methods now we deploythe contract to another , which is more advance than deploy the single account and single contract , now import the contract to another solidity file and create the new contract named as factory and create the global variable of adf smart contract and create the new function at the factory contract and through the new adf() function from the sdf variable create the several numbers of adf contract at the factory contract and view the address of the several adf smart contract meaning is through the account we will intract with several contract and perform there several operations not the single contract and single operation 
//the given factory is act as the manager of every adf contract which means 'simple storage contract' and it will create the several adf contract and stores in array at the index order and calls the any function presented at any contract while follow this code 
contract factory{
    //adf public Adf;
    adf[] public Adfarray;

    function createstorage()public{
        //Adf=new adf(); to create single contract
        //adress
        //ABI
        adf Adf=new adf(); //create several contract
        Adfarray.push(Adf);
    }

    function fstore(uint Adfindex,uint Adfnum)public{
        //Adfarray[Adfindex].store(Adfnum); (another method to call)
        adf Adf=Adfarray[Adfindex];
        Adf.store(Adfnum);
    }

    function fget(uint Adfindex)public view returns(uint){
        //return Adfarray[Adfindex].retrive(); (another method to call)
        adf Adf=Adfarray[Adfindex];
        return Adf.retrive();
    }

}