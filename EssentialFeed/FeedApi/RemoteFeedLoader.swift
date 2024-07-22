//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mostafa on 7/21/24.
//

import Foundation

public protocol HTTPClient {
    func getUrl(
        url: URL,
        completion: @escaping (Error) -> Void)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private  let url: URL
    
    public enum Error: Swift.Error {
        case connectivityError
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.getUrl(url: url) { error in
            completion(.connectivityError)
        }
    }
}
