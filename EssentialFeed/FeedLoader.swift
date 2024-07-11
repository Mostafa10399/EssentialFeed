//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mostafa on 7/12/24.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(compleation: @escaping () -> Void)
}
