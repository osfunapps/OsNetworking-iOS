//
//  ByteBufferWrapper.swift
//  OsTools
//
//  Created by Oz Shabat on 25/04/2021.
//

import Foundation
import OsTools


public protocol NetworkAddress {
    static var family: Int32 { get }
    static var maxStringLength: Int32 { get }
}
extension in_addr: NetworkAddress {
    public static let family = AF_INET
    public static let maxStringLength = INET_ADDRSTRLEN
}
extension in6_addr: NetworkAddress {
    public static let family = AF_INET6
    public static let maxStringLength = INET6_ADDRSTRLEN
}

extension String {
    public init<A: NetworkAddress>(address: A) {
        // allocate a temporary buffer large enough to hold the string
        var buf = ContiguousArray<Int8>(repeating: 0, count: Int(A.maxStringLength))
        self = withUnsafePointer(to: address) { rawAddr in
            buf.withUnsafeMutableBufferPointer {
                String(cString: inet_ntop(A.family, rawAddr, $0.baseAddress, UInt32($0.count)))
            }
        }
    }
}

public extension Array where Element == Data {
    func getIPAddresses(removeScopeIdentifier: Bool = true) -> [String] {
        var ipAddresses: [String] = []
        for data in self {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
                let sockaddrPtr = pointer.baseAddress!.assumingMemoryBound(to: sockaddr.self)
                if getnameinfo(sockaddrPtr, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    var ipAddress = String(cString: hostname)
                    if removeScopeIdentifier, let percentIndex = ipAddress.firstIndex(of: "%") {
                        ipAddress = String(ipAddress[..<percentIndex])
                    }
                    ipAddresses.append(ipAddress)
                }
            }
        }
        return ipAddresses
    }
}
