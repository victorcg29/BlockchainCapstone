pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/utils/Address.sol";
import "./ERC721Mintable.sol";
import "./Verifier.sol";

// define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract SquareVerifier is Verifier {

}


// define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is VCGToken {
    SquareVerifier public squareContract;

    constructor(address verifierAddress) VCGToken() public{
        squareContract = SquareVerifier(verifierAddress);
    }

    // define a solutions struct that can hold an index & an address
    struct Solutions {
        uint tokenId;
        address to;
    }

    // define an array of the above struct
    Solutions[] solutions;

    // define a mapping to store unique solutions submitted
    mapping(bytes32 => Solutions) private uniqueSolutionsSubmitted;


    // Create an event to emit when a solution is added
    event SolutionAdded(uint tokenid, address to);

    // Create a function to add the solutions to the array and emit the event
    function AddSolution
                        (
                            address toAddress, 
                            uint tokenId, 
                            bytes32 key
                        ) 
                        public 
    {
        Solutions memory newSolution = Solutions({tokenId : tokenId, to : toAddress});
        solutions.push(newSolution);
        uniqueSolutionsSubmitted[key] = newSolution;
        emit SolutionAdded(tokenId, toAddress);
    }

    // Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mintToken
                        (
                            address toAddress,
                            uint tokenId,
                            uint[2] memory a,
                            uint[2][2] memory b,
                            uint[2] memory c,
                            uint[2] memory input
                        )
                            public 
    {
        bytes32 key = keccak256(abi.encodePacked(a, b, c, input));
        require(uniqueSolutionsSubmitted[key].to == address(0),"Solution is already used.");
        require(squareContract.verifyTx(a, b, c, input),"Solution is not correct");

        AddSolution(toAddress, tokenId, key);
        super.mint(toAddress, tokenId);
    }

    function IsMintable
                        (
                            address toAddress, 
                            uint tokenId,
                            uint[2] memory a,
                            uint[2][2] memory b,
                            uint[2] memory c,
                            uint[2] memory input
                        )
                        public 
    {
        // check if solution is valid
        require(squareContract.verifyTx(a, b, c, input), "Solution is not correct");
        bytes32 key = keccak256(abi.encodePacked(a, b, c, input));
        require(uniqueSolutionsSubmitted[key].to == address(0),"Solution is already used.");

        AddSolution(toAddress, tokenId, key);
    }
}