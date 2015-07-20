//
//  CDUserFactory.m
//  LeanChatExample
//
//  Created by lzw on 15/4/7.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import "CDUserFactory.h"
#import "CDUser.h"
#import "CDCacheManager.h"

@implementation CDUserFactory

#pragma mark - CDUserDelegate
- (void)cacheUserByIds:(NSSet *)userIds block:(AVBooleanResultBlock)block {
//    [[CDCacheManager manager] cacheUsersWithIds:userIds callback:block];
    
    block(YES,nil);
}

- (id <CDUserModel> )getUserById:(NSString *)userId {
    
    CDUser *user = [[CDUser alloc] init];
    CDUser *avUser = (CDUser *)[[CDCacheManager manager] lookupUser:userId];
    if (avUser == nil) {
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
            return user;
        }else{
            user.userId = userId;
            user.username = userId;
            user.avatarUrl = @"";
            return user;
        }
        
    }else{
        user.userId = userId;
        user.username = avUser.username;
        user.avatarUrl = avUser.avatarUrl;
        return user;
    }
}

@end
