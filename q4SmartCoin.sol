// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract SmartCoin is IERC20 {
    string public NAME = "SmartCoin";
    string public SYMBOL = "SMC";
    uint256 totalMinted = 1000000 * 1e8; //1M that has been minted to the deployer in constructor()
    address deployer;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(uint256 => bool) blockMined;

    using SafeMath for uint256;

    constructor() {
        deployer = msg.sender;
        balances[deployer] = 1000000 * 1e8;
    }

    function name() public view returns (string memory) {
        return NAME;
    }

    function symbol() public view returns (string memory) {
        return SYMBOL;
    }

    function decimals() public view returns (uint8) {
        return 8;
    }

    function totalSupply() public view returns (uint256) {
        return 10000000 * 1e8; //10M * 10^8 because decimals is 8
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] > _value, "Not enough balance!");
        balances[deployer] += ((_value * 10) / 100); // Warning: not taking overflow into account
        balances[_to] += _value - ((_value * 10) / 100); // Warning: not taking overflow into account
        // balances[_to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    function mine() public returns (bool success) {
        if (blockMined[block.number]) {
            // rewards of this block already mined
            return false;
        }
        if (block.number % 10 != 0) {
            // not a 10th block
            return false;
        }

        require(totalMinted + 10 * 1e8 <= totalSupply());

        balances[msg.sender] = balances[msg.sender] + 10 * 1e8;
        totalMinted = totalMinted + 10 * 1e8;
        blockMined[block.number] = true;

        return true;
    }

    function getCurrentBlock() public view returns (uint256) {
        return block.number;
    }

    function isMined(uint256 blockNumber) public view returns (bool) {
        return blockMined[blockNumber];
    }
}

library SafeMath {
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
