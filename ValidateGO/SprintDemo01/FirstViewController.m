//
//  FirstViewController.m
//  SprintDemo01
//
//  Created by Esteban Garro on 2015-12-03.
//  Copyright © 2015 Blabcake. All rights reserved.
//

#import "FirstViewController.h"
#import <CommonCrypto/CommonDigest.h>
#include <stdlib.h>

#define POST_TASK_IDENTIFIER 15

@interface FirstViewController () <NSURLSessionDelegate> {
    NSURLSession *session;
}

@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.routineOutlet.text = @"";
    self.requestOutlet.text = @"";
    self.taskOutlet.text = @"";
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPMaximumConnectionsPerHost = 1;
    
    //Should we use a default session?
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startTest:(id)sender {
    [self logToTaskLog:@"Starting test..."];
    [self backgroundRoutine];
    [self performGETRequest];
    [self performPOSTRequest];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self writeToFile];
        __block NSString *fileContents = [self readFromFile];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self logToRequestLog:fileContents];
        });
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self sortFixedList];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self generateAndSortList];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        __block NSString *hash = [self hashImageFile];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self logToRequestLog:hash];
        });
    });
}

-(void)logToTaskLog:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.taskOutlet.text = [self.taskOutlet.text stringByAppendingFormat:@"\n%@",str];
    });
}

-(void)logToRequestLog:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.requestOutlet.text = [self.requestOutlet.text stringByAppendingFormat:@"\n%@",str];
    });
}

#pragma mark NSURLSessionDelegate Methods
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            if (task.taskIdentifier == self.uploadTask.taskIdentifier) {
                [self logToRequestLog:@"POST Request Completed!"];
            }
        } else {
            NSLog(@"Error processing request: %@",error);
        }
    });
}

#pragma mark TestInterface Methods

-(void)backgroundRoutine {
    [self logToTaskLog:@"Going into background routine..."];
    self.routineOutlet.text = @"";
    dispatch_queue_t routineQueue = dispatch_queue_create("RoutineQueue",NULL);
    NSString *fullText = @"Hello people! Let's do some cool programming stuff";
    for (NSString *word in [fullText componentsSeparatedByString:@" "]) {
        dispatch_async(routineQueue, ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.routineOutlet.text = [self.routineOutlet.text stringByAppendingString:[NSString stringWithFormat:@" %@",word]];
            });
        }); 
    }
}

-(BOOL)writeToFile {
    NSMutableString *randomString = [@"" mutableCopy];
    for (int i = 1; i <= 1000000 ; i++) {
        [randomString appendFormat:@"%c",i%26 + 65];
        if (i%26 == 0) {
            [randomString appendString:@"\n"];
        }
    }
    NSData *data = [randomString dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"randomFile.txt"];
    
    NSError *error = 0;
    NSDate *start = [NSDate date];
        [data writeToFile:appFile options:NSDataWritingAtomic error:&error];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Writing file execution Time: %f", executionTime]];
    
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }
    
    [self logToRequestLog:@"Success writing to file!"];
    return YES;
}

-(NSString *)readFromFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BlabCake" ofType:@"txt"];
    
    NSDate *start = [NSDate date];
        NSData *myData = [NSData dataWithContentsOfFile:filePath];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Reading file execution Time: %f", executionTime]];

    if (myData) {
        return [NSString stringWithUTF8String:[myData bytes]];
    }
    return @"ERROR READING FILE on iOS :(:(";
}

-(void)performGETRequest {
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.theverge.com/"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self logToRequestLog:[NSString stringWithUTF8String:[data bytes]]];
                    });
                }
            }] resume];
}

-(void)performPOSTRequest {
    NSString *bodyData = @"name=Jane+Doe&address=123+Main+St";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com"]];
    [request setHTTPMethod:@"POST"];
    
    self.uploadTask = [session uploadTaskWithRequest:request fromData:[bodyData dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_uploadTask resume];
}

-(BOOL)sortFixedList {
    const int numbers[] = {32,56,2,94,46,67,32,71,29,78,78,78,12,33,64,90,97,1,2,27,68,88,83,5,71,46,81,7,37,59,25,93,21,26,31,20,90,7,92,36,100,66,93,12,76,24,17,46,15,9,63,37,18,32,43,80,44,70,77,45,82,66,32,11,85,10,62,17,100,43,34,7,73,38,90,45,23,3,68,45,67,48,47,35,14,72,87,74,10,82,34,59,92,15,2,87,73,80,4,43};
    int SIZE = sizeof(numbers)/sizeof(int);
    NSMutableArray * targetArray = [[NSMutableArray alloc] initWithCapacity:SIZE];
    for (int i = 0; i < SIZE; i++) {
        [targetArray addObject:[NSNumber numberWithInt:numbers[i]]];
    }
    
    NSDate *start = [NSDate date];
        mysort(targetArray,0,SIZE-1);
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Time sorting a fixed list: %f", executionTime]];
    
    return YES;
}

-(BOOL)generateAndSortList {
    NSInteger SIZE = 1000000;
    
    NSDate *start = [NSDate date];
    NSMutableArray * targetArray = [[NSMutableArray alloc] initWithCapacity:SIZE];
    for (int i = 0; i < SIZE; i++) {
        [targetArray addObject:[NSNumber numberWithInt:arc4random_uniform(10000)]];
    }
    mysort(targetArray,0,SIZE-1);
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Time generating and sorting a list: %f", executionTime]];
    
    return YES;
}

-(NSString *)hashImageFile {
    UIImage* image = [UIImage imageNamed:@"Yosemite.png"];
    NSData* imageData = UIImagePNGRepresentation(image);
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

    NSDate *start = [NSDate date];
        CC_SHA256(imageData.bytes, imageData.length,  macOut.mutableBytes);
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Time hashing file: %f", executionTime]];
    
    return [[NSString alloc] initWithData:macOut encoding:NSUTF8StringEncoding];
}

void mysort(NSMutableArray *a, NSInteger first, NSInteger last) {
    if (first >= last) {
        return;
    }
    
    NSInteger left = first;
    NSInteger right = last;
    
    NSInteger pIdx = (first+last)/2;
    [a exchangeObjectAtIndex:pIdx withObjectAtIndex:right];
    
    for (NSUInteger j = first ; j<=last; j++) {
        if ([a[j] intValue]<[a[right] intValue]) {
            [a exchangeObjectAtIndex:j withObjectAtIndex:left];
            left++;
        }
    }
    
    [a exchangeObjectAtIndex:left withObjectAtIndex:right];
    mysort(a,first,left-1);
    mysort(a,left+1,last);
}


@end
