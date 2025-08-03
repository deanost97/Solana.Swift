import Foundation
import UIKit
import Network

// MARK: - Wallet Types and Models

public enum WalletType: String, CaseIterable {
    case phantom = "phantom"
    case metamask = "metamask"
    
    var name: String {
        switch self {
        case .phantom:
            return "Phantom"
        case .metamask:
            return "MetaMask"
        }
    }
    
    var deepLinkScheme: String {
        switch self {
        case .phantom:
            return "phantom://"
        case .metamask:
            return "metamask://"
        }
    }
    
    var universalLink: String {
        switch self {
        case .phantom:
            return "https://phantom.app"
        case .metamask:
            return "https://metamask.app.link"
        }
    }
}

public enum WalletConnectionState {
    case disconnected
    case connecting
    case connected(WalletAccount)
    case failed(Error)
}

public struct WalletAccount {
    public let address: String
    public let walletType: WalletType
    public let publicKey: String?
    public let chainId: String?
    
    public init(address: String, walletType: WalletType, publicKey: String? = nil, chainId: String? = nil) {
        self.address = address
        self.walletType = walletType
        self.publicKey = publicKey
        self.chainId = chainId
    }
}

public enum WalletConnectionError: LocalizedError {
    case walletNotInstalled(WalletType)
    case userRejected
    case connectionFailed(String)
    case transactionFailed(String)
    case invalidResponse
    case unsupportedWallet
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .walletNotInstalled(let type):
            return "\(type.name) wallet is not installed"
        case .userRejected:
            return "User rejected the connection request"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .transactionFailed(let message):
            return "Transaction failed: \(message)"
        case .invalidResponse:
            return "Invalid response from wallet"
        case .unsupportedWallet:
            return "Unsupported wallet type"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - NFT Models

public struct NFT {
    public let tokenId: String
    public let contractAddress: String
    public let name: String?
    public let description: String?
    public let imageUrl: String?
    public let animationUrl: String?
    public let externalUrl: String?
    public let attributes: [NFTAttribute]
    public let collection: NFTCollection?
    public let owner: String?
    public let marketplace: NFTMarketplace
    public let lastSale: NFTSale?
    public let currentPrice: NFTPrice?
    
    public init(
        tokenId: String,
        contractAddress: String,
        name: String? = nil,
        description: String? = nil,
        imageUrl: String? = nil,
        animationUrl: String? = nil,
        externalUrl: String? = nil,
        attributes: [NFTAttribute] = [],
        collection: NFTCollection? = nil,
        owner: String? = nil,
        marketplace: NFTMarketplace,
        lastSale: NFTSale? = nil,
        currentPrice: NFTPrice? = nil
    ) {
        self.tokenId = tokenId
        self.contractAddress = contractAddress
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.animationUrl = animationUrl
        self.externalUrl = externalUrl
        self.attributes = attributes
        self.collection = collection
        self.owner = owner
        self.marketplace = marketplace
        self.lastSale = lastSale
        self.currentPrice = currentPrice
    }
}

public struct NFTAttribute {
    public let traitType: String
    public let value: String
    public let displayType: String?
    public let rarity: Double?
    
    public init(traitType: String, value: String, displayType: String? = nil, rarity: Double? = nil) {
        self.traitType = traitType
        self.value = value
        self.displayType = displayType
        self.rarity = rarity
    }
}

public struct NFTCollection {
    public let name: String
    public let slug: String?
    public let description: String?
    public let imageUrl: String?
    public let externalUrl: String?
    public let floorPrice: NFTPrice?
    public let totalSupply: Int?
    public let verified: Bool
    
    public init(
        name: String,
        slug: String? = nil,
        description: String? = nil,
        imageUrl: String? = nil,
        externalUrl: String? = nil,
        floorPrice: NFTPrice? = nil,
        totalSupply: Int? = nil,
        verified: Bool = false
    ) {
        self.name = name
        self.slug = slug
        self.description = description
        self.imageUrl = imageUrl
        self.externalUrl = externalUrl
        self.floorPrice = floorPrice
        self.totalSupply = totalSupply
        self.verified = verified
    }
}

public struct NFTPrice {
    public let amount: Double
    public let currency: String
    public let usdValue: Double?
    
    public init(amount: Double, currency: String, usdValue: Double? = nil) {
        self.amount = amount
        self.currency = currency
        self.usdValue = usdValue
    }
}

public struct NFTSale {
    public let price: NFTPrice
    public let timestamp: Date
    public let transactionHash: String?
    public let fromAddress: String?
    public let toAddress: String?
    
