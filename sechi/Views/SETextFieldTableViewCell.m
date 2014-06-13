//
//  SETextFieldTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SETextFieldTableViewCell.h"

@interface SETextFieldTableViewCell()

@property (strong, nonatomic) NSString* originalValue;

@end

@implementation SETextFieldTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = 63.0f;
        self.valueTextView.delegate = self;
    }
    return self;
}

- (void)awakeFromNib
{
    self.height = 63.0f;
    self.valueTextView.delegate = self;
}

/**
 *  Hide keyboard on return when text view is a first responder
 *
 *  @param textView
 *  @param range
 *  @param text
 *
 *  @return BOOL should change the content of the text view
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

/**
 *  Set the label of the field
 *
 *  @param label string that should be used as a input label
 */
- (void) setLabel:(NSString *)label {
    _label = label;
    self.fieldNameLabel.text = label;
}

/**
 *  Set the value of the text view. It will be used for comparsion in changesWereMade method.
 *
 *  @param value new value of the text view
 */
- (void)setValue:(NSString *)value {
    _value = value;
    self.valueTextView.text = value;
    self.originalValue = _value;
    self.height = [self cellHeightForText:value];
}

- (BOOL)changesWereMade {

    if (self.originalValue == nil || [self.valueTextView.text isEqualToString:self.originalValue]) {
        return NO;
    }
    
    return YES;
}

- (CGFloat) cellHeightForText: (NSString*) text {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect singleLineRect = [@"abc" boundingRectWithSize:CGSizeMake(self.valueTextView.frame.size.width - self.valueTextView.font.pointSize, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{
                                                           NSFontAttributeName: self.valueTextView.font,
                                                           }
                                                 context:nil];
    
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(self.valueTextView.frame.size.width - (self.valueTextView.font.pointSize/2), CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{
                                                   NSFontAttributeName: self.valueTextView.font,
                                                   NSParagraphStyleAttributeName: paragraphStyle,
                                                   }
                                         context:nil];
    
    CGFloat height = textRect.size.height + singleLineRect.size.height + 8.0f;
    CGFloat minHeight = 44;
    return height < minHeight ? minHeight : height;
}

@end
