# SlideContainerViewController
implement a containerViewController,   has  two child viewController right and left, can use gesture slide to show each other.

##Installation
copy 	
SlideContainerViewController.h,		
SlideContainerViewController.m, 	
UIViewController+SlideContainerViewController.h,	
UIViewController+SlideContainerViewController.m		
to your project

##How to use
UIViewController *leftVC  = ....

UIViewController *rightVC = ....

<font color=red>//default show rightChild VC</font>  
SlideContainerViewController *slideContainerVC =  [[SlideContainerViewController alloc]initWithRightViewController:rightVC withLeftViewController:leftVC];

<font color=red>//show  reftChild VC</font>  	
[slideContainerVC showLeftViewWithAnimated:YES];

<font color=red>//show  rightChild VC</font>  	
[slideContainerVC showRightViewWithAnimated:YES];

<font color=red>//if want to show leftVC, add this method to you viewcontroller</font>  
- (BOOL)needShowLeftChildVCWhenGestureBegin:(CGPoint)location{
	return NO;
}


##Release Notes
####version 1.0
手势跟随做动画时，将新进来的界面截了图，与老的vc.view做动画.

###version 1.1
不再用截图来做手势跟随的动画，而是直接用子view,
这样调用的方式跟系统的NavigationController手势跟随是一样的，vc的调用顺序为：


oldVC　　　　　newVC	
手势跟随开始:		
willDisAppear					 
　　　　　　　　willAppear

a)手势跟随结束， 新界面展示：	
did DisAppear	
　　　　　　　　didAppear
               
b)手势跟随结束，新界面没有打开：		
　　　　　　　　willDisAppear	
　　　　　　　　didDisAppear	
willAppear	
didAppear