    public init(
        price: NFTPrice,
        timestamp: Date,
        transactionHash: String? = nil,
        fromAddress: String? = nil,
        toAddress: String? = nil
    ) {
        self.price = price
        self.timestamp = timestamp
        self.transactionHash = transactionHash
        self.fromAddress = fromAddress
        self.toAddress = toAddress
    }
}

public enum NFTMarketplace: String, CaseIterable {
    case openSea = "opensea"
    case magicEden = "magiceden"
    case solanart = "solanart"
    case digitaleyes = "digitaleyes"
    
    var name: String {
        switch self {
        case .openSea:
            return "OpenSea"
        case .magicEden:
            return "Magic Eden"
        case .solanart:
            return "Solanart"
        case .digitaleyes:
            return "DigitalEyes"
        }
    }
    
    var baseUrl: String {
        switch self {
        case .openSea:
            return "https://api.opensea.io/api/v1"
        case .magicEden:
            return "https://api-mainnet.magiceden.dev/v2"
        case .solanart:
            return "https://qzlsklfacc.medianetwork.cloud"
        case .digitaleyes:
            return "https://digitaleyes.market/api"
        }
    }
    
    var supportsChain: [String] {
        switch self {
        case .openSea:
            return ["ethereum", "polygon", "solana"]
        case .magicEden:
            return ["solana"]
        case .solanart:
            return ["solana"]
        case .digitaleyes:
            return ["solana"]
        }
    }
}

public struct NFTQueryParameters {
    public let walletAddress: String
    public let marketplace: NFTMarketplace?
    public let collection: String?
    public let limit: Int
    public let offset: Int
    public let includeMetadata: Bool
    
    public init(
        walletAddress: String,
        marketplace: NFTMarketplace? = nil,
        collection: String? = nil,
        limit: Int = 20,
        offset: Int = 0,
        includeMetadata: Bool = true
    ) {
        self.walletAddress = walletAddress
        self.marketplace = marketplace
        self.collection = collection
        self.limit = limit
        self.offset = offset
        self.includeMetadata = includeMetadata
    }
}

public struct NFTResponse {
    public let nfts: [NFT]
    public let totalCount: Int
    public let hasMore: Bool
    public let nextOffset: Int?
    
    public init(nfts: [NFT], totalCount: Int, hasMore: Bool, nextOffset: Int? = nil) {
        self.nfts = nfts
        self.totalCount = totalCount
        self.hasMore = hasMore
        self.nextOffset = nextOffset
    }
}

public enum NFTError: LocalizedError {
    case invalidWalletAddress
    case apiKeyMissing
    case networkError(Error)
    case invalidResponse
    case marketplaceNotSupported
    case rateLimitExceeded
    case unauthorized
    
    public var errorDescription: String? {
        switch self {
        case .invalidWalletAddress:
            return "Invalid wallet address provided"
        case .apiKeyMissing:
            return "API key is required for this marketplace"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from marketplace API"
        case .marketplaceNotSupported:
            return "Marketplace is not supported for this operation"
        case .rateLimitExceeded:
            return "Rate limit exceeded, please try again later"
        case .unauthorized:
            return "Unauthorized access to marketplace API"
        }
    }
}

// MARK: - Transaction Models

public struct SolanaTransaction {
    public let instructions: [TransactionInstruction]
    public let feePayer: String
    public let recentBlockhash: String?
    
    public init(instructions: [TransactionInstruction], feePayer: String, recentBlockhash: String? = nil) {
        self.instructions = instructions
        self.feePayer = feePayer
        self.recentBlockhash = recentBlockhash
    }
    
    public func serialize() throws -> Data {
        // Simplified serialization - in a real implementation, this would properly serialize the transaction
        let transactionData = [
            "instructions": instructions.count,
            "feePayer": feePayer,
            "recentBlockhash": recentBlockhash ?? ""
        ]
        return try JSONSerialization.data(withJSONObject: transactionData)
    }
}

public struct TransactionInstruction {
    public let programId: String
    public let accounts: [AccountMeta]
    public let data: Data
    
    public init(programId: String, accounts: [AccountMeta], data: Data) {
        self.programId = programId
        self.accounts = accounts
        self.data = data
    }
}

public struct AccountMeta {
    public let publicKey: String
    public let isSigner: Bool
    public let isWritable: Bool
    
    public init(publicKey: String, isSigner: Bool, isWritable: Bool) {
        self.publicKey = publicKey
        self.isSigner = isSigner
        self.isWritable = isWritable
    }
}

// MARK: - Protocols

public protocol WalletConnectionDelegate: AnyObject {
    func walletConnectionDidChange(state: WalletConnectionState)
    func walletDidReceiveTransaction(signature: String, success: Bool)
    func walletConnectionDidFail(error: Error)
}

public protocol WalletConnectionProtocol: AnyObject {
    var connectionState: WalletConnectionState { get }
    var delegate: WalletConnectionDelegate? { get set }
    
