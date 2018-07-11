var LandAsset = artifacts.require("./LandEvolution.sol");

module.exports = function(deployer) {
    deployer.deploy(LandAsset);
};
