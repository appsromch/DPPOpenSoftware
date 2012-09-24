//
//  DPPApplicationModel.h
//  ContactsTest
//
//  Created by Lee Higgins on 28/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DPPApplicationModel : NSObject


@property(strong,nonatomic) NSString* storeFile;
@property(strong,nonatomic) NSString* modelName;
@property(assign,nonatomic) BOOL background;
@property(nonatomic,retain) id mergePolicy;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(NSString*)generateUID;

+(DPPApplicationModel*)sharedInstance;
+(DPPApplicationModel*)backgroundInstance;

-(void)saveContext;
-(void)waitForBackgroundContexts;

-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName withArgs:(NSDictionary*)args;
-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName withArgs:(NSDictionary*)args sortedByDescriptors:(NSArray*)sortDescriptors;
-(NSManagedObject*)insertNewEntityNamed:(NSString*)entityName ofClass:(Class)entityClass;
-(NSManagedObject*)fetchEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject;
-(NSManagedObject*)fetchOrInsertEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                        withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject;

@end
