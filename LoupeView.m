//
//  LoupeView.m
//
//
//  Created by ajimonster on 2015/12/09.
//
//

#import "LoupeView.h"

@implementation LoupeView
// ---------------------------------------------------------------------------------
//	init
// ---------------------------------------------------------------------------------
- (id)init
{
    self = [ super init ] ;
    if (self)
    {
        isVertical = [[ UIScreen mainScreen ] bounds].size.width < [[ UIScreen mainScreen ] bounds].size.height ;
        
        loupeWidth = isVertical?
                      [[ UIScreen mainScreen ] bounds].size.width / 2 :
                      ([[ UIScreen mainScreen ] bounds].size.height - (20+44+44)) / 2 ;//200 ;
        
        
        self.frame = CGRectMake(0,
                                0,
                                loupeWidth,
                                loupeWidth) ;
        loupeViewImage = [[[ UIImageView alloc ] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          loupeWidth,
                                                                          loupeWidth)] autorelease] ;
        [ self addSubview:loupeViewImage ] ;
        //backBroundColorはclearColor対策
        //形はご自由に
        self.backgroundColor = [ UIColor whiteColor ] ;
        self.layer.cornerRadius = 5 ;
        self.clipsToBounds = true;
        self.layer.borderColor =  [ UIColor darkGrayColor ].CGColor ;
        self.layer.borderWidth = 3 ;
    }
    
    return self ;
}
// ---------------------------------------------------------------------------------
//	drawRect
// ---------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    
}
// ---------------------------------------------------------------------------------
//	makeView
// ---------------------------------------------------------------------------------
- (void)makeView:(UIView*)view
           point:(CGPoint)point
       zeroPoint:(CGPoint)zero
{
    float loupeX = point.x - loupeWidth - loupeWidth / 8 ;
    float loupeY = point.y - loupeWidth - loupeWidth / 8 ;
    
    
    CGPoint maxPoint = CGPointMake((zero.x + [[ UIScreen mainScreen ] bounds].size.width) - loupeWidth,
                                   (zero.y + [[ UIScreen mainScreen ] bounds].size.height) - loupeWidth) ;
    
    if (loupeX <= zero.x)
    {
        //loupeX *= - 1 ;
        if (point.x + loupeWidth / 8  > maxPoint.x)
        {
            loupeX = zero.x ;
        }
        else
        {
            loupeX = point.x + loupeWidth / 8 ;
        }
    }
    if (loupeY <= zero.y)
    {
        //loupeY *= - 1 ;
        if (point.y + loupeWidth / 8  > maxPoint.y)
        {
            loupeY = zero.y ;
        }
        else
        {
            loupeY = point.y + loupeWidth / 8 ;
        }
    }
    
    self.frame = CGRectMake(loupeX,
                            loupeY,
                            loupeWidth,
                            loupeWidth) ;
    
    UIImage* cutViewImage ;
    cutViewImage = nil ;
    
    CGSize loupeSize = CGSizeMake(loupeWidth / 4,loupeWidth / 4) ;
    UIGraphicsBeginImageContextWithOptions(loupeSize,NO,0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //ちょうど指でなぞっている部分が映るよう調整
    CGAffineTransform affineMoveLeftTop
    = CGAffineTransformMakeTranslation( - (int)point.x + loupeWidth / 8 ,
                                        - (int)point.y + loupeWidth / 8 );
    
    CGContextConcatCTM( context , affineMoveLeftTop );
    
    [(CALayer*)view.layer renderInContext:context];
    
    
    cutViewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    loupeViewImage.image = cutViewImage ;
    
}

@end


// ---------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------


@implementation LoupeObject

// ---------------------------------------------------------------------------------
//	init
// ---------------------------------------------------------------------------------
- (id)init
{
    self = [ super init ] ;
    if (self)
    {
        [ self addObserver:self
                forKeyPath:@"isLoupeMode"
                   options:NSKeyValueObservingOptionNew
                   context:nil ] ;
        mLoupeView = nil ;
        mControllArray = [[ NSMutableArray alloc ] init] ;
        
        mContentRectZero = CGPointZero ;
    }
    
    return self ;
}
// ---------------------------------------------------------------------------------
//	observeValueForKeyPath
//  self.isLoupeModeを監視。NOにされたら自分で全部片付け
//  表示している側のViewでremoveしなくていい
// ---------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"isLoupeMode"])
    {
        if (!self.isLoupeMode)
        {
            [ self removeLoupeView ] ;
        }
    }
}
// ---------------------------------------------------------------------------------
//	removeLoupeView
// ---------------------------------------------------------------------------------
- (void)removeLoupeView
{
    if (mLoupeView != nil)
    {
        [mLoupeView removeFromSuperview] ;
        [mLoupeView release] ;
        mLoupeView = nil ;
        
        for (int i=0;i<[mControllArray count];i++)
        {
            id obj = [mControllArray objectAtIndex:i] ;
            if ([ obj isKindOfClass:[ UIScrollView class]])
            {
                UIScrollView* sv = (UIScrollView*)obj ;
                sv.scrollEnabled = YES ;
            }
            else if([obj isKindOfClass:[UITableView class]])
            {
                UITableView* tv = (UITableView*)obj ;
                tv.scrollEnabled = YES ;
            }
            else if([obj isKindOfClass:[UIWebView class]])
            {
                UIWebView* wv = (UIWebView*)obj ;
                wv.scrollView.scrollEnabled = YES ;
            }
        }
        
        [ mControllArray removeAllObjects ] ;
    }
}
// ---------------------------------------------------------------------------------
//	makeLoupeImageFromView
//  この時点で、呼び出した側のViewにルーペ貼り付けます
//  呼び出し側で　addSubView いりません
// ---------------------------------------------------------------------------------
- (void)makeLoupeImageFromView:(UIView*)view
                withTouchPoint:(CGPoint)point
{
    if (!self.isLoupeMode)
    {
        [ self lookAllResponder:view ] ;
    }
    
    
    if (mLoupeView == nil)
    {
        mLoupeView = [[ LoupeView alloc ] init ] ;
    }
    [ mLoupeView makeView:view
                    point:point
                zeroPoint:mContentRectZero ] ;
    
    [ view addSubview:mLoupeView ] ;
    
    self.isLoupeMode = YES ;
}

