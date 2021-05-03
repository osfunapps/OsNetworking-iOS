//
//  ByteBufferWrapper.swift
//  OsTools
//
//  Created by Oz Shabat on 25/04/2021.
//

import Foundation
import OsTools

/// Just a simple bye buffer. Init to read/write to/from bytes (readUint16, writeUint16 and more...)
public class ByteBufferWrapper {
    
    var _packet: Data!
    private var _totalLength: Int!
    var _offset = 0
    
    public init(packet: Data = Data()) {
        self._packet = packet
        _totalLength = packet.count
        _offset = 0
    }
    
    
    // MARK: - write
    
    public func writeBytes (data: Data) {
        self._add(data: data)
    }
    
    /// will write a string to the packet
    public func writeSGString(data: String) {
        let uInt8Value0 = UInt8(data.count >> 8)
        let uInt8Value1 = UInt8(data.count & 0x00ff)
        let lengthBuffer = Data([uInt8Value0, uInt8Value1])
        
        let buf = Data(data.utf8)
        let addon: Data = Data([0])
        let dataBuffer = buf + addon
        let ans = lengthBuffer + dataBuffer
        self._add(data: ans)
    }
    
    /// will write a single byte to the buffer
    public func writeUInt8(data: UInt8) {
        _add(data:  Data([data]))
    }
    
    /// will write 2 bytes to the packet
    public func writeUInt16BE(data: Int) {
        let uInt8Value0 = UInt8(data >> 8)
        let uInt8Value1 = UInt8(data & 0x00ff)
        _add(data: Data([uInt8Value0, uInt8Value1]))
    }
    
    /// will write 8 bytes to the packet
    public func writeUInt64LE(value: Int) {
        let byte1 = UInt8(value & 0xff)
        let byte2 = UInt8(value >> 8 & 0xff)
        let byte3 = UInt8(value >> 16 & 0xff)
        let byte4 = UInt8(value >> 24 & 0xff)
        let byte5 = UInt8(value >> 32 & 0xff)
        let byte6 = UInt8(value >> 40 & 0xff)
        let byte7 = UInt8(value >> 48 & 0xff)
        let byte8 = UInt8(value >> 56 & 0xff)
        _add(data: Data([byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8]))
    }
    
    /// Will break a number to 8 (little endian) bytes and add them to the buffer starting a given offset
    public func writeUInt64BE(number: Int) {
        let byte1 = UInt8(number & 0xff)
        let byte2 = UInt8(number >> 8 & 0xff)
        let byte3 = UInt8(number >> 16 & 0xff)
        let byte4 = UInt8(number >> 24 & 0xff)
        let byte5 = UInt8(number >> 32 & 0xff)
        let byte6 = UInt8(number >> 40 & 0xff)
        let byte7 = UInt8(number >> 48 & 0xff)
        let byte8 = UInt8(number >> 56 & 0xff)
        _add(data: Data([byte8, byte7, byte6, byte5, byte4, byte3, byte2, byte1]))
    }
    
    
    /// will write 4 bytes to the packet
    public func writeUInt32BE(data: Int) {
        let __data = UInt32(data)
        let byte1 = UInt8(data & 0x000000FF)         // 10
        let byte2 = UInt8((data & 0x0000FF00) >> 8)  // 154
        let byte3 = UInt8((data & 0x00FF0000) >> 16) // 0
        let intt = (__data & (0xFF000000 as UInt32))
        let byte4 = UInt8(intt >> 24) // 0
        _add(data: Data([byte4, byte3, byte2, byte1]))
        //        self._packet = self._packet + bytes
    }
    
    public func writeUInt32LE(value: Int) {
        let byte1 = UInt8(value & 0xff)
        let byte2 = UInt8(value >> 8 & 0xff)
        let byte3 = UInt8(value >> 16 & 0xff)
        let byte4 = UInt8(value >> 24 & 0xff)
        _add(data: Data([byte1, byte2, byte3, byte4]))
    }
    
    public func writeUInt16LE(value: Int) {
        let byte1 = UInt8(value & 0xff)
        let byte2 = UInt8(value >> 8 & 0xff)
        _add(data: Data([byte1, byte2]))
    }
    
    
    public func writeFloat32LE(valToAdd: Float) {
        writeUInt32LE(value: Int(valToAdd.bitPattern))
    }
    
    
    public func writeFloat32BE(valToAdd: Float) {
        writeUInt32BE(data: Int(valToAdd.bitPattern))
    }
    
    // MARK: - read
    
    /// will read a single byte from the buffer
    public func readUInt8() throws -> UInt8 {
        let value = try readPointee(size: 1) as UInt8
        return UInt8(bigEndian: value)
    }
    
