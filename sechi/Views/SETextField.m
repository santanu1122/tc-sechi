//
//  SETextField.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SETextField.h"

@interface SETextField()

@end

@implementation SETextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void) setupView {
    self.borderStyle = UITextBorderStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.font = [SEConstants textFieldFont];
}

@end
