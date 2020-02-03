//
//  Utils.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/29/20.
//

import Foundation

extension String {
    var data: Data {
        data(using: .utf8)!
    }
}

let testOpenHtmlElementsString = #"""
<div><div><div>
"""#

let testClosedHtmlElementsString = #"""
<div><div><div></div></div></div>
"""#

let testHtmlElementsWithTextString = #"""
<div>here<div>is<div>some</div></div></div>
"""#

let testHtmlString = #"""
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body><h1>Heading</h1><p>Paragraph</p></body>
</html>
"""#
