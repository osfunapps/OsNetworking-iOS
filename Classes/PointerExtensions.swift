//
//  PointerExtensions.swift
//  GeneralStreamiOS
//
//  Created by Oz Shabat on 12/02/2020.
//  Copyright © 2020 osCast. All rights reserved.
//

import Foundation

extension UnsafeBufferPointer where Element == UInt8 {
    
    /// Reads 4 bytes from the buffer at the specified offset and returns them as a UInt32 (little endian).
    public func readUInt32LE(offset: Int) -> UInt32 {
        guard offset >= 0, offset + 3 < count else {
            fatalError("Buffer access out of bounds")
        }

        let byte0 = UInt32(self[offset])
        let byte1 = UInt32(self[offset + 1]) << 8
        let byte2 = UInt32(self[offset + 2]) << 16
        let byte3 = UInt32(self[offset + 3]) << 24
        return byte0 | byte1 | byte2 | byte3
    }
    
    /// Reads a single byte from the buffer at the specified offset and returns it as a UInt8 (big endian).
    public func readUInt8BE(offset: Int) -> UInt8 {
        guard offset >= 0, offset < count else {
            fatalError("Buffer access out of bounds")
        }

        return self[offset]
    }
    
    /// Reads 2 bytes from the buffer at the specified offset and returns them as a UInt16 (big endian).
    public func readUInt16BE(offset: Int) -> UInt16 {
        guard offset >= 0, offset + 1 < count else {
            fatalError("Buffer access out of bounds")
        }

        let byte0 = UInt16(self[offset]) << 8
        let byte1 = UInt16(self[offset + 1])
        return byte0 | byte1
    }

    
    public func readUInt16LE(from offset: Int) -> UInt16 {
          guard offset >= 0, offset + 1 < count else {
              fatalError("Buffer access out of bounds")
          }

          let lowerByte = UInt16(self[offset])
          let upperByte = UInt16(self[offset + 1]) << 8
          return lowerByte | upperByte
      }
    
    /// Reads 4 bytes from the buffer at the specified offset and returns them as a UInt32 (big endian).
    public func readUInt32BE(offset: Int) -> UInt32 {
        guard offset >= 0, offset + 3 < count else {
            fatalError("Buffer access out of bounds")
        }

        let byte0 = UInt32(self[offset]) << 24
        let byte1 = UInt32(self[offset + 1]) << 16
        let byte2 = UInt32(self[offset + 2]) << 8
        let byte3 = UInt32(self[offset + 3])
        return byte0 | byte1 | byte2 | byte3
    }
    
    /// Reads 8 bytes from the buffer at the specified offset and returns them as a UInt64 (little endian).
    public func readUInt64LE(offset: Int) -> UInt64 {
        guard offset >= 0, offset + 7 < count else {
            fatalError("Buffer access out of bounds")
        }

        let byte0 = UInt64(self[offset])
        let byte1 = UInt64(self[offset + 1]) << 8
        let byte2 = UInt64(self[offset + 2]) << 16
        let byte3 = UInt64(self[offset + 3]) << 24
        let byte4 = UInt64(self[offset + 4]) << 32
        let byte5 = UInt64(self[offset + 5]) << 40
        let byte6 = UInt64(self[offset + 6]) << 48
        let byte7 = UInt64(self[offset + 7]) << 56
        return byte0 | byte1 | byte2 | byte3 | byte4 | byte5 | byte6 | byte7
    }
    
    /// Converts the buffer to a String using UTF-8 encoding.
    public func toUTFString() -> String? {
        if let string = String(bytes: self, encoding: .utf8) {
            return string
        } else {
            print("not a valid UTF-8 sequence")
            return nil
        }
    }
    
    /// Reads the specified number of bytes from the buffer at the given offset and returns them as a UTF-8 String.
    public func readString(offset: Int, dataLength: Int) -> String {
        guard offset >= 0, offset + dataLength <= count else {
            fatalError("Buffer access out of bounds")
        }

        let bytes = UnsafeBufferPointer(start: baseAddress?.advanced(by: offset), count: dataLength)
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }

    
}

extension Int {

    
    /// Will break a number to a single byte and add it to a data object
    public func writeUInt8() -> Data {
        return Data([UInt8(self)])
    }
    
    /// Will break a number to 2 (big endian) bytes and add them to a data object
       public func writeUInt16BE() -> Data {
           let uInt8Value0 = UInt8(self >> 8)
           let uInt8Value1 = UInt8(self & 0x00ff)
           return Data([uInt8Value0, uInt8Value1])
       }
       
    /// Will break a number to 2 (little endian) byte array and add it to a data object
    public func writeUInt16LE() -> Data {
        let byte1 = UInt8(self & 0xff)
        let byte2 = UInt8(self >> 8 & 0xff)
        return Data([byte1, byte2])
    }
    
