//
//  SEJobPhotosTableViewCell.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEJobPhotosTableViewCell.h"
#import "SEJobPhotoInfo.h"

@implementation SEJobPhotosTableViewCell

/**
 *  Setup collection view delegate and attribute
 */
- (void)awakeFromNib
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

/**
 *  Returns number of items to display in collection view, plus one because of "add" button cell
 *
 *  @param collectionView
 *  @param section
 *
 *  @return number of items to display in collection view
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasource.count + 1;
}


/**
 *  Prepare UICollectionViewCell to show. Collection view has only one image, add button or photo that is linked to the schedule.
 *
 *  @param collectionView collection view for which it's needed
 *  @param indexPath      index path at which it will be displayed
 *
 *  @return collection view cell object
 */
- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:SEJobPhotoCollectionViewCellIdentifier
                                                                           forIndexPath:indexPath];
    if(indexPath.row == 0) {
        UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_add_photo"]];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.backgroundView = backgroundImageView;
    } else {
        SEJobPhotoInfo* photoInfo = [self.datasource objectAtIndex:indexPath.row-1];
        UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:photoInfo.filePath]];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.backgroundView = backgroundImageView;
    }
    
    return cell;
}

/**
 *  If there's nothing set in datasource, returns empty array
 *
 *  @return datasource for colletion view in cell
 */
- (NSArray*) datasource {
    if(!_datasource){
        _datasource = @[];
    }
    return _datasource;
}

@end
