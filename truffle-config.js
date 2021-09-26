const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const privateKeys = fs.readFileSync('.secret').toString().split('\n');

module.exports = {
    networks: {
        dev: {
            host: "localhost",
            port: 8545,
            gasPrice: 0,
            network_id: "*" // eslint-disable-line camelcase
        },
        bsc_testnet: {
            provider: () =>
                new HDWalletProvider(
                    privateKeys,
                    `https://data-seed-prebsc-2-s1.binance.org:8545/`,
                    0,
                    1
                ),
            network_id: 97,
            // confirmations: 2,
            gas: 5500000,
            timeoutBlocks: 200,
            skipDryRun: true,
        },

        bsc_mainnet: {
            provider: () =>
                new HDWalletProvider(
                    privateKeys,
                    `https://bsc-dataseed.binance.org/`,
                    0,
                    1
                ),
            network_id: 56,
            confirmations: 2,
            gas: 2000000,
            timeoutBlocks: 200,
            skipDryRun: true,
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        bscscan: '4F91FHBBB5XICNI9HX5UMTTN19G3N7X4N2'
    },
    compilers: {
        solc: {
            version: '0.8.6', // Fetch exact version from solc-bin (default: truffle's version)
            docker: false, // Use "0.5.1" you've installed locally with docker (default: false)
            settings: {
                // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200,
                },
            },
        },
    },
};