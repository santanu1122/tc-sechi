//
//  SEJobClientInfoTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobClientInfoTableViewCell.h"

@implementation SEJobClientInfoTableViewCell

- (CGFloat) cellHeightNeeded {
    
    CGFloat minimumHeight = 145;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect clientLabelHeight = [self.clientLabel.text boundingRectWithSize:CGSizeMake(self.clientLabel.frame.size.width, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName: self.clientLabel.font}
                                                                   context:nil];
    
    CGRect infoLabelHeight = [self.infoTextView.text boundingRectWithSize:CGSizeMake(self.infoTextView.frame.size.width - self.infoTextView.font.pointSize, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{
                                                                         NSFontAttributeName: [SEConstants textFieldFont],
                                                                         NSParagraphStyleAttributeName: paragraphStyle,
                                                                         }
                                                               context:nil];
    
    CGRect singleLineInfoLabelHeight = [@"a" boundingRectWithSize:CGSizeMake(self.infoTextView.frame.size.width - self.infoTextView.font.pointSize, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{
                                                                         NSFontAttributeName: [SEConstants textFieldFont],
                                                                         NSParagraphStyleAttributeName: paragraphStyle,
                                                                         }
                                                               context:nil];
    
    CGFloat calcHeight = ((clientLabelHeight.size.height + 4) * 3) + 4 + singleLineInfoLabelHeight.size.height + infoLabelHeight.size.height + 9 + 2;
    
    if(calcHeight < minimumHeight) {
        return minimumHeight;
    }
    
    return calcHeight;
}


@end
