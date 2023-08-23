//
//  ImageViewer.h
//  MyMinistry
//
//  Created by Koji Murata on 14/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewer : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareAction;
@property (strong, nonatomic) IBOutlet UINavigationItem *viewNavBar;

@end
