//
//  FileHandler.swift
//  agriplace-ios
//
//  Created by Hassan Ahmed on 10/05/2017.
//  Copyright © 2017 Hassan Ahmed. All rights reserved.
//

import Foundation

class FileHandler {

    class func removeItemAtPath(_ path: String) -> Bool {
        let filemanager = FileManager.default
            do {
                try filemanager.removeItem(atPath: path)
                return true
            }
            catch let error {
                print(error.localizedDescription)
        }
        return false
    }
    
    private class func appendPath(_ rootPath: String, pathFile: String) -> String {
        var destinationPath: String
        
        if rootPath.hasSuffix("/") {
            destinationPath = rootPath + "\(pathFile)"
        }
        else {
            destinationPath = rootPath + "/\(pathFile)"
        }
        
        return destinationPath
    }
    
    /**
     Returns path of the documents directory.
     */
    public class func documentPath() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
    }
    
    /**
     Returns URL object of the path to documents directory.
     */
    public class func documentURL() -> URL? {
        var pathURL: URL?
        if let path = documentPath() {
            pathURL = URL(string: path)
        }
        return pathURL
    }
    
    /**
     Returns URL object with file path to documents directory pointing to given file name.
     */
    public class func documentURL(fileName: String) -> URL? {
        var fileDocumentURL: URL?
        
        if let documentPath = documentPath() {
            fileDocumentURL = URL.init(fileURLWithPath: appendPath(documentPath, pathFile: fileName))
        }
        
        return fileDocumentURL
    }
    
    /**
     Returns path of the temp directory.
     */
    public class func temporaryPath() -> String {
        return NSTemporaryDirectory()
    }

    /**
     Returns URL object of the path to temp directory.
     */
    public class func temporaryURL() -> URL? {
        return URL(string: temporaryPath())
    }

    /**
     Returns URL object with file path to temp directory pointing to given file name.
     */
    public class func temporaryURL(fileName: String) -> URL? {
        return URL(fileURLWithPath: self.appendPath(self.temporaryPath(), pathFile: fileName))
    }
    
    public class func temporaryURL(fileName: String, inDirectory:String) -> URL? {
        let dirURL = URL.init(fileURLWithPath: temporaryPath()).appendingPathComponent(inDirectory, isDirectory: true)
        return dirURL.appendingPathComponent(fileName)
    }
    
    public class func fileExist(at path: String) -> Bool {
        let filemanager = FileManager.default
        return filemanager.fileExists(atPath: path)
    }
    
    public class func createDirectory(atPath: String) -> Bool {
        let filemanager = FileManager.default
        var returnValue = false

         let url = URL(fileURLWithPath: atPath)
            do {
                try filemanager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at : \(atPath)")
                returnValue = true
            } catch let error {
                print("Error creating directory at path: \(atPath)")
                print(error.localizedDescription)
            }
        
        return returnValue
    }
    
    private class func copyItem(fileManager: FileManager, at: URL, to: URL) -> Bool {
        var returnValue = false
        do {
            try fileManager.copyItem(at: at, to: to)
            returnValue = true
        }
        catch let error {
            print(error.localizedDescription)
            returnValue = false
        }
        return returnValue
    }
    
    public class func copyBundleResource(resourceName: String, ofType: String, toDirectory atPath: String) -> Bool {
        var returnValue = false
        let filemanager = FileManager.default
        
        let url = URL(fileURLWithPath: atPath)
            let destUrl = url.appendingPathComponent(resourceName + "." + ofType)
        
            if let sourcePath = Bundle.main.path(forResource: resourceName, ofType: ofType) {
                let sourceUrl = URL(fileURLWithPath:sourcePath)
            
                if filemanager.fileExists(atPath: destUrl.path) {
                    if removeItemAtPath(destUrl.path) {
                        returnValue = copyItem(fileManager: filemanager, at: sourceUrl, to: destUrl)
                    }
                    else {
                        print("File already exists. Unable to delete the file.")
                    }
                }
                else {
                    returnValue = copyItem(fileManager: filemanager, at: sourceUrl, to: destUrl)
                }
            }
        
        return returnValue
    }
    
    public class func writeFile(atPath: String, withContent: String) -> Bool {
        var returnValue = false
        
        do {
            try withContent.write(toFile: atPath, atomically: true, encoding: String.Encoding.utf8)
            returnValue = true
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return returnValue
    }
    
    public class func documentsDirectoryContents() -> [String] {
        let filemanager = FileManager.default
        var directoryContents = [String]()
        do {
            let contents = try filemanager.contentsOfDirectory(atPath: documentPath()!)
            directoryContents.append(contentsOf: contents)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return directoryContents
    }
    
    public class func tempDirectoryContents() -> [String] {
        let filemanager = FileManager.default
        var directoryContents = [String]()
        do {
            let contents = try filemanager.contentsOfDirectory(atPath: temporaryPath())
            directoryContents.append(contentsOf: contents)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return directoryContents
    }
}
