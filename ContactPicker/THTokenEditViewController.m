//
//  THTokenEditViewControllerDemo.m
//  TokenEdit
//
//  Created by Vladislav Kovtash on 12.11.13.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "THTokenEditViewController.h"

@interface THTokenEditViewController () <THTokenEditDelegate>

@property (nonatomic, strong) NSMutableArray *privateSelectedTokens;
@property (nonatomic, strong) NSArray *filteredTokens;

@end

@implementation THTokenEditViewController

static const CGFloat kEditViewHeight = 100.0;

NSString *THTokenEditTokenCellReuseID = @"THTokenEditTokenCell";

@synthesize tokenEditView = _tokenEditView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Tokens";
        self.tokens = [NSArray arrayWithObjects:@"Tristan Himmelman",
                         @"John Snow", @"Alex Martin", @"Nicolai Small",@"Thomas Lee", @"Nicholas Hudson", @"Bob Barss",
                         @"Andrew Stall", @"Marc Sarasin", @"Mike Beatson",@"Erica Slon", @"Eric Anderson", @"Josh Salpeter", nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
        
    // Initialize and add Token Edit View
    self.tokenEditView = [[THTokenEditView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kEditViewHeight)];
    self.tokenEditView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.tokenEditView.delegate = self;
    [self.tokenEditView setPlaceholderLabelText:@"Who would you like to message?"];
    [self.tokenEditView setPromptLabelText:@"To:"];
    //[self.tokenEditView setLimitToOne:YES];
    [self.view addSubview:self.tokenEditView];
    
    CALayer *layer = [self.tokenEditView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.tokenEditView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.tokenEditView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.tokenEditView];
}

- (void)viewDidLayoutSubviews {
    [self adjustTableFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)selectedTokens{
    return [self.privateSelectedTokens copy];
}

#pragma mark - Publick properties

- (NSArray *)filteredTokens {
    if (!_filteredTokens) {
        _filteredTokens = _tokens;
    }
    return _filteredTokens;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedTokens.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedTokens {
    if (!_privateSelectedTokens) {
        _privateSelectedTokens = [NSMutableArray array];
    }
    return _privateSelectedTokens;
}

#pragma mark - Private methods

- (void)adjustTableFrame {
    CGFloat yOffset = self.tokenEditView.frame.origin.y + self.tokenEditView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    self.tableView.frame = tableFrame;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.filteredTokens objectAtIndex:indexPath.row];
}

- (void) didChangeSelectedItems {
    
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredTokens.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THTokenEditTokenCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THTokenEditTokenCellReuseID];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([self.privateSelectedTokens containsObject:[self.filteredTokens objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id token = [self.filteredTokens objectAtIndex:indexPath.row];
    NSString *tokenTilte = [self titleForRowAtIndexPath:indexPath];
    
    if ([self.privateSelectedTokens containsObject:token]){ // token is already selected so remove it from TokenEditView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.privateSelectedTokens removeObject:token];
        [self.tokenEditView removeToken:token];
    } else {
        // Token has not been selected, add it to THTokenEditView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.privateSelectedTokens addObject:token];
        [self.tokenEditView addToken:token withName:tokenTilte];
//		
//		UIColor *color = [UIColor blueColor];
//		if (self.privateSelectedTokens.count % 2 == 0){
//			color = [UIColor orangeColor];
//		} else if (self.privateSelectedTokens.count % 3 == 0){
//			color = [UIColor purpleColor];
//		}
//		THTokenViewStyle *style = [[THTokenViewStyle alloc] initWithTextColor:[UIColor whiteColor] backgroundColor:color cornerRadiusFactor:2.0];
//		THTokenViewStyle *selectedStyle = [[THTokenViewStyle alloc] initWithTextColor:[UIColor whiteColor] backgroundColor:[UIColor greenColor] cornerRadiusFactor:2.0];
//		[self.tokenEditView addToken:token withName:tokenTilte withStyle:style andSelectedStyle:selectedStyle];
    }
	
    self.filteredTokens = self.tokens;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THTokenEditTextViewDelegate

- (void)tokenEdit:(THTokenEditView *)tokenEdit textFieldDidChange:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]){
        self.filteredTokens = self.tokens;
    } else {
        NSPredicate *predicate = [self newFilteringPredicateWithText:textField.text];
        self.filteredTokens = [self.tokens filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)tokenEditDidResize:(THTokenEditView *)tokenEditView {
    CGRect frame = self.tableView.frame;
    frame.origin.y = tokenEditView.frame.size.height + tokenEditView.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)tokenEdit:(THTokenEditView *)tokenEdit didRemoveToken:(id)token {
    [self.privateSelectedTokens removeObject:token];
    
    NSInteger index = [self.tokens indexOfObject:token];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (BOOL)tokenEdit:(THTokenEditView *)tokenEdit textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0){
        NSString *token = [[NSString alloc] initWithString:textField.text];
        [self.privateSelectedTokens addObject:token];
        [self.tokenEditView addToken:token withName:textField.text];
    }
    return YES;
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

@end
