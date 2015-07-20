//
//  UserService.m
//  LeanChat
//
//  Created by lzw on 14-10-22.
//  Copyright (c) 2014年 LeanCloud. All rights reserved.
//

#import "CDUserManager.h"
#import "CDUtils.h"
#import "CDCacheManager.h"
#import "UIImage+Icon.h"

static UIImage *defaultAvatar;

static CDUserManager *userManager;

@implementation CDUserManager

+ (instancetype)manager {
    static dispatch_once_t token ;
    dispatch_once(&token, ^{
        userManager = [[CDUserManager alloc] init];
    });
    return userManager;
}


- (void)findFriendsWithBlock:(AVArrayResultBlock)block {
    AVUser *user = [AVUser currentUser];
    AVQuery *q = [user followeeQuery];
    q.cachePolicy = kAVCachePolicyNetworkElseCache;
    [q findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (error == nil) {
            [[CDCacheManager manager] registerUsers:objects];
        }
        block(objects, error);
    }];
}

- (void)isMyFriend:(AVUser *)user block:(AVBooleanResultBlock)block {
    AVUser *currentUser = [AVUser currentUser];
    AVQuery *q = [currentUser followeeQuery];
    [q whereKey:@"followee" equalTo:user];
    [q findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (error) {
            block(NO, error);
        }
        else {
            if (objects.count > 0) {
                block(YES, nil);
            }
            else {
                block(NO, error);
            }
        }
    }];
}

- (NSString *)getPeerIdOfUser:(AVUser *)user {
    return user.objectId;
}

// should exclude friends
- (void)findUsersByPartname:(NSString *)partName withBlock:(AVArrayResultBlock)block {
    AVQuery *q = [AVUser query];
    [q setCachePolicy:kAVCachePolicyNetworkElseCache];
    [q whereKey:@"username" containsString:partName];
    AVUser *curUser = [AVUser currentUser];
    [q whereKey:@"objectId" notEqualTo:curUser.objectId];
    [q orderByDescending:@"updatedAt"];
    [q findObjectsInBackgroundWithBlock:block];
}

- (void)findUsersByIds:(NSArray *)userIds callback:(AVArrayResultBlock)callback {
    if ([userIds count] > 0) {
        AVQuery *q = [AVUser query];
        [q setCachePolicy:kAVCachePolicyNetworkElseCache];
        [q whereKey:@"objectId" containedIn:userIds];
        [q findObjectsInBackgroundWithBlock:callback];
    }
    else {
        callback([[NSArray alloc] init], nil);
    }
}

- (void)displayAvatarOfUser:(AVUser *)user avatarView:(UIImageView *)avatarView {
    [self getAvatarImageOfUser:user block: ^(UIImage *image) {
        [avatarView setImage:image];
    }];
}

- (void)getBigAvatarImageOfUser:(AVUser *)user block:(void (^)(UIImage *image))block {
    CGFloat avatarWidth = 60;
    CGSize avatarSize = CGSizeMake(avatarWidth, avatarWidth);
    [[CDUserManager manager] getAvatarImageOfUser:user block: ^(UIImage *image) {
        UIImage *resizedImage = [CDUtils resizeImage:image toSize:avatarSize];
        block(resizedImage);
    }];
}

- (void)getAvatarImageOfUser:(AVUser *)user block:(void (^)(UIImage *image))block {
    AVFile *avatar = [user objectForKey:@"avatar"];
    if (avatar) {
        [avatar getDataInBackgroundWithBlock: ^(NSData *data, NSError *error) {
            if (error == nil) {
                block([UIImage imageWithData:data]);
            }
            else {
                block([self defaultAvatarOfUser:user]);
            }
        }];
    }
    else {
        block([self defaultAvatarOfUser:user]);
    }
}

- (UIImage *)defaultAvatarOfUser:(AVUser *)user {
    return [UIImage imageWithHashString:user.objectId displayString:[[user.username substringWithRange:NSMakeRange(0, 1)] capitalizedString]];
}

- (void)saveAvatar:(UIImage *)image callback:(AVBooleanResultBlock)callback {
    NSData *data = UIImagePNGRepresentation(image);
    AVFile *file = [AVFile fileWithData:data];
    [file saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (error) {
            callback(succeeded, error);
        }
        else {
            AVUser *user = [AVUser currentUser];
            [user setObject:file forKey:@"avatar"];
            [user setFetchWhenSave:YES];
            [user saveInBackgroundWithBlock:callback];
        }
    }];
}

- (void)updateUsername:(NSString *)username block:(AVBooleanResultBlock)block{
    AVUser *user = [AVUser currentUser];
    user.username = username;
    [user saveInBackgroundWithBlock:block];
}

- (void)addFriend:(AVUser *)user callback:(AVBooleanResultBlock)callback {
    AVUser *curUser = [AVUser currentUser];
    [curUser follow:user.objectId andCallback:callback];
}

- (void)removeFriend:(AVUser *)user callback:(AVBooleanResultBlock)callback {
    AVUser *curUser = [AVUser currentUser];
    [curUser unfollow:user.objectId andCallback:callback];
}


@end
