//
//  XMLRPCParser.swift
//  roTorrent
//
//  Created by Romain Hild on 19/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

public enum XMLRPCType: CustomStringConvertible {
    case xmlrpcInt(Int)
    case xmlrpcBool(Bool)
    case xmlrpcString(String)
    case xmlrpcDouble(Double)
    case xmlrpcDate(Date)
    case xmlrpcData(Data)
    case xmlrpcStruct([String:XMLRPCType])
    case xmlrpcArray([XMLRPCType])
    case xmlrpcNil
    
    public var description: String {
        get {
            switch self {
            case .xmlrpcInt(let int):
                return String(int)
            case .xmlrpcBool(let bool):
                return String(bool)
            case .xmlrpcString(let string):
                return string
            case .xmlrpcDouble(let double):
                return String(double)
            case .xmlrpcDate(let date):
                return String(describing: date)
            case .xmlrpcData(let data):
                return String(data: data, encoding: String.Encoding.utf8)!
            case .xmlrpcStruct(let dict):
                var s = "[\n"
                for (key,value) in dict {
                    s += "\(key) : \(value)\n"
                }
                if let range = s.range(of: ", ") {
                    s.removeSubrange(range)
                }
                s += "]"
                return s
            case .xmlrpcArray(let array):
                var s = "[\n"
                for item in array {
                    s += "\(item)\n"
                }
                if let range = s.range(of: ", ") {
                    s.removeSubrange(range)
                }
                s += "]"
                return s
            case .xmlrpcNil:
                return "nil"
            }
        }
    }
}

class XMLRPCParser : XMLParser, XMLParserDelegate
{
    var result = XMLRPCType.xmlrpcNil
    var tmp = [Any]()
    var type: String = ""
    var scalar: XMLRPCType = .xmlrpcNil
    var isFault: Bool = false
    var hasValue: Bool = false
    
    
    override init(data: Data) {
        super.init(data: data)
        self.delegate = self
        shouldProcessNamespaces = false
        shouldReportNamespacePrefixes = false
        shouldResolveExternalEntities = false
    }
    
    override func parse() -> Bool {
        super.parse()
        return !isFault
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        result = tmp.removeLast() as! XMLRPCType
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        type = elementName
        switch elementName {
        case "params":
            isFault = false
        case "fault":
            isFault = true
        case "struct":
            tmp.append(XMLRPCType.xmlrpcStruct([String:XMLRPCType]()))
        case "array":
            tmp.append(XMLRPCType.xmlrpcArray([XMLRPCType]()))
        case "string","int","i4","i8","boolean","double","dateTime.iso8601","base64":
            hasValue = false
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch type {
        case "string":
            if hasValue {
                switch scalar {
                case .xmlrpcString(var s):
                    s += string
                    scalar = .xmlrpcString(s)
                default:
                    break
                }
            } else {
                scalar = .xmlrpcString(string)
            }
        case "int","i4","i8":
            scalar = .xmlrpcInt(Int(string)!)
        case "boolean":
            scalar = .xmlrpcBool(string=="1")
        case "double":
            scalar = .xmlrpcDouble(Double(string)!)
        case "dateTime.iso8601":
            scalar = XMLRPCType.xmlrpcDate(Date()) // WARNING: Incomplete!!!
        case "base64":
            scalar = .xmlrpcData(Data(base64Encoded: string, options: NSData.Base64DecodingOptions(rawValue: 0))!)
        case "name":
            tmp.append(string)
        default:
            scalar = .xmlrpcNil
            break
        }
        hasValue = true
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "string","int","i4","i8","boolean","double","dateTime.iso8601","base64":
            if !hasValue {
                scalar = .xmlrpcNil
            }
            if tmp.count == 0 { // empty array => scalar only param
                tmp.append(scalar)
            }
            else if let _ = tmp.last as? String { // last item is name => inside a struct/member
                tmp.append(scalar)
            }
            else { // else it is in an array
                let last = tmp.removeLast() as! XMLRPCType
                switch last {
                case .xmlrpcArray(let xmlRpcArray):
                    var newArray = xmlRpcArray
                    newArray.append(scalar)
                    tmp.append(XMLRPCType.xmlrpcArray(newArray))
                default:
                    break
                }
            }
            type = ""
        case "name":
            type = ""
        case "member":
            let value = tmp.removeLast() as! XMLRPCType
            let key = tmp.removeLast() as! String
            let last = tmp.removeLast() as! XMLRPCType
            switch last {
            case .xmlrpcStruct(let xmlRpcStruct):
                var newStruct = xmlRpcStruct
                newStruct.updateValue(value, forKey: key)
                tmp.append(XMLRPCType.xmlrpcStruct(newStruct))
            default:
                break
            }
        case "array","struct":
            if tmp.count == 1 {
                break
            }
            else if let _ = tmp.last as? String {
                break
            }
            else {
                let last = tmp.removeLast() as! XMLRPCType
                let old = tmp.removeLast() as! XMLRPCType
                switch old {
                case .xmlrpcArray(let xmlRpcArray):
                    var newArray = xmlRpcArray
                    newArray.append(last)
                    tmp.append(XMLRPCType.xmlrpcArray(newArray))
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        isFault = true
        print("Error \(parseError.code), Description: \(parser.parserError?.localizedDescription), Line: \(parser.lineNumber), Column: \(parser.columnNumber)")
    }
}
