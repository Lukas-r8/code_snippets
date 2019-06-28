import Foundation

enum RegexPatterns: String {
    case matchAll = ".*"
    case fiveLettersWord = "\\b[^\\d\\s]{3,5}\\b"
    case fourNumbers = "\\b\\d{4}\\b"
    case email = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    case allDigits = "\\b\\d+\\b"
}

extension String {
    func regex(_ patt: RegexPatterns = .matchAll) -> [String] {
        let regex = try? NSRegularExpression(pattern: patt.rawValue, options: [.caseInsensitive, .useUnicodeWordBoundaries])
        let result = regex?
            .matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            .map { (checkResult) -> String in
                let range = Range(checkResult.range, in: self)!
                
                return String(self[range])
        }
        return result ?? [String]()
    }
    
    mutating func regexReplace(_ patt: RegexPatterns = .matchAll, replace: (String) -> String) {
        var offset = 0
        let regex = try? NSRegularExpression(pattern: patt.rawValue, options: [.caseInsensitive, .useUnicodeWordBoundaries])
        regex?
            .matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            .map({ (checkRes) in
                let offsetRange = NSRange(location: checkRes.range.lowerBound + offset, length: checkRes.range.length)
                let strRange = Range(offsetRange, in: self)!
                let searchTerm = String(self[strRange])
                offset += replace(searchTerm).count - searchTerm.count
                self = self.replacingOccurrences(of: searchTerm, with: replace(searchTerm))
            })
    }
    
    func isValidEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$", options: [.caseInsensitive, .useUnicodeWordBoundaries])
        let result = regex?
            .matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            .map { (checkResult) -> String in
                let range = Range(checkResult.range, in: self)!
                return String(self[range])
        }
        return result?.count != 0
    }
    
}


