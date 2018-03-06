pragma solidity ^0.4.18;
import "./ERC223.sol";
import "./SafeMath.sol";
import "./ContractReceiver.sol";
// ----------------------------------------------------------------------------------------------
// Krypto Token by Krypto Limited.
// An ERC223 standard
//
// author: Krypto Team
// Contact: datwhnguyen@gmail.com 
contract BasicKrypto is ERC223 {
    using SafeMath for uint256;
    
    uint256 public constant decimals = 10;
    string public constant symbol = "KRT";
    string public constant name = "Krypto";
    uint256 public _totalSupply = 10 ** 19; // total supply is 10^19 unit, equivalent to 10^9 Krypto

    // Owner of this contract
    address public owner;

    // tradable
    bool public tradable = false;

    // Balances Krypto for each account
    mapping(address => uint256) balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
            
    /**
     * Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isTradable(){
        require(tradable == true || msg.sender == owner);
        _;
    }

    /// @dev Constructor
    function BasicKrypto() 
        public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
    }
    
    /// @dev Gets totalSupply
    /// @return Total supply
    function totalSupply()
        public 
        constant 
        returns (uint256) {
        return _totalSupply;
    }
        
    /// @dev Gets account's balance
    /// @param _addr Address of the account
    /// @return Account balance
    function balanceOf(address _addr) 
        public
        constant 
        returns (uint256) {
        return balances[_addr];
    }
    
    
    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }
 
    /// @dev Transfers the balance from msg.sender to an account
    /// @param _to Recipient address
    /// @param _value Transfered amount in unit
    /// @return Transfer status
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) 
    public 
    isTradable
    returns (bool success) {
      
        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if(isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value);
        }
    }
    
    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes _data) 
    public
    isTradable 
    returns (bool success) {
        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value);
        }
    }
    
    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) 
    public 
    isTradable
    returns (bool success) {
        if(isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = balanceOf(msg.sender).sub(_value);
            balances[_to] = balanceOf(_to).add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        else {
            return transferToAddress(_to, _value);
        }
    }
    
    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value) private returns (bool success) {
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
      //function that is called when transaction target is a contract
     function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
     
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    isTradable
    returns (bool success) {
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);
        return true;
    }
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) 
        public
        returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    // get allowance
    function allowance(address _owner, address _spender) 
        public
        constant 
        returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC223(tokenAddress).transfer(owner, tokens);
    }
}