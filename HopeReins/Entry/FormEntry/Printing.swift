//
//  Printing.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 3/14/24.
//

import SwiftUI

extension DynamicFormView {
    
    func onPrint() {
        let pi = NSPrintInfo.shared
        pi.topMargin = 0.0
        pi.bottomMargin = 0.0
        pi.leftMargin = 0.0
        pi.rightMargin = 0.0
        pi.orientation = .portrait
        pi.horizontalPagination = .fit
        pi.verticalPagination = .automatic
        
        let rootView = Print_Preview(uiManagement: uiManagement)
        let view = NSHostingView(rootView: rootView)
        view.frame.size.width = 650
        view.layoutSubtreeIfNeeded()
        let height = view.intrinsicContentSize.height
        view.frame.size.height = height
        
        let contentRect = NSRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        let newWindow = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        newWindow.contentView = view
        
        let myNSBitMapRep = newWindow.contentView!.bitmapImageRepForCachingDisplay(in: contentRect)!
        newWindow.contentView!.cacheDisplay(in: contentRect, to: myNSBitMapRep)
        
        let myNSImage = NSImage(size: myNSBitMapRep.size)
        myNSImage.addRepresentation(myNSBitMapRep)
        
        let nsImageView = NSImageView(frame: contentRect)
        nsImageView.image = myNSImage
        
        let po = NSPrintOperation(view: nsImageView, printInfo: pi)
        po.printInfo.orientation = .portrait
        po.showsPrintPanel = true
        po.showsProgressPanel = true
        po.printPanel.options.insert(NSPrintPanel.Options.showsPaperSize)
        po.printPanel.options.insert(NSPrintPanel.Options.showsOrientation)
        
        if po.run() {
            print("In Print completion")
        }
    }
    
}
