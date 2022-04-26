// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.9;

// Import OpenZeppelin contracts
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Import abstract contracts
import { AbstractAERC20 } from "./AbstractAERC20.sol";

// Import errors
import { AlreadyInitialized } from "../../abstracts/Errors.sol";

contract AERC20 is AbstractAERC20, ERC20, Ownable {
    // STORAGE

    string internal name_;
    string internal symbol_;

    bool internal nameIsInitialized = false;
    bool internal symbolIsInitialized = false;

    address[] internal owners;
    mapping(address => bool) public isOwner;

    // CONSTRUCTOR

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) Ownable() {
        name_ = _name;
        symbol_ = _symbol;
    }

    // FUNCTIONS

    function getOwners() external view override returns(address[] memory) {
        return owners;
    }

    function setName(string memory _initName) internal override {
        if (nameIsInitialized) {
            revert AlreadyInitialized();
        }

        name_ = _initName;
        nameIsInitialized = true;
    }

    function setSymbol(string memory _initSymbol) internal override {
        if (symbolIsInitialized) {
            revert AlreadyInitialized();
        }

        symbol_ = _initSymbol;
        symbolIsInitialized = true;
    }

    function name() public view virtual override(ERC20,AbstractAERC20) returns (string memory) {
        return name_;
    }

    function symbol() public view virtual override(ERC20,AbstractAERC20) returns (string memory) {
        return symbol_;
    }

    function mint(address _recipient, uint256 _amount) external virtual override onlyOwner { 
        _mint(_recipient, _amount);
    }

    function burn(address _owner, uint256 _amount) external virtual override onlyOwner { 
        _burn(_owner, _amount);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal virtual override {
        super._beforeTokenTransfer(_from, _to, _amount);

        // If sending to someone who is not an owner and not burning tokens
        if (!isOwner[_to] && _to != address(0)) {
            isOwner[_to] = true;
            owners.push(_to);
        }

        // If transferring entire balance
        if (_amount == balanceOf(_from)) {
            isOwner[_from] = false;
        }
    }
}
