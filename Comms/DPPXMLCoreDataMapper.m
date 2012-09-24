//
//  DPPXMLCoreDataMapper.m
//  ContactsTest
//
//  Created by Lee Higgins on 28/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//


//This is an experimental class to explore if a generic mapper can be provided to map any dictionary based
//feed data to a core data model without requiring a 1 to 1 mapping between feed and core data model.
//The starting feed is XML but this could be applied to JSon as well by swapping the parser.

//NB: To start with I will not support nested entities in the feed (relationships in core data). I will add this later by swapping 
//the currentEntity and currentAttributes properties for a mutable array/stack instead of a single element. This way debugging and testing is kept simple. 

#import "DPPXMLCoreDataMapper.h"
#import "DPPApplicationModel.h"
//key names for plist format

#define kEntitiesKey @"Entities"
#define kAttributesKey @"Attributes"
#define kEntityNameKey  @"EntityName"
#define kBooleanPhrazesKey @"BooleanPhrazes"
#define kUniqueIdentifingAttributesKey @"XMLUniqueIdentifingAttributes"

@interface DPPXMLCoreDataMapper()

@property(nonatomic,retain) NSDictionary* mapping;
@property(nonatomic,retain) NSString* currentEntityName;
@property(nonatomic,retain) NSString* currentAttributeName;
@property(nonatomic,retain) NSString* currentAttributeValue;
@property(nonatomic,retain) NSMutableDictionary* currentAttributes;

@property(nonatomic,assign) NSInteger entitySaveCount;

-(void)saveCoreData;

@end

@implementation DPPXMLCoreDataMapper

@synthesize applicationModel;

@synthesize mapping;

@synthesize currentEntityName;
@synthesize currentAttributeName;
@synthesize currentAttributeValue;
@synthesize currentAttributes;

@synthesize entitySaveInterval;
@synthesize entitySaveCount;

@synthesize debugSlow;

-(DPPXMLCoreDataMapper*)initWithDictionary:(NSDictionary*)map
{
    self = [self init];
    if(self)
    {
        self.mapping = map;
    }
    return self;
}

-(DPPXMLCoreDataMapper*)initWithContentsOfFile:(NSString*)filename
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:filename];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    self = [self initWithDictionary:plistData];
    return self;
}

-(void)parseXMLStream:(NSInputStream *)xmlData
{
    entitySaveCount = 0;
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithStream:xmlData];
    xmlParser.delegate = self;
    if([xmlParser parse])
    {
        [self saveCoreData];
    }
}

-(void)parseXML:(NSData*)xmlData
{
    if(debugSlow)
    {
        NSLog(@"Warning! Debug mode slow parsing enabled (set debugSlow to NO to disable).");
    }
    entitySaveCount = 0;
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    xmlParser.delegate = self;
    if([xmlParser parse])
    {
        [self saveCoreData];
    }
}

-(NSDictionary*)mappingEntities
{
    return [mapping objectForKey:kEntitiesKey];
}

-(NSDictionary*)booleanPhrazes
{
    return [mapping objectForKey:kBooleanPhrazesKey];
}

-(NSString*)predicateStringForUniqueAttributes:(NSArray*)uniqueAttributes withMapping:(NSDictionary*)attributeMapping
{
    NSMutableString* predicateString = [NSMutableString string];
    BOOL firstAttribute = YES;
    
    //TODO needs to look at type and change the predicate "wording" i.e == for numbers instead of like etc..
    for(NSString* attributeName in uniqueAttributes)
    {
        if(!firstAttribute)
        {
            [predicateString appendString:@" AND "];
        }
        
        NSString* coreDataAttributeName = [attributeMapping objectForKey:attributeName];
        NSString* attributeValue = [currentAttributes objectForKey:attributeName];
        [predicateString appendFormat:@"(%@ like \"%@\")",coreDataAttributeName,attributeValue];
        firstAttribute = NO;
    }
    return predicateString;
}

