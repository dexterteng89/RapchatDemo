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
#import "SVProgressHUD.h"

// Offset for sliding view up when keyboard appears
#define kOFFSET_FOR_KEYBOARD 105.0

@interface BRLoginViewController ()
{
    NSArray *userArray;
//    MBProgressHUD *hud;
    
    BOOL _loginAttemped;
    BOOL _signUpMode;
}
- (BOOL)validateFormFields;
- (void)validateAndLogin;
- (void)toggleEmailFieldHidden;
- (void)keyboardWillShow;
- (void)keyboardWillHide;
- (void)setSlideViewUp:(BOOL)movedUp;

@end

@implementation BRLoginViewController
@synthesize usernameField, passwordField, emailField, footerButton,
            passwordLabel, emailLabel, usernameLabel;

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
    
    _signUpMode = YES;
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

- (void)signUp
{
    NSLog(@"SignUp called");
    
    [SVProgressHUD showWithStatus:@"  SIGNING UP  "];
    
    [[BRHTTPClient sharedClient] signUpWithHandle:usernameField.text
      email:emailField.text
      password:passwordField.text
      success:^(AFJSONRequestOperation *operation, id responseObject) {
        NSLog(@"[LVC] Sign Up successful");
        [SVProgressHUD dismiss];

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 500) {
            [SVProgressHUD showErrorWithStatus:@"Something went wrong!"];
        } else {
            NSLog(@"Sign up: shit done failed");
            
            NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:0
                                                                   error:nil];
            
            NSLog(@"failure JSON: %@", json);
            NSString *errorMessage = [[[json objectForKey:@"info"] objectForKey:@"email"] lastObject];
            NSLog(@"errorMessage: %@", errorMessage);
            
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
}

- (void)signIn
{
    NSLog(@"SignIn called");

    [SVProgressHUD showWithStatus:@"  LOGGING IN  "];
    
    [[BRHTTPClient sharedClient] signInWithHandle:usernameField.text password:passwordField.text success:^(AFJSONRequestOperation *operation, id responseObject) {
        //TODO: dismiss HUD on success
        NSLog(@"[LVC] sign in successful");
        [SVProgressHUD dismiss];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        NSData *jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:0
                                                               error:nil];
        NSString *errorMessage = [json objectForKey:@"error"];
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}


- (IBAction)toggleSignupMode:(id)sender
{
    if (_signUpMode) {
        [self toggleEmailFieldHidden];
        
        [footerButton setTitle:@"DON'T HAVE AN ACCOUNT?" forState:UIControlStateNormal];
        usernameLabel.text = @"ENTER YOUR RAPPER NAME";
        
        _signUpMode = NO;
    } else {
        [self toggleEmailFieldHidden];
        
        [footerButton setTitle:@"ALREADY HAVE AN ACCOUNT?" forState:UIControlStateNormal];
        usernameLabel.text = @"CREATE YOUR RAPPER NAME";
        
        _signUpMode = YES;
    }
    
}

- (void)toggleEmailFieldHidden
{
    float kOFFSET_FOR_TEXTFIELDS = 73.0;
    
    if (_signUpMode) {
        // hide email field and slide password field up
        
        [UIView animateWithDuration:0.25f animations:^{
            emailField.alpha = 0;
            emailLabel.alpha = 0;
            
            CGRect passFieldFrame = passwordField.frame;
            passFieldFrame.origin.y -= kOFFSET_FOR_TEXTFIELDS;
            passwordField.frame = passFieldFrame;
            
            CGRect passLabelFrame = passwordLabel.frame;
            passLabelFrame.origin.y -= kOFFSET_FOR_TEXTFIELDS;
            passwordLabel.frame = passLabelFrame;
            
        } completion:nil];
        [UIView commitAnimations];
    } else {
        // show email field and move password field down
        [UIView animateWithDuration:0.25f animations:^{
            CGRect passFieldFrame = passwordField.frame;
            passFieldFrame.origin.y += kOFFSET_FOR_TEXTFIELDS;
            passwordField.frame = passFieldFrame;
            
            CGRect passLabelFrame = passwordLabel.frame;
            passLabelFrame.origin.y += kOFFSET_FOR_TEXTFIELDS;
            passwordLabel.frame = passLabelFrame;
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05f animations:^{
                emailField.alpha = 1;
                emailLabel.alpha = 1;
            }];
        }];
        [UIView commitAnimations];
        
    }
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // If form empty, return key will jump to next field. If login was already 
    // attempted and failed, return key will become "GO" button for all fields
    
    if (textField == self.usernameField) {
        if (!_loginAttemped) {
            if (_signUpMode)
                [self.emailField becomeFirstResponder];
            else
                [self.passwordField becomeFirstResponder];
        } else {
            [self validateAndLogin];
        }
    } else if (textField == self.emailField) {
        if (!_loginAttemped) 
            [self.passwordField becomeFirstResponder];
        else
            [self validateAndLogin];
    } else if (textField == self.passwordField) {
        [self validateAndLogin];
    }
    
    return NO;
}

- (void)validateAndLogin
{
    // Validate the form fields, and if valid, call appropriate login method
    
    if ([self validateFormFields]) {
        NSLog(@"Form Valid");
        //log in
        if (_signUpMode) {
            [self signUp];
        } else {
            [self signIn];
        }
        
    } else {
        NSLog(@"Form NOT Valid");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something's wrong!"
                                                        message:@"RULES: Name must be 3-15 characters, no spaces. Email must be valid. Password must be more than 5 characters"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        _loginAttemped = YES;
        self.emailField.returnKeyType = UIReturnKeyGo;
        self.usernameField.returnKeyType = UIReturnKeyGo;
    }
}

- (BOOL)validateFormFields
{
    BOOL handleValid, passwordValid, emailValid;
    
    NSString *handleRegex = @"[a-zA-Z0-9_]{3,15}";
    NSPredicate *handleTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", handleRegex];
    handleValid = [handleTest evaluateWithObject: usernameField.text];

    NSString *emailRegex = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    emailValid = [emailTest evaluateWithObject: emailField.text];

    passwordValid = passwordField.text.length >= 6;
    
    if (_signUpMode) {
        if (handleValid && emailValid && passwordValid) 
            return YES;
    } else {
        if (handleValid && passwordValid)
            return YES;
    }
    
    return NO;
}

#pragma mark - Translate View

// Move view up when keyboard appears so form is not hidden

- (void)keyboardWillShow
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setSlideViewUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setSlideViewUp:NO];
    }
}

- (void)keyboardWillHide
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setSlideViewUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setSlideViewUp:NO];
    }
}

-(void)setSlideViewUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
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
