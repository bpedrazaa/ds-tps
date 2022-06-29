/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('../../test-application/javascript/CAUtil.js');
const { buildCCPOrg1, buildWallet } = require('../../test-application/javascript/AppUtil.js');
const mqtt = require('mqtt');
require("dotenv").config();

const channelName = 'mychannel';
const chaincodeName = 'basic';
const mspOrg1 = 'Org1MSP';
const walletPath = path.join(__dirname, 'wallet');
const org1UserId = 'appUser';

const topicSubVerify = "verify";
const topicSubRegister = "register";
const topicPub = "results";
const port = process.env.PORT;
const broker = process.env.BROKER;
const connectUrl = `mqtt://${broker}:${port}`;
const client = mqtt.connect(connectUrl)

function prettyJSONString(inputString) {
  return JSON.stringify(JSON.parse(inputString), null, 2);
}

async function main() {
  try {
    client.on('connect', () => {
      client.subscribe(topicSubVerify, () => {
        console.log("Suscribed to topic: ", topicSubVerify);
      })
      client.subscribe(topicSubRegister, () => {
        console.log("Suscribed to topic: ", topicSubRegister);
      })
    })
		// build an in memory object with the network configuration (also known as a connection profile)
    const ccp = buildCCPOrg1();

    // build an instance of the fabric ca services client based on
    // the information in the network configuration
    const caClient = buildCAClient(FabricCAServices, ccp, 'ca.org1.example.com');

    // setup the wallet to hold the credentials of the application user
    const wallet = await buildWallet(Wallets, walletPath);

    // in a real application this would be done on an administrative flow, and only once
    await enrollAdmin(caClient, wallet, mspOrg1);

    // in a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(caClient, wallet, mspOrg1, org1UserId, 'org1.department1');

    // Create a new gateway instance for interacting with the fabric network.
    // In a real application this would be done as the backend server session is setup for
    // a user that has been verified.
    const gateway = new Gateway();
    try {
			// setup the gateway instance
			// The user will now be able to create connections to the fabric network and be able to
			// submit transactions and query. All transactions submitted by this gateway will be
			// signed by this user using the credentials stored in the wallet.
      await gateway.connect(ccp, {
        wallet,
        identity: org1UserId,
        discovery: { enabled: true, asLocalhost: true } // using asLocalhost as this gateway is using a fabric network deployed locally
      });

      // Build a network instance based on the channel where the smart contract is deployed
      const network = await gateway.getNetwork(channelName);

      // Get the contract from the network.
      const contract = network.getContract(chaincodeName);

      // Initialize Ledger
      console.log('\n--> Submit Transaction: InitLedger, function creates the initial set of assets on the ledger');
      await contract.submitTransaction('InitLedger');
      console.log('*** Result: committed');

      // Get All Assets
      console.log('\n--> Evaluate Transaction: GetAllAssets, function returns all the current assets on the ledger');
      let result = await contract.evaluateTransaction('GetAllAssets');
      console.log(`*** Result: ${prettyJSONString(result.toString())}`);

      // MQTT Suscription implementation
      client.on('message',async (topic, payload) => {
        // If the ESP32 is registering itself...
        if (topic.toString() === 'register') {
          console.log("\n\n##########\tREGISTERING\t##########");
          console.log(`Received: ${payload.toString()}, from topic: ${topic.toString()}`)

          payload = JSON.parse(payload)
          const id = payload.ID.toString()
          const owner = payload.owner.toString()

          // Check if the asset already exists
          console.log('\n--> Submit Transaction: AssetExists');
          result = await contract.submitTransaction('AssetExists', id);
          result = prettyJSONString(result.toString())
          if (result === "true") {
            console.log("An Asset with this ID already exists")
          }else if (result === "false"){
            // Create the asset
            console.log('\n--> Submit Transaction: CreateAsset, creates new asset with ID and owner arguments');
            result = await contract.submitTransaction('CreateAsset', id, owner);
            console.log('*** Result: committed');
            if (`${result}` !== '') {
              console.log(`*** Result: ${prettyJSONString(result.toString())}`);
            }
          }
          console.log("##########################################\n");
        }
        // If the ESP32 is Verifying its owner
        else if (topic.toString() === 'verify') {
          console.log("\n\n##########\tVERIFYING\t##########");
          console.log(`Received: ${payload.toString()}, from topic: ${topic.toString()}`)
          payload = JSON.parse(payload)

          console.log('\n--> Submit Transaction, ReadAsset function returns an asset with a given assetid');
          result = await contract.submitTransaction('ReadAsset', payload.ID.toString());
          console.log(`*** Result: ${prettyJSONString(result.toString())}`);

          client.publish(topicPub, result, (error) => {
            if(error){
              console.error(error)
            }
          })
          console.log("##########################################\n");
        }
      })
    } finally {
      // Disconnect from the gateway when the application is closing
      // This will close all connections to the network
      gateway.disconnect();
    }
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
	}
}

main();
