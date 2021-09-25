//
//  Geolocation.swift
//  FetchMe-Events
//
//  Created by Zakee Tanksley on 9/25/21.
//

import Foundation
import UIKit

extension UIDevice {
    
    /// UNUSED: Gets IP address for searching for recommended events
    /// - Returns: IP address
    func getIP() -> String? {
        
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                //Accesses the instance referenced by this pointer "pointee".
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else {
                    return nil
                }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    guard let ifa_name = interface.ifa_name else {
                        return nil
                    }
                    let name: String = String(cString: ifa_name)
                    
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                    
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
}
