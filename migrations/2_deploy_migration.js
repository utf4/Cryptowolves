const Migrations = artifacts.require("CryptoPanda");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
