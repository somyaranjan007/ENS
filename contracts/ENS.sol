/* SPDX-License-Identifier: MIT */
pragma solidity ^0.8.7;

contract ENS {

    uint256 public constant domainPricePerYear = 1 ether;
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    mapping (string => bool) availableDomain ;
    mapping (string => address) public domainOwner;
    mapping (string => mapping (address => uint256)) public domainOwnerPeriod;

    event DomainChecked(string _domain, bool _status);
    event RegisteredDomain(address ownerOfDomain, string domainName, uint256 domainTimePeriod);
    event RenewedDomain(address ownerOfDomain, string domainName, uint256 domainTimePeriod);
    event ReleasedDomain(address ownerOfDomain, string domainName);
    event RemainingTime(address ownerOfDomain, string domainName, string message);


    function checkDomain(string memory _domain) public{
        require(availableDomain[_domain] == false, "Domain not available");
        emit DomainChecked(_domain, availableDomain[_domain]);
    }

    function registerDomain(string memory _domainName, uint256 _subscriptionPeriod) external payable {
        require(domainOwner[_domainName] == address(0), "Domain is registered!");
        require(msg.value == domainPricePerYear * _subscriptionPeriod, "You didn't send enough ethers for your domain!");

        availableDomain[_domainName] = true;
        domainOwner[_domainName] = msg.sender;
        domainOwnerPeriod[_domainName][msg.sender] = block.timestamp + ((365*24*60*60) * _subscriptionPeriod);

        emit RegisteredDomain(msg.sender, _domainName, block.timestamp + ((365*24*60*60) * _subscriptionPeriod));
    }

    function resolveDomain(string memory _domainName) external view returns(address) {
        return domainOwner[_domainName];
    }

     function renewDomain(string memory _domainName, uint256 _subscriptionPeriod) external payable {
        require(domainOwner[_domainName] == msg.sender, "You are not the owner of this domain!");
        require(msg.value == domainPricePerYear * _subscriptionPeriod, "You didn't send enough ethers for your domain renewal!");

        
        domainOwnerPeriod[_domainName][msg.sender] = block.timestamp + (_subscriptionPeriod * SECONDS_PER_YEAR);

        emit RenewedDomain(msg.sender, _domainName, block.timestamp + (_subscriptionPeriod * SECONDS_PER_YEAR));
    }

    function releaseDomain(string memory _domainName) external {
        require(domainOwner[_domainName] == msg.sender, "You are not the owner of this domain!");

        if (block.timestamp >= domainOwnerPeriod[_domainName][msg.sender]) {
            // Subscription period has ended, prompt user to renew or release domain
            delete domainOwner[_domainName];
            delete domainOwnerPeriod[_domainName][msg.sender];
            availableDomain[_domainName] = false;

            emit ReleasedDomain(msg.sender, _domainName);
        } else {
            // Subscription period has not ended yet
            uint256 remainingTime = domainOwnerPeriod[_domainName][msg.sender] - block.timestamp;
            emit RemainingTime(msg.sender, _domainName, string(abi.encodePacked("Subscription period has not ended yet. Domain can be released in ", remainingTime, " seconds.")));
        }
    }
}
