//
//  NodeType.swift
//  SwiftSax
//
//  Created by Krukowski, Jan on 2/4/20.
//

import Foundation

public enum NodeType: Int {
    case element = 1
    case attribute = 2
    case text = 3
    case cdataSection = 4
    case entityReference = 5
    case entity = 6
    case pi = 7
    case comment = 8
    case document = 9
    case documentType = 10
    case documentFragment = 11
    case notation = 12
    case htmlDocument = 13
    case dtd = 14
    case elementDeclaration = 15
    case attributeDeclaration = 16
    case entityDeclaration = 17
    case namespace = 18
    case xincludeStart = 19
    case xincludeEnd = 20
}
