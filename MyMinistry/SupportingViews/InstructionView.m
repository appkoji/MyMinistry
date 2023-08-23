//
//  InstructionView.m
//  MyMinistry
//
//  Created by Koji Murata on 15/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "InstructionView.h"

@interface InstructionView ()

@end

@implementation InstructionView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewController loaded");
    
    [_titleLabel setText:_inputTitleString];
    [_descriptionLabel setText:_inputDescriptionString];
    [_backgroundImage setImage:_inputBackgroundImage];
    
    //prepare video to play inside the videoview
    NSLog(@"inputVideoUrl %@", _inputVideoUrl);
    if (_videoDisplayView && _inputVideoUrl) {
        [self initializeVideo];
    }
    
}

- (void)initializeVideo {
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"smartBarVid.m4v" ofType:nil]];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    //AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    videoLayer.frame = CGRectMake(0, 0, _videoDisplayView.frame.size.width, _videoDisplayView.frame.size.height);
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_videoDisplayView.layer addSublayer:videoLayer];
    
    [_videoDisplayView.layer setMasksToBounds:YES];
    [_videoDisplayView.layer setCornerRadius:20.0f];
    
    [self.avPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];

}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)retrieveBgImg {
    // load basicImage/existing image when yesterday's image is not available, or when internet is not available for download.
    
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    
    if ([save objectForKey:@"bgImage"]) { //search if path exists
        //if yes, read file from path
        [_backgroundImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[save objectForKey:@"bgImage"]]]];
    } else {
        //when daily system image is not available, use default system image
        [_backgroundImage setImage:[UIImage imageNamed:@"mibg-01.png"]];
    }
    
}

@end
