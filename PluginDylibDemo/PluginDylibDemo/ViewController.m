//
//  ViewController.m
//  PluginDylibDemo
//
//  Created by 门超 on 2019/6/18.
//  Copyright © 2019 BGY. All rights reserved.
//


#import "ViewController.h"
#import <dlfcn.h>

#import  <SSZipArchive/SSZipArchive.h>

@interface ViewController ()
   
@property (weak, nonatomic) NSBundle *bundle;
    
@end
static void *libHandle = NULL;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
#if 1 //模拟器下载framework到沙盒
    //framework不能从程序中拷贝到沙盒，只能改为zip包
  //[self zipToFramework];
   [self copyFrameworkToDocument];
  [self unzipZipToFramework];
#endif
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //方式1：flopen加载
      [self dlopenLoadDylib];
        
        //方式2：Bundle加载
        // [self loadFrameWorkByBundle];
    });
    
}
  
//copy 资源文件到 沙盒
- (void)copyFrameworkToDocument{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    NSLog(@"%@",docPath);
    NSString * str = [[NSBundle mainBundle] pathForResource:@"PluginDylib2" ofType:@"zip"];
     NSData *data = [NSData dataWithContentsOfFile:str];
    
  
    NSString *filePath2 = [docPath stringByAppendingPathComponent:@"PluginDylib.zip"];
 
    [data writeToFile:filePath2 atomically:YES];
    
}

- (void)unzipZipToFramework {
    //    if (!_zipPath) {
    //        return;
    //    }
    //    NSString *unzipPath = [self tempUnzipPath];
    //    NSLog(@"Unzip path: %@", unzipPath);
    //    if (!unzipPath) {
    //        return;
    //    }
    //   NSString *password = _passwordField.text;
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *zipPath = [docPath stringByAppendingPathComponent:@"PluginDylib.zip"];
    
    
    NSString *unzipPath = [docPath stringByAppendingPathComponent:@"PluginDylib.framework"];
    
    
    
    BOOL success = [SSZipArchive unzipFileAtPath:zipPath
                                   toDestination:unzipPath
                              preserveAttributes:YES
                                       overwrite:YES
                                  nestedZipLevel:0
                                        password:nil
                                           error:nil
                                        delegate:nil
                                 progressHandler:nil
                               completionHandler:nil];
    if (success) {
        NSLog(@"Success unzip");
        
    } else {
        NSLog(@"No success unzip");
        
    }
    
    
}
    
    
//framework 压缩到 PluginDylib2.zip
- (void)zipToFramework {
    NSString *zipPath = @"/Users/menchao/BGY/插件化开发/PluginDylibDemo/PluginDylibDemo/PluginDylib.framework";
    NSString *outZipPath = @"/Users/menchao/BGY/插件化开发/PluginDylibDemo/PluginDylibDemo/PluginDylib2.zip";
    BOOL success = [SSZipArchive createZipFileAtPath: outZipPath
                             withContentsOfDirectory:zipPath
                                 keepParentDirectory:NO
                                    compressionLevel:-1
                                            password: nil
                                                 AES:YES
                                     progressHandler:nil];
    if (success) {
        NSLog(@"Success zip");
      
    } else {
        NSLog(@"No success zip");
       
    }
}
    
    


    
- (IBAction)excuteFrameworkMethod:(id)sender {
    [self callMethodOfFrameWork];
}
    
    
- (void)showDialog:(NSString *)content{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    UIViewController *rootViewController =    [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}
    
#pragma mark - dlopen
    
- (void) dlopenLoadDylib {
    //从服务器去下载并且存入Documents下,需要定义规则，PluginDylib,然后去加载
    NSString *frameworkPath = [NSString stringWithFormat:@"%@/Documents/PluginDylib.framework/PluginDylib",NSHomeDirectory()];
    libHandle = NULL;
    libHandle = dlopen([frameworkPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
    NSString *str = @"加载动态库失败!";
    if (libHandle == NULL) {
        char *error = dlerror();
        NSLog(@"dlopen error: %s", error);
    } else {
        NSLog(@"dlopen load framework success.");
        str = @"加载动态库成功!";
    }
    [self showDialog:str];
}
    
- (void)callMethodOfFrameWork{
    Class pClass = NSClassFromString(@"PluginDylibViewController");
    if(pClass){
        //事先要知道有什么方法在这个FrameWork中
        id vc = [[pClass alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        
        //由于没有引入相关头文件故通过performSelector调用
       // [object performSelector:@selector(love)];
    }else {
          [self showDialog:@"调用方法失败!"];
    }
}
    
    
    
#pragma mark - NSBundle 加载
    
    //通过Bundle方式加载FrameWork
- (void)loadFrameWorkByBundle {
    //从服务器去下载并且存入Documents下(只要知道存哪里即可),事先要知道framework名字,然后去加载
    NSString *frameworkPath = [NSString stringWithFormat:@"%@/Documents/PluginDylib.framework",NSHomeDirectory()];
    
    NSError *err = nil;
    NSBundle *bundle = [NSBundle bundleWithPath:frameworkPath];
    NSString *str = @"加载动态库失败!";
    if ([bundle loadAndReturnError:&err]) {
        NSLog(@"bundle load framework success.");
        str = @"加载动态库成功!";
        self.bundle = bundle;
    } else {
        NSLog(@"bundle load framework err:%@",err);
    }
    [self showDialog:str];
}
    
    

- (void)unLoadFrameWork{
    if([self.bundle unload]){
        NSLog(@"释放成功!");
    }else{
        NSLog(@"释放失败!");
    }
}
    
- (void)dlcloseFrameWork {
    int result = dlclose(libHandle);
    //为0表示释放成功
    if(result == 0){
        NSLog(@"释放成功!");
    }else{
        NSLog(@"释放失败!");
    }
}
@end
