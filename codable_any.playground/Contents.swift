
indirect enum DataObject: Codable {
    
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: DataObject])
    case array([DataObject])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self){self = .string(value)}
        else if let value = try? container.decode(Int.self){self = .int(value) }
        else if let value = try? container.decode(Double.self){self = .double(value) }
        else if let value = try? container.decode(Bool.self){self = .bool(value) }
        else if let value = try? container.decode([String: DataObject].self){self = .object(value)}
        else if let value = try? container.decode([DataObject].self){self = .array(value)}
        else { throw DecodingError.typeMismatch(Any.self, DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "No typeMatch Found for this object"))}
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        do {
            switch self {
            case .object(let object): try container.encode(object)
            case .string(let str): try container.encode(str)
            case .int(let int): try container.encode(int)
            case .double(let double): try container.encode(double)
            case .array(let array): try container.encode(array)
            case .bool(let bool): try container.encode(bool)
            }
        } catch {
            throw error
        }
    }
}