-(BOOL)updateEntity:(NSManagedObject*)coreDataEntity withAttributes:(NSDictionary*)attributes usingTypes:attributeTypes andMapping:(NSDictionary*)attributeMapping 
{
    BOOL fullyMapped = YES;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    
    for(NSString* attribute in attributes.allKeys)
    {
        NSString* coreDataAttributeName = [attributeMapping objectForKey:attribute];
        if(coreDataAttributeName)
        {
            NSNumber* attributeTypeObj = [attributeTypes objectForKey:coreDataAttributeName];
            if(attributeTypeObj)
            {
                NSAttributeType attributeType = [attributeTypeObj unsignedIntValue];
                
                switch(attributeType)
                {
                    case NSStringAttributeType:
                    { //we are a string
                        [coreDataEntity setValue:[attributes objectForKey:attribute] forKey:coreDataAttributeName];
                    }
                        break;
                    case NSInteger16AttributeType:
                    case NSInteger32AttributeType:
                    case NSInteger64AttributeType:
                    case NSDoubleAttributeType:
                    case NSFloatAttributeType:
                    case NSDecimalAttributeType:
                    { //we are a number
                        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                        NSNumber * value = [numberFormatter numberFromString:[attributes objectForKey:attribute]];
                        [coreDataEntity setValue:value forKey:coreDataAttributeName];
                    }
                        break;
                    case NSBooleanAttributeType:
                    {
                        NSNumber * value = [[self booleanPhrazes] objectForKey:[attributes objectForKey:attribute]];
                        if(value)
                        {
                            [coreDataEntity setValue:value forKey:coreDataAttributeName];
                        }
                        else 
                        {
                            fullyMapped = NO;
                            NSLog(@"Boolean phraze not understood %@ in xml attribute %@ in xml entity %@",[attributes objectForKey:attribute], attribute,currentEntityName);
                        }
                    }
                        //TODO: rest of the types NSDate etc....
                        break;
                        
                }
            }
        }
        else 
        {
            fullyMapped = NO;
            NSLog(@"No attibute mapping for attribute %@ in Entity %@(xml name %@)",attribute,NSStringFromClass([coreDataEntity class]),currentEntityName);
        }
    }
    
    if((entitySaveCount % MAX(1,entitySaveInterval)) == 0)
    { //so we can save to flash every 'N' elements
        [self saveCoreData];
    }
    entitySaveCount++;
    
    return fullyMapped; 
}

-(NSManagedObject*)coreDataEntityWithName:(NSString*)coreDataEntityName description:(NSEntityDescription*)entity uniquelyIdentifiedByPredicate:(NSPredicate*)predicate
{//return a matching object, or new object if no match found....
    NSManagedObject* coreDataEntity = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:1];
    
    NSError* error=nil;
    NSArray* result = [applicationModel.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error)
    {
        NSLog(@"Error finding entity %@ error %@",currentEntityName,error.debugDescription);
    }
    
    if(result.count >0)
    {//found an existing entry to update.....
        coreDataEntity = [result objectAtIndex:0];
        NSLog(@"Updating entity %@ (UID: %@)", coreDataEntityName,predicate);
    }
    else 
    { //create new entity
        coreDataEntity = [NSEntityDescription
                          insertNewObjectForEntityForName:coreDataEntityName
                          inManagedObjectContext:applicationModel.managedObjectContext];
        NSLog(@"Creating new entity %@ (UID: %@)", coreDataEntityName,predicate);
    }
    return coreDataEntity;
}

-(void)saveCurrentEntity
{
    NSArray* uniqueAttributes = [[[self mappingEntities] objectForKey:currentEntityName] objectForKey:kUniqueIdentifingAttributesKey];
    NSDictionary* attributeMapping = [[[self mappingEntities] objectForKey:currentEntityName] objectForKey:kAttributesKey];
    
    //first try to find an existing object
    NSString* coreDataEntityName = [[[self mappingEntities] objectForKey:currentEntityName] objectForKey:kEntityNameKey];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:coreDataEntityName 
                                   inManagedObjectContext:applicationModel.managedObjectContext];
    
    //create a fast lookup for the types.... (TODO: can do this on load and cache if needed)
    NSMutableDictionary* attributeTypes = [NSMutableDictionary dictionaryWithCapacity:entity.properties.count]; 
    for (NSAttributeDescription *property in entity) 
    {
        [attributeTypes setObject:[NSNumber numberWithUnsignedInt:property.attributeType] forKey:property.name];
    }
    
    //create the predicate from the unique indent attributes
    
    NSString* predicateString = [self predicateStringForUniqueAttributes:uniqueAttributes withMapping:attributeMapping];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];

    NSManagedObject* coreDataEntity = [self coreDataEntityWithName:coreDataEntityName description:entity uniquelyIdentifiedByPredicate:predicate];
    
    [self updateEntity:coreDataEntity withAttributes:currentAttributes usingTypes:attributeTypes andMapping:attributeMapping];
    
    self.currentEntityName = nil;
    self.currentAttributes = nil;
    
    if(debugSlow)
    {
        [NSThread sleepForTimeInterval:2.0]; //slow things down for testing...
    }
}

-(void)saveCoreData
{
    NSError* error=nil;
    [applicationModel.managedObjectContext save:&error];
    if(error)
    {
        NSLog(@"Error saving coredata error %@",error.debugDescription);
        //TODO: add Debug assert 
    }
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if(self.currentEntityName)
    { //must be attribute
        self.currentAttributeName = elementName;
    }
    else 
    { //must be entity 
        NSString* coreDataEntityName = [[[self mappingEntities] objectForKey:elementName] objectForKey:kEntityNameKey];
        if(coreDataEntityName)
        {
            self.currentEntityName = elementName;
            self.currentAttributes = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([self.currentEntityName isEqualToString:elementName])
    {//end the entity
        [self saveCurrentEntity];
    }
    else if([self.currentAttributeName isEqualToString:elementName])
    {//end the attribute
        [self.currentAttributes setObject:currentAttributeValue forKey:currentAttributeName];
        self.currentAttributeName = nil;
        self.currentAttributeValue = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(currentAttributeName)
    {//if we have a current attribute set the value
        self.currentAttributeValue = string;
    }
}


@end
