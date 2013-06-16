//
//  ECCellType.h
//  Encore
//
//  Created by Shimmy on 2013-06-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#ifndef Encore_ECCellType_h
#define Encore_ECCellType_h

typedef enum {
    ECCellTypeAddPast,
    ECCellTypePastShows,
    ECCellTypeToday,
    ECCellTypeFutureShows,
    ECCellTypeAddFuture,
    ECNumberOfSections
} ECCellType;

NSString* reuseIdentifierForCellType(ECCellType type);

#endif
