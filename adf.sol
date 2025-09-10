// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

contract adf {
    // view keyword is not allow for data modification it allow for retrive data
    // pure keyword is not allow for read the data for storage and using some algorithms pure keywors use in functions
    // global scope
    // data types : bool,uint,int,bytes,string
    uint public a;
    // boys public leader=boys({id: 1 , name: "william butcher"}); one by one statically;
    boys[] public team;//array
    
    mapping(string=>uint) public nameToid;//mapping which used to store the two value and assign the one variableas input and get the mapping variable as output

    struct boys{
        uint id;
        string name;
    }
    
    function store(uint b)  public virtual{
        a=b;
        //a=b+1;
        //retrive(); // if you call the function from the another function to read the data is adding the gas limit
    }

    function retrive()public view returns(uint){ // gas limit is not neccessary for retrive data
        return a;
    }
    // storage information access at six places (storage,memory,calldata,code,stack,logs)variables
    // data location access through array,struct,mapping used at the parameter of the function for this (storage,memory,calldata)variables are apply
    // memory variables are the temporary variable use at the functions and it will be modifies the data
    // caldata variables are the temporary variables that can't be modified the data it will works at functions
    // storage is the permanent variable it can be modifies the data , it will used at inside the function and as the global variable

    //example for memory variable
    function addmembers(uint en,string memory member)public{ //why uint variables comes under function? uint asssign the bits size which is automatically called as the memory variable the memory keyword does'nt needs but string variable is the form of array , contains the characters ,for that memory is needs
      //member="cat";(data will be modifies at memory variable)
      boys memory tm=boys({id:en,name:member});
      team.push(tm);//array
      nameToid[member]=en;//mappng
      //team.push(boys(en,member)); memory keywors does'nt need
    }
    // example of calldata variable
    //function addmembers(uint en,string calldata member)public{
    //member="homelander";(data not modifies at calldata , error will occurs)
    //  boys memory tm=boys({id:en,name:member});
    //  team.push(tm);
    //}

}
// 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
// local scope 
//contract df{
//    function local()public{
//        uint b; // access in the function not at the whole contract
//    }
// }

