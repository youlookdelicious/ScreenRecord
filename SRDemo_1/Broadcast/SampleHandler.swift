//
//  SampleHandler.swift
//  Broadcast
//
//  Created by yMac on 2019/5/30.
//  Copyright © 2019 cs. All rights reserved.
//

import ReplayKit
@_exported import Photos

class SampleHandler: RPBroadcastSampleHandler {

    
    var writer: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    
//    let sharePath  = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sss.fx.rtmpdemo")!.path
    let filePath  = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sss.fx.rtmpdemo")!.path + "/Library/Caches/screenRecord.mp4"
    
    var fileName: String!
    
    var lastSampleBuffer: CMSampleBuffer?
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        print("broadcastStarted")
        initWriter()
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        
        if writer.status != .writing {
            return
        }
        
        videoInput.markAsFinished()
        audioInput.markAsFinished()
        print("writer.status0 = \(writer.status.rawValue)")
        if let lastSampleBuffer = lastSampleBuffer {
            writer.endSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(lastSampleBuffer))
        }
        
        let thread = CMThread.init()
        
        writer.finishWriting { [weak self] in
            
            print("status1 === \(self?.writer.status.rawValue ?? 10086)")
            print("finishWriting handler")
            self?.writer = nil
            let notification = CFNotificationCenterGetDarwinNotifyCenter()
            CFNotificationCenterPostNotification(notification, CFNotificationName.uploadVideoSuccess, nil, nil, true)
//            let _ = thread.sleep(milliseconds: 3000)
//            print("-----------------------")
            thread.interrupt()
        }
        // extension进程和APP进程是相互独立的
        // 点击“停止直播”之后，extension进程会在非常短的时间内结束掉，导致finishWriting可能无法完成最后的写入工作而无法生成一个完整的mp4文件
        // 这里让程序休眠，直到写入完成之后 interrupt 结束休眠，继而结束extension进程
        if !thread.isInterrup {
            let _ = thread.sleep(milliseconds: 3000)
        }
        print("=========================2")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        
        guard let _ = writer else {
            return
        }
        
        if writer.status == .unknown && sampleBufferType == .video {
            writer.startWriting()
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        }
        if writer.status == .failed {
            print("Error occured, status = \(writer.status.rawValue), \(writer.error!.localizedDescription) \(String(describing: writer.error))")
            return
        }
        
        switch sampleBufferType {
            case RPSampleBufferType.video:
                
                if videoInput.isReadyForMoreMediaData {
                    if videoInput.append(sampleBuffer) {
                        print("videoInput append sampleBuffer")
                        lastSampleBuffer = sampleBuffer
                    } else {
                        print("videoInput append sampleBuffer failed")
                    }
                }
                
                break
            case RPSampleBufferType.audioApp:
                // Handle audio sample buffer for app audio
                break
            case RPSampleBufferType.audioMic:
                // Handle audio sample buffer for mic audio
                
                if audioInput.isReadyForMoreMediaData {
                    print("audioInput append sampleBuffer")
                    audioInput.append(sampleBuffer)
                }
                
                break
        @unknown default:
            fatalError()
        }
        
    }
    
    
    
}

extension SampleHandler {
    
    func initWriter() {
        
        if writer == nil {
            do {
//                fileName = timeStamp + ".mp4"
//                let filePath = sharePath + "/Library/Caches/" + fileName!
//                print("init sharePathList = \(getFileListInFolderWithPath(path: sharePath + "/Library"))")
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    print("remove item error = \(error)")
                }
                try writer = AVAssetWriter.init(outputURL: .init(fileURLWithPath: filePath), fileType: .mp4)
            } catch  {
                fatalError("Assetwriter error : \(error)")
            }

//            let videoCompressionProps: [String: Any] = [
//                AVVideoMaxKeyFrameIntervalKey: 8*1024.0*1024,
//                AVVideoAverageBitRateKey: 64000,
//                AVVideoH264EntropyModeKey: AVVideoH264EntropyModeCABAC
//            ]

            // 视频的宽高都必须是16的整数倍,否则经过AVFoundation的API合成后系统会自动对尺寸进行校正，不足的地方会以绿边的形式进行填充。
            let widthRemainder = UIScreen.main.bounds.size.width.truncatingRemainder(dividingBy: 16)
            let heightRemainder = UIScreen.main.bounds.size.height.truncatingRemainder(dividingBy: 16)
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: UIScreen.main.bounds.size.width + widthRemainder,
                AVVideoHeightKey: UIScreen.main.bounds.size.height + heightRemainder
//                AVVideoCompressionPropertiesKey: videoCompressionProps
            ]
            videoInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: videoSettings)
            videoInput.expectsMediaDataInRealTime = true
            if writer.canAdd(videoInput) {
                writer.add(videoInput)
                print("add video input")
            } else {
                print("can not add video input")
            }
            
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 64000
            ]
            audioInput = AVAssetWriterInput.init(mediaType: .audio, outputSettings: audioSettings)
            audioInput.expectsMediaDataInRealTime = true
            if writer.canAdd(audioInput) {
                writer.add(audioInput)
                print("add audio input")
            } else {
                print("can not add audio input")
            }
            
        }
    }
    
}

// MARK: - File
extension SampleHandler {
    //获取文件夹下文件列表
    func getFileListInFolderWithPath(path:String) -> Array<String> {
        let fileManager = FileManager.default
        let fileList = try! fileManager.contentsOfDirectory(atPath: path)
        return fileList
    }
    //获取文件大小
    func getFileSize(folderPath: String)-> String {
        if folderPath.count == 0 {
            return "0MB" as String
        }
        let manager = FileManager.default
        if !manager.fileExists(atPath: folderPath){
            return "0MB" as String
        }
        var fileSize:Float = 0.0
        do {
            let files = try manager.contentsOfDirectory(atPath: folderPath)
            
            for file in files {
                let path = folderPath + file
                fileSize = fileSize + fileSizeAtPath(filePath: path)
            }
        }catch{
            fileSize = fileSize + fileSizeAtPath(filePath: folderPath)
        }
        
        var resultSize = ""
        if fileSize >= 1024.0*1024.0{
            resultSize = NSString(format: "%.2fMB", fileSize/(1024.0 * 1024.0)) as String
        }else if fileSize >= 1024.0{
            resultSize = NSString(format: "%.fkb", fileSize/(1024.0 )) as String
        }else{
            resultSize = NSString(format: "%llub", fileSize) as String
        }
        
        return resultSize
    }
    /**  计算单个文件或文件夹的大小 */
    func fileSizeAtPath(filePath:String) -> Float {
        
        let manager = FileManager.default
        var fileSize:Float = 0.0
        if manager.fileExists(atPath: filePath) {
            do {
                let attributes = try manager.attributesOfItem(atPath: filePath)
                if attributes.count != 0 {
                    fileSize = attributes[FileAttributeKey.size]! as! Float
                }
            }catch{
            }
        }
        return fileSize;
    }
}

// MARK: - TimeStamp
extension SampleHandler {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}
