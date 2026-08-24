//
//  verseBundle.swift
//  verse
//
//  Created by ajayprasanth on 20/01/26.
//

import WidgetKit
import SwiftUI

@main
struct verseBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        verse()
        QuoteWidget()
    }
}
