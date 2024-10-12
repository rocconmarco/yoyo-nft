<br />
<div id="readme-top" align="center">

<h3 align="center">Yoyo Nft</h3>

  <p align="center">
    A collection of unique NFTs that embodies the true spirit of yoga.
    <br />
    <a href="https://github.com/rocconmarco/yoyo-nft"><strong>Repository GitHub »</strong></a>
    <br />
  </p>
</div>

## About The Project

Yoyo Nft is a collection of unique NFTs developed and deployed on the Ethereum Sepolia testnet as part of the “Ethereum Advanced” project commissioned by start2impact University.

<br>

The project aims at enhancing customers retention of a yoga centre, by giving its first 125 clients a unique NFT which grants exclusive discounts on courses and activities of the centre.

<br>

Customers are then able to transfer and exchange their NFTs if they want to, as a sort of reference program for their friends to join the centre.

<br>

## Specs for nerds

The project has been challenging for a couple of reasons. In developing an NFT, one must consider the technical and also the graphic aspects of the digital asset.

<br>

For the graphic design of the NFT collection, I learned of to proper create separate png files, all with the same dimensions, with Inkscape, an opensource software for vectorial design. I created three groups of attributes, namely background, body, and vibe.

<br>

I, then, combined the attributes in all possible combination by writing a Python script, for automating the process. The same has been done for the metadata, with a total of 125 unique json files and 125 unique png files as an output.

<br>

The assets have been uploaded on IPFS, in order to guarantee the permanent accessibility of the assets and to avoid the single point of failure vulnerability of a centralized storage system.

<br>

The YoyoNft smart contract is developed in Solidity, tested and deployed with Foundry. As the best practices suggest, the smart contract inherits from the ERC721 token standard implemented by OpenZeppelin. This way, the contract has already all the functions related to inspecting the contract (e.g. ownerOf, balanceOf, etc.), as well as functions related to the transfer of tokens.

### The minting process

As the client required, the minting process of the NFT has to be random, in order to increase the excitement of obtaining a new digital asset. For this purpose, the YoyoNft contract implements the Chainlink VRF, the most reliable random number generator to the date of writing (Oct, 2024).

<br>

The requestNft function has been implemented, as to interact with the Chainlink VRF and to start the process of requesting a random number as the tokenId of the new NFT. In this function, a new request is created, passing the required arguments, and then assigning the requestId to the address of the requester.

<br>

The VRF Coordinator then elaborates the request, and after (a minimum of) 3 blocks of confirmation, it will activate the callback function defined inside the YoyoNft contract. In this function, the exact logic for assessing the availability of the random tokenId, and, in case of necessity, the search for the first available tokenId consecutive to the already minted one.

### Checking the results

As of today (Oct, 2024), the project does not have a front end. For this reason, the interaction with the smart contract has to be made via Etherscan. Everyone with a Sepolia address and with a minimum of Sepolia ETH balance (for paying the gas fees) have the opportunity to mint one (or more) NFT(s) by searching the deployed contract address:

<br>

<strong>0x07A0626B776b97daf66a0050F500c4606944e05E</strong>

<br>

By simply calling the requestNft function and signing the transaction, the NFT minting process is complete. In case all the NFTs have already been minted (max supply is set at 125), the transaction will revert.

<br>

In order to discover the tokenId of the generated NFT, one must search for the contract address of the VRF Coordinator in Etherscan, and look for the exact transaction containing the tokenId. The contract uses the VRF Coordinator v2.5, which has the following address:

<br>

<strong>0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B</strong>

<br>

With the YoyoNft contract address and the tokenId, the user will then be able to import the NFT in the wallet, where it will be added to all the other NFTs he/she possesses.

### Testing

The YoyoNft contract has a test suite that covers the 100% of all the functions. The tests have been designed to simulate a response from the VRF Coordinator through the mock contract provided by Chainlink.

<br>

## Contacts

<strong>Marco Roccon - Digital Innovation & Development</strong><br>
Portfolio website: https://rocconmarco.github.io/<br>
Linkedin: https://www.linkedin.com/in/marcoroccon/<br>
GitHub: https://github.com/rocconmarco

<br>

## Copyright

© 2024 Marco Roccon. All rights reserved.
