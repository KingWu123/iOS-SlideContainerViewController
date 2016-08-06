# SlideContainerViewController
implement a containerViewController,   has  two child viewController  slide right-left


手势跟随做动画时，将新进来的界面截了图，与老的vc.view做动画. 手指松开时，才进行transition。transition的时候会调用beginAppearanceTransition等。因此手势跟随时，是不会有viewWillAppear等方法的调用的， 手势完了之后才有。
这个跟 系统自带的navigation是不一样的，系统还是用的两个view进行动画， 在手势跟随时，就调用beginAppearanceTransition
