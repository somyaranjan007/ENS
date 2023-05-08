/* SPDX-License-Identifier: MIT */
pragma solidity ^0.8.7;

contract ENS {

    uint256 public constant domainPricePerYear = 1 ether;

    mapping (string => bool) domainAvailable;
    mapping (string => address) public domainOwner;
    mapping (string => mapping (address => uint256)) public domainOwnerPeriod;

    event DomainChecked(string _domain, bool _status);
    event RegisteredDomain(address ownerOfDomain, string domainName, uint256 domainTimePeriod);

    function checkDomain(string _domain) view {
        require(availableDomain[_domain] == false, "Domain not available");
        emit DomainChecked(_domain, availableDomain[_domain]);
    }

    function registerDomain(string memory _domainName, uint256 _subscriptionPeriod) external payable {
        require(domainOwner[_domainName] == address(0), "Domain is registered!");
        require(msg.value == domainPricePerYear * _subscriptionPeriod, "You didn't send enough ethers for your domain!")

        domainAvailable[_domainName] = true;
        domainOwner[_domainName] = msg.sender;
        domainOwnerPeriod[_domainName][msg.sender] = block.timestamp * ((365*24*60*60) * _subscriptionPeriod);

        emit RegisteredDomain(msg.sender, _domainName, block.timestamp * ((365*24*60*60) * _subscriptionPeriod));
    }

    function resolveDomain(string memory _domainName) external view returns(address) {
        return domainOwner[_domainName];
    }
}