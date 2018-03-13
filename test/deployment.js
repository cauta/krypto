var krypto = artifacts.require("./Krypto.sol");

contract('krypto', async(accounts) => {

    it("msg.sender should be the owner of this contract: ", function() {
        return krypto.deployed().then(function(instance) {
            return instance.owner.call();
        }).then(function(owner) {
            assert.equal(owner, accounts[0], "first token is not own by owner");
        });
    });

    it("balance of owner should be 1,000,000,000 * 10^10: ", function() {
        return krypto.deployed().then(function(instance) {
            return instance.balanceOf.call(accounts[0]);
        }).then(function(balance) {
            assert.equal(balance, "10000000000000000000", "balance of owner is wrong");
        });
    });

    it("turnOnTradable() should do it right", async() => {
        var account_zero = accounts[0];
        var account_one = accounts[1];

        let instance = await krypto.deployed();
        let krypt = instance;

        await krypt.turnOnTradable({ from: account_one }).catch(function(error) {});
        let tradable_1 = await krypt.tradable.call();
        assert.equal(tradable_1, false, "tradable was turn on not by another address");

        await krypt.turnOnTradable({ from: account_zero }).catch(function(error) {
            console.log("revert detected from owner address");
        });
        let tradable = await krypt.tradable.call();
        assert.equal(tradable, true, "tradable was not turn on by owner");
    });

    it("transfer should do it right", async() => {
        let account_zero = accounts[0];
        let account_one = accounts[1];
        let amount = 10000000000000;

        let account_zero_starting_balance;
        let account_one_starting_balance;
        let account_zero_ending_balance;
        let account_one_ending_balance;

        let instance = await krypto.deployed();
        let krypt = instance;

        let balance = await krypt.balanceOf.call(account_zero);

        account_zero_starting_balance = balance.toNumber();
        balance = await krypt.balanceOf.call(account_one);
        account_one_starting_balance = balance.toNumber();

        await krypt.transfer(account_one, amount, { from: account_zero });

        balance = await krypt.balanceOf.call(account_zero);
        account_zero_ending_balance = balance.toNumber();
        balance = await krypt.balanceOf.call(account_one);
        account_one_ending_balance = balance.toNumber();

        assert.equal(account_zero_ending_balance, account_zero_starting_balance - amount, "Amount wasn't correctly taken from the sender");
        assert.equal(account_one_ending_balance, account_one_starting_balance + amount, "Amount wasn't correctly sent to the receiver");

    });
});