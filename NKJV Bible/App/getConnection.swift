//
//  getConnection.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 25/09/23.
//

import UIKit
import SystemConfiguration
import CoreTelephony
import Foundation
import Network



class getConnection: NSObject {
    
     static let shared = getConnection()

    private let pathMonitor = NWPathMonitor()
    private let pathLock = NSLock()
    private var didStartPathMonitor = false
    private var lowDataMode = false

    /// Offline, or 2G / Low Data Mode. Nil when the connection is fine to continue.
    func networkBlockMessage() -> String? {
        let type = getConnectionType()
        if type == "NO INTERNET" || !NetworkManager.sharedInstance.isConnectedToInternet() {
            return "No internet connection."
        }
        if type == "2G" || isLowDataMode() {
            return "Check your internet connection."
        }
        return nil
    }

    private func isLowDataMode() -> Bool {
        startPathMonitorIfNeeded()
        pathLock.lock()
        defer { pathLock.unlock() }
        return lowDataMode
    }

    private func startPathMonitorIfNeeded() {
        guard !didStartPathMonitor else { return }
        didStartPathMonitor = true
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.pathLock.lock()
            self.lowDataMode = path.isConstrained
            self.pathLock.unlock()
        }
        pathMonitor.start(queue: DispatchQueue.global(qos: .utility))
        pathLock.lock()
        lowDataMode = pathMonitor.currentPath.isConstrained
        pathLock.unlock()
    }

    func getConnectionType() -> String {
            guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
                return "NO INTERNET"
            }

            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(reachability, &flags)

            let isReachable = flags.contains(.reachable)
            let isWWAN = flags.contains(.isWWAN)

            if isReachable {
                if isWWAN {
                    let networkInfo = CTTelephonyNetworkInfo()
                    let carrierType = networkInfo.serviceCurrentRadioAccessTechnology

                    guard let carrierTypeName = carrierType?.first?.value else {
                        return "UNKNOWN"
                    }

                    switch carrierTypeName {
                    case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                        return "2G"
                    case CTRadioAccessTechnologyLTE:
                        return "4G"
                    default:
                        return "3G"
                    }
                } else {
                    return "WIFI"
                }
            } else {
                return "NO INTERNET"
            }
        }
    
}



