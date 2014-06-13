//
//  SEJobAddressTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobAddressTableViewCell.h"

@implementation SEJobAddressTableViewCell

- (CGFloat) cellHeightNeeded {
    
    CGFloat minimumHeight = 63.0f;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    

    CGRect infoLabelHeight = [self.addressLabel.text boundingRectWithSize:CGSizeMake(self.addressLabel.frame.size.width - self.addressLabel.font.pointSize, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{
                                                                            NSFontAttributeName: TextFieldFont,
                                                                            NSParagraphStyleAttributeName: paragraphStyle,
                                                                            }
                                                                  context:nil];
    
    CGRect singleLineInfoLabelHeight = [@"a" boundingRectWithSize:CGSizeMake(self.addressLabel.frame.size.width - self.addressLabel.font.pointSize, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{
                                                                    NSFontAttributeName: TextFieldFont,
                                                                    NSParagraphStyleAttributeName: paragraphStyle,
                                                                    }
                                                          context:nil];
    
    CGFloat calcHeight = singleLineInfoLabelHeight.size.height + infoLabelHeight.size.height + 14 + 2;
    
    if(calcHeight < minimumHeight) {
        return minimumHeight;
    }
    
    return calcHeight;
}

@end
