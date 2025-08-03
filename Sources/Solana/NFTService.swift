import Foundation
import Alamofire

public class NFTService {
    private let session: Session
    private let openSeaApiKey: String?
    private let magicEdenApiKey: String?
    
    public init(openSeaApiKey: String? = nil, magicEdenApiKey: String? = nil) {
        self.openSeaApiKey = openSeaApiKey
        self.magicEdenApiKey = magicEdenApiKey
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = Session(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    public func fetchNFTs(parameters: NFTQueryParameters) async throws -> NFTResponse {
        var allNFTs: [NFT] = []
        
        // Fetch from multiple marketplaces if no specific marketplace is specified
        let marketplaces: [NFTMarketplace] = parameters.marketplace != nil ? [parameters.marketplace!] : [.openSea, .magicEden]
        
        for marketplace in marketplaces {
            do {
                let nfts = try await fetchNFTsFromMarketplace(marketplace: marketplace, parameters: parameters)
                allNFTs.append(contentsOf: nfts)
            } catch {
                print("Failed to fetch NFTs from \(marketplace.name): \(error)")
                // Continue with other marketplaces
            }
        }
        
        // Remove duplicates based on contract address and token ID
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
    
    // MARK: - OpenSea Integration
    
    private func fetchOpenSeaNFTs(parameters: NFTQueryParameters) async throws -> [NFT] {
        let url = "\(NFTMarketplace.openSea.baseUrl)/assets"
        
        var queryParams: [String: Any] = [
            "owner": parameters.walletAddress,
            "limit": parameters.limit,
            "offset": parameters.offset
        ]
        
        if let collection = parameters.collection {
            queryParams["collection"] = collection
        }
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = openSeaApiKey {
            headers["X-API-KEY"] = apiKey
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, parameters: queryParams, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let openSeaResponse = try JSONDecoder().decode(OpenSeaAssetsResponse.self, from: data)
                            let nfts = openSeaResponse.assets.map { self.convertOpenSeaAssetToNFT($0) }
                            continuation.resume(returning: nfts)
                        } catch {
                            continuation.resume(throwing: NFTError.invalidResponse)
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            switch statusCode {
                            case 401:
                                continuation.resume(throwing: NFTError.unauthorized)
                            case 429:
                                continuation.resume(throwing: NFTError.rateLimitExceeded)
                            default:
                                continuation.resume(throwing: NFTError.networkError(error))
                            }
                        } else {
                            continuation.resume(throwing: NFTError.networkError(error))
                        }
                    }
                }
        }
    }
    
    private func fetchOpenSeaNFTMetadata(contractAddress: String, tokenId: String) async throws -> NFT {
        let url = "\(NFTMarketplace.openSea.baseUrl)/asset/\(contractAddress)/\(tokenId)"
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = openSeaApiKey {
            headers["X-API-KEY"] = apiKey
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let asset = try JSONDecoder().decode(OpenSeaAsset.self, from: data)
                            let nft = self.convertOpenSeaAssetToNFT(asset)
                            continuation.resume(returning: nft)
                        } catch {
                            continuation.resume(throwing: NFTError.invalidResponse)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NFTError.networkError(error))
                    }
                }
        }
    }
    
    private func fetchOpenSeaCollectionNFTs(collectionSlug: String, limit: Int) async throws -> [NFT] {
        let url = "\(NFTMarketplace.openSea.baseUrl)/assets"
        
        let queryParams: [String: Any] = [
            "collection": collectionSlug,
            "limit": limit
        ]
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = openSeaApiKey {
            headers["X-API-KEY"] = apiKey
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, parameters: queryParams, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let openSeaResponse = try JSONDecoder().decode(OpenSeaAssetsResponse.self, from: data)
                            let nfts = openSeaResponse.assets.map { self.convertOpenSeaAssetToNFT($0) }
                            continuation.resume(returning: nfts)
                        } catch {
                            continuation.resume(throwing: NFTError.invalidResponse)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NFTError.networkError(error))
                    }
                }
        }
    }
    
    // MARK: - Magic Eden Integration
    
    private func fetchMagicEdenNFTs(parameters: NFTQueryParameters) async throws -> [NFT] {
        let url = "\(NFTMarketplace.magicEden.baseUrl)/wallets/\(parameters.walletAddress)/tokens"
        
        var queryParams: [String: Any] = [
            "limit": parameters.limit,
            "offset": parameters.offset
        ]
        
        if let collection = parameters.collection {
            queryParams["collection"] = collection
        }
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = magicEdenApiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, parameters: queryParams, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let magicEdenTokens = try JSONDecoder().decode([MagicEdenToken].self, from: data)
                            let nfts = magicEdenTokens.map { self.convertMagicEdenTokenToNFT($0) }
                            continuation.resume(returning: nfts)
                        } catch {
                            continuation.resume(throwing: NFTError.invalidResponse)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NFTError.networkError(error))
                    }
                }
        }
    }
    
    private func fetchMagicEdenNFTMetadata(contractAddress: String, tokenId: String) async throws -> NFT {
        let url = "\(NFTMarketplace.magicEden.baseUrl)/tokens/\(contractAddress)"
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = magicEdenApiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let token = try JSONDecoder().decode(MagicEdenToken.self, from: data)
                            let nft = self.convertMagicEdenTokenToNFT(token)
                            continuation.resume(returning: nft)
                        } catch {
                            continuation.resume(throwing: NFTError.invalidResponse)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NFTError.networkError(error))
                    }
                }
        }
    }
    
    private func fetchMagicEdenCollectionNFTs(collectionSlug: String, limit: Int) async throws -> [NFT] {
        let url = "\(NFTMarketplace.magicEden.baseUrl)/collections/\(collectionSlug)/tokens"
        
        let queryParams: [String: Any] = [
            "limit": limit
        ]
        
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if let apiKey = magicEdenApiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, parameters: queryParams, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let magicEdenTokens = try JSONDecoder().decode([MagicEdenToken].self, from: data)
                            let nfts = magicEdenTokens.map { self.convertMagicEdenTokenToNFT($0) }
                            continuation.resume(returning: nfts)
                        } catch {
                            continuation.resume(throwing: NFTError.invalidResponse)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NFTError.networkError(error))
                    }
                }
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

// MARK: - OpenSea API Models

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

// MARK: - Magic Eden API Models

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