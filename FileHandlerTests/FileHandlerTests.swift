//
//  FileHandlerTests.swift
//  FileHandlerTests
//
//  Created by Hassan Ahmed on 06/09/2017.
//  Copyright © 2017 Hassan Ahmed. All rights reserved.
//

import XCTest
@testable import FileHandler

class FileHandlerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDocumentDirectory() {
        let path = FileHandler.documentPath()
        print("Documents Directory: \(String(describing: path))")
        XCTAssertNotNil(path)
    }
    
    func testDocumentUrl() {
        let url = FileHandler.documentURL()
        print("Documents Directory URL: \(String(describing: url))")
        XCTAssertNotNil(url)
    }
    
    func testDocumentFileUrl() {
        let url = FileHandler.documentURL(fileName: "myfile.txt")
        print("Documents Directory File URL: \(String(describing: url))")
        XCTAssertNotNil(url)
    }
    
    func testTempDirectory() {
        let path = FileHandler.temporaryPath()
        print("Temp Directory: \(String(describing: path))")
        XCTAssertNotNil(path)
    }
    
    func testTemporaryUrl() {
        let url = FileHandler.temporaryURL()
        print("Temp Directory URL: \(String(describing: url))")
        XCTAssertNotNil(url)
    }
    
    func testTemporaryFileUrl() {
        let url = FileHandler.temporaryURL(fileName: "myfile.txt")
        print("Temp Directory File URL: \(String(describing: url))")
        XCTAssertNotNil(url)
    }
    
    func testCreateDirectoryInDocumentsDirectory() {
        let path = FileHandler.documentURL()?.appendingPathComponent("English")
        XCTAssertTrue(FileHandler.createDirectory(atPath: path!.absoluteString))
    }
    
    func testCreateDirectoryInTempDirectory() {
        let path = FileHandler.temporaryURL()?.appendingPathComponent("vdo")
        XCTAssertTrue(FileHandler.createDirectory(atPath: path!.absoluteString))
    }
    
    func testCopyBundleResource() {
        XCTAssertTrue(FileHandler.copyBundleResource(resourceName: "big", ofType: "mp4", toDirectory: FileHandler.temporaryPath() + "vdo"))
    }
    
    func testRemoveItem() {
        let path = FileHandler.temporaryURL(fileName: "nl/en_ah.txt")
        XCTAssertTrue(FileHandler.removeItemAtPath(path!.path))
    }
    
    func testFileExist() {
        XCTAssertTrue(FileHandler.fileExist(at: FileHandler.temporaryURL(fileName: "English")!.path))
    }
    
    func testFileInDirectory() {
        let url = FileHandler.temporaryURL(fileName: "en_ah.txt", inDirectory: "English")
        XCTAssertNotNil(url)
    }
    
    func testWriteFile() {
        if let url = FileHandler.temporaryURL(fileName: "en_abc.txt", inDirectory: "English") {
            let path = url.path
            XCTAssert(FileHandler.writeFile(atPath: path, withContent: "{}"))
        }
        else {
            XCTFail()
        }
    }
    
    func testDocumentsDirectoryContents() {
        let contents = FileHandler.documentsDirectoryContents()
        print("Directory Contents: \(contents)")
        XCTAssertGreaterThan(contents.count, 0)
    }
    
    func testTempDirectoryContents() {
        let contents = FileHandler.tempDirectoryContents()
        print("Directory Contents: \(contents)")
        XCTAssertGreaterThan(contents.count, 0)
    }
    
    func testFileSize() {
        if let url = FileHandler.temporaryURL(fileName: "big.mp4", inDirectory: "vdo") {
            if let size = FileHandler.sizeOfFile(atPath: url.path) {
                XCTAssertGreaterThan(size, 0)
            }
            else {
                XCTFail()
            }
        }
    }    
}
