import Foundation

public protocol SolanaAccountStorage {
    func save(_ signer: Signer) -> Result<Void, Error>
    var account: Result<Signer, Error> { get }
    func clear() -> Result<Void, Error>
}

public class Solana {
    let router: SolanaRouter
    public let socket: SolanaSocket
    public let api: Api
    public let action: Action
    public let tokens: TokenInfoProvider
    public let walletManager: WalletConnectionManager
    public let nftService: NFTService

    public init(
        router: SolanaRouter,
        tokenProvider: TokenInfoProvider = EmptyInfoTokenProvider(),
        openSeaApiKey: String? = nil,
        magicEdenApiKey: String? = nil
    ) {
        self.router = router
        self.socket = SolanaSocket(endpoint: router.endpoint)
        self.tokens = tokenProvider
        self.api = Api(router: router, supportedTokens: self.tokens.supportedTokens)
        self.action = Action(api: self.api, router: router, supportedTokens: self.tokens.supportedTokens)
        
        #if canImport(UIKit)
        self.walletManager = WalletConnectionManager()
        #else
        // For non-iOS platforms, provide a mock implementation
        fatalError("Wallet connection is only supported on iOS")
        #endif
        
        self.nftService = NFTService(openSeaApiKey: openSeaApiKey, magicEdenApiKey: magicEdenApiKey)
    }
    
    // MARK: - Convenience Methods
    
    /// Connect to a wallet (Phantom or MetaMask)
    public func connectWallet(_ walletType: WalletType) async throws -> WalletAccount {
        #if canImport(UIKit)
        return try await walletManager.connect(walletType: walletType)
        #else
        throw WalletConnectionError.unsupportedWallet
        #endif
    }
    
    /// Disconnect from the current wallet
    public func disconnectWallet() async throws {
        #if canImport(UIKit)
        try await walletManager.disconnect()
        #else
        throw WalletConnectionError.unsupportedWallet
        #endif
    }
    
    /// Get NFTs for a wallet address
    public func getNFTs(for walletAddress: String, marketplace: NFTMarketplace? = nil, limit: Int = 20) async throws -> NFTResponse {
        let parameters = NFTQueryParameters(
            walletAddress: walletAddress,
            marketplace: marketplace,
            limit: limit
        )
        return try await nftService.fetchNFTs(parameters: parameters)
    }
    
    /// Get specific NFT metadata
    public func getNFTMetadata(contractAddress: String, tokenId: String, marketplace: NFTMarketplace) async throws -> NFT {
        return try await nftService.fetchNFTMetadata(
            contractAddress: contractAddress,
            tokenId: tokenId,
            marketplace: marketplace
        )
    }
    
    /// Get NFTs from a specific collection
    public func getCollectionNFTs(collectionSlug: String, marketplace: NFTMarketplace, limit: Int = 20) async throws -> [NFT] {
        return try await nftService.fetchCollectionNFTs(
            collectionSlug: collectionSlug,
            marketplace: marketplace,
            limit: limit
        )
    }
}

public class Api {
    internal let router: SolanaRouter
    internal let supportedTokens: [Token]

    public init(router: SolanaRouter, supportedTokens: [Token]) {
        self.router = router
        self.supportedTokens = supportedTokens
    }
}

public class Action {
    internal let api: Api
    internal let router: SolanaRouter
    internal let supportedTokens: [Token]

    public init(api: Api, router: SolanaRouter, supportedTokens: [Token]) {
        self.router = router
        self.supportedTokens = supportedTokens
        self.api = api
    }
}
