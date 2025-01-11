
# Carbon Credit Contract

This repository contains a Solidity smart contract (`CarbonCredit.sol`).The CarbonCredit smart contract is an Ethereum-based solution for managing carbon credits using ERC721 tokens. It facilitates the registration and verification of companies and surveyors, issuance and transfer of carbon credits, and tracking of credit usage.

## Features

Features
Company Registration and Verification: Companies can register with a survey reference and await verification from designated surveyors.

Surveyor Registration: Surveyors can register and manage company verification requests.

Credit Issuance: Verified companies receive ERC721 tokens representing carbon credits.

Credit Transfer: Companies can transfer carbon credits to others, with associated cost handling.

Request Management: Companies can request additional credits, and surveyors can approve or reject these requests.


## Getting Started

1.  **Prerequisites:**
    *   Node.js and npm (or yarn)
    *   Hardhat: npm install --save-dev hardhat
    *   OpenZeppelin Contracts: npm install @openzeppelin/contracts

2. **Installation**
   
    ```bash
    git clone <repository_url>
    cd <repository_directory>
    npm install
    ```

This repository contains a Solidity smart contract (`CarbonCredit.sol`)

3. **Configuration**

    * In your Hardhat configuration file (`hardhat.config.js`), configure your network settings (e.g., local Hardhat network, testnet, mainnet).

4.  **Deployment:**

    *  Compile the contracts:
     
       ```bash
       npx hardhat compile
       ```
    
    *  Deploy the Carbon Credit contract, providing the name amd symbol for the associated carbon credit NFT as a constructor argument:
       
       ```bash
       npx hardhat run scripts/deploy.js --network <network_name>
       ```
    
    (Create a 'deploy.js' script in the 'scripts' directory similar to the example below)


    ```javascript
    const { ethers } = require("hardhat");

    async function main() {
        const Dapp = await ethers.getContractFactory("CarbonCredit");
        const dapp = await Dapp.deploy("name","symbol");

        await dapp.deployed();

        console.log("Dapp deployed to:", dapp.address);
    }

    main().catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });
    
5. **Interaction:**

 
    *   Use Hardhat console or a frontend application to interact with the contract.

## Contract Functions

* **`registerCompany(address company, string name, uint totalCredits, uint creditsUsed, string surveyReference, address surveyCompany)`: Registers a company for carbon credits.

* **`approveCreditInfo(address company)`: Approves and verifies a company's carbon credit details.
transferCredits(address to, address from, uint numberOfTokens, uint cost, uint index): Facilitates the transfer of credits between companies.

* **`registerSurveyer(address surveyer, string name)`: Registers a new surveyor.

* **`registerReceiveRequest(address company, uint numberOfTokens)`: Allows companies to request additional credits.

## Events

* **`Decision(address company, bool verification)`: Emitted when a company's verification status changes.

* **`ReceivedSomeCredits(address company, string from, uint creditCount)`: Emitted when a company receives new credits.


## Disclaimer

This contract is provided as-is and without any warranties. Use it at your own risk.

