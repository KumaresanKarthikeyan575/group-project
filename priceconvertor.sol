// SPDX-License-Identifier:MIT

pragma solidity 0.8.26;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library priceconvertor{
     function getprice()internal view returns(uint256){
        // ABI
        //address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //eth interms of usd
        //3000.00000000
        (,int256 price,,,) = pricefeed.latestRoundData();
        return uint256(price * 1e10); //1**10==10000000000
    }

    function getConverionRate(uint256 ethAmount)internal view returns(uint256){
        uint256 ethPrice = getprice();
        //3000.000000000000000000 ETH/USD price
        //1.000000000000000000 ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;
        //2.999e21
        return ethAmountInUsd;
    }
}