import UIKit

public enum ImageFormat {
    case unknown, png, jpeg
}

open class DataCache {
    static let cacheDirectoryPrefix = "io.stickerface.cache."
    static let ioQueuePrefix = "io.stickerface.queue."
    static let defaultMaxCachePeriodInSecond: TimeInterval = 60 * 60 * 24 * 7         // a week
    
    public static let instance = DataCache(name: "default")
    
    let cachePath: String
    
    let memCache = NSCache<AnyObject, AnyObject>()
    let ioQueue: DispatchQueue
    let fileManager: FileManager
    
    /// Name of cache
    open var name: String = ""
    
    /// Life time of disk cache, in second. Default is a week
    open var maxCachePeriodInSecond = DataCache.defaultMaxCachePeriodInSecond
    
    /// Size is allocated for disk cache, in byte. 0 mean no limit. Default is 0
    open var maxDiskCacheSize: UInt = 0
    
    /// Specify distinc name param, it represents folder name for disk cache
    public init(name: String, path: String? = nil) {
        self.name = name
        
        var cachePath = path ?? NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        cachePath = (cachePath as NSString).appendingPathComponent(DataCache.cacheDirectoryPrefix + name)
        self.cachePath = cachePath
        
        ioQueue = DispatchQueue(label: DataCache.ioQueuePrefix + name)
        
        self.fileManager = FileManager()
        
        #if !os(OSX) && !os(watchOS)
            NotificationCenter.default.addObserver(self, selector: #selector(cleanExpiredDiskCache), name: UIApplication.willTerminateNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(cleanExpiredDiskCache), name: UIApplication.didEnterBackgroundNotification, object: nil)
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Store data

extension DataCache {
    
    /// Write data for key. This is an async operation.
    public func write(data: Data, forKey key: String) {
        memCache.setObject(data as AnyObject, forKey: key as AnyObject)
        writeDataToDisk(data: data, key: key)
    }
    
    private func writeDataToDisk(data: Data, key: String) {
        ioQueue.async {
            if self.fileManager.fileExists(atPath: self.cachePath) == false {
                do {
                    try self.fileManager.createDirectory(atPath: self.cachePath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("DataCache: Error while creating cache folder: \(error.localizedDescription)")
                }
            }
            
            self.fileManager.createFile(atPath: self.cachePath(forKey: key), contents: data, attributes: nil)
        }
    }
    
    /// Read data for key
    public func readData(forKey key:String) -> Data? {
        var data = memCache.object(forKey: key as AnyObject) as? Data
        
        if data == nil {
            if let dataFromDisk = readDataFromDisk(forKey: key) {
                data = dataFromDisk
                memCache.setObject(dataFromDisk as AnyObject, forKey: key as AnyObject)
            }
        }
        
        return data
    }
    
    /// Read data from disk for key
    public func readDataFromDisk(forKey key: String) -> Data? {
        return self.fileManager.contents(atPath: cachePath(forKey: key))
    }
    
    // MARK: - Read & write Codable types
    public func write<T: Encodable>(codable: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(codable)
        write(data: data, forKey: key)
    }
    
    public func readCodable<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = readData(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Read & write primitive types
    
    
    /// Write an object for key. This object must inherit from `NSObject` and implement `NSCoding` protocol. `String`, `Array`, `Dictionary` conform to this method.
    ///
    /// NOTE: Can't write `UIImage` with this method. Please use `writeImage(_:forKey:)` to write an image
    public func write(object: NSCoding, forKey key: String) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: object) else { return }
        write(data: data, forKey: key)
    }
    
    /// Write a string for key
    public func write(string: String, forKey key: String) {
        write(object: string as NSCoding, forKey: key)
    }
    
    /// Write a dictionary for key
    public func write(dictionary: Dictionary<AnyHashable, Any>, forKey key: String) {
        write(object: dictionary as NSCoding, forKey: key)
    }
    
    /// Write an array for key
    public func write(array: Array<Any>, forKey key: String) {
        write(object: array as NSCoding, forKey: key)
    }
    
    /// Read an object for key. This object must inherit from `NSObject` and implement NSCoding protocol. `String`, `Array`, `Dictionary` conform to this method
    public func readObject(forKey key: String) -> NSObject? {
        let data = readData(forKey: key)
        
        if let data = data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSObject
        }
        
        return nil
    }
    
    /// Read a string for key
    public func readString(forKey key: String) -> String? {
        return readObject(forKey: key) as? String
    }
    
    /// Read an array for key
    public func readArray(forKey key: String) -> Array<Any>? {
        return readObject(forKey: key) as? Array<Any>
    }
    
    /// Read a dictionary for key
    public func readDictionary(forKey key: String) -> Dictionary<AnyHashable, Any>? {
        return readObject(forKey: key) as? Dictionary<AnyHashable, Any>
    }
    
    // MARK: - Read & write image
    
    /// Write image for key. Please use this method to write an image instead of `writeObject(_:forKey:)`
    public func write(image: UIImage, forKey key: String, format: ImageFormat? = .png) {
        var data: Data? = nil
        
        if let format = format, format == .png {
            data = image.pngData()
        }
        else {
            data = image.jpegData(compressionQuality: 0.9)
        }
        
        if let data = data {
            write(data: data, forKey: key)
        }
    }
    
    /// Read image for key. Please use this method to write an image instead of `readObject(forKey:)`
    public func readImage(forKey key: String) -> UIImage? {
        let data = readData(forKey: key)
        if let data = data {
            return UIImage(data: data, scale: 1.0)
        }
        
        return nil
    }
    
    @available(*, deprecated, message: "Please use `readImage(forKey:)` instead. This will be removed in the future.")
    public func readImageForKey(key: String) -> UIImage? {
        return readImage(forKey: key)
    }
}

// MARK: - Utils

extension DataCache {
    /// Check if has data for key
    public func hasData(forKey key: String) -> Bool {
        return hasDataOnDisk(forKey: key) || hasDataOnMem(forKey: key)
    }
    
    /// Check if has data on disk
    public func hasDataOnDisk(forKey key: String) -> Bool {
        return self.fileManager.fileExists(atPath: self.cachePath(forKey: key))
    }
    
    /// Check if has data on mem
    public func hasDataOnMem(forKey key: String) -> Bool {
        return (memCache.object(forKey: key as AnyObject) != nil)
    }
}

// MARK: - Clean

extension DataCache {
    
    /// Clean all mem cache and disk cache. This is an async operation.
    public func cleanAll() {
        cleanMemCache()
        cleanDiskCache()
    }
    
    /// Clean cache by key. This is an async operation.
    public func clean(byKey key: String) {
        memCache.removeObject(forKey: key as AnyObject)
        
        ioQueue.async {
            do {
                try self.fileManager.removeItem(atPath: self.cachePath(forKey: key))
            } catch {
                print("DataCache: Error while remove file: \(error.localizedDescription)")
            }
        }
    }
    
    public func cleanMemCache() {
        memCache.removeAllObjects()
    }
    
    public func cleanDiskCache() {
        ioQueue.async {
            do {
                try self.fileManager.removeItem(atPath: self.cachePath)
            } catch {
                print("DataCache: Error when clean disk: \(error.localizedDescription)")
            }
        }
    }
    
    /// Clean expired disk cache. This is an async operation.
    @objc public func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }
    
    // This method is from Kingfisher
    /**
     Clean expired disk cache. This is an async operation.
     
     - parameter completionHandler: Called after the operation completes.
     */
    open func cleanExpiredDiskCache(completion handler: (()->())? = nil) {
        
        // Do things in cocurrent io queue
        ioQueue.async {
            
            var (URLsToDelete, diskCacheSize, cachedFiles) = self.travelCachedFiles(onlyForCacheSize: false)
            
            for fileURL in URLsToDelete {
                do {
                    try self.fileManager.removeItem(at: fileURL)
                } catch {
                    print("DataCache: Error while removing files \(error.localizedDescription)")
                }
            }
            
            if self.maxDiskCacheSize > 0 && diskCacheSize > self.maxDiskCacheSize {
                let targetSize = self.maxDiskCacheSize / 2
                
                // Sort files by last modify date. We want to clean from the oldest files.
                let sortedFiles = cachedFiles.keysSortedByValue {
                    resourceValue1, resourceValue2 -> Bool in
                    
                    if let date1 = resourceValue1.contentAccessDate,
                       let date2 = resourceValue2.contentAccessDate
                    {
                        return date1.compare(date2) == .orderedAscending
                    }
                    
                    // Not valid date information. This should not happen. Just in case.
                    return true
                }
                
                for fileURL in sortedFiles {
                    
                    do {
                        try self.fileManager.removeItem(at: fileURL)
                    } catch {
                        print("DataCache: Error while removing files \(error.localizedDescription)")
                    }
                    
                    URLsToDelete.append(fileURL)
                    
                    if let fileSize = cachedFiles[fileURL]?.totalFileAllocatedSize {
                        diskCacheSize -= UInt(fileSize)
                    }
                    
                    if diskCacheSize < targetSize {
                        break
                    }
                }
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                handler?()
            })
        }
    }
}

