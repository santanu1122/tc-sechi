//
//  SEJobPhotosTableViewCell.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SESwipeableTableViewCell.h"

/**
 *  Custom table view cell for single schedule view screen (photos part specifically)
 */
@interface SEJobPhotosTableViewCell : SESwipeableTableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *datasource;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
