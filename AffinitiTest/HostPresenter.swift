//
//  HostPresenter.swift
//  AffinitiTest
//
//  Created by Muhammad Nauman on 18/05/2021.
//

import UIKit

protocol HostPresenterDelegate: NSObjectProtocol {
    func netService(status: String)
    func socket(status: String, socket: GCDAsyncSocket)
    func incomingValue(data: Data)
}

class HostPresenter: NSObject {

    private var hostService = HostService()
    weak private var delegate: HostPresenterDelegate?
    
    init(hostService: HostService) {
        self.hostService = hostService
    }
    
    func setDelegate(delegate: HostPresenterDelegate) {
        self.delegate = delegate
    }
    
    func startBroadcast() {
        hostService.startBroadcast(netServiceBlock: { (isConnected, netServiceStatus) in
            if isConnected {
                self.delegate?.netService(status: netServiceStatus ?? "NetSrvice Connected.")
            } else {
                self.delegate?.netService(status: netServiceStatus ?? "NetService Failed to connect.")
            }
        }, socketBlock: { (socketStatus, objSocket) in
            self.delegate?.socket(status: socketStatus, socket: objSocket)
        }) { (incomingVal) in
            self.delegate?.incomingValue(data: incomingVal)
        }
    }
    
    func removeSocket() {
        hostService.removeSocket()
    }
}
