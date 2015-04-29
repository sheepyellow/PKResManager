//
//  ViewController.m
//  PKResManagerDemo
//
//  Created by passerbycrk on 15/4/29.
//  Copyright (c) 2015年 pcrk. All rights reserved.
//

#import "ViewController.h"
#import "TestStyleDemoViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)dealloc {
    [[PKResManager getInstance] removeChangeStyleObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc] initWithObjects:@"Demo",@"List",@"Reset", nil];
    [self.tableView reloadData];
    [[PKResManager getInstance] addChangeStyleObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestDemoId" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont pk_fontForKey:@"DemoCellFont"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dataStr = (self.dataArray)[indexPath.row];
    if ([dataStr isEqualToString:@"Demo"]) {
        TestStyleDemoViewController *viewController = [[TestStyleDemoViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if ([dataStr isEqualToString:@"List"]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"TestStyleListViewControllerID"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([dataStr isEqualToString:@"Reset"]) {
        [[PKResManager getInstance] resetStyle];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Result"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - PKResChangeStyleDelegate

- (void)didChangeStyleWithManager:(PKResManager *)manager
{
    UIColor *navFontColor = nil;
    if ([[PKResManager getInstance].currentStyleName isEqualToString:PK_SYSTEM_STYLE_DEFAULT_NAME]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        navFontColor = [UIColor blackColor];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        navFontColor = [UIColor whiteColor];
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor pk_colorForKey:@"DemoNavColor"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : navFontColor,
                                                                    NSFontAttributeName : [UIFont pk_fontForKey:@"DemoNavFont"]};
    
    [self.tableView reloadData];
}

@end
