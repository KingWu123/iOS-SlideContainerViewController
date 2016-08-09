//
//  UIViewController+SlideContainerViewController.h
//  SlideContainerViewController
//
//  Created by king.wu on 7/28/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlideContainerViewController;

@interface UIViewController (SlideContainerViewController)

- (SlideContainerViewController *)slideContainerViewController;

- (BOOL)needShowLeftChildVCWhenGestureBegin:(CGPoint)location;
@end
