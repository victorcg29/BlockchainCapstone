var ERC721MintableComplete = artifacts.require('VCGToken');

contract('TestERC721Mintable', accounts => {

    const account_one = accounts[0];
    const account_two = accounts[1];
    const account_three = accounts[2];
    const account_four = accounts[3];
    const account_five = accounts[4];

    const mint_account_one = 5;
    const mint_account_two = 5;
    const totalSupply = mint_account_one + mint_account_two;
    

    describe('match erc721 spec', function () {
        beforeEach(async function () {
            this.contract = await ERC721MintableComplete.new({from: account_one});

            // mint multiple tokens
            for(let i = 0; i < mint_account_one; ++i) {
                await this.contract.mint(account_one, i);
            }
            for(let i = 5; i < mint_account_two + 5; ++i) {
                await this.contract.mint(account_two, i);
            }
        });

        it('should return total supply', async function () {
            let total_supply = await this.contract.totalSupply.call();
            assert.equal(total_supply.toNumber(), totalSupply, "total supply is not correct");
        });

        it('should get token balance', async function () {
            let balance_two = await this.contract.balanceOf.call(account_two, {from: account_one});
            assert.equal(balance_two.toNumber(), mint_account_two, "Balance of account_two is not 1");
        });

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () {
            let tokenId = 1;
            let tokenURI = await this.contract.tokenURI.call(tokenId, {from: account_one});
            assert(tokenURI === `https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/${tokenId}`, "TokenURI is not correct");
        });

        it('should transfer token from one owner to another', async function () {
            let tokenId = 6;
            await this.contract.approve(account_three, tokenId, {from: account_two});
            await this.contract.transferFrom(account_two, account_three, tokenId, {from: account_two});

            newOwner = await this.contract.ownerOf.call(tokenId);
            assert.equal(newOwner, account_three, "Owner is not account_three");
        })
    });

    describe('have ownership properties', function () {
        beforeEach(async function () {
            this.contract = await ERC721MintableComplete.new({from: account_one});
        });

        it('should fail when minting when address is not contract owner', async function () {
            let fail = false;
            try {
                let tokenId = 6;
                await this.contract.mint(account_five, tokenId, {from: account_two});
            } catch (e) {
                fail = true;
            }
            assert.equal(fail, true, "address is not contract owner");
        });


        it('should return contract owner', async function () {
            let owner = await this.contract.owner.call({from: account_one});
            assert.equal(owner, account_one, "owner is not account_one");
        });

    });
});