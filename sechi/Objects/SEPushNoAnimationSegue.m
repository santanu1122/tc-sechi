//
//  SEPushNoAnimationSegue.m
//  sechi
//
//  Created by karolszafranski on 08.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEPushNoAnimationSegue.h"

@implementation SEPushNoAnimationSegue

- (void) perform {
    [[self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:NO];
}

@end
