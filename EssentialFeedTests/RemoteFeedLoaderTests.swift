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
    
    func test_RemoteFeedLoader_Load_DeliveryErrorOnClientError() {
        // Arrange
        let (sut, client) = makeSut()
        expect(sut,
               toCompleteWith: .failure(.connectivityError),
               when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
            
        })
    }
    
    func test_RemoteFeedLoader_Load_DeliveryErrorOnNon200OnHttpResponse() {
        // Arrange
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        // Act
        samples.enumerated().forEach { index, code in
            expect(sut,
                   toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_RemoteFeedLoader_Load_Delivers200ResponseButWithInvalidJson() {
        let (sut, client) = makeSut()
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_RemoteFeedLoader_Load_Delivers200ResponseWithEmptyJsonList() {
        let (sut, client) = makeSut()
        let emptyListJson = Data("{\"items\": []}".utf8)

        expect(sut,
               toCompleteWith: .success([]),
               when: {
            client.complete(withStatusCode: 200, data: emptyListJson)

        })
    }
    
    func test_RemoteFeedLoader_Load_DeliversItemsOn200HTTPResponseWithJsonItems() {
        let (sut, client) = makeSut()
        let item1 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageUrl: URL(string: "http://a-url.com")!)
        
        let item1Json = [
            "id": item1.id.uuidString,
            "image": item1.imageUrl.absoluteString]
        
        let item2 = FeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageUrl: URL(string: "http://another-url.com")!)
        let item2Json = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageUrl.absoluteString
        ]
        let itemsJson = ["items": [item1Json, item2Json]]
        let jsonData = try! JSONSerialization.data(withJSONObject: itemsJson)
        expect(sut,
               toCompleteWith: .success([item1, item2]),
               when: {
            
            client.complete(withStatusCode: 200, data: jsonData)
        })
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
                        toCompleteWith result: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
