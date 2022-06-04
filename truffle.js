module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "172.27.160.1",
      port: 7545,
      network_id: "*"
    },
  },
  compilers: {
    solc: {
      version: "0.8.13"
    }
  },
  plugins: ["truffle-contract-size", "solidity-coverage"]
};
