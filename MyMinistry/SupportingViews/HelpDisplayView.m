//
//  HelpDisplayView.m
//  MyMinistry
//
//  Created by Koji Murata on 25/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "HelpDisplayView.h"

@interface HelpDisplayView ()

@end

@implementation HelpDisplayView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //if it has inputVideo
    if (_inputDat) {
        _inputDat = [_inputDat stringByReplacingOccurrencesOfString:@"$VID" withString:@""];
        [self initializeVideoWithName:_inputDat];
    }
    
}

- (void)initializeVideoWithName:(NSString *)videoName {
    //smartBarVid.m4v
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:videoName ofType:nil]];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    videoLayer.frame = CGRectMake(0, 0, _shortDisplayView.frame.size.width, _shortDisplayView.frame.size.height);
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_shortDisplayView.layer addSublayer:videoLayer];
    [_shortDisplayView.layer setMasksToBounds:YES];
    [_shortDisplayView.layer setCornerRadius:20.0f];
    [self.avPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
}
- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    //[player seekToTime:kCMTimeZero];
    [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        finished = true;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
