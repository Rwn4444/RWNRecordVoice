//
//  RWNAudioRecorderView.m
//  RecordVoice
//
//  Created by shenhua on 2018/9/19.
//  Copyright © 2018年 RWN. All rights reserved.
//

#import "RWNAudioRecorderView.h"
#import <AVFoundation/AVFoundation.h>
#import "lame/lame.h"
#import "RWNGCDTime.h"



#define recordPath  @"RWNPath.caf"

@interface RWNAudioRecorderView()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

///录音
@property(nonatomic,strong) AVAudioRecorder* avaudioRecorder;
///播放
@property(nonatomic,strong) AVAudioPlayer * avaudioPlayer;
///session
@property(nonatomic,strong) AVAudioSession *session ;
///mp3
@property(nonatomic,copy) NSString * mp3Str;
///时间
@property(nonatomic,copy) NSString * timeIdentifier;

@end

@implementation RWNAudioRecorderView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(90, 100, 80, 50);
        [btn setTitle:@"录音" forState:UIControlStateNormal];
        [btn setTitle:@"结束录音" forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame=CGRectMake(200, 100, 80, 50);
        [btn1 setTitle:@"播放" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        btn1.backgroundColor = [UIColor redColor];
        btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn1.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [btn1 addTarget:self action:@selector(playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn1];

    }
    return self;
    
}

-(NSString *)timeIdentifier{
    
    if (!_timeIdentifier) {
        _timeIdentifier = [RWNGCDTime RWNTimeNWaitDoTask:^{
            NSLog(@"%s",__func__);
        } interval:1];
    }
    return _timeIdentifier;
}


#pragma mark - Action Methods
- (void)btnAction:(UIButton*)sender
{
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startRecord];
    }else{
       [self stopRecord];
    }
    /*
    switch (sender.tag) {
        case 555:   //录音
            [self startRecord];
            break;
        case 556:   // 暂停
            [self pauaseRecord];
            break;
        case 557:  // 播放
            [self playRecord];
            break;
        case 558: //停止
            [self stopRecord];
            break;
        default:
            break;
    }
     */
}//按钮事件

-(void)playBtnAction:(UIButton *)sender{
    
    [self playRecord];
    
}

#pragma mark --开始录音--
- (void)startRecord
{
    
    if (![self.avaudioRecorder isRecording]) {
        [self SessionInit];
        [self.avaudioRecorder record];
        [RWNGCDTime startTaskWithIdentifier:self.timeIdentifier];
    }
    
}

#pragma mark --暂停录音--
- (void)pauaseRecord
{
    if ([self.avaudioRecorder isRecording]) {
        [self.avaudioRecorder pause];
        [RWNGCDTime suspendTaskWithIdentifier:self.timeIdentifier];
        
    }
}
#pragma mark --停止录音--
- (void)stopRecord
{
    
    //调用这个方法后，直接执行录制完成的代理方法
    [self.avaudioRecorder stop];
    [RWNGCDTime cancaleTaskWithIdentifier:self.timeIdentifier];
    self.timeIdentifier = nil;
    
}

#pragma mark - OverRide Method
- (AVAudioRecorder*)avaudioRecorder
{
    if (!_avaudioRecorder) {
        
        NSError *error = nil;
        _avaudioRecorder = [[AVAudioRecorder alloc]initWithURL:[self getSavePath] settings:[self recordConfigure] error:&error];
        _avaudioRecorder.delegate = self;
        //如果要监控声波则必须设置为YES
        _avaudioRecorder.meteringEnabled = YES;
        // 把录音文件加载到缓冲区
        [_avaudioRecorder prepareToRecord];
        
        if (error) {
            NSAssert(YES, @"录音机初始化失败,请检查参数");
        }
    }
    
    return _avaudioRecorder;
    
}//录音机

- (NSURL*)getSavePath
{
    
    //获取沙盒根目录
    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath =  [homePath stringByAppendingPathComponent:recordPath];
    return [NSURL fileURLWithPath:filePath];
    
}//设置存储路径

- (NSMutableDictionary*)recordConfigure
{
    NSMutableDictionary *configure = [NSMutableDictionary dictionary];
    //设置录音格式
    [configure setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [configure setObject:@8000 forKey:AVSampleRateKey];
    //设置通道
    [configure setObject:@1 forKey:AVNumberOfChannelsKey];
    //设置采样点位数 ，分别 8、16、24、32
    [configure setObject:@8 forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [configure setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //设置录音质量:中等质量
    [configure setObject:@(AVAudioQualityMedium) forKey:AVEncoderAudioQualityKey];
    // ... 其他设置
    return configure;
}//录音配置

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    if (flag) {
        
        NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath =  [homePath stringByAppendingPathComponent:recordPath];
        self.mp3Str = [self audioPCMtoMP3:filePath];
        
    }
    
}

- (NSString *)audioPCMtoMP3:(NSString *)wavPath {
    
    NSString *cafFilePath = wavPath;
    NSString *mp3FilePath = [NSString stringWithFormat:@"%@.mp3",[NSString stringWithFormat:@"%@%@",[cafFilePath substringToIndex:cafFilePath.length - 4],[self getTimestamp]]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil]){
//        NSLog(@"删除原MP3文件");
    }
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 22050.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        return mp3FilePath;
    }
}

- (NSString *)getTimestamp{
    
    NSDate *nowDate = [NSDate date];
    double timestamp = (double)[nowDate timeIntervalSince1970]*1000;
    long nowTimestamp = [[NSNumber numberWithDouble:timestamp] longValue];
    NSString *timestampStr = [NSString stringWithFormat:@"%ld",nowTimestamp];
    return timestampStr;
    
}

- (AVAudioPlayer*)avaudioPlayer
{
    if (!_avaudioPlayer) {
        NSError *error = nil;
        _avaudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:self.mp3Str] error:&error];
        //设置代理
//        _avaudioPlayer.delegate = self;
        //将播放文件加载到缓冲区
        [_avaudioPlayer prepareToPlay];
    }
    return _avaudioPlayer;
}


- (void)playRecord
{
    if (!self.avaudioPlayer.isPlaying) {
        [self.avaudioPlayer play];
    }
}//播放录音


-(void)SessionInit{
    
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [session setActive:YES error:nil];
    }
    self.session = session;
    
}

//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//
//    NSLog(@"%d",flag);
//
//}

//-(void)dealloc{
//
//    NSLog(@"销毁了");
//
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
