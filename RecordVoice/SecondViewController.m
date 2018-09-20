//
//  SecondViewController.m
//  RecordVoice
//
//  Created by shenhua on 2018/9/20.
//  Copyright © 2018年 RWN. All rights reserved.
//

#import "SecondViewController.h"
#import "RWNAudioRecorderView.h"

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setUI];
    // Do any additional setup after loading the view.
}

#pragma mark - Private Methods
- (void)setUI
{
    
    RWNAudioRecorderView *audio =[[RWNAudioRecorderView alloc] initWithFrame:CGRectMake(0,64, KScreenWidth, 200)];
    audio.backgroundColor=[UIColor yellowColor];
    [self.view addSubview:audio];
    
}//绘制UI

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self dismissViewControllerAnimated:YES completion:nil];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
