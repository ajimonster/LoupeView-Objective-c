# LoupeView-Objective-c

表示中のViewの一部をルーペのように拡大表示する機能を自作しました。

タッチをした地点から、指を離すまでルーペ用のビューが表示される仕様です。

読み物系のUIはもちろん、ほかにも面白い使い方がありそうです。


簡単に組み込めることを前提に作ったので,基本的にプロパティのBOOLでほとんど管理できます。
ルーペを表示している間の処理をしっかり書けば、スクロールやテーブルの上でも使用可能です。 


# 実装例
```
LoupeObject* loupeObj = [[ LoupeObject alloc ] init] ;

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{ 
	if (!loupeObj.isLoupeMode)
	{
		loupeObj.isLoupeMode = YES ;
		[ loupeObj makeLoupeImageFromView:self withTouchPoint:[touch locationInView:self]] ;
	}
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	if (loupeObj.isLoupeMode)
	{
		[ loupeObj makeLoupeImageFromView:self withTouchPoint:[touch locationInView:self]] ;
	}
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	loupeObj.isLoupeMode = NO ;
}
```
