//
//  DPPApplicationModel.m
//  ContactsTest
//
//  Created by Lee Higgins on 28/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPApplicationModel.h"
#import "DPPARCCompatibility.h"

#define kContextReadyToSaveNotificationName @"ContextReadyToSaveNotification"
#define kContextDidSaveNotificationKey @"ContextDidSaveNotificationKey"



@interface DPPApplicationModel()

@property(nonatomic,readonly) NSNotificationQueue* updateMainContextRequests; //use to only update the GUI when the user is not interacting

-(void)mergeContextWhenReady:(NSNotification*)contextDidSaveNotification; //the main context will only update when ready to...

-(void)mergeContext:(NSNotification*)contextReadyToSaveNotification;
@end





@implementation DPPApplicationModel

static NSUInteger backgroundInstanceCount=0;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;                      //copied from apple core data project template
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize storeFile;
@synthesize modelName;
@synthesize background;
@synthesize mergePolicy;

@dynamic updateMainContextRequests;


+(NSString*)generateUID
{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

+(DPPApplicationModel*)sharedInstance
{
    static DPPApplicationModel* shared = nil;
    @synchronized(self)
    {
        if(shared==nil)
        {
            shared = [[DPPApplicationModel alloc] init];
            
            //only the main context observes this....
            [[NSNotificationCenter defaultCenter] addObserver:shared
                                                     selector:@selector(mergeContext:)
                                                         name:kContextReadyToSaveNotificationName
                                                       object:shared];
            
        }
    }
    return shared;
}

+(DPPApplicationModel*)instance
{
    DPPApplicationModel* instance = [[DPPApplicationModel alloc] initWithPersistentStoreCoordinator:[DPPApplicationModel sharedInstance].persistentStoreCoordinator 
                                                                                           andModel:[DPPApplicationModel sharedInstance].managedObjectModel];

    return ARC_AUTORELEASE(instance);
}

+(DPPApplicationModel*)backgroundInstance
{
    NSAssert([NSThread currentThread] != [NSThread mainThread],@"This function must be called on a background thread!");
    DPPApplicationModel* backgroundInstance = [DPPApplicationModel instance];
    
    @synchronized(self)
    {
        backgroundInstanceCount++;
    }
    
    backgroundInstance.background = YES;
    return ARC_AUTORELEASE(backgroundInstance);
}

#pragma mark - Core Data stack

-(DPPApplicationModel*)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator andModel:(NSManagedObjectModel*)model
{
    self = [self init];
    if(self)
    {
        __persistentStoreCoordinator = ARC_RETAIN(coordinator);
        __managedObjectModel = ARC_RETAIN(model);
    }
    return self;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeContextWhenReady:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
    
    if (mergePolicy) 
    {
        __managedObjectContext.mergePolicy = mergePolicy;
    }
    
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeFile];
    
    //Check if database was bundled with Application and if so, copy to Documents directory
	if (![[NSFileManager defaultManager] fileExistsAtPath:storeFile]) 
    {
		NSString *bundledStorePath = [[NSBundle mainBundle] pathForResource:storeFile ofType:nil];
		if (bundledStorePath) 
        {
			[[NSFileManager defaultManager] copyItemAtPath:bundledStorePath toPath:storeFile error:NULL];
		}
	}
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return __persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    } 
}

-(void)postMainContextUpdate:(NSNotification*)contextDidSaveNotification
{
    NSAssert([NSThread currentThread] == [NSThread mainThread],@"This function must be called in the main thread!");
    NSNotification* contextReadyToSaveNotification = [NSNotification notificationWithName:kContextReadyToSaveNotificationName object:self userInfo:[NSDictionary dictionaryWithObject:contextDidSaveNotification forKey:kContextDidSaveNotificationKey]];
    [self.updateMainContextRequests enqueueNotification:contextReadyToSaveNotification postingStyle:NSPostWhenIdle]; //will merge when no scrolling or animations
}

-(void)mergeContext:(NSNotification*)contextReadyToSaveNotification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:[contextReadyToSaveNotification.userInfo objectForKey:kContextDidSaveNotificationKey]];
}

-(void)mergeContextWhenReady:(NSNotification*)contextDidSaveNotification
{
    if(__managedObjectContext !=nil) //only merge if we have a context!!
    {
        if(contextDidSaveNotification.object != self.managedObjectContext)
        { //we didn't do the saving.....
            if(self.managedObjectContext == [self.class sharedInstance].managedObjectContext)
            {//we are the foreground main context don't just update, wait until user has stopped interacting
                [self performSelectorOnMainThread:@selector(postMainContextUpdate:)
                                       withObject:contextDidSaveNotification
                                    waitUntilDone:YES];
            }
            else 
            {//something was saved and we're not the main context so just merge the changes
                
                //TODO: test test test! with multiple background threads etc.....
                
                [self.managedObjectContext mergeChangesFromContextDidSaveNotification:contextDidSaveNotification];
            }
        }
    }
}

-(NSNotificationQueue*)updateMainContextRequests
{
    return [NSNotificationQueue defaultQueue];
}


#pragma mark - CoreData helper functions....

-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName withArgs:(NSDictionary*)args
{
    return [self executeFetchRequestTemplateNamed:templateName withArgs:args sortedByDescriptors:nil]; 
}

-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName withArgs:(NSDictionary*)args sortedByDescriptors:(NSArray*)sortDescriptors
{ 
    
    NSFetchRequest *fetchRequest = [__managedObjectModel fetchRequestFromTemplateWithName:templateName
                                                                    substitutionVariables:args]; 
    
    if(sortDescriptors)
    {
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

-(NSManagedObject*)insertNewEntityNamed:(NSString*)entityName ofClass:(Class)entityClass
{    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
   //  NSLog(@"Create Entity %@",entityName );
    return ARC_AUTORELEASE([[entityClass alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext]);
}
-(NSManagedObject*)fetchEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                        withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", attributeName, valueObject];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchResults.count == 1)
    {
        //NSLog(@"Found Entity %@",entityName );
        return [fetchResults objectAtIndex:0];
    }
    return nil;
}

-(NSManagedObject*)fetchOrInsertEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                        withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject
{
    NSManagedObject* foundObject = [self fetchEntityNamed:entityName ofClass:entityClass withUniqueAttribute:attributeName withValue:valueObject];
    //If no results insert one.
    if (foundObject==nil)
    {
        NSManagedObject *newObject = [self insertNewEntityNamed:[entityClass description] ofClass:entityClass];
        //Set unique ID, so you can be sure any returned object has this set
        [newObject setValue:valueObject forKey:attributeName];
        return newObject;
    }
    return foundObject;
}

#pragma mark Cleanup

-(void)waitForBackgroundContexts
{
    //LH This should be called in the app delegates application will/did terminate to ensure background saving is complete..
    BOOL complete=NO; 
    NSAssert([NSThread currentThread] == [NSThread mainThread] ,@"This can only be called from the main thread.");
    do
    {
        NSUInteger instances = 0;
        @synchronized(self)
        {
            instances=backgroundInstanceCount;
        }
        
        if(instances > 0)
        { //wait but run the runloop....
            NSLog(@"Waiting for %d background contexts",instances);
            [[NSRunLoop mainRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:0.1]];
        }
        else 
        {
            NSLog(@"Background contexts complete.");
            complete = YES;
        }
    }while(!complete);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self saveContext];
    
    if(background)
    {
        @synchronized(self)
        {
            backgroundInstanceCount--;
        }
    }
    
    self.mergePolicy = nil;

    ARC_SUPER_DEALLOC;
}

@end
