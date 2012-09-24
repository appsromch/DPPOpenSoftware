//
//  DPPXMLCoreDataMapper.h
//  ContactsTest
//
//  Created by Lee Higgins on 28/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DPPApplicationModel;

@interface DPPXMLCoreDataMapper : NSObject<NSXMLParserDelegate>


@property (nonatomic,strong) DPPApplicationModel*       applicationModel;
@property (nonatomic,assign) NSInteger                  entitySaveInterval;
@property (nonatomic,assign) BOOL                       debugSlow;

-(DPPXMLCoreDataMapper*)initWithDictionary:(NSDictionary*)map;
-(DPPXMLCoreDataMapper*)initWithContentsOfFile:(NSString*)filename;

-(void)parseXMLStream:(NSInputStream *)xmlData;
-(void)parseXML:(NSData*)xmlData;

@end
