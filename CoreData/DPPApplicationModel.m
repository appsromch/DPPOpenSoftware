//
//  DPPApplicationModel.m
//  ContactsTest
//
//  Created by Lee Higgins on 28/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPApplicationModel.h"
#import "DPPARCCompatibility.h"
#import "WeakReference.h"

#define kContextReadyToSaveNotificationName @"ContextReadyToSaveNotification"
#define kContextDidSaveNotificationKey @"ContextDidSaveNotificationKey"

#define EnsureCorrectContextThreadUsage(model) NSAssert((model == [DPPApplicationModel sharedInstance] && [NSThread currentThread] == [NSThread mainThread]) || (model != [DPPApplicationModel sharedInstance] && [NSThread currentThread] != [NSThread mainThread]),@"Incorrect thread usage")

@interface DPPApplicationModel()

@property(nonatomic,strong) NSMutableDictionary* observersForObjects;

@property(nonatomic,retain) NSMutableSet* recycleBin;
@property(nonatomic,readonly) NSNotificationQueue* updateMainContextRequests; //use to only update the GUI when the user is not interacting
@property(nonatomic,readonly) NSMutableDictionary* mergeCompletionList;

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
@synthesize recycleBin;

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
            shared = [[DPPApplicationModel alloc] initMain];
            
            
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

-(id)initMain
{
    self = [super init];
    if(self)
    {
        _mergeCompletionList = [NSMutableDictionary dictionary];
    }
    return self;
}

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
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
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

    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];;
    return __managedObjectModel;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)restoreDatabaseFromBundle
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:_storeURL.path])
    {
		NSString *bundledStorePath = [[NSBundle mainBundle] pathForResource:storeFile ofType:nil];
		if (bundledStorePath)
        {
            NSLog(@"Restored from Prepopulated database.....");
			[[NSFileManager defaultManager] copyItemAtPath:bundledStorePath toPath:_storeURL.path error:NULL];
		}
	}
}
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    if(storeFile)
    {
        _storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeFile];
    }
    //Check if database was bundled with Application and if so, copy to Documents directory
    [self restoreDatabaseFromBundle];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:options error:&error]) {
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
        
        //Simple remove the old data......
        [[NSFileManager defaultManager] removeItemAtURL:_storeURL error:nil];
        [self restoreDatabaseFromBundle];
        [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:options error:&error];
    }    
    
    return __persistentStoreCoordinator;
}

- (void)saveContext
{
   // EnsureCorrectContextThreadUsage(self);
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
       
        NSSet* updatedObjects = [managedObjectContext.updatedObjects copy];
        NSSet* deletedObjects = [managedObjectContext.deletedObjects copy];
                if ([managedObjectContext hasChanges])
                {
                      NSError *error = nil;
                    [self notifyObserversOfChanges:updatedObjects
                                         deletions:deletedObjects
                                     aboutToChange:YES];//LH  update observers on changes in the same context when saved will be on background threads if not main context
                    if([managedObjectContext save:&error])
                    {
                        [self notifyObserversOfChanges:updatedObjects
                                             deletions:deletedObjects
                                         aboutToChange:NO]; //LH  update observers on changes in the same context when saved
                    }
                    else
                    {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    }
        
                }
    }
}

-(void)postMainContextUpdate:(NSNotification*)contextDidSaveNotification
{
     dispatch_async(dispatch_get_main_queue(), ^{
            NSNotification* contextReadyToSaveNotification = [NSNotification notificationWithName:kContextReadyToSaveNotificationName object:self userInfo:[NSDictionary dictionaryWithObject:contextDidSaveNotification forKey:kContextDidSaveNotificationKey]];
            [self.updateMainContextRequests enqueueNotification:contextReadyToSaveNotification postingStyle:NSPostWhenIdle]; //will merge when no scrolling or animations
     });
}

