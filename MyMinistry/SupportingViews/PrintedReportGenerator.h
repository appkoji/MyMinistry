//
//  PrintedReportGenerator.h
//  MyMinistry
//
//  Created by Koji Murata on 14/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintedReportGenerator : UIViewController

// all dynamic uilabel properties
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *prgLabels;

@property (weak, nonatomic) id parent;

- (UIImage *)generatePrintedReport;

@end
