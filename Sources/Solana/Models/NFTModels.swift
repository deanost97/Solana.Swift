import Foundation

// MARK: - NFT Base Model
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

// MARK: - NFT Attribute
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

// MARK: - NFT Collection
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

// MARK: - NFT Price
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

// MARK: - NFT Sale
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

// MARK: - NFT Marketplace
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

// MARK: - NFT Query Parameters
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

// MARK: - NFT Response
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

// MARK: - NFT Error
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