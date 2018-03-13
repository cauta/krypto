var HDWalletProvider = require("truffle-hdwallet-provider");

// mnemonic with account have ether on ropsten
var mnemonic_test = "first way scale critic never cradle volcano rhythm exchange shed hamster deposit";

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration! 
    package_name: "Krypto",
    version: "0.0.1",
    description: "Deploy Krypto token",
    authors: [
        "Trong Cau Ta <trongcauhcmus@gmail.com>"
    ],

    dependencies: {
        "owned": "^0.0.1",
    },

    networks: {
        ropsten: {
            provider: function() {
                return new HDWalletProvider(mnemonic_test, "https://ropsten.infura.io/BEvyXAHwmD8PWVIbupLH");
            },
            network_id: '3',
            gas: 4000000,
            gasPrice: 25000000000
        },
    },

    mocha: {
        useColors: true
    },

    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },

    license: "MIT",
};