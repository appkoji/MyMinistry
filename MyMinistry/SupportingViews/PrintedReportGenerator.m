//
//  PrintedReportGenerator.m
//  MyMinistry
//
//  Created by Koji Murata on 14/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "PrintedReportGenerator.h"
#import "SubmitScene.h"

@interface PrintedReportGenerator ()

@end

@implementation PrintedReportGenerator



- (UIImage *)generatePrintedReport {
    
    UIImage *generatedImage;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(490, 370), YES, 2.0);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    generatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"Creating image bounds:%@ withinContext %@", [NSValue valueWithCGRect:self.view.bounds], self.view.layer);
    
    UIGraphicsEndImageContext();
    
    
    return generatedImage;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    
    
    
    // populate all datas at once
    [_prgLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull disp, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //values to be added
        if ([disp.accessibilityLabel isEqualToString:@"nameVal"]) {
            if ([save objectForKey:@"userDat-name"]) {
                [disp setText:[save objectForKey:@"userDat-name"]];
            } else {
                [disp setText:[self localizedText:@"nullName"]];
            }
        }
        
        if ([disp.accessibilityLabel isEqualToString:@"monthVal"]) {
            [disp setText:[_parent reportingMonth]];
        }
        
        if ([disp.accessibilityLabel isEqualToString:@"pubsVal"]) {
            [disp setText:[[[_parent inputData] objectForKey:@"tot-pubs"] stringValue]];
        } if ([disp.accessibilityLabel isEqualToString:@"vidsVal"]) {
            [disp setText:[[[_parent inputData] objectForKey:@"tot-vids"] stringValue]];
        } if ([disp.accessibilityLabel isEqualToString:@"hoursVal"]) {
            //        [theCell.valueDisplay setText:[self timeFormatted:[[_inputData objectForKey:@"tot-hours"] intValue]]];
            [disp setText:[self timeFormatted:[[[_parent inputData] objectForKey:@"tot-hours"] intValue]]];
        } if ([disp.accessibilityLabel isEqualToString:@"rvsVal"]) {
            [disp setText:[[[_parent inputData] objectForKey:@"tot-rvs"] stringValue]];
        } if ([disp.accessibilityLabel isEqualToString:@"bssVal"]) {
            [disp setText:[[[_parent inputData] objectForKey:@"tot-bss"] stringValue]];
        }
        
        if ([disp.accessibilityLabel isEqualToString:@"notesVal"]) {
            [disp setText:[_parent editingTextView].text];
        }
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)timeFormatted:(int)unformattedTime {
    // input unformattedTime is in minutes.
    // convert to seconds first!
    
    int totalSeconds = unformattedTime*60;
    
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
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

@end
