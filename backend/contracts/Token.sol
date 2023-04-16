// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name;
    string public symbol;
    uint256 public _totalSupply;

    mapping(address => uint256) public balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 Supply
    ) {
        name = _name;
        symbol = _symbol;
        _totalSupply = Supply;
        balances[msg.sender] = _totalSupply;
    }

    function updateTotalSupply(uint256 _amount , address sender) public {

        _totalSupply += _amount;
        balances[sender] += _amount;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= _value, "Insufficient balance.");
        require(_to != address(0), "Invalid address.");

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return balances[account];
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
}
