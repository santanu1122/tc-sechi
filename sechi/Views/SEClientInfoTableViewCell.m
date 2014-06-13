//
//  SEClientInfoTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEClientInfoTableViewCell.h"

@implementation SEClientInfoTableViewCell

- (CGFloat) cellHeightNeeded; {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect clientLabelHeight = [self.clientLabel.text boundingRectWithSize:CGSizeMake(self.clientLabel.frame.size.width, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName: self.clientLabel.font}
                                                                   context:nil];
    
    return (clientLabelHeight.size.height * 4) + (5*4);
}

@end
