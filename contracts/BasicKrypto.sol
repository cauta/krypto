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
    function isContract(address _addr) 
    private 
    view 
    returns (bool is_contract) {
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
        bytes memory empty;
        return transfer(_to, _value, empty);
    }
    
    /// @dev Function that is called when a user or another contract wants to transfer funds .
    /// @param _to Recipient address
    /// @param _value Transfer amount in unit
    /// @param _data the data pass to contract reveiver
    function transfer(
        address _to, 
        uint _value, 
        bytes _data) 
    public
    isTradable 
    returns (bool success) {
        require(_to != 0x0);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);
        if(isContract(_to)) {
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
        }
        return true;
    }
    
    /// @dev Function that is called when a user or another contract wants to transfer funds .
    /// @param _to Recipient address
    /// @param _value Transfer amount in unit
    /// @param _data the data pass to contract reveiver
    /// @param _custom_fallback custom name of fallback function
    function transfer(
        address _to, 
        uint _value, 
        bytes _data, 
        string _custom_fallback) 
    public 
    isTradable
    returns (bool success) {
        require(_to != 0x0);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);

        if(isContract(_to)) {
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
        }
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
        uint256 _value)
    public
    isTradable
    returns (bool success) {
        require(_to != 0x0);
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

    // withdraw any ERC20 token in this contract to owner
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC223(tokenAddress).transfer(owner, tokens);
    }
    
    // allow people can transfer their token
    // NOTE: can not turn off
    function turnOnTradable() 
    public
    onlyOwner{
        tradable = true;
    }
}