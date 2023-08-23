//
//  AppDelegate.h
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSMutableArray <UIViewController *> *viewWithBg;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImage *commonBGImages;

- (UIImage *)updateBGImageEntry;
- (void)bgImageDidUpdate;
- (void)displayNotification;

@end

