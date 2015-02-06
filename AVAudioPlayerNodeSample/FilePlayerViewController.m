//
//  FilePlayerViewController.m
//  AVAudioPlayerNodeSample
//
//  Created by hiraya.shingo on 2015/02/06.
//  Copyright (c) 2015年 Shingo Hiraya. All rights reserved.
//

#import "FilePlayerViewController.h"

@import AVFoundation;

@interface FilePlayerViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation FilePlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.engine = [AVAudioEngine new];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loop.m4a" ofType:nil];
    self.audioFile = [[AVAudioFile alloc] initForReading:[NSURL fileURLWithPath:path]
                                                   error:nil];
    
    self.audioPlayerNode = [[AVAudioPlayerNode alloc] init];
    [self.engine attachNode:self.audioPlayerNode];
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:mixerNode
                  format:self.audioFile.processingFormat];
    
    // Start the engine.
    NSError *error;
    [self.engine startAndReturnError:&error];
    if (error) {
        NSLog(@"error:%@", error);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

- (void)play
{
    [self.audioPlayerNode scheduleFile:self.audioFile
                                atTime:nil
                     completionHandler:nil];
    [self.audioPlayerNode play];
}

- (IBAction)didTapPlayButton:(id)sender
{
    if (self.audioPlayerNode.isPlaying) {
        [self.audioPlayerNode stop];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [self play];
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)didChangeVolumeSliderValue:(id)sender
{
    float value = ((UISlider *)sender).value;
    [self.engine mainMixerNode].outputVolume = value;
}

- (IBAction)didChangePanSliderValue:(id)sender
{
    float value = ((UISlider *)sender).value;
    self.audioPlayerNode.pan = value;
}

@end