    func connect(walletType: WalletType) async throws -> WalletAccount
    func disconnect() async throws
    func signTransaction(transaction: SolanaTransaction) async throws -> String
    func signMessage(message: String) async throws -> String
    func isWalletInstalled(walletType: WalletType) -> Bool
}

// MARK: - Wallet Connection Manager

public class WalletConnectionManager: WalletConnectionProtocol {
    public private(set) var connectionState: WalletConnectionState = .disconnected
    public weak var delegate: WalletConnectionDelegate?
    
    private var currentAccount: WalletAccount?
    
    public init() {}
    
    // MARK: - Wallet Connection
    
    public func connect(walletType: WalletType) async throws -> WalletAccount {
        delegate?.walletConnectionDidChange(state: .connecting)
        connectionState = .connecting
        
        // Check if wallet is installed
        guard isWalletInstalled(walletType: walletType) else {
            let error = WalletConnectionError.walletNotInstalled(walletType)
            connectionState = .failed(error)
            delegate?.walletConnectionDidFail(error: error)
            throw error
        }
        
        do {
            let account = try await performWalletConnection(walletType: walletType)
            currentAccount = account
            connectionState = .connected(account)
            delegate?.walletConnectionDidChange(state: connectionState)
            return account
        } catch {
            connectionState = .failed(error)
            delegate?.walletConnectionDidFail(error: error)
            throw error
        }
    }
    
    public func disconnect() async throws {
        currentAccount = nil
        connectionState = .disconnected
        delegate?.walletConnectionDidChange(state: .disconnected)
    }
    
    public func signTransaction(transaction: SolanaTransaction) async throws -> String {
        guard case .connected(let account) = connectionState else {
            throw WalletConnectionError.connectionFailed("No wallet connected")
        }
        
        do {
            let signature = try await performTransactionSigning(transaction: transaction, walletType: account.walletType)
            delegate?.walletDidReceiveTransaction(signature: signature, success: true)
            return signature
        } catch {
            delegate?.walletDidReceiveTransaction(signature: "", success: false)
            throw error
        }
    }
    
    public func signMessage(message: String) async throws -> String {
        guard case .connected(let account) = connectionState else {
            throw WalletConnectionError.connectionFailed("No wallet connected")
        }
        
        return try await performMessageSigning(message: message, walletType: account.walletType)
    }
    
