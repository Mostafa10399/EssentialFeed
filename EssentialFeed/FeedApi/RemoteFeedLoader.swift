//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mostafa on 7/21/24.
//

import Foundation

public protocol HTTPClient {
    func getUrl(url: URL)
    var requestedUrl: URL? { get }
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private  let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load() {
        client.getUrl(url: url  )
    }
}