    /// Will break a number to 4 (big endian) bytes and add it to a data object
      public func writeUInt32BE() -> Data {
          let __data = UInt32(self)
          let byte1 = UInt8(self & 0x000000FF)         // 10
          let byte2 = UInt8((self & 0x0000FF00) >> 8)  // 154
          let byte3 = UInt8((self & 0x00FF0000) >> 16) // 0
          let intt = (__data & (0xFF000000 as UInt32))
          let byte4 = UInt8(intt >> 24) // 0
          return Data([byte4, byte3, byte2, byte1])
      }
    
    /// Will break a number to 4 (little endian) bytes and add them to a data object
    public func writeUInt32LE() -> Data {
        let byte1 = UInt8(self & 0xff)
        let byte2 = UInt8(self >> 8 & 0xff)
        let byte3 = UInt8(self >> 16 & 0xff)
        let byte4 = UInt8(self >> 24 & 0xff)
        return Data([byte1, byte2, byte3, byte4])
    }
    
    
    /// Will break a float to 2 (little endian) bytes and add it to a data object
    public func writeFloat32LE(valToAdd: Float) -> Data {
        return Int(valToAdd.bitPattern).writeUInt32LE()
    }
    
    /// Will break a number to 8 (little endian) bytes and add it to a data object
    public func writeUInt64LE() -> Data {
        let byte1 = UInt8(self & 0xff)
        let byte2 = UInt8(self >> 8 & 0xff)
        let byte3 = UInt8(self >> 16 & 0xff)
        let byte4 = UInt8(self >> 24 & 0xff)
        let byte5 = UInt8(self >> 32 & 0xff)
        let byte6 = UInt8(self >> 40 & 0xff)
        let byte7 = UInt8(self >> 48 & 0xff)
        let byte8 = UInt8(self >> 56 & 0xff)
        return Data([byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8])
    }
    
    /// Will break a number to 8 (big endian) bytes and add it to a data object
    public func writeUInt64BE() -> Data {
        let byte1 = UInt8(self & 0xff)
        let byte2 = UInt8(self >> 8 & 0xff)
        let byte3 = UInt8(self >> 16 & 0xff)
        let byte4 = UInt8(self >> 24 & 0xff)
        let byte5 = UInt8(self >> 32 & 0xff)
        let byte6 = UInt8(self >> 40 & 0xff)
        let byte7 = UInt8(self >> 48 & 0xff)
        let byte8 = UInt8(self >> 56 & 0xff)
        return Data([byte8, byte7, byte6, byte5, byte4, byte3, byte2, byte1])
    }
    
}


extension Array where Element == UInt8  {
    
    // Will break a number to 2 (big endian) bytes and add them to the buffer starting a given offset
    public mutating func writeUInt16BE(number: Int, offset: Int) {
        self[offset] = UInt8(number >> 8)
        self[offset+1] = UInt8(number & 0x00ff)
    }
    
    // Will break a number to 2 (little endian) bytes and add them to the buffer starting a given offset
    public mutating func writeUInt16LE(number: Int, offset: Int) {
        self[offset] = UInt8(number & 0xff)
        self[offset + 1] = UInt8(number >> 8 & 0xff)
    }
    
    /// Will break a number to 4 (little endian) bytes and add them to the buffer starting a given offset
    public mutating func writeUInt32LE(number: Int64, offset: Int) {
        self[offset] = UInt8(number & 0xff)
        self[offset + 1] = UInt8(number >> 8 & 0xff)
        self[offset + 2] = UInt8(number >> 16 & 0xff)
        self[offset + 3] = UInt8(number >> 24 & 0xff)
    }
    
    
    /// Will break a number to 8 (little endian) bytes and add them to the buffer starting a given offset
    public mutating func writeUInt64LE(number: Int, offset: Int) {
        self[offset] = UInt8(number & 0xff)
        self[offset + 1] = UInt8(number >> 8 & 0xff)
        self[offset + 2] = UInt8(number >> 16 & 0xff)
        self[offset + 3] = UInt8(number >> 24 & 0xff)
        self[offset + 4] = UInt8(number >> 32 & 0xff)
        self[offset + 5] = UInt8(number >> 40 & 0xff)
        self[offset + 6] = UInt8(number >> 48 & 0xff)
        self[offset + 7] = UInt8(number >> 56 & 0xff)
    }
    
    /// Will break a number to 8 (little endian) bytes and add them to the buffer starting a given offset
    public mutating func writeUInt64BE(number: Int, offset: Int) {
        self[offset] = UInt8(number >> 56 & 0xff)
        self[offset + 1] = UInt8(number >> 48 & 0xff)
        self[offset + 2] = UInt8(number >> 40 & 0xff)
        self[offset + 3] = UInt8(number >> 32 & 0xff)
        self[offset + 4] = UInt8(number >> 24 & 0xff)
        self[offset + 5] = UInt8(number >> 16 & 0xff)
        self[offset + 6] = UInt8(number >> 8 & 0xff)
        self[offset + 7] = UInt8(number & 0xff)
    }
}
