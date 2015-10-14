//
//  SPLineTool.h
//  test
//
//  Created by smallpay on 15/10/13.
//  Copyright © 2015年 xmg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPLinePoint : NSObject
{
@public
    double X;
    double Y;
}
@property(nonatomic,readwrite) double X;
@property(nonatomic,readwrite) double Y;
@end

typedef NS_ENUM(NSInteger,SPLineStyle)
{
    SPLineStyle_0,//采样点无规律，要求生成闭合曲线
    SPLineStyle_1,//采样点x坐标连续
    SPLineStyle_2//采样点x坐标连续
};

@interface SPLineTool : NSObject

//pList 为SPLinePoint离散点数组，SM是在两个点中间插入点的数目，返回值为SPLinePoint数组
+(NSArray *)SPLine:(NSArray *)points SM:(int)SM style:(SPLineStyle) style;
@end
