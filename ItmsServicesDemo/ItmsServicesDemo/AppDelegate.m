//
//  AppDelegate.m
//  ItmsServicesDemo
//
//  Created by zhuge.zzy on 12/4/15.
//  Copyright © 2015 arbullzhang. All rights reserved.
//

#import "AppDelegate.h"
#import "XMLReader.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define VERSION_ADDRESS @"https://raw.githubusercontent.com/arbullzhang/itmsServicesDemo/master/ItmsServicesDemo.xml"

@interface AppDelegate ()
{
    NSDictionary *resultDic;
    NSOperationQueue *_operationQueue;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
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
    
    [self checkUpdate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//////////////////////////////////////////////////////////////////////////////////////////////
///  check update

- (void)checkUpdate{
    
    NSURL *url = [NSURL URLWithString:VERSION_ADDRESS];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _operationQueue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:_operationQueue completionHandler:^(NSURLResponse *response, NSData *resultData, NSError *connectionError)
    {
        NSHTTPURLResponse * httpResp = (NSHTTPURLResponse*)response;
        if(httpResp && [httpResp statusCode] == 200)
        {
            NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
            NSError *parseError = nil;
            NSDictionary *resultDictionaryTemp = [XMLReader dictionaryForXMLString:resultString error:&parseError];
            resultDic = (NSDictionary *)[resultDictionaryTemp objectForKey:@"info"];
            NSString *newVersionIDStr = [(NSDictionary *)[resultDic objectForKey:@"version"] objectForKey:@"text"];
            
            // local version information
            NSUserDefaults *versionDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *localDic =[[NSBundle mainBundle] infoDictionary];
            
            NSString *currentVersionIDStr =[localDic objectForKey:@"CFBundleVersion"];
            if(!currentVersionIDStr)
            {
                [versionDefaults setObject:@"1.0" forKey:@"version"];
            }
            else
            {
                if([currentVersionIDStr compare:newVersionIDStr] == NSOrderedAscending)
                {
                    [versionDefaults setObject:newVersionIDStr forKey:@"version"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@""
                                                                         message:@"检测到最新版本，请更新！"
                                                                        delegate:self
                                                               cancelButtonTitle:@"立即更新"
                                                               otherButtonTitles:@"下次再说", nil];
                        [alert show];
                        
                    });
                    
                }
            }
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // download and install new version
        {
            NSString* newVersionURLStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [(NSDictionary *)[resultDic objectForKey:@"url"] objectForKey:@"text"]];
            if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.1"))
            {
                newVersionURLStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [(NSDictionary *)[resultDic objectForKey:@"httpurl"] objectForKey:@"text"]];
            }
            NSURL *url = [NSURL URLWithString:newVersionURLStr];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
        case 1:
            break;
        default:
            break;
    }
}

@end
