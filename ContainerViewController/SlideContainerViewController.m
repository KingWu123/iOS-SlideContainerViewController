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




#define CONTAIN_VIEW_AIMATION_TIME  0.3
@interface SlideContainerViewController ()<UIGestureRecognizerDelegate>


typedef NS_ENUM(NSInteger, SHOW_SUBVC_DIRECTION) {
    FROM_LEFT_TO_RIGHT,  //从左向右滑动， 左边的VC将要显示出来
    FROM_RIGHT_TO_LEFT,  //从右先做滑动， 右边的VC将要显示出来
};

//手势的移动方向
typedef NS_ENUM(NSInteger, PanGestureMoveType) {
    PanGestureMoveLeft = 0,
    PanGestureMoveRight,
};


@property (nonatomic, strong)UIViewController *rightViewController;
@property (nonatomic, strong)UIViewController *leftViewController;
@property (nonatomic, weak)UIViewController *visibleViewController;


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
        
        //
        self.rightViewController = rightViewController;
        self.leftViewController = leftViewController;
        
        
        [self displayContentController:rightViewController];
        self.visibleViewController = rightViewController;
        
        
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        self.panGesture.delegate = self;
        [self.transitionView addGestureRecognizer:self.panGesture];
        
        
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
        [self transitionFromViewController:self.rightViewController toViewController:self.leftViewController direction:FROM_LEFT_TO_RIGHT];
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
        [self transitionFromViewController:self.leftViewController toViewController:self.rightViewController direction:FROM_RIGHT_TO_LEFT];
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
 *
 * 注：beginAppearanceTransition和endAppearanceTransition调用顺序不要改变
 */
- (void)transitionFromViewController: (UIViewController*) oldVC
                    toViewController: (UIViewController*) newVC
                           direction:(SHOW_SUBVC_DIRECTION)direction{
  
    
    [oldVC willMoveToParentViewController:nil];
    [oldVC beginAppearanceTransition: NO animated: YES];
    
    
    [self addChildViewController:newVC];
    [newVC beginAppearanceTransition: YES animated: YES];
    newVC.view.frame = [self newViewStartFrame:direction];
    CGRect endFrame = [self oldViewEndFrame:direction];
    [self.wrapperView addSubview:newVC.view];
    
    [self.transitionView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:CONTAIN_VIEW_AIMATION_TIME delay:0.0 options:(7 << 16) animations:^{
        newVC.view.frame = self.wrapperView.bounds;
        oldVC.view.frame = endFrame;
        
        if (direction == FROM_RIGHT_TO_LEFT){
            [self.wrapperView bringSubviewToFront:oldVC.view];
        }

        
    } completion:^(BOOL finished) {
        
        [oldVC.view removeFromSuperview];
        [oldVC endAppearanceTransition];
        [oldVC removeFromParentViewController];
        
        [newVC endAppearanceTransition];
        [newVC didMoveToParentViewController:self];
        
        [self.transitionView setUserInteractionEnabled:YES];

    }];
    
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

//不显示一个child VC
- (void)hideContentController:(UIViewController *)contentViewController{
    
    [contentViewController willMoveToParentViewController:nil];
    [contentViewController.view removeFromSuperview];
    [contentViewController removeFromParentViewController];
    
}



#pragma mark - PanGesture
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
 
    //只有从屏幕的最左边拉出，界面才需要显示
    if(self.visibleViewController == _rightViewController ){
        [self handleLeftVCShowPanGestureRecognizer:recognizer];
    }else if (self.visibleViewController == _leftViewController){
        [self handleRightVCShowPanGestureRecognizer:recognizer];
    }
}


//手势更随，当前显示的是rightVC, 从左向右滑，leftVC将要显示出来
- (void)handleLeftVCShowPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan){

        //rightViewController将要不显示
        [self.rightViewController willMoveToParentViewController:nil];
        [self.rightViewController beginAppearanceTransition: NO animated: YES];
        
        //leftViewcontroller将要显示
        [self addChildViewController:self.leftViewController];
        [self.leftViewController beginAppearanceTransition: YES animated: YES];
        self.leftViewController.view.frame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
        [self.wrapperView addSubview:self.leftViewController.view];
        
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
        
        //这个时候，说明正在进行手势跟随， 所以可以移除其它冲突的手势
        [self removeConflictGesturesTouchEvent];
        
        
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
        
            //leftVC frame
            CGRect originFrame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
            CGRect leftChildRootViewFrame =  CGRectMake(
                                                        originFrame.origin.x + offset.x,
                                                        _leftViewController.view.frame.origin.y,
                                                        _leftViewController.view.frame.size.width,
                                                        _leftViewController.view.frame
                                                        .size.height);
            
            self.leftViewController.view.frame = leftChildRootViewFrame;

            
            //rightVC
            CGRect rightVCFrame = self.rightViewController.view.frame;
            self.rightViewController.view.frame = CGRectMake(offset.x/3, rightVCFrame.origin.y, rightVCFrame.size.width, rightVCFrame.size.height);

            
        }else{
            return;
        }

    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        
        //手势结束，根据最后的手势情况，决定leftVC是显示出来，还是回退回去
        [self leftVCBackOrShow];
    }
}

