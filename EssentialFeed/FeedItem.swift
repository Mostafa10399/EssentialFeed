//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Mostafa on 7/12/24.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
