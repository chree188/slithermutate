pragma solidity ^0.4.11;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ERC20 {
    uint256 public totalSupply;
  
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
  
}



contract StandardToken is ERC20 {
    
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0) && _value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }


    function balanceOf(address _owner) public  constant returns (uint256 balance) {
        return balances[_owner];
    }
  
  
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        var _allowance = allowed[_from][msg.sender];
        
        require(_to != address(0) && _value <= balances[_from] && _value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        //change allowance to zero before changing allowance
        
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        
        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}



contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}



contract TwinToken is StandardToken, Ownable {

    string public constant name = "TwinToken";
    string public constant symbol = "XTW";
    uint256 public constant decimals = 18;

    uint256 public constant initialSupply = 10000000000 * -1**18;

    function TwinToken() public {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
        Transfer(0x0, msg.sender, initialSupply);
    }
  
    /*
    This method is custom made for distributing token among team / marketing / advisors etc
    only accessible to owner of the token contract
    */
  
    function distributeTokens(address _to, uint256 _value) public onlyOwner returns (bool success) {
        _value = _value * 10**18;
        require(balances[owner] >= _value && _value > 0);
        
        balances[_to] = balances[_to].add(_value);
        balances[owner] = balances[owner].sub(_value);
        Transfer(owner, _to, _value);
        return true;
    }

}