    public func isWalletInstalled(walletType: WalletType) -> Bool {
        guard let url = URL(string: walletType.deepLinkScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    // MARK: - Private Methods
    
    private func performWalletConnection(walletType: WalletType) async throws -> WalletAccount {
        switch walletType {
        case .phantom:
            return try await connectPhantom()
        case .metamask:
            return try await connectMetaMask()
        }
    }
    
    private func connectPhantom() async throws -> WalletAccount {
        let dappUrl = "https://your-dapp.com"
        let connectParams = [
            "dapp_encryption_public_key": generateRandomKey(),
            "cluster": "mainnet-beta",
            "app_url": dappUrl,
            "redirect_link": "\(dappUrl)/phantom-connect"
        ]
        
        let queryString = connectParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let phantomURL = URL(string: "phantom://v1/connect?\(queryString)") else {
            throw WalletConnectionError.connectionFailed("Invalid Phantom URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(phantomURL)
        }
        
        // Simulate connection delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Mock successful connection
        let mockAddress = "11111111111111111111111111111112"
        let account = WalletAccount(
            address: mockAddress,
            walletType: .phantom,
            publicKey: mockAddress,
            chainId: "solana:mainnet"
        )
        
        return account
    }
    
    private func connectMetaMask() async throws -> WalletAccount {
        let dappUrl = "https://your-dapp.com"
        let connectParams = [
            "channelId": UUID().uuidString,
            "pubkey": generateRandomKey(),
            "comm": "socket",
            "redirectLink": "\(dappUrl)/metamask-connect"
        ]
        
        let queryString = connectParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let metamaskURL = URL(string: "metamask://connect?\(queryString)") else {
            throw WalletConnectionError.connectionFailed("Invalid MetaMask URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(metamaskURL)
        }
        
        // Simulate connection delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Mock successful connection
        let mockAddress = "0x742d35Cc6Ab7F0532f07C2c8F7aaF28E87628d57"
        let account = WalletAccount(
            address: mockAddress,
            walletType: .metamask,
            publicKey: nil,
            chainId: "ethereum:1"
        )
        
        return account
    }
    
    private func performTransactionSigning(transaction: SolanaTransaction, walletType: WalletType) async throws -> String {
        switch walletType {
        case .phantom:
            return try await signTransactionPhantom(transaction: transaction)
        case .metamask:
            return try await signTransactionMetaMask(transaction: transaction)
        }
    }
    
    private func signTransactionPhantom(transaction: SolanaTransaction) async throws -> String {
        let serializedTransaction = try transaction.serialize()
        let base64Transaction = serializedTransaction.base64EncodedString()
        
        let signParams = [
            "transaction": base64Transaction,
            "message": "Please sign this transaction"
        ]
        
        let queryString = signParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let phantomURL = URL(string: "phantom://v1/signTransaction?\(queryString)") else {
            throw WalletConnectionError.transactionFailed("Invalid Phantom transaction URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(phantomURL)
        }
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "phantom_signature_\(UUID().uuidString)"
    }
    
    private func signTransactionMetaMask(transaction: SolanaTransaction) async throws -> String {
        let transactionData = [
            "to": "0x742d35Cc6Ab7F0532f07C2c8F7aaF28E87628d57",
            "value": "0x0",
            "data": "0x"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: transactionData)
        let base64Transaction = jsonData.base64EncodedString()
        
        let signParams = [
            "transaction": base64Transaction,
            "method": "eth_sendTransaction"
        ]
        
        let queryString = signParams.compactMap { key, value in
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "\(key)=\(encodedValue)"
        }.joined(separator: "&")
        
        guard let metamaskURL = URL(string: "metamask://sign?\(queryString)") else {
            throw WalletConnectionError.transactionFailed("Invalid MetaMask transaction URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(metamaskURL)
        }
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "0x\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
    }
    
    private func performMessageSigning(message: String, walletType: WalletType) async throws -> String {
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message
        
        let baseURL: String
        switch walletType {
        case .phantom:
            baseURL = "phantom://v1/signMessage"
        case .metamask:
            baseURL = "metamask://signMessage"
        }
        
        guard let signURL = URL(string: "\(baseURL)?message=\(encodedMessage)") else {
            throw WalletConnectionError.connectionFailed("Invalid message signing URL")
        }
        
        await MainActor.run {
            UIApplication.shared.open(signURL)
        }
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "message_signature_\(UUID().uuidString)"
    }
    
    private func generateRandomKey() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<32).map { _ in characters.randomElement()! })
    }
}

// MARK: - NFT Service

public class NFTService {
    private let openSeaApiKey: String?
    private let magicEdenApiKey: String?
    
    public init(openSeaApiKey: String? = nil, magicEdenApiKey: String? = nil) {
        self.openSeaApiKey = openSeaApiKey
        self.magicEdenApiKey = magicEdenApiKey
    }
    
    public func fetchNFTs(parameters: NFTQueryParameters) async throws -> NFTResponse {
        var allNFTs: [NFT] = []
        
        let marketplaces: [NFTMarketplace] = parameters.marketplace != nil ? [parameters.marketplace!] : [.openSea, .magicEden]
        
        for marketplace in marketplaces {
            do {
                let nfts = try await fetchNFTsFromMarketplace(marketplace: marketplace, parameters: parameters)
                allNFTs.append(contentsOf: nfts)
            } catch {
                print("Failed to fetch NFTs from \(marketplace.name): \(error)")
            }
        }
        
        let uniqueNFTs = removeDuplicateNFTs(allNFTs)
        
        return NFTResponse(
            nfts: Array(uniqueNFTs.prefix(parameters.limit)),
            totalCount: uniqueNFTs.count,
            hasMore: uniqueNFTs.count > parameters.limit,
            nextOffset: uniqueNFTs.count > parameters.limit ? parameters.offset + parameters.limit : nil
        )
    }
    
    public func fetchNFTMetadata(contractAddress: String, tokenId: String, marketplace: NFTMarketplace) async throws -> NFT {
        switch marketplace {
        case .openSea:
            return try await fetchOpenSeaNFTMetadata(contractAddress: contractAddress, tokenId: tokenId)
        case .magicEden:
            return try await fetchMagicEdenNFTMetadata(contractAddress: contractAddress, tokenId: tokenId)
        default:
            throw NFTError.marketplaceNotSupported
        }
    }
    
    public func fetchCollectionNFTs(collectionSlug: String, marketplace: NFTMarketplace, limit: Int = 20) async throws -> [NFT] {
        switch marketplace {
        case .openSea:
            return try await fetchOpenSeaCollectionNFTs(collectionSlug: collectionSlug, limit: limit)
        case .magicEden:
            return try await fetchMagicEdenCollectionNFTs(collectionSlug: collectionSlug, limit: limit)
        default:
            throw NFTError.marketplaceNotSupported
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchNFTsFromMarketplace(marketplace: NFTMarketplace, parameters: NFTQueryParameters) async throws -> [NFT] {
        switch marketplace {
        case .openSea:
            return try await fetchOpenSeaNFTs(parameters: parameters)
        case .magicEden:
            return try await fetchMagicEdenNFTs(parameters: parameters)
        default:
            throw NFTError.marketplaceNotSupported
        }
    }
    
    private func fetchOpenSeaNFTs(parameters: NFTQueryParameters) async throws -> [NFT] {
        let url = "\(NFTMarketplace.openSea.baseUrl)/assets"
        
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "owner", value: parameters.walletAddress),
            URLQueryItem(name: "limit", value: String(parameters.limit)),
            URLQueryItem(name: "offset", value: String(parameters.offset))
        ]
        
        if let collection = parameters.collection {
            components.queryItems?.append(URLQueryItem(name: "collection", value: collection))
        }
        
        guard let finalURL = components.url else {
            throw NFTError.invalidResponse
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = openSeaApiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NFTError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let openSeaResponse = try JSONDecoder().decode(OpenSeaAssetsResponse.self, from: data)
                return openSeaResponse.assets.map { convertOpenSeaAssetToNFT($0) }
            case 401:
                throw NFTError.unauthorized
            case 429:
                throw NFTError.rateLimitExceeded
            default:
                throw NFTError.networkError(NSError(domain: "HTTPError", code: httpResponse.statusCode))
            }
        } catch {
            throw NFTError.networkError(error)
        }
    }
    
    private func fetchMagicEdenNFTs(parameters: NFTQueryParameters) async throws -> [NFT] {
        let url = "\(NFTMarketplace.magicEden.baseUrl)/wallets/\(parameters.walletAddress)/tokens"
        
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(parameters.limit)),
            URLQueryItem(name: "offset", value: String(parameters.offset))
        ]
        
        if let collection = parameters.collection {
            components.queryItems?.append(URLQueryItem(name: "collection", value: collection))
        }
        
        guard let finalURL = components.url else {
            throw NFTError.invalidResponse
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = magicEdenApiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let magicEdenTokens = try JSONDecoder().decode([MagicEdenToken].self, from: data)
            return magicEdenTokens.map { convertMagicEdenTokenToNFT($0) }
        } catch {
            throw NFTError.networkError(error)
        }
    }
    
