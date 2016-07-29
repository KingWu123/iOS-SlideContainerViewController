//
//  ViewController.m
//  ContainerViewController
//
//  Created by king.wu on 7/27/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+SlideContainerViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scorllView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scorllView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    // Do any additional setup after loading the view, typically from a nib.
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


@end
