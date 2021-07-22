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

extension Array where Element == Data {
    
    /**
     Will return ipv4 or ipv6 addresses from a data object
     */
    public func getIPAddresses() -> [String] {
        return compactMap(addressToString(data:))
    }
    
    func addressToString(data: Data) -> String? {
        return data.withUnsafeBytes {
            let family = $0.baseAddress!.assumingMemoryBound(to: sockaddr_storage.self).pointee.ss_family
            // family determines which address type to cast to (IPv4 vs IPv6)
            if family == numericCast(AF_INET) {
                return String(address: $0.baseAddress!.assumingMemoryBound(to: sockaddr_in.self).pointee.sin_addr)
            } else if family == numericCast(AF_INET6) {
                return String(address: $0.baseAddress!.assumingMemoryBound(to: sockaddr_in6.self).pointee.sin6_addr)
            }
            return nil
        }
    }
    
}
