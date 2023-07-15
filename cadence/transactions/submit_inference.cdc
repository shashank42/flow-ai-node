
// import FlowTransferNFT from 0x1b25a8536e63a7da
// import NonFungibleToken from 0x631e88ae7f1d7c20
// import MetadataViews from 0x631e88ae7f1d7c20
import MainContractV2 from "MainContractV2"
import ExampleToken from "ExampleToken"
import FungibleToken from "FungibleToken"
import ExampleNFT from "ExampleNFT"
import NonFungibleToken from "NonFungibleToken"
import InferenceNFT from "InferenceNFT"

transaction(
    id: UInt64,
    url: String,
    ){ 
    let tokenReciever: &{FungibleToken.Receiver}
    let NFTRecievingCapability: &{NonFungibleToken.CollectionPublic}
    let minter: &InferenceNFT.NFTMinter

    let senderVault: Capability<&ExampleToken.Vault>
    let address: Address

    prepare(signer: AuthAccount){

        self.senderVault = signer.getCapability<&ExampleToken.Vault>(/private/exampleTokenVault)

        self.tokenReciever = signer
            .getCapability(ExampleToken.ReceiverPublicPath)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Unable to borrow receiver reference")


        self.NFTRecievingCapability = getAccount(signer.address).getCapability(InferenceNFT.CollectionPublicPath) 
                        .borrow<&InferenceNFT.Collection{NonFungibleToken.CollectionPublic}>()
                        ?? panic("Failed to get User's collection.")

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&InferenceNFT.NFTMinter>(from: InferenceNFT.MinterStoragePath)
            ?? panic("Account does not store an object at the specified path")

        self.address = signer.address

    }
    execute{
        MainContractV2.recieveInference(
        id: id, 
        url: url, 
        responder: self.address,
        tokenProvider: self.senderVault,
        responderRecievingCapability: self.tokenReciever,
        responderNFTRecievingCapability: self.NFTRecievingCapability,
        minter: self.minter
        )

    }
}