    private func fetchOpenSeaNFTMetadata(contractAddress: String, tokenId: String) async throws -> NFT {
        let url = "\(NFTMarketplace.openSea.baseUrl)/asset/\(contractAddress)/\(tokenId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = openSeaApiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let asset = try JSONDecoder().decode(OpenSeaAsset.self, from: data)
            return convertOpenSeaAssetToNFT(asset)
        } catch {
            throw NFTError.networkError(error)
        }
    }
    
    private func fetchMagicEdenNFTMetadata(contractAddress: String, tokenId: String) async throws -> NFT {
        let url = "\(NFTMarketplace.magicEden.baseUrl)/tokens/\(contractAddress)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = magicEdenApiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let token = try JSONDecoder().decode(MagicEdenToken.self, from: data)
            return convertMagicEdenTokenToNFT(token)
        } catch {
            throw NFTError.networkError(error)
        }
    }
    
    private func fetchOpenSeaCollectionNFTs(collectionSlug: String, limit: Int) async throws -> [NFT] {
        let url = "\(NFTMarketplace.openSea.baseUrl)/assets"
        
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "collection", value: collectionSlug),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let finalURL = components.url else {
            throw NFTError.invalidResponse
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = openSeaApiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let openSeaResponse = try JSONDecoder().decode(OpenSeaAssetsResponse.self, from: data)
            return openSeaResponse.assets.map { convertOpenSeaAssetToNFT($0) }
        } catch {
            throw NFTError.networkError(error)
        }
    }
    
    private func fetchMagicEdenCollectionNFTs(collectionSlug: String, limit: Int) async throws -> [NFT] {
        let url = "\(NFTMarketplace.magicEden.baseUrl)/collections/\(collectionSlug)/tokens"
        
        var components = URLComponents(string: url)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let finalURL = components.url else {
            throw NFTError.invalidResponse
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = magicEdenApiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let magicEdenTokens = try JSONDecoder().decode([MagicEdenToken].self, from: data)
            return magicEdenTokens.map { convertMagicEdenTokenToNFT($0) }
        } catch {
            throw NFTError.networkError(error)
        }
    }
    
    // MARK: - Conversion Methods
    
    private func convertOpenSeaAssetToNFT(_ asset: OpenSeaAsset) -> NFT {
        let attributes = asset.traits?.map { trait in
            NFTAttribute(
                traitType: trait.traitType ?? "",
                value: trait.value ?? "",
                displayType: trait.displayType,
                rarity: nil
            )
        } ?? []
        
        let collection = asset.collection.map { openSeaCollection in
            NFTCollection(
                name: openSeaCollection.name ?? "",
                slug: openSeaCollection.slug,
                description: openSeaCollection.description,
                imageUrl: openSeaCollection.imageUrl,
                externalUrl: openSeaCollection.externalUrl,
                verified: openSeaCollection.safelistRequestStatus == "verified"
            )
        }
        
        let lastSale = asset.lastSale.map { sale in
            NFTSale(
                price: NFTPrice(
                    amount: Double(sale.totalPrice ?? "0") ?? 0,
                    currency: sale.paymentToken?.symbol ?? "ETH"
                ),
                timestamp: ISO8601DateFormatter().date(from: sale.eventTimestamp ?? "") ?? Date(),
                transactionHash: sale.transactionHash
            )
        }
        
        return NFT(
            tokenId: asset.tokenId ?? "",
            contractAddress: asset.assetContract?.address ?? "",
            name: asset.name,
            description: asset.description,
            imageUrl: asset.imageUrl,
            animationUrl: asset.animationUrl,
            externalUrl: asset.externalLink,
            attributes: attributes,
            collection: collection,
            owner: asset.owner?.address,
            marketplace: .openSea,
            lastSale: lastSale
        )
    }
    
    private func convertMagicEdenTokenToNFT(_ token: MagicEdenToken) -> NFT {
        let attributes = token.attributes?.map { attribute in
            NFTAttribute(
                traitType: attribute.traitType ?? "",
                value: attribute.value ?? "",
                rarity: attribute.rarity
            )
        } ?? []
        
        let collection = NFTCollection(
            name: token.collection ?? "",
            verified: token.verifiedCollection ?? false
        )
        
        return NFT(
            tokenId: token.mintAddress ?? "",
            contractAddress: token.mintAddress ?? "",
            name: token.name,
            description: token.description,
            imageUrl: token.image,
            attributes: attributes,
            collection: collection,
            owner: token.owner,
            marketplace: .magicEden,
            currentPrice: token.price.map { price in
                NFTPrice(amount: price, currency: "SOL")
            }
        )
    }
    
    private func removeDuplicateNFTs(_ nfts: [NFT]) -> [NFT] {
        var uniqueNFTs: [NFT] = []
        var seenKeys: Set<String> = []
        
        for nft in nfts {
            let key = "\(nft.contractAddress)_\(nft.tokenId)"
            if !seenKeys.contains(key) {
                seenKeys.insert(key)
                uniqueNFTs.append(nft)
            }
        }
        
        return uniqueNFTs
    }
}

