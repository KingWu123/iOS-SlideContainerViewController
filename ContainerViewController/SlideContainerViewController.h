//
//  SlideContainerViewController.h
//  SlideContainerViewController
//
//  Created by king.wu on 7/28/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  实现类似于QQ的  个人账号界面 和 主界面 打开效果的ContianViewController
 */

@interface SlideContainerViewController : UIViewController



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
