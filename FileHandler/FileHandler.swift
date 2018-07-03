//
//  FileHandler.swift
//  agriplace-ios
//
//  Created by Hassan Ahmed on 10/05/2017.
//  Copyright © 2017 Hassan Ahmed. All rights reserved.
//

import Foundation
import AVFoundation

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
    
    public class func sizeOfFile(atPath: String) -> Double? {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: atPath)
        var size: Double?
        
        if let attributes = try? fileManager.attributesOfItem(atPath: url.path) {
            if let fileSize = attributes[FileAttributeKey.size] as? Double {
                size = fileSize
            }
        }
        
        return size
    }
    
    public class func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    public class func compressVideoViaAVAssetWriter(inputURL: URL, outputURL: URL, completion:@escaping (URL)->Void) {
        var assetWriter: AVAssetWriter?
        let bitrate:NSNumber = NSNumber(value:900000)
        
        var audioFinished = false
        var videoFinished = false
        
        let asset = AVAsset(url: inputURL)
        
        guard let assetReader = try? AVAssetReader(asset: asset) else {
            print("Unable to initialize AVAssetReader.")
            return
        }
        
        guard let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else {
            print("Unable to find a video track.")
            return
        }
        
        guard let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first else {
            print("Unable to find an audio track.")
            return
        }
        
        let closeWriter:()->Void = {
            if (audioFinished && videoFinished){
                assetWriter?.finishWriting(completionHandler: {
                    
                    completion((assetWriter?.outputURL)!)
                    
                })
                
                assetReader.cancelReading()
                
            }
        }
        
        let videoReaderSettings: [String:Any] =  [kCVPixelBufferPixelFormatTypeKey as String!:kCVPixelFormatType_32ARGB ]
        
        // ADJUST BIT RATE OF VIDEO HERE
        
        let videoSettings:[String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:bitrate],
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoWidthKey: videoTrack.naturalSize.width
        ]
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        if assetReader.canAdd(assetReaderVideoOutput) {
            assetReader.add(assetReaderVideoOutput)
        }
        else {
            fatalError("Couldn't add video output reader")
        }
        
        if assetReader.canAdd(assetReaderAudioOutput) {
            assetReader.add(assetReaderAudioOutput)
        }
        else {
            fatalError("Couldn't add audio output reader")
        }
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeQuickTimeMovie)
        } catch {
            assetWriter = nil
        }
        
        guard let writer = assetWriter else {
            fatalError("assetWriter was nil")
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        writer.startWriting()
        assetReader.startReading()
        writer.startSession(atSourceTime: kCMTimeZero)

        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while(audioInput.isReadyForMoreMediaData){
                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                if (sample != nil){
                    audioInput.append(sample!)
                }else{
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            //request data here
            
            while(videoInput.isReadyForMoreMediaData){
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil){
                    videoInput.append(sample!)
                }else{
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
}
