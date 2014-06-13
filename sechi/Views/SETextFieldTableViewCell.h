//
//  SETextFieldTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Custom table view cell used for text input (creating forms based on table views).
 */
@interface SETextFieldTableViewCell : UITableViewCell<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel* fieldNameLabel;
@property (strong, nonatomic) IBOutlet SETextView* valueTextView;

/**
 *  Values needed to automate the process of saving (rewriting) input to the object.
 */
@property (strong, nonatomic) NSString* label;
@property (strong, nonatomic) NSString* value;
@property (strong, nonatomic) NSString* key;

/**
 *  Height that should be returned for displaying cell.
 */
@property (nonatomic) CGFloat height;

/**
 *  Method informs the caller if current value changed in comparsion to the original value.
 *
 *  @return BOOL indicating if was value changed
 */
- (BOOL)changesWereMade;

/**
 *  Returns height of the cell needed to properly display the cell with whole content visible.
 *
 *  @param text text for which the height should be returned
 *
 *  @return height needed to properly display the cell
 */
- (CGFloat) cellHeightForText: (NSString*) text;

@end
