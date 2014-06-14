class SEClientAddressTableViewCell: SESwipeableTableViewCell {

	@IBOutlet var addressLabel: UITextView
	@IBOutlet var mapButton: UIButton

	/**
	 *  Calculates height needed to properly display cell based on current content
	 *
	 *  @return height of the cell
	 */
	- (CGFloat) cellHeightNeeded {
    
	    var minimumHeight: Float = 63.0
	    
	    var paragraphStyle = NSMutableParagraphStyle()
	    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping
	    
	    var infoLabelHeight = self.addressLabel.text.boundingRectWithSize(CGSizeMake(self.addressLabel.frame.size.width - self.addressLabel.font.pointSize, CGFLOAT_MAX)
	                                                                  options: NSStringDrawingUsesLineFragmentOrigin
	                                                               attributes: @{
	                                                                            NSFontAttributeName: [SEConstants textFieldFont],
	                                                                            NSParagraphStyleAttributeName: paragraphStyle,
	                                                                            }
	                                                                  context: nil)
	    
	    var singleLineInfoLabelHeight = "a".boundingRectWithSize(CGSizeMake(self.addressLabel.frame.size.width - self.addressLabel.font.pointSize, CGFLOAT_MAX)
	                                                          options: NSStringDrawingUsesLineFragmentOrigin
	                                                       attributes: @{
	                                                                    NSFontAttributeName: [SEConstants textFieldFont],
	                                                                    NSParagraphStyleAttributeName: paragraphStyle,
	                                                                    }
	                                                          context: nil)
	    
	    var calcHeight: Float = singleLineInfoLabelHeight.size.height + infoLabelHeight.size.height + 14 + 2
	    
	    if calcHeight < minimumHeight {
	        return minimumHeight
	    }
	    
	    return calcHeight
	}

}