    /// Method to get a UInt16 from two bytes in the byte array (little-endian).
    public func readUInt16LE() throws -> UInt16 {
        let value = try readPointee(size: 2) as UInt16
        return UInt16(littleEndian: value)
    }
    
    /// Method to get a UInt16 from two bytes in the byte array (big-endian).
    public func readUInt16BE() throws -> UInt16 {
        let value = try readPointee(size: 2) as UInt16
        return UInt16(bigEndian: value)
    }
    
    /// Method to get a UInt32 from four bytes in the byte array (little-endian).
    public func readUInt32LE() throws -> UInt32 {
        let value = try readPointee(size: 4) as UInt32
        return UInt32(littleEndian: value)
    }
    
    /// Method to get a UInt16 from two bytes in the byte array (big-endian).
    public func readUInt32BE() throws -> UInt32 {
        let value = try readPointee(size: 4) as UInt32
        return UInt32(bigEndian: value)
    }
    
    /// Method to get a UInt64 from four bytes in the byte array (little-endian). (It's basically "readLong")
    public func readUInt64LE() throws -> UInt64 {
        let value = try readPointee(size: 4) as UInt64
        return UInt64(littleEndian: value)
    }
    
    /// Method to get a UInt64 from four bytes in the byte array (big-endian). (It's basically "readLong")
    public func readUInt64BE() throws -> UInt64 {
        let value = try readPointee(size: 4) as UInt64
        return UInt64(bigEndian: value)
    }
    
    /// will read a string from the packet
    public func readSGString() throws -> String  {
        
        let dataLength = try self.readUInt16BE()
        if self._offset > _packet.count || self._offset + Int(dataLength) > self._packet.count {
            throw ByteBufError.bufferUnderflowException
        }
        
        let data = try self._packet.slice(self._offset, self._offset + Int(dataLength));
        self._offset = (self._offset + 1 + Int(dataLength));
        
        guard let str = data.bytes.toUTFString() else {
            throw ByteBufError.stringParseException
        }
        return str
    }
    
    public func readLESGString() throws -> String {
        let dataLength = Int(try self.readUInt16LE())
        let data = try self._packet.slice(self._offset, self._offset + dataLength);
        
        self._offset = self._offset + dataLength;
        return data.bytes.toUTFString()!
    }
    
    
    
    public func readFloat32LE() throws -> Float {
        return Float.init(bitPattern: try readUInt32LE())
    }
    
    public func readFloat32BE() throws -> Float {
        return Float.init(bitPattern: try readUInt32BE())
    }
    
    
    public func readIntLE() throws -> Int {
        return Int(try readUInt32LE())
    }
    
    public func readIntBE() throws -> Int {
        return Int(try readUInt32BE())
    }
    
    
    /// will read bytes from the packet
    public func readBytes(count: Int = 0) throws -> Data {
        var data: Data = Data()
        if count == 0 {
            data = try self._packet.slice(self._offset)
            self._offset = self._totalLength
        } else {
            data = try self._packet.slice(self._offset, self._offset+count)
            self._offset = self._offset+count
        }
        
        return data
    }
    
    private func readPointee<T>(size: Int) throws -> T {
        let bytes = try _packet.slice(self._offset).bytes
        if bytes.count < size {
            throw ByteBufError.bufferUnderflowException
        }
        let pointee = try _packet.slice(self._offset).bytes.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) { $0 }
        }.pointee
        self._offset += size
        return pointee
    }
    
    
    // MARK: - others
    
    private func _add(data: Data) {
        //        JavaTools.javaSystemArraycopy(data, 0, &self._packet, offset, data.count)
        self._packet = self._packet + data
    }
    
    public func toBuffer() -> Data {
        return self._packet
    }
    
    // added:
    public func remaining() -> Int {
        return self._packet.count - _offset
    }
    
    public func clear() {
        self._packet.removeAll()
    }
    
    public func count() -> Int {
        return self._packet.count
    }
    
    // This method transfers bytes from this buffer into the given
    // destination array. Copied from Java's public ByteBuffer get(byte[] dst, int offset, int length)
    public func get(dst: inout Data, offset: Int, length: Int) throws -> ByteBufferWrapper {
        if length > remaining() {
            throw ByteBufError.bufferUnderflowException
        }
        
        let end = offset + length
        for i in offset...end - 1 {
            dst[i] = try readUInt8()
        }
        return self
    }
    /// corresponds to Java's public final int position()
    public func position() -> Int {
        return _offset
    }
    
    /// corresponds to Java's public abstract int arrayOffset()
    public func arrayOffset() -> Int {
        return _offset
    }
    
}

public enum ByteBufError: Error {
    case bufferUnderflowException
    case stringParseException
}
