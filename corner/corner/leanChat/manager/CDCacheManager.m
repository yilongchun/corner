//
//  CDCacheService.m
//  LeanChat
//
//  Created by lzw on 14/12/3.
//  Copyright (c) 2014年 LeanCloud. All rights reserved.
//

#import "CDCacheManager.h"
#import "CDUtils.h"
#import "CDUserManager.h"
#import <LeanChatLib/CDChatListVC.h>
#import "CDUser.h"

static CDCacheManager *cacheManager;

@interface CDCacheManager ()

@property (nonatomic, strong) NSCache *userCache;
@property (nonatomic, strong) NSString *currentConversationId;

@end

@implementation CDCacheManager

+ (instancetype)manager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        cacheManager = [[CDCacheManager alloc] init];
    });
    return cacheManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userCache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - user cache

- (void)registerUsers:(NSArray *)users {
    for (CDUser *user in users) {
        DLog(@"%@",user.userId);
        [self.userCache setObject:user forKey:user.userId];
    }
}

- (AVUser *)lookupUser:(NSString *)userId {
    return [self.userCache objectForKey:userId];
}

- (void)cacheUsersWithIds:(NSSet *)userIds callback:(AVBooleanResultBlock)callback {

    NSMutableArray *uncachedUserIds = [NSMutableArray array];
    for (NSString *userId in userIds) {
        if ([[CDCacheManager manager] lookupUser:userId] == nil) {
            [uncachedUserIds addObject:userId];
        }
    }
    if ([uncachedUserIds count] > 0) {
        
        for (NSString *userId in uncachedUserIds) {
            NSString *myuserid = [UD objectForKey:USER_ID];
            NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,myuserid]];
            NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userId,token];
            
            AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
            NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil error:nil];
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
            
            [requestOperation setResponseSerializer:responseSerializer];
            [requestOperation start];
            [requestOperation waitUntilFinished];
            NSDictionary *dic = [requestOperation responseObject];
            DLog(@"%@",dic);
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"message"] cleanNull]];
                NSNumber *userid = [userinfo objectForKey:@"id"];
                NSString *nickname = [userinfo objectForKey:@"nickname"];
                NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];
                NSString *username;
                if ([nickname isEqualToString:@""]) {
                    username = [userid stringValue];
                }else{
                    username = nickname;
                }
                CDUser *user = [[CDUser alloc] init];
                user.userId = userId;
                user.username = username;
                user.avatarUrl = avatar_url;
                [[CDCacheManager manager] registerUsers:@[user]];
                
            }
        }
        callback(YES, nil);
//        
//        
//        
//        
//        
//        
//        
//        [[CDUserManager manager] findUsersByIds:[[NSMutableArray alloc] initWithArray:[uncachedUserIds allObjects]] callback: ^(NSArray *objects, NSError *error) {
//            if (objects) {
//                [[CDCacheManager manager] registerUsers:objects];
//            }
//            callback(YES, error);
//        }];
    }
    else {
        callback(YES, nil);
    }
}

#pragma mark - current conversation

- (void)setCurConv:(AVIMConversation *)conv {
    self.currentConversationId = conv.conversationId;
}



@end