// MARK: - Helpers

extension DataCache {
    
    // This method is from Kingfisher
    fileprivate func travelCachedFiles(onlyForCacheSize: Bool) -> (urlsToDelete: [URL], diskCacheSize: UInt, cachedFiles: [URL: URLResourceValues]) {
        
        let diskCacheURL = URL(fileURLWithPath: cachePath)
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let expiredDate: Date? = (maxCachePeriodInSecond < 0) ? nil : Date(timeIntervalSinceNow: -maxCachePeriodInSecond)
        
        var cachedFiles = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskCacheSize: UInt = 0
        
        for fileUrl in (try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? [] {
            
            do {
                let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }
                
                // If this file is expired, add it to URLsToDelete
                if !onlyForCacheSize,
                    let expiredDate = expiredDate,
                    let lastAccessData = resourceValues.contentAccessDate,
                    (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
                {
                    urlsToDelete.append(fileUrl)
                    continue
                }
                
                if let fileSize = resourceValues.totalFileAllocatedSize {
                    diskCacheSize += UInt(fileSize)
                    if !onlyForCacheSize {
                        cachedFiles[fileUrl] = resourceValues
                    }
                }
            } catch {
                print("DataCache: Error while iterating files \(error.localizedDescription)")
            }
        }
        
        return (urlsToDelete, diskCacheSize, cachedFiles)
    }
    
    func cachePath(forKey key: String) -> String {
        let fileName = key.md5
        return (cachePath as NSString).appendingPathComponent(fileName)
    }
}

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        return Array(self).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
    }
}

