//
//  TestStyleDemoViewController.m
//  PKResManager
//
//  Created by passerbycrk on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestStyleDemoViewController.h"
#import "TestStyleView.h"

@interface TestStyleDemoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation TestStyleDemoViewController {
    NSTimeInterval _beginChangeStyleTime;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone; // default: UIRectEdgeAll
        self.extendedLayoutIncludesOpaqueBars = YES; // default: NO
        self.automaticallyAdjustsScrollViewInsets = NO; // default: YES
        _beginChangeStyleTime = .0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"all style";
    
    [self addAllStyleView];
    
    [self addProgressView];

    [self addTestBtn];
}

#pragma mark - Private

- (void)addAllStyleView {
    int rowCount = 150;
    
    CGRect frame = CGRectMake(.0f, 10.0f, self.view.bounds.size.width, self.view.bounds.size.height-150.0f);
    CGFloat edge = (frame.size.width - 310.f)/3.f;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, rowCount*60)];
    [self.view addSubview:_scrollView];
    for (int row = 0; row < rowCount; row ++) {
        for (int col = 0; col < 2; col ++) {
            TestStyleView *view = [[TestStyleView alloc] initWithFrame:CGRectMake(edge + col*(155+edge), row*60, 155, 50)];
            [_scrollView addSubview:view];
        }
    }   
}

- (void)addProgressView {
    CGFloat progressY = _scrollView.frame.size.height + 20.f;
    // percent
    if (!_progressLabel) {
        UILabel *progressLabel  = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, progressY, 50, 30)];
        progressLabel.text = @"0.0% ";
        progressLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.view addSubview:progressLabel];
        _progressLabel = progressLabel;
    }
    
    
    // time
    if (!_timeLabel) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0f, progressY, 50, 30)];
        timeLabel.text = @"0.00'";
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.view addSubview:timeLabel];
        _timeLabel = timeLabel;
    }
    
    
    // view
    if (!_progressView) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGRect frame = progressView.frame;
        frame.origin.x = 80.0f;
        frame.origin.y = progressY;
        progressView.frame = frame;
        [progressView setProgress:0.0f];
        [self.view addSubview:progressView];
        _progressView = progressView;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeStyleProgressUpdateNotification:)
                                                 name:PKResManagerChangeStyleProgressUpdateNotification object:nil];
}

- (void)customAction {
    if ([[PKResManager getInstance] containsStyle:SAVED_CUSTOM_STYLE]) {
        [[PKResManager getInstance] swithToStyle:SAVED_CUSTOM_STYLE];
    }
}

- (void)changeAction {
    if ([[PKResManager getInstance].currentStyleName isEqualToString:PK_SYSTEM_STYLE_DEFAULT_NAME]) {
        [[PKResManager getInstance] swithToStyle:SAVED_NIGHT_STYLE];
    } else {
        [[PKResManager getInstance] swithToStyle:PK_SYSTEM_STYLE_DEFAULT_NAME];
    }
}

- (void)resetAction {
    [[PKResManager getInstance] resetStyle];
}

- (void)addTestBtn {
    CGFloat progressY = _scrollView.frame.size.height + 50.f;
    
    UIButton *changeBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, progressY, 80.0f, 30.0f)];
    [changeBtn setTitle:@"change" forState:UIControlStateNormal];
    changeBtn.backgroundColor = [UIColor redColor];
    [changeBtn addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:changeBtn];
    
    
    if ([[PKResManager getInstance] containsStyle:SAVED_CUSTOM_STYLE]) {
        UIButton *savedBtn = [[UIButton alloc] initWithFrame:CGRectMake(120.0f, progressY, 80.0f, 30.0f)];
        [savedBtn setTitle:@"custom" forState:UIControlStateNormal];
        savedBtn.backgroundColor = [UIColor blueColor];
        [savedBtn addTarget:self action:@selector(customAction) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:savedBtn];
    }
    
    UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(220.0f, progressY, 80.0f, 30.0f)];
    [resetBtn setTitle:@"reset" forState:UIControlStateNormal];
    resetBtn.backgroundColor = [UIColor blackColor];
    [resetBtn addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:resetBtn];
}

#pragma mark - PKResManagerChangeStyleProgressUpdateNotification

- (void)changeStyleProgressUpdateNotification:(NSNotification *)notification {
    NSNumber *progressNum = [notification.userInfo objectForKey:PKResManagerChangeStyleProgressUpdateNotificationProgressKey];
    if (progressNum.floatValue > 0) {
        if (_beginChangeStyleTime <= .0f) {
            _beginChangeStyleTime = [[NSDate date] timeIntervalSince1970];
        }
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f%%",progressNum.floatValue*100];
        [self.progressView setProgress:progressNum.floatValue];
        if (progressNum.floatValue >= 1.0f) {
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970] - _beginChangeStyleTime;
            self.timeLabel.text = [NSString stringWithFormat:@"%.2f'",endTime];
            _beginChangeStyleTime = .0f;
        }
    } else {
        _beginChangeStyleTime = .0f;
    }
}

@end