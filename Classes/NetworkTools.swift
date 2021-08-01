//
//  ByteBufferWrapper.swift
//  OsTools
//
//  Created by Oz Shabat on 25/04/2021.
//

import Foundation
import OsTools

public class NetworkTools {
    
    /// Will turn an ipv6 address to a mac address
    public static func ipv6ToMac(ipv6: String) -> String? {
        var ipv6Copy = ipv6
        if let subnetIndex = ipv6.firstIndexOf(string: "/") {
            ipv6Copy = ipv6.substring(0, subnetIndex)
        }
        
        let ipv6Parts = ipv6Copy.split(separator: ":")
        var macParts = [String]()
        
        let startRunning = ipv6Parts.count - 4
        let endRunning = ipv6Parts.count - 1
        
        if startRunning <= 0 || endRunning <= 0 || startRunning > endRunning {
            return nil
        }
        
        for ipv6PartIdx in startRunning...endRunning {
            var ipv6Part = ipv6Parts[ipv6PartIdx]
            while ipv6Part.count < 4 {
                ipv6Part = "0" + ipv6Part
            }
            
            let str = String(ipv6Part).substring(0, 2)
            
            let totalIPv6PartSize = ipv6Part.count
            let startIPv6Part = totalIPv6PartSize - 2
            if totalIPv6PartSize >= startIPv6Part {
                let m = String(ipv6Part).substring(startIPv6Part, totalIPv6PartSize)
                macParts.append(str)
                macParts.append(m)
            }
        }
        //  modify parts to match MAC value
        if macParts.isEmpty {
            return nil
        }
        guard let ans = Int(macParts[0], radix: 16) else {return nil}
        let ans2 = ans ^ 2
        macParts[0] = String(format:"%02X", ans2)
        if macParts.count > 4 {
            macParts.remove(at: 4)
        }
        if macParts.count > 3 {
            macParts.remove(at: 3)
        }
        let macAddrStr = macParts.joined(separator: ":")
        if isMACAddressValid(macAddressString: macAddrStr) {
            return macAddrStr
        } else {
            return nil
        }
    }
    
    public static func isMACAddressValid(macAddressString: String) -> Bool {
        var returnValue = true
        let macRegEx = "^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$" // Format Only: XX:XX:XX:XX:XX:XX
        //let macRegEx = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$" // Format: XX:XX:XX:XX:XX:XX and XX-XX-XX-XX-XX-XX
        do {
            let regex = try NSRegularExpression(pattern: macRegEx)
            let nsString = macAddressString as NSString
            let results = regex.matches(in: macAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    
    /// Will turn a link to data
    public static func linkToData(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let req = URL(string: url)
        let request =  URLRequest.init(url: req!)
        URLSession(configuration: .default).dataTask(with: request, completionHandler: completion).resume()
    }
}
