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
        completion: @escaping (Error?, HTTPURLResponse?) -> Void)
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
        client.getUrl(url: url) { error, response  in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivityError)
            }
            
        }
    }
}
