//
//  AppDelegate.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

/*
 App Download Link
 https://itunes.apple.com/us/app/smart-ministry/id1358230171?ls=1&mt=8
 https://apple.co/2Hy1xaG
 */

#import "AppDelegate.h"
#import "OverviewScene.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //[application setMinimumBackgroundFetchInterval:10];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Override point for customization after application launch.
    _viewWithBg = [NSMutableArray new];
    //get image from file each time the app has been restarted
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"bgImageData"];
    _commonBGImages = [UIImage imageWithData:imageData];
    
    // request notification authorization : UNMutableNotificationContent
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSLog(@"cannot show notification");
        }
    }];
    
    if (application.applicationIconBadgeNumber > 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
    //check if next month
    NSLog(@"Fetch did happen");
    
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    NSString *thisMonth = [self getMonthYear:[NSDate date]];
    BOOL isNewReport = NO;
    if ([save objectForKey:@"Notification-monthlyReport"]) {
        if (![[save objectForKey:@"Notification-monthlyReport"] isEqualToString:thisMonth]) {
            isNewReport = YES;
        }
    } else {
        //since empty, no monthly reports available yet. Just add entry
        [save setObject:thisMonth forKey:@"Notification-monthlyReport"];
        [save synchronize];
    }
    if (isNewReport == YES) {
        [self displayNotification];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Fetch will finish");
        completionHandler(UIBackgroundFetchResultNewData);
    });
}

- (NSString *)getMonthYear:(NSDate *)returnedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-YYYY"];
    return [dateFormat stringFromDate:returnedDate]; // 06-1993
}

- (void)displayNotification {
    
    NSLog(@"preparing to display notifications");
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [self localizedText:@"fieldServiceSubmissionNotificationTitle"];
    content.body = [self localizedText:@"newReport"];
    content.sound = [UNNotificationSound defaultSound];
    content.badge = [NSNumber numberWithInteger:1];
    
    NSTimeInterval delay = 10;
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:delay repeats:NO];
    NSString *identifier = @"ReportSubmissionNotificationID";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error %@", error);
        }
    }];
    
}

- (NSString *)localizedText:(NSString *)inputIdentifier {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localizedDisplayTexts" ofType:@"plist"]];
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *userLang = @"EN";
    if ([saveData objectForKey:@"userSetting-lang"]) {
        userLang = [saveData objectForKey:@"userSetting-lang"];
    }
    return [[dic objectForKey:inputIdentifier] objectForKey:userLang];
}

- (UIImage *)updateBGImageEntry {
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"bgImageData"];
    _commonBGImages = [UIImage imageWithData:imageData];
    
    // temporary use Nebula
    //_commonBGImages = [UIImage imageNamed:@"projectNebula"];
    
    return _commonBGImages;
}

- (void)bgImageDidUpdate {
    //this method calls all view that requires instant update on the image.
    NSLog(@"APPDELEGATE - bgImageDidUpdate");
    [self updateBGImageEntry];
    
    // call responding methods
    [_viewWithBg enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(executeBackgroundUpdate:)]) {
            OverviewScene *os = (OverviewScene *)obj;
            [os executeBackgroundUpdate:self.commonBGImages];
            //[obj performSelector:@selector(executeBackgroundUpdate:) withObject:_commonBGImages];
        }
    }];
}

- (void)checkIfNewMonth {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
