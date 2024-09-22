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
        sut.load { _ in }
        // Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_RemoteFeedLoader_DeliveryErrorOnClientError() {
        // Arrange
        let (sut, client) = makeSut()
        expect(sut,
               toCompleteWithError: .connectivityError,
               when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
            
        })
    }
    
    func test_RemoteFeedLoader_DeliveryErrorOnNon200OnHttpResponse() {
        // Arrange
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        // Act
        samples.enumerated().forEach { index, code in
            expect(sut,
                   toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_RemoteFeedLoader_Delivers200ResponseButWithInvalidJson() {
        let (sut, client) = makeSut()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_RemoteFeedLoader_loadTwice_requestsDataFromUrlTwice() {
        // Arrange
        let url =  URL(string: "https//:a-url.com")!
        let (sut, client) = makeSut()
        // Act
        sut.load { _ in }
        sut.load { _ in }
        // Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    private func makeSut(url: URL = URL(string: "https//:a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithError error: RemoteFeedLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        action()
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        func getUrl(
            url: URL,
            completion: @escaping (HTTPClientResult) -> Void) {
                messages.append((url, completion))
            }
        
        func complete(with error: Error, index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
                messages[index].completion(.success(data , response))
        }
    }
}