-(void)mergeContext:(NSNotification*)contextReadyToSaveNotification
{
        NSNotification* changes = [contextReadyToSaveNotification.userInfo objectForKey:kContextDidSaveNotificationKey];
        if(changes.object != [DPPApplicationModel sharedInstance].managedObjectContext)
        {
            NSDictionary* userInfo = changes.userInfo;
            NSSet *updatedObjects = [userInfo objectForKey:NSUpdatedObjectsKey];
            NSSet *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];
            
            [self notifyObserversOfChanges:updatedObjects deletions:deletedObjects aboutToChange:YES];
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:changes];
            [self notifyObserversOfChanges:updatedObjects deletions:deletedObjects aboutToChange:NO];
            
            //empty the bin and delete the objects
            if(recycleBin.count > 0)
            {
                @synchronized([DPPApplicationModel sharedInstance])
                {
                    for(NSManagedObjectID* objectID in recycleBin)
                    {
                        if([[DPPApplicationModel sharedInstance].managedObjectContext objectWithID:objectID]!=nil)
                        {
                            [[DPPApplicationModel sharedInstance].managedObjectContext deleteObject:[[DPPApplicationModel sharedInstance].managedObjectContext objectWithID:objectID]];
                        }
                    }
                    [recycleBin removeAllObjects];
                }
                [[DPPApplicationModel sharedInstance] saveContext];
            }
            
            @synchronized([DPPApplicationModel sharedInstance])
            {
                NSValue* contextValue = [NSValue valueWithNonretainedObject:changes.object];
                NSBlockOperation* mergeCompletion = [_mergeCompletionList objectForKey:contextValue];
                if(mergeCompletion)
                {//LH add the operation to be executed after the merge, all changes will be present in the main context....
                    [[NSOperationQueue mainQueue] addOperation:mergeCompletion];
                }
                [_mergeCompletionList removeObjectForKey:contextValue];
            }
        }
}

