//
//  GoGostressedNotifier.m
//  SprintDemo01
//
//  Created by Esteban Garro on 2015-12-03.
//  Copyright © 2015 Blabcake. All rights reserved.
//

#import "MainNotifier.h"

@implementation MainNotifier

-(id)init {
    self = [super init];
    if (self) {
        self.acc = @"";
    }
    return self;
}

#pragma mark GoGostressedNotifier Methods

-(void)notify:(NSString*)a {
    self.acc = [_acc stringByAppendingFormat:@" %@",a];
    [self.delegate notifierRegisteredChange:self];
}

@end
