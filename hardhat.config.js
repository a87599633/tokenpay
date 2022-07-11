require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async(taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
    for (const account of accounts) {
        console.log(account.address);
    }
});

module.exports = {
    solidity: {
        version: '0.8.4',
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    contractSizer: {
        alphaSort: true,
        runOnCompile: true,
        disambiguatePaths: false,
    },
    networks: {
        bsctest: {
            url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
            accounts: ["7a43e9e22e4116235a4e4e85af72967255fa33072bd7027f6a6ac598422ea6bf"]
        }
    },
    etherscan: {
        apiKey: "3E534B3WVT1HFCE6IU6FRNIKIAB1EPVM68",
    }
};