//从左向右滑动的手势结束后， leftChildVC是回退回去，还是显示出来
- (void)leftVCBackOrShow{
    
    //如果的距离超过1/3，或者向右滑动的话， 则显示出左界面，
    if (fabs(self.leftViewController.view.frame.origin.x + self.leftViewController.view.frame.size.width) >= self.wrapperView.frame.size.width/3  || self.panGestureLastMoveType == PanGestureMoveRight)
    {
        float time = fabs(self.leftViewController.view.frame.origin.x)/self.leftViewController.view.frame.size.width * CONTAIN_VIEW_AIMATION_TIME;
        
        [self.transitionView setUserInteractionEnabled:NO];
        [UIView animateWithDuration:time delay:0.0 options:(7 << 16) animations:^{
            
            self.leftViewController.view.frame = self.wrapperView.bounds;
            self.rightViewController.view.frame = [self oldViewEndFrame:FROM_LEFT_TO_RIGHT];
            
        } completion:^(BOOL finished) {
            //rightVC did remove
            [self.rightViewController.view removeFromSuperview];
            [self.rightViewController endAppearanceTransition];
            [self.rightViewController removeFromParentViewController];
            
            //leftVC did add
            [self.leftViewController endAppearanceTransition];
            [self.leftViewController didMoveToParentViewController:self];
            
            [self.transitionView setUserInteractionEnabled:YES];
        }];
        
        
        self.visibleViewController = self.leftViewController;
        
    }
    //否则，界面回退回去
    else{
        
        float time = fabs(self.leftViewController.view.frame.origin.x + self.leftViewController.view.frame.size.width)/self.leftViewController.view.frame.size.width * CONTAIN_VIEW_AIMATION_TIME;
        
        [UIView animateWithDuration: time
                              delay: 0.0
                            options: (7 << 16)
                         animations:^{
                             self.leftViewController.view.frame = [self newViewStartFrame:FROM_LEFT_TO_RIGHT];
                             self.rightViewController.view.frame = self.wrapperView.bounds;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             //leftViewChildController
                             [self.leftViewController willMoveToParentViewController:nil];
                             [self.leftViewController beginAppearanceTransition: NO animated: YES];
                             
                             [self.leftViewController.view removeFromSuperview];
                             [self.leftViewController endAppearanceTransition];
                             [self.leftViewController removeFromParentViewController];
                             
                             //rightViewChildController
                             [self.rightViewController willMoveToParentViewController:self];
                             [self.rightViewController beginAppearanceTransition: YES animated: YES];
                             
                             [self.rightViewController endAppearanceTransition];
                             [self.rightViewController didMoveToParentViewController:self];
                             
                             
                             [self.transitionView setUserInteractionEnabled:YES];
                         }] ;
        
    }
}


//手势更随，当前显示的是LeftVC, 从右向左滑， rightVC 将要显示出来
- (void)handleRightVCShowPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {

    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        //leftViewController将要不显示
        [self.leftViewController willMoveToParentViewController:nil];
        [self.leftViewController beginAppearanceTransition: NO animated: YES];
        
        //rightViewcontroller将要显示
        [self addChildViewController:self.rightViewController];
        [self.rightViewController beginAppearanceTransition: YES animated: YES];
        self.rightViewController.view.frame = [self newViewStartFrame:FROM_RIGHT_TO_LEFT];
        [self.wrapperView insertSubview:self.rightViewController.view belowSubview:self.leftViewController.view];
        
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
        
        //这个时候，说明正在进行手势跟随， 所以可以移除其它冲突的手势
        [self removeConflictGesturesTouchEvent];

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
            
            //rightChildFrame
            CGRect originFrame = [self newViewStartFrame:FROM_RIGHT_TO_LEFT];
            CGRect rightChildFrame =  CGRectMake(
                                                 originFrame.origin.x + offset.x/3,
                                                 _rightViewController.view.frame.origin.y,
                                                 _rightViewController.view.frame.size.width,
                                                 _rightViewController.view.frame
                                                 .size.height);
            self.rightViewController.view.frame = rightChildFrame;
            
            //left VC
            CGRect leftVCFrame = self.leftViewController.view.frame;
            self.leftViewController.view.frame = CGRectMake(offset.x, leftVCFrame.origin.y, leftVCFrame.size.width, leftVCFrame.size.height);

            
        }else{
            return;
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        //手势结束，根据最后的手势情况，决定rightVC是显示出来，还是回退回去
        [self rightVCBackOrShow];
    }
}