extension String {
    var md5: String {
        if let data = self.data(using: .utf8, allowLossyConversion: true) {
            
            let message = data.withUnsafeBytes { (bufferPointer) -> [UInt8] in
                return Array(bufferPointer)
            }
            
            let MD5Calculator = MD5(message)
            let MD5Data = MD5Calculator.calculate()
            
            let MD5String = NSMutableString()
            for c in MD5Data {
                MD5String.appendFormat("%02x", c)
            }
            return MD5String as String
            
        } else {
            return self
        }
    }
}


/** array of bytes, little-endian representation */
func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)
    
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { (bytesPointer) -> [UInt8] in
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        for j in 0..<min(MemoryLayout<T>.size, totalBytes) {
            bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
        }
        return bytes
    }
    
    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()
    
    return bytes
}

extension Int {
    /** Array of bytes with optional padding (little-endian) */
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
    
}

extension NSMutableData {
    
    /** Convenient way to append bytes */
    func appendBytes(_ arrayOfBytes: [UInt8]) {
        append(arrayOfBytes, length: arrayOfBytes.count)
    }
    
}

protocol HashProtocol {
    var message: Array<UInt8> { get }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len: Int) -> Array<UInt8>
}

extension HashProtocol {
    
    func prepare(_ len: Int) -> Array<UInt8> {
        var tmpMessage = message
        
        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0
        
        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }
        
        tmpMessage += Array<UInt8>(repeating: 0, count: counter)
        return tmpMessage
    }
}

func toUInt32Array(_ slice: ArraySlice<UInt8>) -> Array<UInt32> {
    var result = Array<UInt32>()
    result.reserveCapacity(16)
    
    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3
        
        result.append(val)
    }
    return result
}

struct BytesIterator: IteratorProtocol {
    
    let chunkSize: Int
    let data: [UInt8]
    
    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }
    
    var offset = 0
    
    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset..<offset + end]
        offset += result.count
        return result.count > 0 ? result : nil
    }
}

struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]
    
    func makeIterator() -> BytesIterator {
        return BytesIterator(chunkSize: chunkSize, data: data)
    }
}

func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFFFFFF) | (value >> (32 - bits))
}

class MD5: HashProtocol {
    
    static let size = 16 // 128 / 8
    let message: [UInt8]
    
    init (_ message: [UInt8]) {
        self.message = message
    }
    
    /** specifies the per-round shift amounts */
    private let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]
    
    /** binary integer part of the sines of integers (Radians) */
    private let sines: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                                   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                                   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                                   0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                                   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                                   0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                                   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                                   0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                                   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                                   0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                                   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                                   0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                                   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                                   0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                                   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                                   0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]
    
    private let hashes: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)
        
        // hash values
        var hh = hashes
        
        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        
        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            let M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")
            
            // Initialize hash value for this chunk:
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]
            
            var dTemp: UInt32 = 0
            
            // Main loop
            for j in 0 ..< sines.count {
                var g = 0
                var F: UInt32 = 0
                
                switch j {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                    break
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                    break
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                    break
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                    break
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ sines[j] &+ M[g]), bits: shifts[j])
                A = dTemp
            }
            
            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)
        
        hh.forEach {
            let itemLE = $0.littleEndian
            result += [UInt8(itemLE & 0xff), UInt8((itemLE >> 8) & 0xff), UInt8((itemLE >> 16) & 0xff), UInt8((itemLE >> 24) & 0xff)]
        }
        return result
    }
}
