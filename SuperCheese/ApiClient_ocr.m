//
//  Created by  fred on 2016/10/26.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "ApiClient_ocr.h"
#import <CloudApiSdk/HttpConstant.h>

@implementation ApiClient_ocr

static NSString* HOST = @"tysbgpu.market.alicloudapi.com";

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    static ApiClient_ocr *api = nil;
    dispatch_once(&onceToken, ^{
        api = [ApiClient_ocr new];
    });
    return api;
}

- (instancetype)init {
    self = [super initWithKey:@"24762824" appSecret:@"79144b7457ea1be8a9d55fad60848bd7"];
    return self;
}


- (void) recoganize:(NSData *) body completionBlock:(void (^)(NSData * , NSURLResponse * , NSError *))completionBlock
{

    //定义Path
    NSString * path = @"/api/predict/ocr_general";

    

    [self httpPost: CLOUDAPI_HTTP
    host: HOST
    path: path
    pathParams: nil
    queryParams: nil
    body: body
    headerParams: nil
    completionBlock: completionBlock];

}


@end
