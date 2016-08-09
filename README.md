# SlideContainerViewController
implement a containerViewController,   has  two child viewController  slide right-left


version 1.0
手势跟随做动画时，将新进来的界面截了图，与老的vc.view做动画. 手指松开时，才进行transition。transition的时候会调用beginAppearanceTransition等。因此手势跟随时，是不会有viewWillAppear等方法的调用的， 手势完了之后才有。
这个跟 系统自带的navigation是不一样的，系统还是用的两个view进行动画， 在手势跟随时，就调用beginAppearanceTransition

version 1.1
不再用截图来做手势跟随的动画，而是直接用子view
这样调用的方式跟系统的NavigationController手势跟随是一样的，即

oldVC            newVC
手势跟随开始:
willDisAppear    
				willAppear

a)手势跟随结束， 新界面展示：
did DisAppear
               didAppear
               
手势跟随结束，新界面没有打开：
				willDisAppear
				didDisAppear
willAppear
didAppear