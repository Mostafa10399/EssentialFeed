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
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping (Error) -> Void) {
        client.getUrl(url: url) { result in
            switch result {
                case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivityError)
            }
        }
    }
}
