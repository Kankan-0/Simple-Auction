var Auctions = artifacts.require("./SimpleAuction.sol");

module.exports = function (deployer) {
    deployer.deploy(Auctions, Date.now(), '0x96F76473F3f3D81e751f8328a8ab6bDa74fB0015');
}