// MARK: - API Response Models

private struct OpenSeaAssetsResponse: Codable {
    let assets: [OpenSeaAsset]
}

private struct OpenSeaAsset: Codable {
    let tokenId: String?
    let name: String?
    let description: String?
    let imageUrl: String?
    let animationUrl: String?
    let externalLink: String?
    let assetContract: OpenSeaAssetContract?
    let collection: OpenSeaCollection?
    let owner: OpenSeaAccount?
    let traits: [OpenSeaTrait]?
    let lastSale: OpenSeaSale?
    
    private enum CodingKeys: String, CodingKey {
        case tokenId = "token_id"
        case name, description
        case imageUrl = "image_url"
        case animationUrl = "animation_url"
        case externalLink = "external_link"
        case assetContract = "asset_contract"
        case collection, owner, traits
        case lastSale = "last_sale"
    }
}

private struct OpenSeaAssetContract: Codable {
    let address: String?
}

private struct OpenSeaCollection: Codable {
    let name: String?
    let slug: String?
    let description: String?
    let imageUrl: String?
    let externalUrl: String?
    let safelistRequestStatus: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, slug, description
        case imageUrl = "image_url"
        case externalUrl = "external_url"
        case safelistRequestStatus = "safelist_request_status"
    }
}

private struct OpenSeaAccount: Codable {
    let address: String?
}

private struct OpenSeaTrait: Codable {
    let traitType: String?
    let value: String?
    let displayType: String?
    
