//
//  SlideContainerViewController.m
//  SlideContainerViewController
//
//  Created by king.wu on 7/28/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import "SlideContainerViewController.h"

@interface TransitionView : UIView

@end

@implementation TransitionView

@end


@interface WrapperView : UIView

@end

@implementation WrapperView

@end


/**
 *  实现类似于QQ的  个人账号界面 和 主界面 打开效果的ContianViewController
 */

#define CONTAIN_VIEW_AIMATION_TIME  0.3
@interface SlideContainerViewController ()<UIGestureRecognizerDelegate>


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

@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign)CGPoint panGesturePreOffset;
@property (nonatomic, assign)PanGestureMoveType panGestureLastMoveType;

@property (nonatomic, weak)TransitionView *transitionView;
@property (nonatomic, weak)WrapperView *wrapperView;


@property (nonatomic, strong)NSMutableSet *conflictGestures;

@end

@implementation SlideContainerViewController



- (instancetype)initWithRightViewController:(UIViewController *)rightViewController withLeftViewController:(UIViewController *)leftViewController{
 
    self = [super init];
    if (self){
        
        //init transitionView
        TransitionView *transitionView = [[TransitionView alloc]initWithFrame:self.view.bounds];
        transitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [transitionView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:transitionView];
        self.transitionView =transitionView;
        
        //init wrapper
        WrapperView *wrapperView = [[WrapperView alloc]initWithFrame:self.view.bounds];
        wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [wrapperView setBackgroundColor:[UIColor clearColor]];
        [self.transitionView addSubview:wrapperView];
        self.wrapperView =wrapperView;
        
        self.rightViewController = rightViewController;
        self.leftViewController = leftViewController;
        
        
        
        //这里主要是让 leftView的view自适应一下，不然做动画截图有问题
        [self displayContentController:leftViewController];
        [self hideContentController:leftViewController];
        
        [self displayContentController:rightViewController];
        self.visibleViewController = rightViewController;
        
        
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        self.panGesture.delegate = self;
        [self.transitionView addGestureRecognizer:self.panGesture];
        
         self.leftVCSnapShotImageView = [[UIImageView alloc]init];
         self.rightVCSnapShotImageView = [[UIImageView alloc]init];
        
        self.conflictGestures = [[NSMutableSet alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor redColor]];
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
    [self.wrapperView addSubview:newVC.view];
    
    [UIView animateWithDuration:CONTAIN_VIEW_AIMATION_TIME delay:0.0 options:(7 << 16) animations:^{
        newVC.view.frame = self.wrapperView.bounds;
        oldVC.view.frame = endFrame;
        
        if (direction == FROM_RIGHT_TO_LEFT){
            [self.wrapperView bringSubviewToFront:oldVC.view];
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
                                newVC.view.frame = self.wrapperView.bounds;
                                oldVC.view.frame = endFrame;
                                
                                if (direction == FROM_RIGHT_TO_LEFT){
                                    [self.wrapperView bringSubviewToFront:oldVC.view];
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
    newVC.view.frame = self.wrapperView.bounds;
    [self.wrapperView addSubview:newVC.view];
    
    
    [oldVC removeFromParentViewController];
    [newVC didMoveToParentViewController:self];

    
}



//新的child vc.view 出现时的初始化位置
- (CGRect)newViewStartFrame:(SHOW_SUBVC_DIRECTION)direction{
    if (direction == FROM_LEFT_TO_RIGHT){
        return CGRectMake(-self.wrapperView.frame.size.width, self.wrapperView.frame.origin.y, self.wrapperView.frame.size.width, self.wrapperView.frame.size.height);
    }else{
        return CGRectMake(self.wrapperView.frame.size.width/3, self.wrapperView.frame.origin.y, self.wrapperView.frame.size.width, self.wrapperView.frame.size.height);
    }
}


//老的child vc.view 结束时的初始化位置
- (CGRect)oldViewEndFrame:(SHOW_SUBVC_DIRECTION)direction{
    if (direction == FROM_LEFT_TO_RIGHT){
        return CGRectMake(self.wrapperView.frame.size.width/3, self.wrapperView.frame.origin.y, self.wrapperView.frame.size.width, self.wrapperView.frame.size.height);
    }else{
        return CGRectMake(-self.wrapperView.frame.size.width, self.wrapperView.frame.origin.y, self.wrapperView.frame.size.width, self.wrapperView.frame.size.height);
    }
}



//显示一个child VC
- (void)displayContentController:(UIViewController *)contentViewController{
    
    [self addChildViewController:contentViewController];
    contentViewController.view.frame = self.wrapperView.bounds;
    [self.wrapperView addSubview:contentViewController.view];
    [contentViewController didMoveToParentViewController:self];
    
    
}

//移除一个child VC
- (void)hideContentController:(UIViewController *)contentViewController{
    
    [contentViewController willMoveToParentViewController:nil];
    [contentViewController.view removeFromSuperview];
    [contentViewController removeFromParentViewController];
    
}



#pragma mark - PanGesture
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
 
    static BOOL isRecognizerSuccess = NO;
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        CGPoint beginPositon = [recognizer locationInView:self.transitionView];
        
        
        if ((beginPositon.x < 50 && self.visibleViewController == _rightViewController)
            || (beginPositon.x > [[UIScreen mainScreen] bounds].size.width - 60 && self.visibleViewController == _leftViewController)){
            isRecognizerSuccess = YES;
        }else{
            isRecognizerSuccess = NO;
        }
    }
    
    
    //想拉出左界面，只有从屏幕的最左边拉出，界面才需要显示
    if(self.visibleViewController == _rightViewController && isRecognizerSuccess){
        [self handleLeftVCShowPanGestureRecognizer:recognizer];
    }
    //想拉叔右界面，只有从屏幕最右边拉出，界面才需要显示
    else if (self.visibleViewController == _leftViewController && isRecognizerSuccess){
        [self handleRightVCShowPanGestureRecognizer:recognizer];
    }

}


//手势更随，当前显示的是rightVC, leftVC 将要显示出来的效果
- (void)handleLeftVCShowPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    
    //用一张截图做动画

    if (recognizer.state == UIGestureRecognizerStateBegan){

        UIImage *leftVCSnapShotImage = [self snapShotController:self.leftViewController];
        self.leftVCSnapShotImageView.image = leftVCSnapShotImage;
        
        
        if (![self.leftVCSnapShotImageView isDescendantOfView:self.wrapperView]){
            [self.wrapperView addSubview:self.leftVCSnapShotImageView];
        }
        self.leftVCSnapShotImageView.frame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
        
        
        CGPoint offset = [recognizer translationInView:self.wrapperView];
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
        
        CGPoint offset = [recognizer translationInView:self.wrapperView];
        
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
            
            //这个时候，说明正在进行手势跟随， 所以可以移除其它冲突的手势
            [self removeConflictGesturesTouchEvent];
            
        }else{
            return;
        }

    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        
        //如果的距离超过1/3，或者向右滑动的话， 则显示出界面，
        if (fabs(self.leftVCSnapShotImageView.frame.origin.x + self.leftVCSnapShotImageView.frame.size.width) >= self.wrapperView.frame.size.width/3  || self.panGestureLastMoveType == PanGestureMoveRight)
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
                                 self.rightViewController.view.frame = self.wrapperView.bounds;
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
        
        if (![self.rightVCSnapShotImageView isDescendantOfView:self.wrapperView]){
            [self.wrapperView insertSubview:self.rightVCSnapShotImageView atIndex:0];
        }
        self.rightVCSnapShotImageView.frame = [self newViewStartFrame:FROM_RIGHT_TO_LEFT];
        
        
        CGPoint offset = [recognizer translationInView:self.wrapperView];
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
        
        CGPoint offset = [recognizer translationInView:self.wrapperView];
        
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

            //这个时候，说明正在进行手势跟随， 所以可以移除其它冲突的手势
            [self removeConflictGesturesTouchEvent];
            
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
                                 self.leftViewController.view.frame = self.wrapperView.bounds;
                                 
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
 
    return [SlideContainerViewController snapImageOfView:controller.view scale:1.0];
}

+(UIImage *)snapImageOfView:(UIView *)aView scale:(CGFloat)aScale{
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
        UIGraphicsBeginImageContextWithOptions(aView.bounds.size, NO, aScale);
        [aView drawViewHierarchyInRect:aView.bounds afterScreenUpdates:YES];
        UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return copied;
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(aView.bounds.size, NO, aScale);
        [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return copied;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if (gestureRecognizer == self.panGesture){
        // 如果otherGestureRecognizer是scrollview 判断scrollview的contentOffset.x 是否小于等于0，YES
        if ([[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
            
            UIScrollView *scrollView = (UIScrollView *)[otherGestureRecognizer view];
            if (scrollView.contentOffset.x <= 0) {
                
                [self.conflictGestures addObject:otherGestureRecognizer];
                return YES;
            }
        }
    }
    return NO;
}

//当手势跟随成功时， 删除其它同时存在的手势的事件，使只有手势跟随的手势存在
- (void)removeConflictGesturesTouchEvent{
    
    for (UIGestureRecognizer *recognizer in self.conflictGestures) {
        BOOL originEnabled = recognizer.enabled;
        recognizer.enabled = NO;
        recognizer.enabled = originEnabled;
    }
    
    [self.conflictGestures removeAllObjects];
}


@end
