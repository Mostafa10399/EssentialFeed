//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mostafa on 7/12/24.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_RemoteFeedLoader_init_doesntRequestedDataFromUrl() {
        // Arrange
        let (_, client) = makeSut()
        // Act
        // Assert
        XCTAssertTrue (client.requestedURLs.isEmpty)
    }
    
    func test_RemoteFeedLoader_load_requestsDataFromUrl() {
        // Arrange
        let url =  URL(string: "https//:a-url.com")!
        let (sut, client) = makeSut()
        // Act
        sut.load()
        // Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_RemoteFeedLoader_DeliveryErrorOnClientError() {
        // Arrange
        let (sut, client) = makeSut()
        var capturedErrors = [RemoteFeedLoader.Error]()
        // Act
        sut.load { capturedErrors.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        // Assert
        XCTAssertEqual(capturedErrors, [.connectivityError])
        
    }
    
    func test_RemoteFeedLoader_loadTwice_requestsDataFromUrlTwice() {
        // Arrange
        let url =  URL(string: "https//:a-url.com")!
        let (sut, client) = makeSut()
        // Act
        sut.load()
        sut.load()
        // Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    private func makeSut(url: URL = URL(string: "https//:a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        func getUrl(
            url: URL,
            completion: @escaping (Error) -> Void) {
                messages.append((url, completion))
            }
        
        func complete(with error: Error, index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
