import { ethers } from "ethers";
import * as oldABI from "./oldABI.json";

async function getIdsAndAddresses() {
    console.log("Starting address gathering");
    const provider = new ethers.providers.JsonRpcProvider("https://rpcapi-tracing.fantom.network");
    const OldContract = new ethers.Contract("0xAA57EFDa5070F114f5Ed45f463AC6073A668e5dD", oldABI, provider);
    const oldc = await OldContract.attach("0xAA57EFDa5070F114f5Ed45f463AC6073A668e5dD");
    console.log("Should be connected to stuff");
    let tokenId: number = 0;
    let userAddress: string = "";
    let addressMap = new Map<number, string>();
    for(let i = 1; i <= 375; i++) {
        tokenId = i;
        userAddress = await oldc.ownerOf(tokenId);
        addressMap.set(tokenId, userAddress);
    }
    console.log(addressMap);
}

getIdsAndAddresses();