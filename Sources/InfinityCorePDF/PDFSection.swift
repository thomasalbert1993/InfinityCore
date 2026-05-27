//
//  PDFSection.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 27/05/2026.
//

#if canImport(PDFKit)

import Foundation
import PDFKit

/// A section containing some `PDFBlock` instances.
/// This is the highest layout level (`PDFSection` > `PDFBlock` > `PDFDrawableElement`).
///
/// The `PDFSection` instances are directly given to `PDFRenderer` which will render them,
/// and dispatch their wrapped blocks among pages and columns, before drawing them.
///
/// Their origin is `[0;_]` related to the PDF page (inside margins) and their width is equal to the page width (excluding margins).
///
/// Sections are always drawn one above the other, you can not draw two sections side by side (in a same container).
///
public struct PDFSection {
    
    public enum Position {
        case automatic(topMargin: CGFloat)
        case newPage
    }
    
    /// The section template, used to generate the wrapped `Block` instances.
    public var template: PDFTemplate
    
    /// The number of columns.
    public var columns: Int = 1
    /// The columns spacing.
    public var columnsSpacing: CGFloat = .centimeters(1)
    
    /// The section position.
    public var position: Position = .automatic(topMargin: 0)
}

#endif
