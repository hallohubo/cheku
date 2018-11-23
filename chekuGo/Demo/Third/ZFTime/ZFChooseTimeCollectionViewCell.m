//
//  ZFChooseTimeCollectionViewCell.m
//  slyjg
//
//  Created by 王小腊 on 16/3/9.
//  Copyright © 2016年 王小腊. All rights reserved.
//

#define CYBColorGreen [UIColor colorWithRed:78/255.0 green:147/255.0 blue:232/255.0 alpha:1]
#define YJCorl(a,b,c) [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:1]
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height

#import "ZFChooseTimeCollectionViewCell.h"

@implementation ZFChooseTimeCollectionViewCell

- (void)awakeFromNib {
    // Initialization code

}

- (void)updateDay:(NSArray*)number outDate:(NSArray*)outdateArray selected:(NSInteger)judge currentDate:(NSArray*)newArray;
{
    NSInteger p_2 =[number componentsJoinedByString:@""].intValue;
    NSInteger p_1 =[newArray componentsJoinedByString:@""].intValue;
    if ([number[2] integerValue]>0) {
        
        if (p_1>p_2){
            
            self.number.backgroundColor = [UIColor whiteColor];
            self.number.textColor =YJCorl(200, 200, 200);
            self.stateLabel.text = @"";
            self.userInteractionEnabled = NO;
            
        }else{
            
            self.number.backgroundColor = [UIColor whiteColor];
            self.number.textColor =[UIColor grayColor];
            self.stateLabel.text = @"";
            self.userInteractionEnabled = YES;
        }
        
    }else{
        
        self.number.backgroundColor = [UIColor whiteColor];
        self.number.textColor =[UIColor whiteColor];
        self.stateLabel.text = @"";
        self.userInteractionEnabled = NO;
    }


    if (outdateArray.count>0) {
        
        NSInteger p_0 =[outdateArray componentsJoinedByString:@""].intValue;
        
        if (p_0 == p_2){
            self.number.backgroundColor = CYBColorGreen;
            self.number.textColor = [UIColor whiteColor];
            self.stateLabel.text = @"出团";
        }
        
        if (judge>0) {
            
            if (p_0 == judge && p_2 == judge) {
                
                self.number.backgroundColor = CYBColorGreen;
                self.number.textColor = [UIColor whiteColor];
                self.stateLabel.text = @"出团 返团";
                
            }else if(p_2 == judge ){
                
                self.number.backgroundColor = CYBColorGreen;
                self.number.textColor = [UIColor whiteColor];
                self.stateLabel.text = @"返团";
            }
            
            
            if (p_2<judge && p_2>p_0) {
                
                self.number.backgroundColor = [UIColor whiteColor];
                self.number.textColor = CYBColorGreen;
                self.stateLabel.text = @"";
            }
        }
    }
    
    if ([number[2] integerValue]>=10) {
        
     self.number.text = [NSString stringWithFormat:@"%@",number[2]];
        
    }else{
    
     NSString*str =[NSString stringWithFormat:@"%@",number[2]];
      self.number.text = [str stringByReplacingOccurrencesOfString:@"0" withString:@""];
    }
    self.currentArray = number;


}

@end