    private enum CodingKeys: String, CodingKey {
        case traitType = "trait_type"
        case value
        case displayType = "display_type"
    }
}

private struct OpenSeaSale: Codable {
    let totalPrice: String?
    let paymentToken: OpenSeaPaymentToken?
    let eventTimestamp: String?
    let transactionHash: String?
    
    private enum CodingKeys: String, CodingKey {
        case totalPrice = "total_price"
        case paymentToken = "payment_token"
        case eventTimestamp = "event_timestamp"
        case transactionHash = "transaction_hash"
    }
}

private struct OpenSeaPaymentToken: Codable {
    let symbol: String?
}

private struct MagicEdenToken: Codable {
    let mintAddress: String?
    let name: String?
    let description: String?
    let image: String?
    let collection: String?
    let attributes: [MagicEdenAttribute]?
    let owner: String?
    let price: Double?
    let verifiedCollection: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case mintAddress = "mintAddress"
        case name, description, image, collection, attributes, owner, price
        case verifiedCollection = "verifiedCollection"
    }
}

private struct MagicEdenAttribute: Codable {
    let traitType: String?
    let value: String?
    let rarity: Double?
    
    private enum CodingKeys: String, CodingKey {
        case traitType = "trait_type"
        case value, rarity
    }
}

// MARK: - Main Integration Class

public class WalletNFTIntegration {
    public let walletManager: WalletConnectionManager
    public let nftService: NFTService
    
    public init(openSeaApiKey: String? = nil, magicEdenApiKey: String? = nil) {
        self.walletManager = WalletConnectionManager()
        self.nftService = NFTService(openSeaApiKey: openSeaApiKey, magicEdenApiKey: magicEdenApiKey)
    }
    
    // MARK: - Convenience Methods
    
    public func connectWallet(_ walletType: WalletType) async throws -> WalletAccount {
        return try await walletManager.connect(walletType: walletType)
    }
    
    public func disconnectWallet() async throws {
        try await walletManager.disconnect()
    }
    
    public func getNFTs(for walletAddress: String, marketplace: NFTMarketplace? = nil, limit: Int = 20) async throws -> NFTResponse {
        let parameters = NFTQueryParameters(
            walletAddress: walletAddress,
            marketplace: marketplace,
            limit: limit
        )
        return try await nftService.fetchNFTs(parameters: parameters)
    }
    
    public func getNFTMetadata(contractAddress: String, tokenId: String, marketplace: NFTMarketplace) async throws -> NFT {
        return try await nftService.fetchNFTMetadata(
            contractAddress: contractAddress,
            tokenId: tokenId,
            marketplace: marketplace
        )
    }
    
    public func getCollectionNFTs(collectionSlug: String, marketplace: NFTMarketplace, limit: Int = 20) async throws -> [NFT] {
        return try await nftService.fetchCollectionNFTs(
            collectionSlug: collectionSlug,
            marketplace: marketplace,
            limit: limit
        )
    }
    
    public func signTransaction(_ transaction: SolanaTransaction) async throws -> String {
        return try await walletManager.signTransaction(transaction: transaction)
    }
    
    public func signMessage(_ message: String) async throws -> String {
        return try await walletManager.signMessage(message: message)
    }
}

// MARK: - Example Usage

public class WalletNFTExample: WalletConnectionDelegate {
    private let integration: WalletNFTIntegration
    private var connectedAccount: WalletAccount?
    
    public init() {
        // Initialize with optional API keys for better rate limits
        self.integration = WalletNFTIntegration(
            openSeaApiKey: "your_opensea_api_key_here", // Optional
            magicEdenApiKey: "your_magiceden_api_key_here" // Optional
        )
        
        // Set delegate to receive wallet connection updates
        integration.walletManager.delegate = self
    }
    
    // MARK: - Wallet Connection Examples
    
