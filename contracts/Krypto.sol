pragma solidity ^0.4.18;
import "./BasicKrypto.sol";

// ----------------------------------------------------------------------------------------------
// Krypto Token by Krypto Limited.
// An ERC20 standard
//
// author: Krypto Team
// Contact: datwhnguyen@gmail.com 
contract Krypto is BasicKrypto {

    bool public _selling = true;//initial selling
    
    uint256 public _originalBuyPrice = 43 * 10**12; // original buy 1ETH = 4300 Krypto = 43 * 10**12 unit

    // List of approved investors
    mapping(address => bool) private approvedInvestorList;
    
    // deposit
    mapping(address => uint256) private deposit;
    
    // icoPercent
    uint256 public _icoPercent = 10;
    
    // _icoSupply is the avalable unit. Initially, it is _totalSupply
    uint256 public _icoSupply = _totalSupply * _icoPercent / 100;
    
    // minimum buy 0.3 ETH
    uint256 public _minimumBuy = 3 * 10 ** 17;
    
    // maximum buy 25 ETH
    uint256 public _maximumBuy = 25 * 10 ** 18;

    // totalTokenSold
    uint256 public totalTokenSold = 0;

    /**
     * Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        require(_selling);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of address is investor
     */
    modifier validInvestor() {
        require(approvedInvestorList[msg.sender]);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of msg value
     * value must greater than equal minimumBuyPrice
     * total deposit must less than equal maximumBuyPrice
     */
    modifier validValue(){
        // require value >= _minimumBuy AND total deposit of msg.sender <= maximumBuyPrice
        require ( (msg.value >= _minimumBuy) &&
                ( (deposit[msg.sender] + msg.value) <= _maximumBuy) );
        _;
    }

    /// @dev Fallback function allows to buy ether.
    function()
        public
        payable {
        buyKrypto();
    }
    
    /// @dev buy function allows to buy ether. for using optional data
    function buyKrypto()
        public
        payable
        onSale
        validValue
        validInvestor {
        uint256 requestedUnits = (msg.value * _originalBuyPrice) / 10**18;
        require(balances[owner] >= requestedUnits);
        // prepare transfer data
        balances[owner] = balances[owner].sub(requestedUnits);
        balances[msg.sender] = balances[msg.sender].add(requestedUnits);
        
        // increase total deposit amount
        deposit[msg.sender] = deposit[msg.sender].add(msg.value);
        
        // check total and auto turnOffSale
        totalTokenSold = totalTokenSold.add(requestedUnits);
        if (totalTokenSold >= _icoSupply){
            _selling = false;
        }
        
        // submit transfer
        Transfer(owner, msg.sender, requestedUnits);
        owner.transfer(msg.value);
    }

    /// @dev Constructor
    function Krypto() BasicKrypto()
        public {
        setBuyPrice(_originalBuyPrice);
    }
    
    /// @dev Enables sale 
    function turnOnSale() onlyOwner 
        public {
        _selling = true;
    }

    /// @dev Disables sale
    function turnOffSale() onlyOwner 
        public {
        _selling = false;
    }
    
    function turnOnTradable() 
        public
        onlyOwner{
        tradable = true;
    }
    
    /// @dev set new icoPercent
    /// @param newIcoPercent new value of icoPercent
    function setIcoPercent(uint256 newIcoPercent)
        public 
        onlyOwner {
        _icoPercent = newIcoPercent;
        _icoSupply = _totalSupply * _icoPercent / 100;
    }
    
    /// @dev set new _maximumBuy
    /// @param newMaximumBuy new value of _maximumBuy
    function setMaximumBuy(uint256 newMaximumBuy)
        public 
        onlyOwner {
        _maximumBuy = newMaximumBuy;
    }

    /// @dev Updates buy price (owner ONLY)
    /// @param newBuyPrice New buy price (in UNIT) 1ETH <=> 10 000 0000000000 unit
    function setBuyPrice(uint256 newBuyPrice) 
        onlyOwner 
        public {
        require(newBuyPrice>0);
        _originalBuyPrice = newBuyPrice; // unit
        // control _maximumBuy_USD = 10,000 USD, Krypto price is 0.1USD
        // maximumBuy_Krypto = 100,000 Krypto = 100,000,0000000000 unit = 10^15
        _maximumBuy = 10**18 * 10**15 /_originalBuyPrice;
    }
    
    /// @dev check address is approved investor
    /// @param _addr address
    function isApprovedInvestor(address _addr)
        public
        constant
        returns (bool) {
        return approvedInvestorList[_addr];
    }
    
    /// @dev get ETH deposit
    /// @param _addr address get deposit
    /// @return amount deposit of an buyer
    function getDeposit(address _addr)
        public
        constant
        returns(uint256){
        return deposit[_addr];
}
    
    /// @dev Adds list of new investors to the investors list and approve all
    /// @param newInvestorList Array of new investors addresses to be added
    function addInvestorList(address[] newInvestorList)
        onlyOwner
        public {
        for (uint256 i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }

    /// @dev Removes list of investors from list
    /// @param investorList Array of addresses of investors to be removed
    function removeInvestorList(address[] investorList)
        onlyOwner
        public {
        for (uint256 i = 0; i < investorList.length; i++){
            approvedInvestorList[investorList[i]] = false;
        }
    }
    
    /// @dev Withdraws Ether in contract (Owner only)
    /// @return Status of withdrawal
    function withdraw() onlyOwner 
        public 
        returns (bool) {
        return owner.send(this.balance);
    }
}