//从右向左滑动的手势结束后， rightChildVC是回退回去，还是显示出来
- (void)rightVCBackOrShow{
    //如果最后一次是向左滑动, 界面退出，
    if (self.panGestureLastMoveType == PanGestureMoveLeft){
        
        float time = fabs(self.leftViewController.view.frame.origin.x + self.leftViewController.view.frame.size.width)/self.leftViewController.view.frame.size.width * CONTAIN_VIEW_AIMATION_TIME;
        
        
        [self.transitionView setUserInteractionEnabled:NO];
        [UIView animateWithDuration:time delay:0.0 options:(7 << 16) animations:^{
            
            self.rightViewController.view.frame = self.wrapperView.bounds;
            self.leftViewController.view.frame = [self oldViewEndFrame:FROM_RIGHT_TO_LEFT];
            
        } completion:^(BOOL finished) {
            [self.leftViewController.view removeFromSuperview];
            [self.leftViewController endAppearanceTransition];
            [self.leftViewController removeFromParentViewController];
            
            [self.rightViewController endAppearanceTransition];
            [self.rightViewController didMoveToParentViewController:self];
            
            [self.transitionView setUserInteractionEnabled:YES];
        }];
        
        
        self.visibleViewController = self.rightViewController;
    }
    //如果最后一次向右滑动， 界面还原
    else if (self.panGestureLastMoveType == PanGestureMoveRight)
    {
        float time = fabs(self.leftViewController.view.frame.origin.x)/self.leftViewController.view.frame.size.width * CONTAIN_VIEW_AIMATION_TIME;
        
        [self.transitionView setUserInteractionEnabled: NO];
        
        
        [UIView animateWithDuration: time
                              delay: 0.0
                            options: (7 << 16)
                         animations:^{
                             self.leftViewController.view.frame = self.wrapperView.bounds;
                             self.rightViewController.view.frame = [self oldViewEndFrame:FROM_LEFT_TO_RIGHT];
                             
                         }
                         completion:^(BOOL finished) {
                             
                             //rightViewChildController
                             [self.rightViewController willMoveToParentViewController:nil];
                             [self.rightViewController beginAppearanceTransition: NO animated: YES];
                             
                             [self.rightViewController.view removeFromSuperview];
                             [self.rightViewController endAppearanceTransition];
                             [self.rightViewController removeFromParentViewController];
                             
                             //leftViewChildController
                             [self.leftViewController willMoveToParentViewController:self];
                             [self.leftViewController beginAppearanceTransition: YES animated: YES];
                             
                             [self.leftViewController endAppearanceTransition];
                             [self.leftViewController didMoveToParentViewController:self];
                             
                             
                             [self.transitionView setUserInteractionEnabled:YES];
                         }] ;
        
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    [self.conflictGestures removeAllObjects];
    
    CGPoint    velocity = [gestureRecognizer velocityInView:self.transitionView];
    CGPoint    location = [gestureRecognizer locationInView:self.transitionView];
    CGPoint    offset = [gestureRecognizer translationInView:self.transitionView];
    
    float rangeWidth = [[UIScreen mainScreen] bounds].size.width/320.0 * 28;
    if (self.visibleViewController == _rightViewController && velocity.x > 0 && location.x - offset.x < rangeWidth){
        return YES;
    }else if (self.visibleViewController == _leftViewController && velocity.x < 0 && location.x - offset.x > [[UIScreen mainScreen] bounds].size.width - 60){
        return YES;
    }
    return NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if (gestureRecognizer == self.panGesture){
        // 如果otherGestureRecognizer是scrollview 判断scrollview的contentOffset.x 是否小于等于0，YES
        if ([[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
            
            return YES;
//            UIScrollView *scrollView = (UIScrollView *)[otherGestureRecognizer view];
//            if (scrollView.contentOffset.x <= 0) {
//                
//                [self.conflictGestures addObject:otherGestureRecognizer];
//                return YES;
//            }
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
