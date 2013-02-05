//
//  TLIndexPathItem.m
//  TractableLabs
//
//  Created by Tim Moose on 07/16/12.
//
//

#import "TLIndexPathItem.h"

@implementation TLIndexPathItem

- (id)initWithIdentifier:(id)identifier sectionName:(NSString *)sectionName cellIdentifier:(NSString *)cellIdentifier data:(id)data
{
    if (self = [super init]) {
        _identifier = identifier;
        _sectionName = sectionName;
        _cellIdentifier = cellIdentifier;
        _data = data;
    }
    return self;
}

- (NSUInteger)hash
{
    NSInteger hash = 0;
    hash += 31 * hash + [self.identifier hash];
    hash += 31 * hash + [self.sectionName hash];
    hash += 31 * hash + [self.cellIdentifier hash];
    hash += 31 * hash + [self.data hash];
    return hash;
}

- (BOOL)isEqual:(id)object
{
    if ([super isEqual:object]) return YES;
    if (object == nil) return NO;
    if (![object isKindOfClass:[TLIndexPathItem class]]) return NO;
    TLIndexPathItem *other = (TLIndexPathItem *)object;
    if (![TLIndexPathItem nilSafeObject:self.identifier isEqual:other.identifier]) return NO;
    if (![TLIndexPathItem nilSafeObject:self.sectionName isEqual:other.sectionName]) return NO;
    if (![TLIndexPathItem nilSafeObject:self.cellIdentifier isEqual:other.cellIdentifier]) return NO;
    if (![TLIndexPathItem nilSafeObject:self.data isEqual:other.data]) return NO;
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"sectionName=%@, identifier=%@", self.sectionName, self.identifier];
}

+ (BOOL) nilSafeObject:(NSObject *)object isEqual:(NSObject *)other
{
    if (object == nil && other == nil) return YES;
    if (object == nil || other == nil) return NO;
    return [object isEqual:other];
}

@end
