var krypto = artifacts.require("./Krypto.sol");
var web3 = require("Web3")

contract('Krypto', function(accounts) {
    it("msg.sender should be the owner of this contract: ", function() {
        return krypto.deployed().then(function(instance) {
            return instance.owner.call();
        }).then(function(owner) {
            console.log("the owner of this contract is: " + owner);
            assert.equal(owner, accounts[0], "first token is not own by owner");
        });
        // return isValid;
    });

    it("balance of owner should be 1,000,000,000 * 10^10: ", function() {
        return krypto.deployed().then(function(instance) {
            return instance.balanceOf.call(accounts[0]);
        }).then(function(balance) {
            console.log("balance of Owner is: " + balance);
            assert.equal(balance, "10000000000000000000", "balance of owner is wrong");
        });
    });
});