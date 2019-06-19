//
//  Tools.m
//  PluginDylib
//
//  Created by 门超 on 2019/6/18.
//  Copyright © 2019 BGY. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+ (NSString *)dateString{
    NSDate *date = [[NSDate alloc]init];
    return  [date description];
}

+ (void)showLog{
    NSLog(@"showLog...");
}

@end
