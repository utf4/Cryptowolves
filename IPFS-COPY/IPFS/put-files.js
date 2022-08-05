/* eslint-disable no-await-in-loop */
/* eslint-disable no-restricted-syntax */
/*
Token for testing :
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDFCNzUyODgwYTY5ZDI3NjU0MUY4ODBjMzljMEU3ODg5ODc3YjUyNmIiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NDAwODM3NjkzMzUsIm5hbWUiOiJ0dXRvcmlhbCJ9.KaGlYehOgizpg7EoKUvCXzWxQf6YvWSnitj8XNu1RbU
*/

/*
How to run it
Type in terminal...
OR
node put-files.js --token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDFCNzUyODgwYTY5ZDI3NjU0MUY4ODBjMzljMEU3ODg5ODc3YjUyNmIiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NDAwODM3NjkzMzUsIm5hbWUiOiJ0dXRvcmlhbCJ9.KaGlYehOgizpg7EoKUvCXzWxQf6YvWSnitj8XNu1RbU ~/Desktop/nft
*/

// https://dweb.link/ipfs/bafybeic3xo5gwrfr7lln75dofsi5evozbz4pd47k7cekw7ccscs25dy4be

// https://dweb.link/ipfs/bafybeihdhqrxuilycefva6phu2ifibht2rytdyw2lvfobszgl5f6jzanni

/*
How to check files
Go to https://dweb.link/ipfs/YOUR_CID, replacing YOUR_CID with the CID you noted in the last step.
You should see a link to your file. If you uploaded multiple files at once, you'll see a list of all the files you uploaded.
Click on a file's link to view it in your browser!
*/

// import process from 'process';
// import minimist from 'minimist';
// import { Web3Storage, getFilesFromPath } from 'web3.storage';

const fs = require('fs');
const process = require('process');
const minimist = require('minimist');

const { Web3Storage, getFilesFromPath } = require('web3.storage');

function writeToJSONFile(fileName, contentToWrite) {
  // convert JSON object to string
  const data = JSON.stringify(contentToWrite);

  // write JSON string to a file
  fs.writeFile(fileName, data, (err) => {
    if (err) {
      throw err;
    }
    console.log('JSON data is saved.');
  });
}

async function main() {
  const args = minimist(process.argv.slice(2));

  const { token } = args;

  const fileHashes = {};

  if (!token) {
    return console.error(
      'A token is needed. You can create one on https://web3.storage'
    );
  }

  if (args._.length < 1) {
    return console.error('Please supply the path to a file or directory');
  }

  const storage = new Web3Storage({ token });

  for (const path of args._) {
    const pathFiles = await getFilesFromPath(path);

    for (let file of pathFiles) {
      const fileName = file.name.split('/')[2];
      file.name = fileName;
      console.log(file);
      console.log(`Uploading file ${file.name}`);
      const cid = await storage.put([file]);
      console.log('Content added with CID:', cid);

      fileHashes[fileName] = cid;
    }
  }
  
  console.log(fileHashes,"fileHahses")
  writeToJSONFile('imageHashes.json', fileHashes);

  //Replace fileHashes with metaData json placeholders

}


main();