    public func connectToPhantom() async {
        do {
            print("🔗 Connecting to Phantom wallet...")
            let account = try await integration.connectWallet(.phantom)
            connectedAccount = account
            print("✅ Connected to Phantom!")
            print("📍 Wallet Address: \(account.address)")
            
            // After connecting, fetch NFTs
            await fetchNFTsExample()
            
        } catch let error as WalletConnectionError {
            handleWalletError(error, walletType: .phantom)
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    public func connectToMetaMask() async {
        do {
            print("🔗 Connecting to MetaMask wallet...")
            let account = try await integration.connectWallet(.metamask)
            connectedAccount = account
            print("✅ Connected to MetaMask!")
            print("📍 Wallet Address: \(account.address)")
            
        } catch let error as WalletConnectionError {
            handleWalletError(error, walletType: .metamask)
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    public func disconnectWallet() async {
        do {
            try await integration.disconnectWallet()
            connectedAccount = nil
            print("🔌 Wallet disconnected")
        } catch {
            print("❌ Failed to disconnect: \(error)")
        }
    }
    
    // MARK: - NFT Examples
    
    public func fetchNFTsExample() async {
        guard let account = connectedAccount else {
            print("❌ No wallet connected")
            return
        }
        
        do {
            print("🔍 Fetching NFTs for wallet: \(account.address)")
            
            let nftResponse = try await integration.getNFTs(for: account.address, limit: 10)
            
            print("🎨 Found \(nftResponse.nfts.count) NFTs:")
            for nft in nftResponse.nfts {
                print("  • \(nft.name ?? "Unnamed NFT") from \(nft.marketplace.name)")
                print("    Contract: \(nft.contractAddress)")
                print("    Token ID: \(nft.tokenId)")
                if let collection = nft.collection {
                    print("    Collection: \(collection.name)")
                }
                if let price = nft.currentPrice {
                    print("    Price: \(price.amount) \(price.currency)")
                }
                print("")
            }
            
        } catch {
            print("❌ Failed to fetch NFTs: \(error)")
        }
    }
    
    public func signTransactionExample() async {
        guard let account = connectedAccount else {
            print("❌ No wallet connected")
            return
        }
        
        do {
            // Create a mock transaction
            let instruction = TransactionInstruction(
                programId: "11111111111111111111111111111112",
                accounts: [
                    AccountMeta(publicKey: account.address, isSigner: true, isWritable: true),
                    AccountMeta(publicKey: "11111111111111111111111111111112", isSigner: false, isWritable: true)
                ],
                data: Data([0, 0, 0, 0])
            )
            
            let transaction = SolanaTransaction(
                instructions: [instruction],
                feePayer: account.address,
                recentBlockhash: "11111111111111111111111111111111"
            )
            
            print("📝 Signing transaction...")
            let signature = try await integration.signTransaction(transaction)
            print("✅ Transaction signed! Signature: \(signature)")
            
        } catch {
            print("❌ Failed to sign transaction: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleWalletError(_ error: WalletConnectionError, walletType: WalletType) {
        switch error {
        case .walletNotInstalled:
            print("❌ \(walletType.name) wallet is not installed")
            Task {
                await openWalletInstallPage(walletType)
            }
        case .userRejected:
            print("❌ User rejected the connection")
        case .connectionFailed(let message):
            print("❌ Connection failed: \(message)")
        default:
            print("❌ Wallet connection error: \(error.localizedDescription)")
        }
    }
    
    private func openWalletInstallPage(_ walletType: WalletType) async {
        await MainActor.run {
            guard let url = URL(string: walletType.universalLink) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - WalletConnectionDelegate
    
    public func walletConnectionDidChange(state: WalletConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .disconnected:
                print("🔌 Wallet disconnected")
            case .connecting:
                print("🔗 Connecting to wallet...")
            case .connected(let account):
                print("✅ Wallet connected: \(account.address)")
            case .failed(let error):
                print("❌ Wallet connection failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func walletDidReceiveTransaction(signature: String, success: Bool) {
        DispatchQueue.main.async {
            if success {
                print("✅ Transaction successful: \(signature)")
            } else {
                print("❌ Transaction failed")
            }
        }
    }
    
    public func walletConnectionDidFail(error: Error) {
        DispatchQueue.main.async {
            print("❌ Wallet connection failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - SwiftUI Integration Example

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
public struct WalletNFTView: View {
    @StateObject private var example = WalletNFTExample()
    @State private var isConnected = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Wallet & NFT Integration")
                .font(.title)
                .padding()
            
            if !isConnected {
                VStack(spacing: 15) {
                    Button("Connect Phantom Wallet") {
                        Task {
                            await example.connectToPhantom()
                            isConnected = example.connectedAccount != nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Connect MetaMask Wallet") {
                        Task {
                            await example.connectToMetaMask()
                            isConnected = example.connectedAccount != nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 15) {
                    Text("Wallet Connected!")
                        .foregroundColor(.green)
                    
                    if let account = example.connectedAccount {
                        Text("Address: \(String(account.address.prefix(8)))...")
                            .font(.caption)
                            .monospaced()
                    }
                    
                    Button("Fetch My NFTs") {
                        Task {
                            await example.fetchNFTsExample()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Sign Transaction") {
                        Task {
                            await example.signTransactionExample()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Disconnect") {
                        Task {
                            await example.disconnectWallet()
                            isConnected = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}
#endif