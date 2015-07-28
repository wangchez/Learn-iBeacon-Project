//
//  MessageDetailVC.m
//  LBSMuseumGuide
//
//  Created by CReW on 2014/9/3.
//  Copyright (c) 2014年 udndigital. All rights reserved.
//

#import "MessageDetailVC.h"

@interface MessageDetailVC ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scollView;

@end

@implementation MessageDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 64);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(saveMessage:)];
    
    
    self.navigationItem.rightBarButtonItem = saveItem;
    
    // Do any additional setup after loading the view.
    PFObject *message = self.targetObj[@"comment"];
    
    if(message != nil)
    {
        NSLog(@"Loading comment.");
        
        [message fetchIfNeededInBackgroundWithBlock:^(PFObject *post, NSError *error) {
            NSString *something = post[@"comment"];
            // do something with your title variable
            self.messageView.text = something;
        }];
    }
    else
    {
        NSLog(@"Create empty comment.");
        
        PFObject *myMessage = [PFObject objectWithClassName:@"Message"];
        
        self.targetObj[@"comment"] = myMessage;
    }
    
}

- (void)saveMessage:(id)sender
{
    PFObject *message = [self.targetObj objectForKey:@"comment"];
    message[@"comment"] = self.messageView.text;

    
    [self.targetObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSString *returnStr = succeeded ? @"儲存成功" : @"儲存失敗";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:returnStr delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // check \n
    if([text isEqual:@"\n"])
	{
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(-kbRect.size.height, 0.0, kbRect.size.height, 0.0);
    self.scollView.contentInset = contentInsets;
    self.scollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.messageView.frame.origin) ) {
        [self.scollView scrollRectToVisible:self.messageView.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scollView.contentInset = contentInsets;
    self.scollView.scrollIndicatorInsets = contentInsets;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
