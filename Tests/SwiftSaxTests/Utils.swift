//
//  Utils.swift
//  swiftsax
//
//  Created by Krukowski, Jan on 1/29/20.
//

import Foundation

extension String {
    var data: Data {
        return data(using: .utf8)!
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
<body>

<h1>My First Heading</h1>

<p>My first paragraph.</p>

© Copyright
α to Ω

</body>
</html>
"""#

let testCollectString = #"""
<div class="offer-item-details">
    <header class="offer-item-header">
        <h3>
            <a href="https://link.com/to/offer" data-tracking="click_body">
                <strong class="visible-xs-block">38 m²</strong>
            </a>
        </h3>
        <p class="text-nowrap"><span class="hidden-xs">Mieszkanie na sprzedaż: </span>Wrocław, Stare Miasto</p>
        <div class="vas-list-no-offer">
            <a class="button-observed observe-link favourites-button observed-text" data-id="666">
                <div class="observed-text-container">
                    <span class="icon observed-60126839"></span>
                    <i class="icon-heart-filled"></i>
                    <div class="observed-label"></div>
                </div>
            </a>
        </div>
    </header>
    <header class="offer-item-header">
        <h3>
            <a href="https://link.com/to/offer2" data-tracking="click_body">
                <strong class="visible-xs-block">38 m²</strong>
            </a>
        </h3>
        <p class="text-nowrap"><span class="hidden-xs">Mieszkanie na sprzedaż: </span>Wrocław, Stare Miasto</p>
        <div class="vas-list-no-offer">
            <a class="button-observed observe-link favourites-button observed-text" data-id="999">
                <div class="observed-text-container">
                    <span class="icon observed-60126839"></span>
                    <i class="icon-heart-filled"></i>
                    <div class="observed-label"></div>
                </div>
            </a>
        </div>
    </header>
</div>
"""#
