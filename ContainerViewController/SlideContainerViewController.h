//
//  SlideContainerViewController.h
//  SlideContainerViewController
//
//  Created by king.wu on 7/28/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+SlideContainerViewController.h"


/**
 *  一个ContainerViewController,  包含Right/left的两个子ViewController,可以实现其左滑，右滑显示的效果。
 */


@interface SlideContainerViewController : UIViewController


/**
 *  初始化函数
 *
 *  @param rightViewController 滑动右边的VC
 *  @param leftViewController  滑动左边的VC
 *
 *  @return SlideContainerViewController
 */
- (instancetype)initWithRightViewController:(UIViewController *)rightViewController withLeftViewController:(UIViewController *)leftViewController;


/**
 *  显示左边的VC
 *
 *  @param animated 是否有动画
 */
- (void)showLeftViewWithAnimated:(BOOL)animated;


/**
 *  显示右边的VC
 *
 *  @param animated 是否有动画
 */
- (void)showRightViewWithAnimated:(BOOL)animated;
@end
