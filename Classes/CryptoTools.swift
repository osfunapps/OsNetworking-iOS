//
//  Tools.swift
//  AndroidTV
//
//  Created by Oz Shabat on 21/04/2021.
//

import Foundation
import CommonCrypto

public class CryptoTools {
    
    /// Strips leading null bytes from a byte array, returning a new copy.
    public static func removeLeadingNullBytes(inArray: Data) -> Data {
        var offset = 0;
        while offset < inArray.count && Int(inArray[offset]) == 0 {
            offset += 1;
        }
        // crash here, for some reason!
        var result = Data(repeating: 0, count: inArray.count - offset)
        for i in offset...inArray.count-1 {
            result[i - offset] = inArray[i]
        }
        return result
    }
    
    
    public static func doHash256Sha(data : Data...) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        let joinedBytes = data.join()
        joinedBytes.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(joinedBytes.count), &hash)
        }
        return Data(hash)
    }
    
    /// Converts a string of hex characters to a byte array.
    public static func hexStringToBytes(hexstr: String?) -> Result<Data, Error> {
        guard let _hexstr = hexstr, _hexstr.count != 0, _hexstr.count % 2 == 0 else { return .failure(CryptoToolsError(errorDescription: "Code illegal"))}
        
        var result = Data(repeating: 0, count: _hexstr.count / 2);
        for i in 0...result.count-1 {
            let substr = _hexstr.substring(2 * i, 2 * (i + 1))
            guard let asInt = Int(substr, radix: 16) else {return .failure(CryptoToolsError(errorDescription: "Code illegal"))}
            result[i] = UInt8(asInt)
        }
        return .success(result)
    }
    
}

public class CryptoToolsError: LocalizedError {

    public var errorDescription: String?

    init(errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
}
