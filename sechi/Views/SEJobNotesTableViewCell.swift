//
//  SEJobNotesTableViewCell.swift
//  sechi
//
//  Created by TCSASSEMBLER on 2014-06-13.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

/**
 *  Custom table view cell for single schedule view screen (notes part specifically)
 */
@objc
class SEJobNotesTableViewCell: SESwipeableTableViewCell {
    
    @IBOutlet var notesLabel: UITextView
    
    /**
     *  Calculates height needed to properly display cell based on current content
     *
     *  @return height of the cell
     */
    func cellHeightNeeded() -> Float {
        var minimumHeight: Float = 63.0
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        
        var infoLabelHeight: Float = 0.0
        if self.notesLabel.text? {
            infoLabelHeight = self.notesLabel.text.bridgeToObjectiveC().boundingRectWithSize(CGSizeMake(self.notesLabel.frame.size.width, CGFLOAT_MAX), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: TextFieldFont, NSParagraphStyleAttributeName: paragraphStyle], context: nil).size.height
        }
        
        var singleLineInfoLabelHeight = "a".bridgeToObjectiveC().boundingRectWithSize(CGSizeMake(self.notesLabel.frame.size.width, CGFLOAT_MAX), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: TextFieldFont, NSParagraphStyleAttributeName: paragraphStyle], context: nil)
        
        var calcHeight: Float = singleLineInfoLabelHeight.size.height + infoLabelHeight + 4 + 2
        
        if calcHeight < minimumHeight {
            return minimumHeight
        }
        
        return calcHeight
    }
    
}
