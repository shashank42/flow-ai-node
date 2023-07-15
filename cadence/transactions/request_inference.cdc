import MainContractV2 from "MainContractV2"
import ExampleToken from "ExampleToken"
import FungibleToken from "FungibleToken"

transaction(recipient: Address, prompt: String, offer: UInt64){

    // The Vault resource that holds the tokens that are being transferred
    let sender: @ExampleToken.Vault
    let vault: Capability //<&ExampleToken.Vault{FungibleToken.Receiver}>
    /// Reference to the Fungible Token Receiver of the recipient
    let tokenReceiver: &{FungibleToken.Receiver}
    let address: Address


    prepare(signer: AuthAccount){

        self.sender <- signer.borrow<&ExampleToken.Vault>(from: ExampleToken.VaultStoragePath)!.withdraw(amount: UFix64(1)) as! @ExampleToken.Vault

        // Get the account of the recipient and borrow a reference to their receiver
        var account = getAccount(signer.address)
        self.tokenReceiver = account
            .getCapability(ExampleToken.ReceiverPublicPath)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Unable to borrow receiver reference")

        self.vault = signer.getCapability(ExampleToken.ReceiverPublicPath)

        self.address = signer.address
    }

    execute{
        MainContractV2.requestInference(
            prompt: prompt, 
            requestor: self.address,
            responder: self.address,
            offer: offer,
            requestorVault: <- self.sender,
            receiverCapability: self.tokenReceiver
        )

    }
}