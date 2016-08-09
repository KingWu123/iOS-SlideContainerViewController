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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"mainVC  will appear");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"mainVC  did appear");
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"mainVC  will disAppear");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"mainVC  did disAppear");
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
