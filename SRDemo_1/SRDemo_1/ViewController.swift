//
//  ViewController.swift
//  SRDemo_1
//
//  Created by yMac on 2019/5/30.
//  Copyright © 2019 cs. All rights reserved.
//

import UIKit
@_exported import ReplayKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let sharePath  = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sss.fx.rtmpdemo")!.path + "/Library/Caches"
    
    lazy var dataSource: [String] = {
        []
    }()
    
    
    var broadcastActivityVC: RPBroadcastActivityViewController?
    var broadcastController: RPBroadcastController?
    
//    var broadcastView: RPSystemBroadcastPickerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 12.0, *) {
//
//            let broadcastView = RPSystemBroadcastPickerView.init(frame: .init(x: 100, y: 200, width: 100, height: 100))
//            // 不指定扩展，可以展示所有可用的扩展列表
//            broadcastView.preferredExtension = "com.cs.ScreenRecordDemo.BroadcastUpload"
//            // 是否显示麦克风按钮，默认true
////            broadcastView.showsMicrophoneButton = false
//            view.addSubview(broadcastView)
//        } else {
//            // Fallback earily version
//
//        }
        
        
        
//        collectionView.cm_register(cell: VideoCollectionViewCell.self)
        flowLayout.itemSize = CGSize.init(width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.width/3)
        
        getVideos()
        
        print("===========uploadVideoSuccess.rawValue = \(CFNotificationName.uploadVideoSuccess.rawValue as String)")
        
        let darwinNotificationCenter = DarwinNotificationsManager.sharedInstance()
        darwinNotificationCenter!.register(forNotificationName: CFNotificationName.uploadVideoSuccess.rawValue as String) {
            self.showAlert(message: "alert!")
        }
    }
    
    @objc func uploadVideoSuccess() {
        
        showAlert(message: getFileSize(folderPath: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sss.fx.rtmpdemo")!.path + "/Library/Caches/"))
        getVideos()
    }
    
    func showAlert(message: String!) {
        let alert = UIAlertController.init(title: "file size", message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getVideos() {
        
        let datas = getFileListInFolderWithPath(path: sharePath)
//        print(datas)
//        print("file size = \(getFileSize(folderPath: sharePath))")
        dataSource.removeAll()
        dataSource = datas
//        for fileName in dataSource {
//            do {
//                try FileManager.default.removeItem(atPath: sharePath + "/" + fileName)
//            } catch {
//                print("remove item failed")
//            }
//        }
        
        collectionView.reloadData()
        
    }
    
    
}

// iOS 11
extension ViewController {
    
    @IBAction func ios11BroadcastClick(_ sender: Any) {
        
//        RPBroadcastActivityViewController.load { (broadcardtVC, error) in
//            guard error == nil else {
//                print("error = \(error!.localizedDescription)")
//                return
//            }
//            if let broadcardtVC = broadcardtVC {
//                self.broadcastActivityVC = broadcardtVC
//                broadcardtVC.delegate = self
//                self.present(broadcardtVC, animated: true, completion: nil)
//            }
//        }
        
        RPBroadcastActivityViewController.load(withPreferredExtension: "com.cs.ScreenRecordDemo.BroadcastUI") { (broadcardtVC, error) in

            guard error == nil else {
                print("error = \(error!.localizedDescription)")
                return
            }
            if let broadcardtVC = broadcardtVC {
                self.broadcastActivityVC = broadcardtVC
                broadcardtVC.delegate = self
                self.present(broadcardtVC, animated: true, completion: nil)
            }
        }
        
    }
}

extension ViewController: RPBroadcastActivityViewControllerDelegate, RPBroadcastControllerDelegate {
    
    
    
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        
        print("broadcarstVC finished!")
        DispatchQueue.main.async {
            broadcastActivityViewController.dismiss(animated: true, completion: nil)
        }
        
        guard error == nil else {
            print("Broadcast Activity Controller is not available. Reason: " + (error?.localizedDescription)! )
            return
        }
        
//        self.broadcastController = broadcastController
//        broadcastController?.delegate = self
        broadcastController?.startBroadcast(handler: { (error) in
            if let error = error {
                print("error = \(error.localizedDescription)")
            } else {
                print("开始屏幕录制")
            }
        })
        
        
    }
    
//    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateBroadcast broadcastURL: URL) {
//        print("didUpdateBroadcast")
//    }
//    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateServiceInfo serviceInfo: [String : NSCoding & NSObjectProtocol]) {
//        print("didUpdateServiceInfo")
//    }
//
//    func broadcastController(_ broadcastController: RPBroadcastController, didFinishWithError error: Error?) {
//
//        if let error = error {
//            print("error = \(error.localizedDescription)")
//        } else {
//            print("broadcastController: didFinishWithError")
//        }
//    }
    
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: VideoCollectionViewCell = collectionView.cm_dequeueReusableCell(forIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let videoUrl = URL.init(fileURLWithPath: sharePath + "/\(dataSource[indexPath.row])")
        let player = AVPlayerViewController()
        player.player = AVPlayer.init(url: videoUrl)
        present(player, animated: true, completion: nil)
        
    }
    
}


extension ViewController {
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
