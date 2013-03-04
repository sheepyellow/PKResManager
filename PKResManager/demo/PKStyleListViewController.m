//
//  PKStyleListViewController.m
//  PKResManager
//
//  Created by zhong sheng on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PKStyleListViewController.h"

@interface PKStyleListViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
- (void)refreshDataSource;
@end

@implementation PKStyleListViewController
@synthesize 
tableView = _tableView,
dataArray = _dataArray;



- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    [self refreshDataSource];
    
    UIButton *addCustomStyleBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 300, 60, 30)];
    addCustomStyleBtn.backgroundColor = [UIColor blueColor];
    [addCustomStyleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addCustomStyleBtn setTitle:@"Add" forState:UIControlStateNormal];
    [addCustomStyleBtn addTarget:self 
                          action:@selector(addCustomStyleAction:) 
                forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addCustomStyleBtn];
    
    
    UIButton *delCustomStyleBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 300, 60, 30)];
    [delCustomStyleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];    
    delCustomStyleBtn.backgroundColor = [UIColor redColor];
    [delCustomStyleBtn setTitle:@"Del" forState:UIControlStateNormal];
    [delCustomStyleBtn addTarget:self 
                          action:@selector(delCustomStyleAction:) 
                forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:delCustomStyleBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
#pragma mark - Private
- (void)refreshDataSource
{
    NSMutableArray *allStyleArray = [PKResManager getInstance].allStyleArray;
    if (!_dataArray)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:allStyleArray.count];
    }
    [_dataArray removeAllObjects];
    // test add undownload style
    for (int i = 0; i < 2; i++) {
        NSDictionary *unknowDict = [NSDictionary dictionaryWithObjects:@[[NSDate date],
                                                                        [NSString stringWithFormat:@"%d",i],
                                                                        [NSString stringWithFormat:@"documents://testSave.bundle%d",i],
                                                                        @"v0.1"]
                                                               forKeys:@[kStyleID,
                                                                        kStyleName,
                                                                        kStyleURL,
                                                                        kStyleVersion]];
        [_dataArray addObject:unknowDict];
    }
    
    [allStyleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *aStyleDict = (NSDictionary*)obj;
        [_dataArray addObject:aStyleDict];
        if (stop) {
            [self.tableView reloadData];
        }
    }];
    
}
- (void)addCustomStyleAction:(id)sender
{
    // test save custom style
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"testSave" ofType:@"bundle"]];
    [[PKResManager getInstance] saveStyle:@"32198139428"
                                     name:CUSTOM_STYLE
                                  version:@1.0f
                               withBundle:bundle];
    [self refreshDataSource];
}
- (void)delCustomStyleAction:(id)sender
{
    [[PKResManager getInstance] deleteStyle:CUSTOM_STYLE];
    [self refreshDataSource];
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
    NSString *identifier = @"styleListId";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    NSDictionary *aStyleDict = (self.dataArray)[indexPath.row];
    NSString *styleName = aStyleDict[kStyleName];
    NSNumber *styleVersion = aStyleDict[kStyleVersion];
    // name
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    cell.textLabel.text = styleName;
    
    // preview
    UIImage *image = [[PKResManager getInstance] previewImageByStyleName:styleName];
    if (image) {
        UIImageView *perviewImageView = [[UIImageView alloc] initWithImage:image];
        perviewImageView.frame = CGRectMake(100.0f, 0.0f, 40, 40);
        [cell addSubview:perviewImageView];
    
    }
    
    // version
    if (styleVersion != nil) {
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, cell.frame.size.height)];
        versionLabel.font = [UIFont systemFontOfSize:13.0f];;
        versionLabel.text = [NSString stringWithFormat:@"v%.1f   ",styleVersion.floatValue];
        versionLabel.textAlignment = UITextAlignmentRight;
        cell.accessoryView = versionLabel;

    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *aStyleDict = (self.dataArray)[indexPath.row];
    NSString *styleName = aStyleDict[kStyleName];
    [[PKResManager getInstance] swithToStyle:styleName onComplete:^(BOOL finished, NSError *error) {
        if (finished) {
            if (error && error.code != PKErrorCodeUnavailable) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[NSString stringWithFormat:@"code:%d",error.code]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

@end
