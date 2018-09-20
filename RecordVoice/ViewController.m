//
//  ViewController.m
//  RecordVoice
//
//  Created by shenhua on 2018/9/18.
//  Copyright © 2018年 RWN. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"




@interface ViewController ()





@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
}





-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    SecondViewController * second =[[SecondViewController alloc] init];
    [self presentViewController:second animated:YES completion:nil];
    
}







@end
