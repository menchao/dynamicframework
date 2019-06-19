//
//  PluginDylibViewController.m
//  PluginDylib
//
//  Created by 门超 on 2019/6/18.
//  Copyright © 2019 BGY. All rights reserved.
//

#import "PluginDylibViewController.h"
#import "Tools.h"

@interface PluginDylibViewController ()

@end

@implementation PluginDylibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //调用Tool类方法
    NSLog(@"date: %@", [Tools  dateString]) ;
   
    //关闭
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 100, 60, 30);
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
@end
