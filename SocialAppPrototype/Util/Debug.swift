import Foundation

func debugLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    NSLog("%@", "[\((filename as NSString).lastPathComponent) \(function) line:\(line)] \(message)")
}