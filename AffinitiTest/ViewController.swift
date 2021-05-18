//
//  ViewController.swift
//  AffinitiTest
//
//  Created by Muhammad Nauman on 13/05/2021.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate, HostPresenterDelegate {
    
    @IBOutlet weak var serverBtn: UIButton!
    @IBOutlet weak var clientBtn: UIButton!
    @IBOutlet weak var progress3: UIProgressView!
    @IBOutlet weak var progress2: UIProgressView!
    @IBOutlet weak var progress1: UIProgressView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    let imageURLs = ["https://upload.wikimedia.org/wikipedia/en/7/7a/Scorpions.png",
                     "https://sample-videos.com/img/Sample-png-image-1mb.png",
                     "https://sample-videos.com/img/Sample-png-image-500kb.png"]
    
    
    var hostPresenter: HostPresenter!
    var joinPresenter: JoinPresenter!
    var services: [NetService]?
    var isHost = false
    var isSent = false
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func downloadImages(urlString: String){
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: URL(string: urlString)!)
        downloadTask.resume()
    }
    
    func client(data: Data){
        isHost = false
        self.joinPresenter = JoinPresenter(joinService: JoinService())
        joinPresenter.setDelegate(delegate: self)
        joinPresenter.startBrowsing()
    }

    func testServer() {
        isHost = true
        self.hostPresenter = HostPresenter(hostService: HostService())
        hostPresenter.setDelegate(delegate: self)
        hostPresenter.startBroadcast()
    }
    
    @IBAction func clientServerAction(_ sender: UIButton) {
        if sender.tag == 0{
            serverBtn.isHidden = true
            client(data: imageView1.image!.pngData()!)
        }
        else{
            clientBtn.isHidden = true
            testServer()
        }
        sender.isUserInteractionEnabled = false
    }
    @IBAction func downloadBtnActions(_ sender: UIButton) {
        for url in imageURLs{
            downloadImages(urlString: url)
        }
    }
    //MARK: URLSessionDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                switch downloadTask.currentRequest?.url?.absoluteString{
                case self.imageURLs[0]:
                    self.imageView1.image = image
                case self.imageURLs[1]:
                    self.imageView2.image = image
                case self.imageURLs[2]:
                    self.imageView3.image = image
                default:
                    break
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentDownloaded = Float(totalBytesWritten / totalBytesExpectedToWrite)
        print(percentDownloaded)
        DispatchQueue.main.async {
            switch downloadTask.currentRequest?.url?.absoluteString{
            case self.imageURLs[0]:
                self.progress1.progress = percentDownloaded
            case self.imageURLs[1]:
                self.progress2.progress = percentDownloaded
            case self.imageURLs[2]:
                self.progress3.progress = percentDownloaded
            default:
                break
            }
        }
    }
    
    //MARK: - HostPresenter Delegate
    
    func netService(status: String) {
        print(status)
//        textView.addTextToConsole(text: status)
    }
    
    func socket(status: String, socket: GCDAsyncSocket) {
//        textView.addTextToConsole(text: status)
        if  !isHost && !isSent{//
            isSent = true
            let size = UInt(MemoryLayout<UInt64>.size)
            let data = self.imageView1.image?.pngData()//Data(str.utf8)
            socket.write(data, withTimeout: 30.0, tag: isHost ? 2 : 3)
            socket.readData(toLength: size, withTimeout: 30.0, tag:  isHost ? 2 : 3)
//            self.pushToGameView(objSock: socket)
        }
        if isHost{
            socket.readData(toLength: 907, withTimeout: 30.0, tag:  isHost ? 2 : 3)
        }
    }
    
    func incomingValue(data: Data) {
        count += 1
        print(count)
        if let img = UIImage(data: data){
            if isHost{
                self.imageView1.image = img
            }
        }
        else{
            print(String(data: data, encoding: .utf8))
        }
    }

}

extension ViewController: JoinPresenterDelegate {
    
    func netServiceBrowser(status: String) {
//        textView.addTextToConsole(text: status)
    }
    
//    func socket(status: String, socket: GCDAsyncSocket) {
////        textView.addTextToConsole(text: status)
//        if status.contains(Constants.NETSERVICE.hostSoc) {
////            self.pushToGameView(objSock: socket)
//        }
//    }
    
//    func netService(status: String) {
//        textView.addTextToConsole(text: status)
//    }
    
    func reloadConnections(services: [NetService]) {
        self.services = services
        if let service = services.first{
            self.joinPresenter.serviceSelected(service: service)
        }
//        tableView.reloadData()
    }
    
//    func incomingValue(str: String) {
//        let iVC = self.navigationController?.viewControllers.filter {
//            return $0 is GameVC
//            }.first
//        guard let gameVc = iVC as? GameVC else {
//            return
//        }
//        gameVc.incomingActionWith(str: str)
//    }
    
}