// ---------------------------------------------------------------------------------
//	lookAllResponder
//  ルーペに関わったUIを取得 scrol table web のscrolを無効にする
// ---------------------------------------------------------------------------------
- (void)lookAllResponder:(UIView*)view
{
    BOOL isSetContentOffset = NO ;
    
    UIResponder *responder = view ;
    while ((responder = responder.nextResponder) != nil)
    {
        if ([responder isKindOfClass:[UIViewController class]])
        {
            UIViewController* vc = (UIViewController*)responder ;
            for (int i=0;i<[vc.view.subviews count];i++)
            {
                id obj = [ vc.view.subviews objectAtIndex:i ] ;
                if ([ obj isKindOfClass:[ UIScrollView class]])
                {
                    UIScrollView* sv = (UIScrollView*)obj ;
                    if ([mControllArray indexOfObject:sv] == NSNotFound)
                    {
                        //NSLog(@"getScroll") ;
                        sv.scrollEnabled = NO ;
                        if (!(sv.contentOffset.x == 0 && sv.contentOffset.y == 0))
                        {
                            isSetContentOffset = YES ;
                            mContentRectZero = sv.contentOffset ;
                        }
                        [mControllArray addObject:sv] ;
                    }
                }
                else if([obj isKindOfClass:[UITableView class]])
                {
                    
                    UITableView* tv = (UITableView*)obj ;
                    if ([mControllArray indexOfObject:tv] == NSNotFound)
                    {
                        //NSLog(@"getTable") ;
                        tv.scrollEnabled = NO ;
                        if (!(tv.contentOffset.x == 0 && tv.contentOffset.y == 0))
                        {
                            isSetContentOffset = YES ;
                            mContentRectZero = tv.contentOffset ;
                        }
                        [mControllArray addObject:tv] ;
                    }
                }
                else if([obj isKindOfClass:[UIWebView class]])
                {
                    UIWebView* wv = (UIWebView*)obj ;
                    if ([mControllArray indexOfObject:wv] == NSNotFound)
                    {
                        //NSLog(@"getWeb") ;
                        wv.scrollView.scrollEnabled = NO ;
                        if (!(wv.scrollView.contentOffset.x == 0 && wv.scrollView.contentOffset.y == 0))
                        {
                            //isSetContentOffset = YES ;
                            //mContentRectZero = wv.scrollView.contentOffset ;
                        }
                        [mControllArray addObject:wv] ;
                    }
                }
            }
        }
        else if([responder isKindOfClass:[UIScrollView class]])
        {
            UIScrollView* sv = (UIScrollView*)responder ;
            if ([mControllArray indexOfObject:sv] == NSNotFound)
            {
                //NSLog(@"getScroll") ;
                sv.scrollEnabled = NO ;
                if (!(sv.contentOffset.x == 0 && sv.contentOffset.y == 0))
                {
                    isSetContentOffset = YES ;
                    mContentRectZero = sv.contentOffset ;
                }
                [mControllArray addObject:sv] ;
            }
        }
        else if([responder isKindOfClass:[UITableView class]])
        {
            UITableView* tv = (UITableView*)responder ;
            if ([mControllArray indexOfObject:tv] == NSNotFound)
            {
                //NSLog(@"getTable") ;
                tv.scrollEnabled = NO ;
                if (!(tv.contentOffset.x == 0 && tv.contentOffset.y == 0))
                {
                    isSetContentOffset = YES ;
                    mContentRectZero = tv.contentOffset ;
                }
                [mControllArray addObject:tv] ;
            }
        }
        else if([responder isKindOfClass:[UIWebView class]])
        {
            UIWebView* wv = (UIWebView*)responder ;
            if ([mControllArray indexOfObject:wv] == NSNotFound)
            {
                //NSLog(@"getWeb") ;
                wv.scrollView.scrollEnabled = NO ;
                if (!(wv.scrollView.contentOffset.x == 0 && wv.scrollView.contentOffset.y == 0))
                {
                    //isSetContentOffset = YES ;
                    //mContentRectZero = wv.scrollView.contentOffset ;
                }
                [mControllArray addObject:wv] ;
            }
        }
    }
    
    if (!isSetContentOffset)
    {
        mContentRectZero = CGPointZero ;
    }
}

@end
