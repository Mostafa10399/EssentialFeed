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
        let json = makeItemJson([])
        // Act
        samples.enumerated().forEach { index, code in
            expect(sut,
                   toCompleteWith: .failure(.invalidData)) {
                client.complete(
                    withStatusCode: code,
                    data: json,
                    at: index)
            }
        }
    }
    
    func test_RemoteFeedLoader_Load_Delivers200ResponseButWithInvalidJson() {
        let (sut, client) = makeSut()
        expect(sut, toCompleteWith: .failure( .invalidData)) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_RemoteFeedLoader_Load_Delivers200ResponseWithEmptyJsonList() {
        let (sut, client) = makeSut()
        let emptyListJson = makeItemJson([])

        expect(sut,
               toCompleteWith: .success([]),
               when: {
            client.complete(withStatusCode: 200, data: emptyListJson)

        })
    }
    
    func test_RemoteFeedLoader_Load_DoesNotDeliverResultAfterSutDeallocated() {
        // Arrange
        let url = URL(string: "https:\\a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        var capturedResults = [RemoteFeedLoader.Result]()
        // Act
        sut?.load { capturedResults.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJson([]))
        // Assert
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_RemoteFeedLoader_Load_DeliversItemsOn200HTTPResponseWithJsonItems() {
        let (sut, client) = makeSut()
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)

        let items = [item1.model, item2.model]
        expect(sut,
               toCompleteWith: .success(items),
               when: {
            let itemsJson = makeItemJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: itemsJson)
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
    
    private func makeSut(
        url: URL = URL(string: "https//:a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy) {
            let client = HTTPClientSpy()
            let sut = RemoteFeedLoader(url: url, client: client)
            trackForMemoryLeaks(sut)
            trackForMemoryLeaks(client)
            return (sut, client)
        }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith expectedResult: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let expectation = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageUrl: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value{
                acc[e.key] = value
            }
        }
        return (item, json)
    }
    
    private func makeItemJson(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": items])
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
        
        func complete(
            withStatusCode code: Int,
            data: Data ,
            at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
                messages[index].completion(.success(data , response))
        }
    }
}
