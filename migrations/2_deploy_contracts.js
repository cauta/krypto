var krypto = artifacts.require("./Krypto.sol");

module.exports = function(deployer) {
    deployer.deploy(krypto);
};