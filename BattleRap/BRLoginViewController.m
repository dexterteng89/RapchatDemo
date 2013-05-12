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

#define kOFFSET_FOR_KEYBOARD 105.0

@interface BRLoginViewController ()
{
    NSArray *userArray;
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
    
    // TODO: progress HUD
    
    [[BRHTTPClient sharedClient] signUpWithHandle:usernameField.text
      email:emailField.text
      password:passwordField.text
      success:^(AFJSONRequestOperation *operation, id responseObject) {
        //TODO: dismiss HUD on success
                                              
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        
        //TODO: update HUD to show failure
        
        NSString *message = [[operation responseJSON] objectForKey:@"error_description"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];        
    }];
}

- (void)signIn
{
    NSLog(@"SignIn called");
    
    // TODO: progress HUD
    
    [[BRHTTPClient sharedClient] signInWithHandle:usernameField.text password:passwordField.text success:^(AFJSONRequestOperation *operation, id responseObject) {
        //TODO: dismiss HUD on success
        NSLog(@"[LVC] sign in successful");

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        NSString *message = [[operation responseJSON] objectForKey:@"error_description"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
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
    if (_signUpMode) {
        // hide email field and slide password field up
        
        [UIView animateWithDuration:0.25f animations:^{
            emailField.alpha = 0;
            emailLabel.alpha = 0;
            
            CGRect passFieldFrame = passwordField.frame;
            passFieldFrame.origin.y -= 76.0;
            passwordField.frame = passFieldFrame;
            
            CGRect passLabelFrame = passwordLabel.frame;
            passLabelFrame.origin.y -= 76.0;
            passwordLabel.frame = passLabelFrame;
            
        } completion:nil];
        [UIView commitAnimations];
    } else {
        // show email field and move password field down
        [UIView animateWithDuration:0.25f animations:^{
            CGRect passFieldFrame = passwordField.frame;
            passFieldFrame.origin.y += 76.0;
            passwordField.frame = passFieldFrame;
            
            CGRect passLabelFrame = passwordLabel.frame;
            passLabelFrame.origin.y += 76.0;
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
