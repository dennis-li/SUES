//
//  CoreDataTableViewController.h
//  SUES
//
//  Created by lixu on 16/8/16.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Public.h"

@interface CoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) NSMutableDictionary *dataDictionary;
@property (nonatomic,strong) NSArray *sectionName;
- (void)performFetch;
-(void)createDataSource;
@end
