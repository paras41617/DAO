const Token = artifacts.require("Token");
const Dao = artifacts.require("DAO");

module.exports = async function (deployer) {
    // Deploy Token contract
    await deployer.deploy(Token,"D","DT",5000);
  
    // Get the Token contract instance
    const tokenInstance = await Token.deployed();
  
    // Deploy Dao contract and pass Token address to constructor
    await deployer.deploy(Dao, tokenInstance.address);
};