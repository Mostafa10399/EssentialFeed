//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mostafa on 7/21/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func getUrl(
        url: URL,
        completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private  let url: URL
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping (Result) -> Void) {
        client.getUrl(url: url) { result in
            switch result {
                case let .success(data, response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map({ $0.item })))
                } else {
                    
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivityError))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var item: FeedItem {
        FeedItem(
            id: id,
            description: description,
            location: location,
            imageUrl: image)
    }
}
