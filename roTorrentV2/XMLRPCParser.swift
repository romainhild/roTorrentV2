//
//  XMLRPCParser.swift
//  roTorrent
//
//  Created by Romain Hild on 19/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

public enum XMLRPCType: CustomStringConvertible {
    case XMLRPCInt(Int)
    case XMLRPCBool(Bool)
    case XMLRPCString(String)
    case XMLRPCDouble(Double)
    case XMLRPCDate(NSDate)
    case XMLRPCData(NSData)
    case XMLRPCStruct([String:XMLRPCType])
    case XMLRPCArray([XMLRPCType])
    case XMLRPCNil
    
    public var description: String {
        get {
            switch self {
            case .XMLRPCInt(let int):
                return String(int)
            case .XMLRPCBool(let bool):
                return String(bool)
            case .XMLRPCString(let string):
                return string
            case .XMLRPCDouble(let double):
                return String(double)
            case .XMLRPCDate(let date):
                return String(date)
            case .XMLRPCData(let data):
                return String(data: data, encoding: NSUTF8StringEncoding)!
            case .XMLRPCStruct(let dict):
                var s = "[\n"
                for (key,value) in dict {
                    s += "\(key) : \(value)\n"
                }
                if let range = s.rangeOfString(", ") {
                    s.removeRange(range)
                }
                s += "]"
                return s
            case .XMLRPCArray(let array):
                var s = "[\n"
                for item in array {
                    s += "\(item)\n"
                }
                if let range = s.rangeOfString(", ") {
                    s.removeRange(range)
                }
                s += "]"
                return s
            case .XMLRPCNil:
                return "nil"
            }
        }
    }
}

class XMLRPCParser : NSXMLParser, NSXMLParserDelegate
{
    var result = XMLRPCType.XMLRPCNil
    var tmp = [Any]()
    var type: String = ""
    var scalar: XMLRPCType = .XMLRPCNil
    var isFault: Bool = false
    var hasValue: Bool = false
    
    
    override init(data: NSData) {
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
    
    func parserDidStartDocument(parser: NSXMLParser) {
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        result = tmp.removeLast() as! XMLRPCType
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        type = elementName
        switch elementName {
        case "params":
            isFault = false
        case "fault":
            isFault = true
        case "struct":
            tmp.append(XMLRPCType.XMLRPCStruct([String:XMLRPCType]()))
        case "array":
            tmp.append(XMLRPCType.XMLRPCArray([XMLRPCType]()))
        case "string","int","i4","i8","boolean","double","dateTime.iso8601","base64":
            hasValue = false
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        switch type {
        case "string":
            if hasValue {
                switch scalar {
                case .XMLRPCString(var s):
                    s += string
                    scalar = .XMLRPCString(s)
                default:
                    break
                }
            } else {
                scalar = .XMLRPCString(string)
            }
        case "int","i4","i8":
            scalar = .XMLRPCInt(Int(string)!)
        case "boolean":
            scalar = .XMLRPCBool(string=="1")
        case "double":
            scalar = .XMLRPCDouble(Double(string)!)
        case "dateTime.iso8601":
            scalar = XMLRPCType.XMLRPCDate(NSDate()) // WARNING: Incomplete!!!
        case "base64":
            scalar = .XMLRPCData(NSData(base64EncodedString: string, options: NSDataBase64DecodingOptions(rawValue: 0))!)
        case "name":
            tmp.append(string)
        default:
            scalar = .XMLRPCNil
            break
        }
        hasValue = true
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "string","int","i4","i8","boolean","double","dateTime.iso8601","base64":
            if !hasValue {
                scalar = .XMLRPCNil
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
                case .XMLRPCArray(let xmlRpcArray):
                    var newArray = xmlRpcArray
                    newArray.append(scalar)
                    tmp.append(XMLRPCType.XMLRPCArray(newArray))
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
            case .XMLRPCStruct(let xmlRpcStruct):
                var newStruct = xmlRpcStruct
                newStruct.updateValue(value, forKey: key)
                tmp.append(XMLRPCType.XMLRPCStruct(newStruct))
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
                case .XMLRPCArray(let xmlRpcArray):
                    var newArray = xmlRpcArray
                    newArray.append(last)
                    tmp.append(XMLRPCType.XMLRPCArray(newArray))
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        isFault = true
        print("Error \(parseError.code), Description: \(parser.parserError?.localizedDescription), Line: \(parser.lineNumber), Column: \(parser.columnNumber)")
    }
}