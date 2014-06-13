//
//  SEPartsViewController.h
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEViewController.h"
#import "SEProductsScannerViewController.h"

/**
 *  View controller used for displaying list of part objects (products).
 */
@interface SEPartsViewController : SEViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIAlertViewDelegate,UISearchBarDelegate,SEProductsScannerViewControllerDelegate>

@end
