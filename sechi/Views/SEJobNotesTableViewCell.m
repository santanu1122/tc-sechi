//
//  SEJobNotesTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobNotesTableViewCell.h"

@implementation SEJobNotesTableViewCell

- (CGFloat) cellHeightNeeded {
    
    CGFloat minimumHeight = 63.0f;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    
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
    
    CGFloat calcHeight = singleLineInfoLabelHeight.size.height + infoLabelHeight.size.height + 4 + 2;
    
    if(calcHeight < minimumHeight) {
        return minimumHeight;
    }
    
    return calcHeight;
}


@end
