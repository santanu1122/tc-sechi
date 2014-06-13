//
//  SEPaymentInfoTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEPaymentInfoTableViewCell.h"

@implementation SEPaymentInfoTableViewCell

- (CGFloat) cellHeightNeeded {
    
    CGFloat minimumHeight = 145;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect clientLabelHeight = [self.clientLabel.text boundingRectWithSize:CGSizeMake(self.clientLabel.frame.size.width, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName: self.clientLabel.font}
                                                                   context:nil];
    
    CGRect infoLabelHeight = [self.notesLabel.text boundingRectWithSize:CGSizeMake(self.notesLabel.frame.size.width - self.notesLabel.font.pointSize, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{
                                                                            NSFontAttributeName: [SEConstants textFieldFont],
                                                                            NSParagraphStyleAttributeName: paragraphStyle,
                                                                            }
                                                                  context:nil];
    
    CGRect singleLineInfoLabelHeight = [@"a" boundingRectWithSize:CGSizeMake(self.notesLabel.frame.size.width - self.notesLabel.font.pointSize, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{
                                                                    NSFontAttributeName: [SEConstants textFieldFont],
                                                                    NSParagraphStyleAttributeName: paragraphStyle,
                                                                    }
                                                          context:nil];
    
    CGFloat calcHeight = ((clientLabelHeight.size.height + 4) * 4) + 4 + singleLineInfoLabelHeight.size.height + infoLabelHeight.size.height + 9 + 2 + 70;
    
    if(calcHeight < minimumHeight) {
        return minimumHeight;
    }
    
    return calcHeight;
}

@end
