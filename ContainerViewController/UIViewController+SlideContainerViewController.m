//
//  UIViewController+SlideContainerViewController.m
//  SlideContainerViewController
//
//  Created by king.wu on 7/28/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import "UIViewController+SlideContainerViewController.h"
#import "SlideContainerViewController.h"

@implementation UIViewController (SlideContainerViewController)

- (SlideContainerViewController *)slideContainerViewController{
    if (self.parentViewController == nil){
        return nil;
    }
    if ([self.parentViewController isKindOfClass:[SlideContainerViewController class]]){
        return (SlideContainerViewController *)self.parentViewController;
    }else{
        return [self.parentViewController slideContainerViewController];
    }
}


- (BOOL)needShowLeftChildVCWhenGestureBegin:(CGPoint)location{
    return YES;
}

@end
