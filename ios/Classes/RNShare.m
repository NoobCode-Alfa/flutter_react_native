//
//  RNShare.m
//  Runner
//
//  Created by Yustan Julmakap on 04/08/23.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNShare, NSObject)

RCT_EXTERN_METHOD(callback:(NSDictionary *)options)
RCT_EXTERN_METHOD(call:(NSDictionary *)options)

@end
