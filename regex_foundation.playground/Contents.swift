import Foundation

extension String {
    enum RegexExpressions: String {
        case email = #"\b[a-z1-9-\._]+@[a-z]+\.\w{1,5}(\.br)?\b"#
        case number = #"\b\d{1,5}\b"#
        case words = #"\b\w{3}\b"#
    }
    
    func matches(regex: RegexExpressions) -> [String] {
        return ranges(regex: regex).map { String(self[$0]) }
    }
    
    func ranges(regex: RegexExpressions) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStart = startIndex
        while let match = range(of: regex.rawValue, options: .regularExpression, range: searchStart ..< endIndex ) {
            ranges.append(match)
            searchStart = match.upperBound
        }
        return ranges
    }
    
    mutating func replace(regex: RegexExpressions, with: (Int, String) -> String ) {
        var lastRange = startIndex ..< endIndex
        var loopCount = 0
        while let r = range(of: regex.rawValue, options: .regularExpression, range: lastRange) {
            let matchStr = String(self[r])
            let replacementString = with(loopCount, matchStr)
            replaceSubrange(r, with: replacementString)
            lastRange = index(r.lowerBound, offsetBy: replacementString.count) ..< endIndex
            loopCount += 1
        }
    }
    
    mutating func replace(regex: RegexExpressions, with: String) {
        replace(regex: regex, with: { _, _ in with})
    }
    
    func contains(regex: RegexExpressions) -> Bool {
        return ranges(regex: regex).count > 0
    }
}
