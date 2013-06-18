
#import "ECCellType.h"
NSString* reuseIdentifierForCellType(ECCellType type)
{
    switch (type) {
        case ECCellTypeAddFuture:
            return @"AddFutureCell";
        case ECCellTypeAddPast:
            return @"AddPastCell";
        case ECCellTypeToday:
            return @"TodayCell";
        case ECCellTypeFutureShows: //purposely left blank so goes to next one
        case ECCellTypePastShows:
            return @"HorizontalCell";
        default:
            return @"Cell";
    }
}

BOOL cellTypeNeedsUpdating (ECCellType type) {
    return type == ECCellTypeFutureShows || type == ECCellTypePastShows;
}