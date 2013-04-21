//
//  BRBattleStore.m
//  BattleRap
//
//  Created by Dexter Teng on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRBattleStore.h"

@implementation BRBattleStore

+ (BRBattleStore *)sharedStore
{
    static BRBattleStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (int)getFriendIDFromName:(NSString *)friendName
{
    NSArray *theUser = [NSArray arrayWithObjects: @"handle",nil];
    NSDictionary *me = [users dictionaryWithValuesForKeys:theUser];
    NSArray *orderedHandles = [me objectForKey:@"handle"];
    
    for (int i = 0; i < orderedHandles.count; i++)
    {
        if ([[orderedHandles objectAtIndex:i] isEqual:friendName])
        {
            int friendID = [[[users objectAtIndex:i] valueForKey:@"id"] integerValue];
            return friendID;
        }
    }
    return 0;
}

- (void)createBattleWith:(NSString *)friendName
{
    NSNumber *userid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] integerValue]];

    NSNumber *friendID = [NSNumber numberWithInt:[self getFriendIDFromName:friendName]];
    
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc] init];
    
    [postDictionary setValue:@"nil" forKey:@"category"];
    [postDictionary setValue:userid forKey:@"user_id"];
    [postDictionary setValue:friendID forKey:@"friend_id"];
    
    
    NSError *error;
    
    NSData *file1Data = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://rapchat-staging.herokuapp.com/battles"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [file1Data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: file1Data];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

//- (void)updateBattleWith:(NSInteger)battleID andWith:(BRVerse *)verse
//{
//    
//}


- (void)populateBattlesWithArray:(NSMutableArray *)data
{
    battles = data;
}

- (void)populateUsers
{
    NSString *stringAPICall = @"http://rapchat-staging.herokuapp.com/users";
    NSURLRequest* rapchatAPIRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringAPICall]];
    [NSURLConnection sendAsynchronousRequest:rapchatAPIRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^ void (NSURLResponse* myResponse, NSData* myData, NSError* theirError)
     {
         //begin parse method
         users = [self parseDataWithResponse:myResponse andData:myData andError:theirError];
         [self.delegate usersDidFinishPostingUsers:users];
     }];
}

- (id)parseDataWithResponse:(NSURLResponse*)myResponse andData:(NSData*)myData andError:(NSError*)theirError
{
    
    if (theirError)
    {
        NSLog(@"RapChatAPIError: %@", [theirError description]);
        return nil;
    }
    else
    {
        NSError *jsonError;
        NSArray *arrayFromJSON = (NSArray *)[NSJSONSerialization JSONObjectWithData:myData
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:&jsonError];
        return arrayFromJSON;
    }
}

- (NSMutableArray *)getUsers
{
    return users;
}

- (void)populateBattles
{
    int rap_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"id"];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *stringAPICall = [NSString stringWithFormat:@"http://rapchat-staging.herokuapp.com/users/%i/battles", rap_id];
    NSURLRequest* rapchatAPIRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringAPICall]];
    [NSURLConnection sendAsynchronousRequest:rapchatAPIRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^ void (NSURLResponse* myResponse, NSData* myData, NSError* theirError)
     {
         //begin parse method
         battles = [self parseDataWithResponse:myResponse andData:myData andError:theirError];
         [self.delegate usersDidFinishPostingBattles:battles];
     }];
}

- (NSMutableArray *)getBattles
{
    return battles;
}

@end
