//
//  THTokenEditViewControllerDemo.h
//  TokenEdit
//
//  Created by Vladislav Kovtash on 12.11.13.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "THTokenEditView.h"

@interface THTokenEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) THTokenEditView *tokenEditView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tokens;
@property (nonatomic, readonly) NSArray *selectedTokens;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredTokens;

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
