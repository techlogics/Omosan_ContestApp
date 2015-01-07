//
//  AppDelegate.m
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard;   // StoryBoardの型宣言
    NSString * storyBoardName;  // StoryBoardの名称設定用
    
    // 機種の取得
    NSString *modelname = [ [ UIDevice currentDevice] model];
    
    // iPadかどうか判断する
    if ( ![modelname hasPrefix:@"iPad"] ) {
        // Windowスクリーンのサイズを取得
        CGRect r = [[UIScreen mainScreen] bounds];
        // 縦の長さが480の場合、古いiPhoneだと判定
        if(r.size.height == 480){
            // NSLog(@"Old iPhone");
            storyBoardName = @"Main2";
        }else{
            // NSLog(@"New iPhone");
            storyBoardName =@"Main";
        }
    }else{
        // NSLog(@"iPad");
        storyBoardName =@"Main2";
    }
    // StoryBoardのインスタンス化
    storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    
    // 画面の生成
    UIViewController *mainViewController = [storyboard instantiateInitialViewController];
    
    // ルートウィンドウにひっつける
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
