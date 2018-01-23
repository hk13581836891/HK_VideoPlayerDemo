//
//  VideoListModel.m
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import "VideoListModel.h"
#import "MJExtension.h"

@implementation VideoListModel

+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID":@"id"};
}
@end