-(void)mergeContextWhenReady:(NSNotification*)contextDidSaveNotification
{
    if(__managedObjectContext !=nil) //only merge if we have a context!!
    {
        if (((NSManagedObjectContext *)contextDidSaveNotification.object).persistentStoreCoordinator == [self persistentStoreCoordinator]) {
            //We only care about this if the context that was saved shares our persistentStoreCoordinator,
            //otherwise the context probably belongs to some library (Google Analytics, for example)
            if(contextDidSaveNotification.object != self.managedObjectContext)
            { //we didn't do the saving so we must merge changes.....
                if(self.managedObjectContext == [DPPApplicationModel sharedInstance].managedObjectContext)
                {//we are the foreground main context don't just update, wait until user has stopped interacting

                   
                        [self postMainContextUpdate:contextDidSaveNotification];
                    
                 
                }
                else 
                {//something was saved and we're not the main context so just merge the changes
                    NSDictionary* userInfo = contextDidSaveNotification.userInfo;
                    NSSet *updatedObjects = [userInfo objectForKey:NSUpdatedObjectsKey];
                    NSSet *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];
                     [self notifyObserversOfChanges:updatedObjects deletions:deletedObjects aboutToChange:YES];
                    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:contextDidSaveNotification];
                    [self notifyObserversOfChanges:updatedObjects deletions:deletedObjects aboutToChange:NO];
                }
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
    EnsureCorrectContextThreadUsage(self);
    return [self executeFetchRequestTemplateNamed:templateName withArgs:args sortedByDescriptors:nil]; 
}

-(NSArray*)executeFetchRequestTemplateNamed:(NSString*)templateName withArgs:(NSDictionary*)args sortedByDescriptors:(NSArray*)sortDescriptors
{
    EnsureCorrectContextThreadUsage(self);
    NSFetchRequest *fetchRequest = [__managedObjectModel fetchRequestFromTemplateWithName:templateName
                                                                    substitutionVariables:args]; 
    
    if(sortDescriptors)
    {
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}
-(NSManagedObject*)temporyEntityNamed:(NSString*)entityName ofClass:(Class)entityClass
{
    EnsureCorrectContextThreadUsage(self);
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return ARC_AUTORELEASE([[entityClass alloc] initWithEntity:description insertIntoManagedObjectContext:nil]);
}
-(NSManagedObject*)insertNewEntityNamed:(NSString*)entityName ofClass:(Class)entityClass
{
   EnsureCorrectContextThreadUsage(self);
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return ARC_AUTORELEASE([[entityClass alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext]);
}
-(NSManagedObject*)fetchEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                        withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject
{
    EnsureCorrectContextThreadUsage(self);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [[self.managedObjectModel entitiesByName] objectForKey:entityName];
    
    /*[NSEntityDescription entityForName:entityName
                                                         inManagedObjectContext:self.managedObjectContext];*/
    [fetchRequest setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", attributeName, valueObject];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchResults.count == 1)
    {
        return [fetchResults objectAtIndex:0];
    }
    return nil;
}

-(void)addToContext:(NSManagedObject*)object
{
    EnsureCorrectContextThreadUsage(self);
    [self.managedObjectContext insertObject:object];
}

-(NSManagedObject*)fetchAnyEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
{
    EnsureCorrectContextThreadUsage(self);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchResults.count == 1)
    {
        return [fetchResults objectAtIndex:0];
    }
    return nil;
}

-(NSManagedObject*)fetchEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
             withFetchTemplateNamed:(NSString *)templateName withArgs:(NSDictionary *)args
{
    EnsureCorrectContextThreadUsage(self);
    NSManagedObject *managedObject = nil;
    
    NSArray *fetchResults = [self executeFetchRequestTemplateNamed:templateName withArgs:args];
    
    if (fetchResults.count > 1)
        NSLog(@"***WARNING:\nMultiple objects found for fetchOrInsertEntityNamed:ofClass:withFetchTemplateNamed:withArgs:\n%@", fetchResults);
    
    if (fetchResults.count > 0)
        managedObject = [fetchResults objectAtIndex:0];
    
    return managedObject;
}

-(NSManagedObject*)fetchOrInsertEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                     withFetchTemplateNamed:(NSString *)templateName withArgs:(NSDictionary *)args
{
    EnsureCorrectContextThreadUsage(self);
    NSManagedObject *managedObject = nil;
    
    NSArray *fetchResults = [self executeFetchRequestTemplateNamed:templateName withArgs:args];
    
    if (fetchResults.count > 1)
        NSLog(@"***WARNING:\nMultiple objects found for fetchOrInsertEntityNamed:ofClass:withFetchTemplateNamed:withArgs:\n%@", fetchResults);
    
    if (fetchResults.count > 0)
        managedObject = [fetchResults objectAtIndex:0];
    
    if (managedObject == nil) {
        managedObject = [self insertNewEntityNamed:[entityClass description] ofClass:entityClass];
    }
    
    return managedObject;
}

-(NSManagedObject*)fetchOrInsertEntityNamed:(NSString *)entityName ofClass:(Class)entityClass
                        withUniqueAttribute:(NSString *)attributeName withValue:(id)valueObject
{
    EnsureCorrectContextThreadUsage(self);
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

#pragma mark -object changes system

-(NSMutableDictionary*)observersForObjects
{
    if(_observersForObjects == nil)
    {
        _observersForObjects  = [NSMutableDictionary dictionary];
    }
    return _observersForObjects;
}

-(void)addObserver:(id<DPPApplicationObjectChangesDelegate>)observer forManagedObject:(NSManagedObject*)object
{
    if(object==nil || observer==nil) return;
    
    NSMutableOrderedSet* observerList = [self.observersForObjects objectForKey:object.objectID];
    if(observerList ==nil)
    {
        observerList = [NSMutableOrderedSet orderedSetWithObject:[WeakReference weakReferenceWithObject:observer]];
        [self.observersForObjects setObject:observerList forKey:object.objectID];
    }
    else
    {
        [observerList addObject:[WeakReference weakReferenceWithObject:observer]];
    }
}

-(void)removeObserver:(id<DPPApplicationObjectChangesDelegate>)observer forManagedObject:(NSManagedObject*)object
{
    if(object==nil || observer==nil) return;
    NSMutableOrderedSet* observerList = [self.observersForObjects objectForKey:object.objectID];
    [observerList removeObject:observer];
}

-(void)removeObserver:(id<DPPApplicationObjectChangesDelegate>)observer
{
     if(observer==nil) return;
    for(NSManagedObjectID* objectID in self.observersForObjects.allKeys)
    {
        NSMutableOrderedSet* observerList = [self.observersForObjects objectForKey:objectID];
        [observerList removeObject:[WeakReference weakReferenceWithObject:observer]];
    }
}

-(void)notifyObserversOfChanges:(NSSet*)updatedObjects deletions:(NSSet*)deletedObjects aboutToChange:(BOOL)aboutTo
{
    //LH for each observed type, check if they are in the updated/deleted list and notify all observers.
    //Also remove any weak referenced objects that have been dealloc'd
    
    NSArray* updatedObjectIDs = [updatedObjects valueForKeyPath:@"objectID"];
    NSArray* deletedObjectIDs = [deletedObjects valueForKeyPath:@"objectID"];
    for(NSManagedObjectID* objectID in self.observersForObjects.allKeys)
    {
        NSMutableArray* deleteBin = [NSMutableArray array]; //LH keep track of observers that have been dealloc'd here
        NSOrderedSet* observerList = [[self.observersForObjects objectForKey:objectID] copy]; //LH copy here incase observer is added or removed in callback
        
        if([deletedObjectIDs containsObject:objectID])
        {
            NSArray *observerArray = [observerList copy];
            for(WeakReference* observeRef in observerArray)
            {
                if(observeRef.nonretainedObjectValue)
                {
                    id<DPPApplicationObjectChangesDelegate> observer = observeRef.nonretainedObjectValue;
                    
                    if(aboutTo)
                    {
                        if([observer respondsToSelector:@selector(applicationModelObjectWillDelete:)])
                        {
                            [observer applicationModelObjectWillDelete:[self.managedObjectContext objectWithID:objectID]];
                        }
                    }
                    else
                    {
                        if([observer respondsToSelector:@selector(applicationModelObjectDidDelete::)])
                        {
                            [observer applicationModelObjectDidDelete:objectID];
                        }
                    }
                }
                else
                {
                   [deleteBin addObject:observeRef]; 
                }
            }
        }
        else if([updatedObjectIDs containsObject:objectID])
        {
            NSArray *observerArray = [observerList copy];
           for(WeakReference* observeRef in observerArray)
           {
               if(observeRef.nonretainedObjectValue)
               {
                   id<DPPApplicationObjectChangesDelegate> observer = observeRef.nonretainedObjectValue;
                   
                   NSManagedObject* updateObject = [self.managedObjectContext objectWithID:objectID];
                   
                   if(updateObject)
                   {
                       if(aboutTo)
                       {
                            if([observer respondsToSelector:@selector(applicationModelObjectWillChange:)])
                            {
                                [observer applicationModelObjectWillChange:updateObject];
                            }
                       }
                       else
                       {
                           if([observer respondsToSelector:@selector(applicationModelObjectDidChange:)])
                           {
                                [observer applicationModelObjectDidChange:updateObject];
                           }
                       }
                   }
               }
               else
               {
                   [deleteBin addObject:observeRef];
               }
           }
        }
        //LH cleanup
        [[self.observersForObjects objectForKey:objectID] removeObjectsInArray:deleteBin];
    }
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

-(void)addMergeCompletion:(void (^)(void))completion
{
    if(__managedObjectContext == nil) return;
    
    if(__managedObjectContext != [DPPApplicationModel sharedInstance].managedObjectContext)
    {
        [[DPPApplicationModel sharedInstance] addMergeCompletion:completion forContext:__managedObjectContext];
    }
    else
    {
        NSLog(@"Added merge completion block on main context?");
    }
}

-(void)addMergeCompletion:(void (^)(void))completion forContext:(NSManagedObjectContext*)context
{
    if(context == nil || completion ==nil) return;
    @synchronized(self)
    {
        NSBlockOperation* completionOperation = [NSBlockOperation blockOperationWithBlock:completion];
        [_mergeCompletionList setObject:completionOperation forKey:[NSValue valueWithNonretainedObject:context]];
    }
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

-(NSMutableSet*)recycleBin
{
    @synchronized(self)
    {
        if(recycleBin==nil)
        {
            recycleBin = [NSMutableSet set];
        }
    }
    return recycleBin;
}

-(void)addToRecycleBin:(NSManagedObject*)managedObject
{//LH only use the main context's bin.....
    if(managedObject ==nil) return;
    @synchronized([DPPApplicationModel sharedInstance])
    {
        [[DPPApplicationModel sharedInstance].recycleBin addObject:managedObject.objectID];
    }
}


@end
