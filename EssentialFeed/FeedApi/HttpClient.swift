//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Mostafa Mahmoud on 02/10/2024.
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
