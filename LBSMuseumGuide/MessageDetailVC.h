//
//  MessageDetailVC.h
//  LBSMuseumGuide
//
//  Created by CReW on 2014/9/3.
//  Copyright (c) 2014年 udndigital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MessageDetailVC : UIViewController<UITextViewDelegate>

@property (nonatomic, weak)PFObject *targetObj;

@end
