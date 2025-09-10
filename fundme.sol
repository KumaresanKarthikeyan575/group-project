//withdraw fund
//set the minimum fund value

// SPDX-License-Identifier:MIT

pragma solidity 0.8.26;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "contracts/priceconvertor.sol";
error NotOwner();

contract fundme{
    using priceconvertor for uint256;
    uint256 public constant minimumUsd=50 * 1e18;//1 *10**18
    address [] public funders;
    mapping (address=>uint256) public addresstofundamount;
    address public /* immutable */ i_owner;
    constructor() {
        i_owner = msg.sender;
    }
    //payable is the keyword is make the color of fund function as "red" instead of yellow
    function fund()public payable{
      //want to be able the minimum fund amount 
      // how do we send eth to this contract
      //the magic is we call the function and send eth at same time
      //wallet address and the contract address holds the native blockchain token like etherium fund at deploy contract
      require(msg.value.getConverionRate() >= minimumUsd, "didn't send enough"); //1e18 ==1*10**18=100000000000000000
      funders.push(msg.sender);
      addresstofundamount[msg.sender]=msg.value;
      //what is revert : the revert is take the ton of gas and return the remaining gas before undo any function simply if error happen the remaining gas is send back to the users how spend gas
      // the main goal is convert the etherium into usd now the chainlink and oracle decentralized network is play the smart contract doesn't interact with the real world the oracle is collect the data and then using the different providers and set the values for the diff assts and converted into the single reference contract the main smart contract is refrence it this how they spend the oracle gas and chainlink token the data of real world is view by the chainlink data
      // chainlink data
      // chainlink pricefeed
      // chainlink yrf
      // chainlink keepers
      // chainlink api
      //18 decimals
    }
    function getversion()public view returns(uint256){
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return pricefeed.version();
    }
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    function withdraw()public onlyOwner{
         for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addresstofundamount[funder] = 0;
    }
    funders = new address[](0);
        // // transfer - 2300 gas failed throw error
        // payable(msg.sender).transfer(address(this).balance);
        // // send - 2300 gas failed return bool
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call - set all gas failed return bool
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
     // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()
    
     fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}