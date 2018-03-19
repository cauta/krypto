const krypto = artifacts.require('./Krypto.sol');

contract('krypto', async accounts => {
    it('msg.sender should be the owner of this contract: ', async () => {
        const instance = await krypto.deployed();
        const owner = await instance.owner.call();
        assert.equal(owner, accounts[0], 'first token is not own by owner');
    });

    it('balance of owner should be 1,000,000,000 * 10^10: ', async () => {
        const instance = await krypto.deployed();
        const balance = await instance.balanceOf.call(accounts[0]);
        assert.equal(balance, 10 ** 19, 'balance of owner is wrong');
    });

    it('turnOnTradable() should do it right', async () => {
        const accountZero = accounts[0];
        const accountOne = accounts[1];
        const instance = await krypto.deployed();

        await instance
            .turnOnTradable({ from: accountOne })
            .catch(function(error) {});

        const tradableOne = await instance.tradable.call();
        assert.equal(
            tradableOne,
            false,
            'tradable was turn on not by another address',
        );

        await instance
            .turnOnTradable({ from: accountZero })
            .catch(function(error) {
                console.log('revert detected from owner address');
            });

        const tradableZero = await instance.tradable.call();
        assert.equal(tradableZero, true, 'tradable was not turn on by owner');
    });

    it('transfer should do it right', async () => {
        let accountZero = accounts[0];
        let accountOne = accounts[1];
        let amount = 10 ** 13;

        let accountZeroStartingBalance;
        let accountOneStartingBalance;
        let accountZeroEndingBalance;
        let accountOneEndingBalance;

        let instance = await krypto.deployed();
        let krypt = instance;

        let balance = await krypt.balanceOf.call(accountZero);

        accountZeroStartingBalance = balance.toNumber();
        balance = await krypt.balanceOf.call(accountOne);
        accountOneStartingBalance = balance.toNumber();

        await krypt.transfer(accountOne, amount, { from: accountZero });

        balance = await krypt.balanceOf.call(accountZero);
        accountZeroEndingBalance = balance.toNumber();
        balance = await krypt.balanceOf.call(accountOne);
        accountOneEndingBalance = balance.toNumber();

        assert.equal(
            accountZeroEndingBalance,
            accountZeroStartingBalance - amount,
            "Amount was't correctly taken from the sender",
        );

        assert.equal(
            accountOneEndingBalance,
            accountOneStartingBalance + amount,
            "Amount wasn't correctly sent to the receiver",
        );
    });
});
