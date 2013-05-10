//
//  BRLoginViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRBattleStore.h"
#import "BRHTTPClient.h"

#define kOFFSET_FOR_KEYBOARD 130.0

@interface BRLoginViewController ()
{
    NSArray *userArray;
    BOOL _formValid;
}
- (BOOL)validateForm;

@end

@implementation BRLoginViewController
@synthesize usernameField, passwordField, emailField;

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"LoginView" bundle:nil];
    if (self) {
        usernameField.delegate = self;
        emailField.delegate = self;
        passwordField.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _formValid = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)login:(id)sender {
    
    // Validate login
    
    // TODO: progress HUD
    
//    [[BRHTTPClient sharedClient] 
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)postUserInformation
{
    NSString *userHandle = [[NSUserDefaults standardUserDefaults] objectForKey:@"handle"];
    
    NSDictionary *postDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:userHandle, @"handle", nil];
    
    NSError *error;
    
    NSData *file1Data = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://rapchat-staging.herokuapp.com/users"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [file1Data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: file1Data];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    BRBattleStore *battleStore = [BRBattleStore sharedStore];
    [battleStore populateUsers];

}

#pragma mark - UITextViewDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        if ([self validateForm]) {
            NSLog(@"Form Valid");
            //log in
        } else {
            NSLog(@"Form NOT Valid");
            //pop alert
        }
    }
    
    return NO;
}

//- (BOOL)textField:(UITextField *)textField
//    shouldChangeCharactersInRange:(NSRange)range
//                replacementString:(NSString *)string
//{
//    //When entering password, validate form
//    if (textField == self.passwordField) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self validateForm];
//        });
//    }
//	return YES;
//}

- (BOOL)validateForm
{
    BOOL handleAndPasswordValid = usernameField.text.length >= 1 &&
                                  passwordField.text.length >= 6;
    NSString *emailRegex = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL emailValid = [emailTest evaluateWithObject:emailField.text];
    
    if (handleAndPasswordValid && emailValid) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Translate View

// Move view up when keyboard appears so form is not hidden

- (void)keyboardWillShow
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

- (void)keyboardWillHide
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
