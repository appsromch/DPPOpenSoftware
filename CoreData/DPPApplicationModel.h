//
//  DPPApplicationModel.h
//  ContactsTest
//
//  Created by Lee Higgins on 28/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol DPPApplicationObjectChangesDelegate <NSObject>
@optional
-(void)applicationModelObjectWillChange:(NSManagedObject*)object;
-(void)applicationModelObjectDidChange:(NSManagedObject*)object;
-(void)applicationModelObjectWillDelete:(NSManagedObject *)object;

//LH not sure how useful this will be..... you must not access the managed object in this callback.
-(void)applicationModelObjectDidDelete:(NSManagedObjectID *)object;
@end


@interface DPPApplicationModel : NSObject


@property(strong,nonatomic) NSURL* storeURL;
@property(strong,nonatomic) NSString* storeFile;
@property(strong,nonatomic) NSString* modelName;
@property(assign,nonatomic) BOOL background;
@property(nonatomic,retain) id mergePolicy;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic) NSMutableDictionary* backgroundWaitList;

//A Unqiue ID currently [[NSProcessInfo processInfo] globallyUniqueString];
+(NSString*)generateUID;

//LH The main context, always use this for GUI updates, only use on the main thread...
+(DPPApplicationModel*)sharedInstance;

//LH a temporary instance, for advanced users.
//The context will be saved when this instance is dealloc'd
+(DPPApplicationModel*)instance;

//LH a background instance, use this in background threads.
//The context will be saved when this instance is dealloc'd
+(DPPApplicationModel*)backgroundInstance;

//LH The below functions tell us when the passed object has changed in this app models context....
//This will callback when either the context is saved and there are changes to the observed object OR
//when other contexts are merged with changes to that observed object.
//Observers are kept as weak references and are removed when dealloc'd

//TIP: Use these observers to disconnect your network request callbacks from GUI updating, this way
//if you use multiple requests to update a single page, the GUI will get updated when the data its interested in changes and not in network api callbacks.
//Consider using fetch results controllers instead of using direct managed objects relationships, they may provide more flexibility.
-(void)addObserver:(id<DPPApplicationObjectChangesDelegate>)observer forManagedObject:(NSManagedObject*)object;
-(void)removeObserver:(id<DPPApplicationObjectChangesDelegate>)observer forManagedObject:(NSManagedObject*)object;
-(void)removeObserver:(id<DPPApplicationObjectChangesDelegate>)observer;

//This allows us to postpone the deletion of objects until after the background contexts have merged to the main thread
-(void)addToRecycleBin:(NSManagedObject*)managedObject;

//LH this will save the current context, if its a background context it will merge with all the
//current background contexts instantly, it will only merge with the main context when it is 'Safe' to do so. When main thread is idle.
//This helps hide any small lockups large merging on the main thread would cause.
-(void)saveContext;

//LH since we might have background threads saving data, we must wait for them to complete if we want to keep their changes.
//This should be called in applicationwillterminate
-(void)waitForBackgroundContexts;

-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName
                                   withArgs:(NSDictionary*)args;

-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName
                                   withArgs:(NSDictionary*)args
                        sortedByDescriptors:(NSArray*)sortDescriptors;


/*
 //LH note to self Help Methods to add, also make above use them.....
-(NSFetchedResultsController*)fetchControllerForTemplateNamed:(NSString*)templateName
                                                     withArgs:(NSDictionary*)args;

-(NSFetchedResultsController*)fetchControllerForTemplateNamed:(NSString*)templateName
                                                     withArgs:(NSDictionary*)args
                                          sortedByDescriptors:(NSArray*)sortDescriptors;
 */

-(NSManagedObject*)temporyEntityNamed:(NSString*)entityName
                              ofClass:(Class)entityClass;

-(NSManagedObject*)insertNewEntityNamed:(NSString*)entityName
                                ofClass:(Class)entityClass;

-(NSManagedObject*)fetchEntityNamed:(NSString *)entityName
                            ofClass:(Class)entityClass
                withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject;

-(NSManagedObject*)fetchOrInsertEntityNamed:(NSString *)entityName
                                    ofClass:(Class)entityClass
                        withUniqueAttribute:(NSString *)attributeName
                                  withValue:(id)valueObject;

-(NSManagedObject*)fetchOrInsertEntityNamed:(NSString *)entityName
                                    ofClass:(Class)entityClass
                     withFetchTemplateNamed:(NSString *)templateName
                                   withArgs:(NSDictionary *)args;

-(NSManagedObject*)fetchEntityNamed:(NSString *)entityName
                            ofClass:(Class)entityClass
             withFetchTemplateNamed:(NSString *)templateName
                           withArgs:(NSDictionary *)args;

-(NSManagedObject*)fetchAnyEntityNamed:(NSString *)entityName
                               ofClass:(Class)entityClass;


//Add the object to this context
-(void)addToContext:(NSManagedObject*)object;

//This will run once the context has been merged with the main context......
//Use this to update display after background changes to coredata.....
//this is called after the observer callbacks...
-(void)addMergeCompletion:(void (^)(void))completion;



@end
