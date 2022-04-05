// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');


  // We get the contract to deploy
  const PopContract = await hre.ethers.getContractFactory("PopPussiesPopPopMoreTests");
  //const connected = await PopContract.deploy("poppussiespoppopmoretests", "PPPPmoretest", "", {gasLimit: 8000000, gasPrice: ethers.utils.parseUnits('500', 'gwei')});
  //await connected.deployed();
  //console.log("Deployed to: ", connected.address);
  //console.log(ethers.utils.parseUnits('0.00001', 'ether'));

  const connected = await PopContract.attach("0xC14724Ed33fD1f77D76dc0Ac1b7772C3F0C75d91");
  //const status = await connected.pausePublic(false);
  //console.log("Mint status: ", status);
  //for(let i = 1; i < 375; i++) {
    try {
      //console.log("Minting " + i + " now");
      await connected.mintFTM(1, {gasLimit: 400000});
    } catch(error) {
      console.log(error);
    }
  //}
  //await connected.setBaseURI("https://gateway.pinata.cloud/ipfs/QmVquDcwREjYePxeE3E5qM8xG2Jxw84pvjM3p7q5rtGnv5/");
  //console.log("Base URI: ", await connected.baseURI);
  //await connected.pausePublic(false);
  //console.log("Giveaways Minted: Check 0x056abd53a55C187d738B4A982D36b4dFa506326A")
  //await bbContract.mint()
  //console.log("Mint Paused: ", await connected.publicPaused());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});

  /*

  // We require the Hardhat Runtime Environment explicitly here. This is optional
  // but useful for running the script in a standalone fashion through `node <script>`.
  //
  // When running the script with `npx hardhat run <script>` you'll find the Hardhat
  // Runtime Environment's members available in the global scope.
  const { BigNumber } = require("@ethersproject/bignumber");
  const hre = require("hardhat");

  async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    let wei = ethers.utils.parseEther("1000")
    let weiString = wei.toString()
    console.log(weiString)
    const SlurpToken = await hre.ethers.getContractFactory("FKSLURPDEV");
    const slurp = await SlurpToken.deploy("FKSLURPDEV", "SLURP", wei, "0xF1a26c9f2978aB1CA4659d3FbD115845371ED0F5");

    await slurp.deployed();

    console.log("Contract deployed to:", slurp.address);
  }

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

  */