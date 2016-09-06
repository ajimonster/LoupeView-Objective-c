//
//  LoupeView.h
//
//
//  Created by ajimonster on 2015/12/09.
//
//

#import <UIKit/UIKit.h>


// ---------------------------------------------------------------------------------
// 画面に表示するもの
// ---------------------------------------------------------------------------------
@interface LoupeView : UIView
{
    //枠とか画像使うなら...
    //UIImage*        loupeImage ;
    BOOL            isVertical ;        //デバイスの向き
    
    CGPoint         contentRectZero ;   //画面上の0,0
    float           loupeWidth ;        //ルーペのサイズ
    UIImageView*    loupeViewImage ;    //拡大して表示する部分
    
}

- (id)init ;

@end



// ---------------------------------------------------------------------------------
// 管理用
// ---------------------------------------------------------------------------------
@interface LoupeObject : NSObject
{
    LoupeView*              mLoupeView ;
    NSMutableArray*         mControllArray ;
    CGPoint                 mContentRectZero ;
}

//ルーペを出しているかどうか
@property(nonatomic,assign)BOOL isLoupeMode ;

- (id)init ;
- (void)removeLoupeView ;

- (void)makeLoupeImageFromView:(UIView*)view
                withTouchPoint:(CGPoint)point ;


@end