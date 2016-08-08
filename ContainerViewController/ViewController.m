//
//  ViewController.m
//  ContainerViewController
//
//  Created by king.wu on 7/27/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+SlideContainerViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scorllView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scorllView.contentSize = CGSizeMake(self.view.frame.size.width * 4, self.view.frame.size.height);
    self.scorllView.pagingEnabled = YES;
    self.scorllView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndDecelerating:) name:USER_CENTER_COMING_TO_SHOW_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)viewWillLayoutSubviews
{
    
}
- (IBAction)userCenterPressed:(id)sender {
    [self.slideContainerViewController showLeftViewWithAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"offsetX = %f", scrollView.contentOffset.x);
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // NSLog(@"222222");
}





@end
