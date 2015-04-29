//
//  TestStyleListViewController.m
//  PKResManager
//
//  Created by passerbycrk on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestStyleListViewController.h"

@interface TestStyleListViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation TestStyleListViewController

- (void)dealloc {
    [[PKResManager getInstance] removeChangeStyleObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [[PKResManager getInstance] addChangeStyleObserver:self];
}

#pragma mark - Private

- (void)refreshDataSource {
    NSMutableArray *allStyleArray = [PKResManager getInstance].allStyleArray;
    if (!_dataArray)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:allStyleArray.count];
    }
    [_dataArray removeAllObjects];
    // test add unknow style
    for (int i = 0; i < 2; i++) {
        NSDictionary *unknowDict = [NSDictionary dictionaryWithObjects:@[[NSDate date],
                                                                        [NSString stringWithFormat:@"UnknowStyle[%d]",i],
                                                                        [NSString stringWithFormat:@"hehehe://testSave.bundle%d",i],
                                                                        @"v0.1"]
                                                               forKeys:@[kStyleID,
                                                                        kStyleName,
                                                                        kStyleURL,
                                                                        kStyleVersion]];
        [_dataArray addObject:unknowDict];
    }
    
    for (NSDictionary *dict in allStyleArray) {
        [_dataArray addObject:dict];
    }
    [self.tableView reloadData];
}

- (void)addCustomStyleAction:(id)sender {
    // test save custom style
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"testSave" ofType:@"bundle"]];
    [[PKResManager getInstance] saveStyle:@"pk_style_test_custom"
                                     name:SAVED_CUSTOM_STYLE
                                  version:@1.0f
                               withBundle:bundle];
    [self refreshDataSource];
}

- (void)delCustomStyleAction:(id)sender {
    [[PKResManager getInstance] deleteStyle:SAVED_CUSTOM_STYLE];
    [self refreshDataSource];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"StyleListId";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];

    NSDictionary *aStyleDict = self.dataArray[indexPath.row];
    NSString *styleName = aStyleDict[kStyleName];
    NSNumber *styleVersion = aStyleDict[kStyleVersion];
    // name
    cell.textLabel.font = [UIFont pk_fontForKey:@"DemoCellFont"];
    cell.textLabel.text = styleName;
    cell.textLabel.textColor = [UIColor blackColor];
    
    // preview
    UIImage *image = [[PKResManager getInstance] previewImageByStyleName:styleName];
    if (image) {
        UIImageView *perviewImageView = [[UIImageView alloc] initWithImage:image];
        perviewImageView.frame = CGRectMake(tableView.frame.size.width - 100, 0.0f, 40, 40);
        [cell addSubview:perviewImageView];
    }
    
    // version
    if (styleVersion != nil) {
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 44.f)];
        versionLabel.font = [UIFont systemFontOfSize:13.0f];;
        versionLabel.text = [NSString stringWithFormat:@"v%.1f   ",styleVersion.floatValue];
        versionLabel.textColor = [UIColor blackColor];
        versionLabel.textAlignment = NSTextAlignmentRight;
        cell.accessoryView = versionLabel;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *aStyleDict = (self.dataArray)[indexPath.row];
    NSString *styleName = aStyleDict[kStyleName];
    [[PKResManager getInstance] swithToStyle:styleName onComplete:^(BOOL finished, NSError *error) {
        if (finished) {
            if (error && error.code != PKStyleErrorCode_Unavailable) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[NSString stringWithFormat:@"code:%ld",(long)error.code]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

#pragma mark - PKResChangeStyleDelegate

- (void)didChangeStyleWithManager:(PKResManager *)manager
{
    [self.tableView reloadData];
}

@end
