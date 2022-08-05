const fs = require("fs");

async function main() {
  fs.readFile("./imageHashes.json", "utf8", (err, jsonString) => {
    if (err) {
      console.log("Error reading file from disk:", err);
      return;
    }
    try {
      const imageHashes = JSON.parse(jsonString);
      console.log("imageHashes:", imageHashes);
      var index=0;
      for (const key in imageHashes) {
          index=index+1
        // console.log(`${key}: ${imageHashes[key]}:${index}`);
        writeFile(imageHashes,key,imageHashes[key],index);
    }
      // writeFile(hashes)
      // => "Customer address is: Infinity Loop Drive"
    } catch (err) {
      console.log("Error parsing JSON string:", err);
    }
  });
}


async function writeFile(Imagehashes,key,value,index) {
  fs.readFile(`./Metadata/${index}.json`, "utf8", (err, jsonString) => {
    if (err) {
      console.log("Error reading file from disk:", err);
      return;
    }
    try {
      const hashes = JSON.parse(jsonString);
      console.log("hashes:", hashes);
      const updatedHashes = (hashes[
        `image`
      ] = `https://dweb.link/ipfs/${Imagehashes[`${key}`]}/${index}.png`);
      // console.log(updatedHashes, "updatedHashes");
      hashes[`image`] = updatedHashes;
      // console.log(hashes, "result");
      writeToJSONFile(`./Metadata/${index}.json`, hashes);

      // => "Customer address is: Infinity Loop Drive"
    } catch (err) {
      console.log("Error parsing JSON string:", err);
    }
  });
}



function writeToJSONFile(fileName, contentToWrite) {
  // convert JSON object to string
  const data = JSON.stringify(contentToWrite);

  // write JSON string to a file
  fs.writeFile(fileName, data, (err) => {
    if (err) {
      throw err;
    }
    console.log("JSON data is saved.");
  });
}

main();
