//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mostafa on 7/21/24.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private  let url: URL
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidData
    }
    
    public typealias Result = LoadFeedResult

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.getUrl(url: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
                case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivityError))
            }
        }
    }
    

}
