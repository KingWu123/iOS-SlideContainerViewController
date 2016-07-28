//
//  SlideContainerViewController.m
//  SlideContainerViewController
//
//  Created by king.wu on 7/28/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import "SlideContainerViewController.h"

/**
 *  实现类似于QQ的  个人账号界面 和 主界面 打开效果的ContianViewController
 */

#define CONTAIN_VIEW_AIMATION_TIME  0.3
@interface SlideContainerViewController ()


typedef NS_ENUM(NSInteger, SHOW_SUBVC_DIRECTION) {
    FROM_LEFT_TO_RIGHT,
    FROM_RIGHT_TO_LEFT,
};

typedef NS_ENUM(NSInteger, PanGestureMoveType) {
    PanGestureMoveLeft = 0,
    PanGestureMoveRight,
};


@property (nonatomic, strong)UIViewController *rightViewController;
@property (nonatomic, strong)UIViewController *leftViewController;

@property (nonatomic, weak)UIViewController *visibleViewController;


@property (nonatomic, strong)UIImageView *rightVCSnapShotImageView;
@property (nonatomic, strong)UIImageView *leftVCSnapShotImageView;

@property (nonatomic, assign)CGPoint panGesturePreOffset;
@property (nonatomic, assign)PanGestureMoveType panGestureLastMoveType;

@end

@implementation SlideContainerViewController



