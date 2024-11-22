import Foundation


extension AOSUniverse {

public func getGmtDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}


public func getLastModifiedDate(dateString: String) -> Date? {
    print("get last modified date: \(dateString)")
    let dateFormatter = getGmtDateFormatter()
    return dateFormatter.date(from: dateString)!
}


public func getLastModifiedDate(for filePath: String) -> Date? {
    let fileManager = FileManager.default

    do {
        let attributes = try fileManager.attributesOfItem(atPath: filePath)
        if let modificationDate = attributes[.modificationDate] as? Date {
            return modificationDate
        }
    } catch {
        print("Error retrieving file attributes: \(error.localizedDescription)")
    }

    return nil
}


func setLastModifiedDate(for fileURL: URL, to date: Date) {
    let fileManager = FileManager.default
    
    do {
        // Create a dictionary with the modification date attribute
        let attributes: [FileAttributeKey: Any] = [.modificationDate: date]
        
        // Set the attributes for the specified file
        try fileManager.setAttributes(attributes, ofItemAtPath: fileURL.path)
        
    } catch {
        print("Error setting last modified date: \(error.localizedDescription)")
    }
}

}
