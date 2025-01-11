// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CarbonCredit is ERC721, Ownable(msg.sender) {

    uint256 private _tokenIdCounter;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        transferOwnership(msg.sender);
    }

    event Decision(address indexed company, bool verification);
    event ReceivedSomeCredits(address indexed company, string from, uint creditCount);

    struct Company {
        uint totalCredits;
        uint creditsUsed;
        uint remainingRequests;
        uint totalPoints; // For rewards
        bool isVerified;
        string surveyReference;
        address surveyCompany;
        uint[] tokenIds;
        string name;
        uint[] costPerCredit;
    }

    struct Surveyer {
        string name;
        address[] requests;
    }

    string[] private surveyerNames;
    address[] private surveyerAddresses;
    address[] private companyAddresses;

    mapping(address => Company) public companies;
    mapping(address => Surveyer) public surveyerCompanies;
    mapping(address => uint[]) public creditRequests;

    modifier notZeroAddress(address value) {
        require(value != address(0), "Address cannot be a zero address");
        _;
    }

    modifier onlySpecificSurveyer(address company) {
        require(companies[company].surveyCompany == msg.sender, "Only relevant Surveyer can perform this action");
        _;
    }

    modifier onlyOwnerCompany(address company) {
        require(msg.sender == company, "Only the company owner can request credits");
        _;
    }

    function getCreditRequests(address company) public view returns (uint[] memory) {
        return creditRequests[company];
    }

    function checkType(address company) public view returns (uint) {
        if (companies[company].totalCredits > 0) {
            return 1;
        }
        if (surveyerCompanies[company].requests.length > 0) {
            return 2;
        }
        return 0;
    }

    function registerSurveyer(address surveyer, string memory name) public notZeroAddress(surveyer) {
        surveyerCompanies[surveyer].name = name;
        surveyerNames.push(name);
        surveyerAddresses.push(surveyer);
    }

    function getCompanyAddresses() public view returns (address[] memory) {
        return companyAddresses;
    }

    function getSurveyerNames() public view returns (string[] memory) {
        return surveyerNames;
    }

    function getSurveyerAddresses() public view returns (address[] memory) {
        return surveyerAddresses;
    }

    function getTokens(address company) public view returns (uint[] memory) {
        return companies[company].tokenIds;
    }

    function getCostPerCredit(address company) public view returns (uint[] memory) {
        return companies[company].costPerCredit;
    }

    function registerCompany(
        address company,
        string memory name,
        uint totalCredits,
        uint creditsUsed,
        string memory surveyReference,
        address surveyCompany
    ) public notZeroAddress(company) returns (string memory) {
        require(bytes(surveyReference).length != 0, "Please provide a reference number");
        companies[company] = Company({
            name: name,
            totalCredits: totalCredits,
            creditsUsed: creditsUsed,
            remainingRequests: 5,
            totalPoints: 0,
            isVerified: false,
            surveyReference: surveyReference,
            surveyCompany: surveyCompany,
            tokenIds: new uint[](0),
            costPerCredit: new uint[](0)
        });
        surveyerCompanies[surveyCompany].requests.push(company);
        return "Awaiting approval from Surveyer";
    }

    function showRegistrationRequests(address surveyer) public view returns (address[] memory) {
        require(surveyerCompanies[surveyer].requests.length > 0, "Only surveyers can have approval requests");
        return surveyerCompanies[surveyer].requests;
    }

    function approveCreditInfo(address company) public onlySpecificSurveyer(company) {
        require(!companies[company].isVerified, "Company is already verified");
        companies[company].isVerified = true;
        companies[company].remainingRequests = 5;
        uint creditsToMint = companies[company].totalCredits - companies[company].creditsUsed;
        for (uint i = 0; i < creditsToMint; i++) {
            uint tokenId = createCredit(company);
            companies[company].tokenIds.push(tokenId);
        }
        companyAddresses.push(company);
        emit Decision(company, true);
    }

    function rejectCreditInfo(address company) public onlySpecificSurveyer(company) {
        companies[company].isVerified = false;
        emit Decision(company, false);
    }

    function createCredit(address to) private returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function registerReceiveRequest(address company, uint numberOfTokens) public onlyOwnerCompany(company) {
        require(companies[company].isVerified, "Only verified companies can request credits");
        require(numberOfTokens > 0, "Number of tokens requested should be greater than 0");
        require(companies[company].remainingRequests > 0, "You do not have enough requests remaining");
        creditRequests[company].push(numberOfTokens);
        uint cost = 475 + ((5 - companies[company].remainingRequests - (companies[company].totalCredits - companies[company].creditsUsed - companies[company].tokenIds.length)) * 17);
        companies[company].costPerCredit.push(cost);
        companies[company].remainingRequests--;
    }


function transferCredits(
    address to,
    address payable from,
    uint numberOfTokens,
    uint cost,
    uint index
) public payable notZeroAddress(to) notZeroAddress(from) {
    require(companies[from].isVerified, "Only verified companies can transfer credits");
    require(companies[to].isVerified, "Only verified companies can receive credits");
    require(companies[from].tokenIds.length >= numberOfTokens, "Not enough credits to be transferred");

    for (uint i = 0; i < numberOfTokens; i++) {
        uint tokenId = companies[from].tokenIds[companies[from].tokenIds.length - 1];
        safeTransferFrom(from, to, tokenId);
        companies[to].tokenIds.push(tokenId);
        companies[from].tokenIds.pop();
    }

    (bool success, ) = from.call{value: (cost * 1 ether) / 10000}("");
    require(success, "Transfer failed");

    creditRequests[to][index] = creditRequests[to][creditRequests[to].length - 1];
    creditRequests[to].pop();
    companies[to].costPerCredit[index] = companies[to].costPerCredit[companies[to].costPerCredit.length - 1];
    companies[to].costPerCredit.pop();

    emit ReceivedSomeCredits(to, companies[from].name, numberOfTokens);
}


}