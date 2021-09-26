const MarketV1 = artifacts.require("MarketV1");
const MyMasterWarCore = artifacts.require("MyMasterWarCore");
const MarketV1Storage = artifacts.require("MarketV1Storage");

module.exports = function (deployer) {
  deployer.then(async () => {
    console.log("Deploy MyMasterWarCore")
    const myMasterWarCoreContract = await deployer.deploy(MyMasterWarCore,
      "0xd679F5A74cDA2F6A46b35eB2AA1aA89B3ABAF064", "0x4a5b46Ee60A25E71F4fdaE0Df0D3f5736d0f1559")
    console.log("MyMasterWarCore address ===> ", myMasterWarCoreContract.address)

    console.log("Deploy MarketV1Storage")
    const marketV1StorageContract = await deployer.deploy(MarketV1Storage)
    console.log("MarketV1Storage address ===> ", marketV1StorageContract.address)

    console.log("Deploy MarketV1")
    const marketV1Contract = await deployer.deploy(MarketV1,
      myMasterWarCoreContract.address,
      "0xbe71511967DbAaf499149C12Eed8553fc7f5B1A4",
      marketV1StorageContract.address,
      250
    )
    console.log("marketV1Contract address ===> ", marketV1Contract.address)
    console.log("Set whilelist for MarketV1Storage")
    await marketV1StorageContract.setWhilelist(marketV1Contract.address, true)
  })
};
