//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mostafa on 7/12/24.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.getUrl(url: url )
    }
}

protocol HTTPClient {
    func getUrl(url: URL)
    var requestedUrl: URL? { get }
}

class HTTPClientSpy: HTTPClient {
    var requestedUrl: URL?
    func getUrl(url: URL) {
        requestedUrl = url
    }
    
    
    
}

final class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_RemoteFeedLoader_init_doesntRequestedDataFromUrl() {
        // Arrange
        let url = URL(string: "https//:a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        // Act
        // Assert
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_RemoteFeedLoader_load_requestDataFromUrl() {
        // Arrange
        let url = URL(string: "https//:a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        // Act
        sut.load()
        // Assert
        XCTAssertEqual(client.requestedUrl, url)
    }
    

}