- (instancetype)initWithRightViewController:(UIViewController *)rightViewController withLeftViewController:(UIViewController *)leftViewController{
 
    self = [super init];
    if (self){
        self.rightViewController = rightViewController;
        self.leftViewController = leftViewController;
        
        [self displayContentController:rightViewController];
        self.visibleViewController = rightViewController;
        
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        [self.view addGestureRecognizer:panGesture];
        
         self.leftVCSnapShotImageView = [[UIImageView alloc]init];
         self.rightVCSnapShotImageView = [[UIImageView alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - show

/**
 *  显示左边的child VC
 *
 *  @param animated 是否有动画
 */
- (void)showLeftViewWithAnimated:(BOOL)animated{
    
    if (self.visibleViewController == self.leftViewController){
        return;
    }
    
    if (animated){
        [self transitionFromViewController:self.rightViewController toViewController:self.leftViewController direction:FROM_LEFT_TO_RIGHT toVCBeginFrame:[self newViewStartFrame:FROM_LEFT_TO_RIGHT]];
    }else{
        [self fromViewController:self.rightViewController toViewController:self.leftViewController];
    }
    self.visibleViewController = self.leftViewController;
}



/**
 *  显示右边的child VC
 *
 *  @param animated 是否有动画
 */
- (void)showRightViewWithAnimated:(BOOL)animated{
    if (self.visibleViewController == self.rightViewController){
        return;
    }
    
    if (animated){
        [self transitionFromViewController:self.leftViewController toViewController:self.rightViewController direction:FROM_RIGHT_TO_LEFT toVCBeginFrame:[self newViewStartFrame:FROM_RIGHT_TO_LEFT]];
    }else{
        [self fromViewController:self.leftViewController toViewController:self.rightViewController];
    }
    
    self.visibleViewController = self.rightViewController;
}



/**
 *  左右两个child VC的带动画的切换过程
 *
 *  @param oldVC           老的child vc
 *  @param newVC           新的要显示的child vc
 *  @param direction       出现的方向
 *  @param toVCBeginFrame  newVC开始是的frame
 */
- (void)transitionFromViewController: (UIViewController*) oldVC
                    toViewController: (UIViewController*) newVC  direction:(SHOW_SUBVC_DIRECTION)direction toVCBeginFrame:(CGRect)toVCBeginFrame{
    // Prepare the two view controllers for the change.
    [oldVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    
    // Get the start frame of the new view controller and the end frame
    // for the old view controller. Both rectangles are offscreen.
    newVC.view.frame = toVCBeginFrame;
    CGRect endFrame = [self oldViewEndFrame:direction];
    
    [oldVC beginAppearanceTransition: NO animated: YES];
    [newVC beginAppearanceTransition: YES animated: YES];
    [self.view addSubview:newVC.view];
    
    [UIView animateWithDuration:CONTAIN_VIEW_AIMATION_TIME delay:0.0 options:(7 << 16) animations:^{
        newVC.view.frame = self.view.bounds;
        oldVC.view.frame = endFrame;
        
        if (direction == FROM_RIGHT_TO_LEFT){
            [self.view bringSubviewToFront:oldVC.view];
        }

        
    } completion:^(BOOL finished) {
        
        [oldVC.view removeFromSuperview];
        
        [oldVC endAppearanceTransition];
        [newVC endAppearanceTransition];
        
        [oldVC removeFromParentViewController];
        [newVC didMoveToParentViewController:self];
    }];
    
    
    /*下面的newVC的viewDidAppear 和  oldVC viewDidDisappear 调用时序反了
    // Queue up the transition animation.
    [self transitionFromViewController: oldVC
                      toViewController: newVC
                              duration: CONTAIN_VIEW_AIMATION_TIME
                               options: (7 << 16)
                            animations:^{
                                // Animate the views to their final positions.
                                newVC.view.frame = self.view.bounds;
                                oldVC.view.frame = endFrame;
                                
                                if (direction == FROM_RIGHT_TO_LEFT){
                                    [self.view bringSubviewToFront:oldVC.view];
                                }
                            }
                            completion:^(BOOL finished) {
                                // Remove the old view controller and send the final
                                // notification to the new view controller.
                                [oldVC removeFromParentViewController];
                                [newVC didMoveToParentViewController:self];
                                
                            }];
     */
}



/**
 *  不带动画的 两个child VC的切换
 *
 *  @param oldVC 老的child vc
 *  @param newVC 新的要显示的child vc
 */
- (void)fromViewController: (UIViewController*) oldVC
                    toViewController: (UIViewController*) newVC{

    [oldVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    
    [oldVC.view removeFromSuperview];
    newVC.view.frame = self.view.bounds;
    [self.view addSubview:newVC.view];
    
    
    [oldVC removeFromParentViewController];
    [newVC didMoveToParentViewController:self];

    
}



//新的child vc.view 出现时的初始化位置
- (CGRect)newViewStartFrame:(SHOW_SUBVC_DIRECTION)direction{
    if (direction == FROM_LEFT_TO_RIGHT){
        return CGRectMake(-self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }else{
        return CGRectMake(self.view.frame.size.width/3, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }
}


//老的child vc.view 结束时的初始化位置
- (CGRect)oldViewEndFrame:(SHOW_SUBVC_DIRECTION)direction{
    if (direction == FROM_LEFT_TO_RIGHT){
        return CGRectMake(self.view.frame.size.width/3, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }else{
        return CGRectMake(-self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }
}



//显示一个child VC
- (void)displayContentController:(UIViewController *)contentViewController{
    
    [self addChildViewController:contentViewController];
    contentViewController.view.frame = self.view.bounds;
    [self.view addSubview:contentViewController.view];
    [contentViewController didMoveToParentViewController:self];
    
    
}

//移除一个child VC
- (void)hideContentController:(UIViewController *)contentViewController{
    
    [contentViewController willMoveToParentViewController:nil];
    [contentViewController.view removeFromSuperview];
    [contentViewController removeFromParentViewController];
    
    //触发viewWillDisappear
    //[contentViewController beginAppearanceTransition: NO animated: NO];
    //触发viewDidDisappear
    //[contentViewController endAppearanceTransition];
    
}



#pragma mark - PanGesture
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
 
    if(self.visibleViewController == _rightViewController){
        [self handleLeftVCShowPanGestureRecognizer:recognizer];
    }else{
        [self handleRightVCShowPanGestureRecognizer:recognizer];
    }
}


//手势更随，当前显示的是rightVC, leftVC 将要显示出来的效果
- (void)handleLeftVCShowPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    
    //用一张截图做动画

    if (recognizer.state == UIGestureRecognizerStateBegan){

        UIImage *leftVCSnapShotImage = [self snapShotController:self.leftViewController];
        self.leftVCSnapShotImageView.image = leftVCSnapShotImage;
        
        if ([self.view viewWithTag:1002] == nil){
            [self.view addSubview:self.leftVCSnapShotImageView];
            self.leftVCSnapShotImageView.tag = 1002;
        }
        self.leftVCSnapShotImageView.frame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
        
        
        CGPoint offset = [recognizer translationInView:self.view];
        self.panGesturePreOffset = offset;
        if (offset.x < 0)
        {
            self.panGestureLastMoveType = PanGestureMoveLeft;
        }
        else
        {
            self.panGestureLastMoveType = PanGestureMoveRight;
        }
        
        
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint offset = [recognizer translationInView:self.view];
        
        //每次move的offset的改变，都更新一下 移动的方向
        if (offset.x < self.panGesturePreOffset.x) {
            self.panGestureLastMoveType = PanGestureMoveLeft;
        }
        else if (offset.x > self.panGesturePreOffset.x)
        {
            self.panGestureLastMoveType = PanGestureMoveRight;
        }
        self.panGesturePreOffset = offset;
        
        if (offset.x > 0){
            
            //leftSnapshotImageView
            CGRect originFrame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
            CGRect leftSnapShotImgViewFrame =  CGRectMake(
                                                          originFrame.origin.x + offset.x,
                                                          _leftVCSnapShotImageView.frame.origin.y,
                                                          _leftVCSnapShotImageView.frame.size.width,
                                                          _leftVCSnapShotImageView.frame
                                                          .size.height);
            
            self.leftVCSnapShotImageView.frame = leftSnapShotImgViewFrame;
            
            //rightVC
            CGRect rightVCFrame = self.rightViewController.view.frame;
            self.rightViewController.view.frame = CGRectMake(offset.x/3, rightVCFrame.origin.y, rightVCFrame.size.width, rightVCFrame.size.height);
            
        }else{
            return;
        }

    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        
        //如果的距离超过1/3，或者向右滑动的话， 则显示出界面，
        if (fabs(self.leftVCSnapShotImageView.frame.origin.x + self.leftVCSnapShotImageView.frame.size.width) >= self.view.frame.size.width/3  || self.panGestureLastMoveType == PanGestureMoveRight)
        {
            [self.leftVCSnapShotImageView removeFromSuperview];
            

            [self transitionFromViewController:self.rightViewController toViewController:self.leftViewController direction:FROM_LEFT_TO_RIGHT toVCBeginFrame:self.leftVCSnapShotImageView.frame];
            self.visibleViewController = self.leftViewController;
            
        }
        //否则，删除界面
        else{
            [UIView animateWithDuration: CONTAIN_VIEW_AIMATION_TIME
                                  delay: 0.0
                                options: (7 << 16)
                             animations:^{
                                 self.leftVCSnapShotImageView.frame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
                                 self.rightViewController.view.frame = self.view.bounds;
                             }
                             completion:^(BOOL finished) {
                                 [self.leftVCSnapShotImageView removeFromSuperview];
                             }] ;
            
        }
    }
}

        
        

//手势更随，当前显示的是LeftVC, rightVC 将要显示出来
- (void)handleRightVCShowPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    
   
   
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
         //用一张截图做动画
        UIImage *rightVCSnapShotImage = [self snapShotController:self.rightViewController];
        self.rightVCSnapShotImageView.image = rightVCSnapShotImage;
        
        if ([self.view viewWithTag:1003] == nil){
            [self.view insertSubview:self.rightVCSnapShotImageView atIndex:0];
            self.rightVCSnapShotImageView.tag = 1003;
        }
        self.rightVCSnapShotImageView.frame = [self newViewStartFrame:FROM_RIGHT_TO_LEFT];
        
        
        CGPoint offset = [recognizer translationInView:self.view];
        self.panGesturePreOffset = offset;
        if (offset.x < 0)
        {
            self.panGestureLastMoveType = PanGestureMoveLeft;
        }
        else
        {
            self.panGestureLastMoveType = PanGestureMoveRight;
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint offset = [recognizer translationInView:self.view];
        
        //每次move的offset的改变，都更新一下 移动的方向
        if (offset.x < self.panGesturePreOffset.x) {
            self.panGestureLastMoveType = PanGestureMoveLeft;
        }
        else if (offset.x > self.panGesturePreOffset.x)
        {
            self.panGestureLastMoveType = PanGestureMoveRight;
        }
        self.panGesturePreOffset = offset;
        
        
        if (offset.x < 0){
            
            //rightVCSnapShotImageView Frame
            CGRect originFrame = [self newViewStartFrame:FROM_RIGHT_TO_LEFT];
            CGRect rightSnapShotImgViewFrame =  CGRectMake(
                                                          originFrame.origin.x + offset.x/3,
                                                          _rightVCSnapShotImageView.frame.origin.y,
                                                          _rightVCSnapShotImageView.frame.size.width,
                                                          _rightVCSnapShotImageView.frame
                                                          .size.height);
            self.rightVCSnapShotImageView.frame = rightSnapShotImgViewFrame;
            
            //left VC
            CGRect leftVCFrame = self.leftViewController.view.frame;
            self.leftViewController.view.frame = CGRectMake(offset.x, leftVCFrame.origin.y, leftVCFrame.size.width, leftVCFrame.size.height);

        }else{
            return;
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        
        //如果最后一次是向左滑动, 界面退出，
        if (self.panGestureLastMoveType == PanGestureMoveLeft){
            
            [self.rightVCSnapShotImageView removeFromSuperview];
            
            [self transitionFromViewController:self.leftViewController toViewController:self.rightViewController direction:FROM_RIGHT_TO_LEFT toVCBeginFrame:self.rightVCSnapShotImageView.frame];
            self.visibleViewController = self.rightViewController;
        }
        //如果最后一次向右滑动， 界面还原
        else if (self.panGestureLastMoveType == PanGestureMoveRight)
        {
            [UIView animateWithDuration:CONTAIN_VIEW_AIMATION_TIME
                                  delay:0.0
                                options: (7 << 16)
                             animations:^{
                                 self.rightVCSnapShotImageView.frame = [self newViewStartFrame:FROM_RIGHT_TO_LEFT];
                                 self.leftViewController.view.frame = self.view.bounds;
                                 
                             }
                             completion:^(BOOL finished) {
                                 [self.rightVCSnapShotImageView removeFromSuperview];
                             }];

        }
    }
    
}


#pragma mark - snapShot
//controller 截图
- (UIImage *)snapShotController:(UIViewController *)controller {
 
    
    CGFloat scale = [[UIScreen mainScreen] scale];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
        scale = [[UIScreen mainScreen] nativeScale];
    }
#endif
    CGSize size = controller.view.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [controller.view.layer renderInContext:context];
    

    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}


@end
