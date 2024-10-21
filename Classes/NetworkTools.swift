//
//  ByteBufferWrapper.swift
//  OsTools
//
//  Created by Oz Shabat on 25/04/2021.
//

import Foundation
import OsTools
import Network
import SystemConfiguration.CaptiveNetwork

public class NetworkTools {
    
    public static func isValidIPv4(_ ip: String) -> Bool {
        var urlComponents = URLComponents()
        urlComponents.host = ip
        if let host = urlComponents.host, let ipAddress = IPv4Address(host) {
            return true
        }
        return false
    }
    
    public static func isValidIPv6(_ ip: String) -> Bool {
        var urlComponents = URLComponents()
        urlComponents.host = ip
        if let host = urlComponents.host, let _ = IPv6Address(host) {
            return true
        }
        return false
    }
    
    public static func ipv6ToMac(ipv6: String) -> String? {
        // Remove any scope identifiers (anything after a % sign)
        let cleanedIPv6 = ipv6.components(separatedBy: "%").first ?? ""
        
        // Strip subnet information if present (anything after a /)
        let subnetStrippedIPv6 = cleanedIPv6.components(separatedBy: "/").first ?? ""
        
        let ipv6Parts = subnetStrippedIPv6.split(separator: ":")
        guard ipv6Parts.count >= 4 else { return nil }
        
        // Typically, the MAC address is derived from the last 64 bits (last 4 parts of the IPv6 address)
        let relevantParts = Array(ipv6Parts.suffix(4))
        var macParts: [String] = []
        
        for part in relevantParts {
            let paddedPart = part.padding(toLength: 4, withPad: "0", startingAt: 0)
            macParts.append(String(paddedPart.prefix(2)))
            macParts.append(String(paddedPart.suffix(2)))
        }
        
        // Modify the first part of the MAC address
        if let firstPart = Int(macParts[0], radix: 16) {
            macParts[0] = String(format: "%02X", firstPart ^ 0x02)
        }

        // Remove unnecessary parts to fit MAC address format
        macParts.removeSubrange(3...4)
        
        // Join to form the final MAC address
        let macAddress = macParts.joined(separator: ":")
        return isMACAddressValid(macAddressString: macAddress) ? macAddress : nil
    }

    
    // Placeholder for MAC address validation function
    func isMACAddressValid(macAddressString: String) -> Bool {
            let regex = "^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$"
        return macAddressString.range(of: regex, options: .regularExpression) != nil
    }
    
    public static func isMACAddressValid(macAddressString: String) -> Bool {
        let macRegEx = "^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$" // Format Only: XX:XX:XX:XX:XX:XX
        do {
            let regex = try NSRegularExpression(pattern: macRegEx)
            let results = regex.firstMatch(in: macAddressString, range: NSRange(macAddressString.startIndex..., in: macAddressString))
            return results != nil
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// Will turn a link to data
    public static func linkToData(link: String,
                                  extraHeaders: [String: String] = [:],
                                  timeoutInterval: TimeInterval = 60, // Default timeout of 60 seconds
                                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: link) else {
            completion(nil, nil, AppError.customError("URL no good!"))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval // Set the timeout interval

        // Add any extra headers to the request
        extraHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Perform the data task
        URLSession(configuration: .default).dataTask(with: request, completionHandler: completion).resume()
    }
    
    /// Will return the WiFi name
    public static func getWiFiSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: AnyObject] {
                    return interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                }
            }
        }
        return nil
    }

}
