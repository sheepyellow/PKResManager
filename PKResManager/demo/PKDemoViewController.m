//
//  PKDemoViewController.m
//  PKResManager
//
//  Created by zhong sheng on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PKDemoViewController.h"
#import "PKStyledViewController.h"
#import "PKStyleListViewController.h"

@interface PKDemoViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation PKDemoViewController
@synthesize 
tableView = _tableView,
dataArray;
- (void)dealloc
{
    [[PKResManager getInstance] removeChangeStyleObject:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[PKResManager getInstance] addChangeStyleObject:self];    
    self.navigationController.navigationBar.tintColor = [UIColor colorForKey:@"DemoModule-navBar"];
    self.navigationItem.title = @"Demo";
    self.dataArray = [[NSMutableArray alloc] initWithObjects:@"Demo",@"List",@"Reset", nil];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count > 0) {
        return self.dataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *demoId = @"demoId";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:demoId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:demoId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.font = [UIFont fontForKey:@"SettingModule-tableCell"];
    cell.textLabel.text = (self.dataArray)[indexPath.row];
    // 
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dataStr = (self.dataArray)[indexPath.row];
    if ([dataStr isEqualToString:@"Demo"]) {        
        PKStyledViewController *viewController = [[PKStyledViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if([dataStr isEqualToString:@"List"]){
        PKStyleListViewController *viewController = [[PKStyleListViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if([dataStr isEqualToString:@"Reset"]){
        [[PKResManager getInstance] resetStyle];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"完成" 
                                                            message:nil 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"确定" 
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark - PKResChangeStyleDelegate
- (void)changeStyle:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIScrollViewIndicatorStyleDefault animated:YES];
    if ([[PKResManager getInstance].styleName isEqualToString:SYSTEM_STYLE_NIGHT]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];        
    }

    self.navigationController.navigationBar.tintColor = [UIColor colorForKey:@"DemoModule-navBar"]; 
    
    [self.tableView reloadData];
}

@end
