pragma solidity ^0.4.18;
import "./ContractReceiver.sol";

contract Receive is ContractReceiver {
    uint256 public a = 0; 
    function increase(uint256 value)
    public {
        require(msg.sender == address(this));
        a = a+value;
    }
}