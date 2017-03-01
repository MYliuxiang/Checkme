//
//  typesDef.h
//  BTHealth
//
//  Created by demo on 13-10-25.
//  Copyright (c) 2013年 LongVision's Mac02. All rights reserved.
//

#ifndef BTHealth_typesDef_h
#define BTHealth_typesDef_h

typedef unsigned char U8;
typedef unsigned short U16;
typedef unsigned int U32;


/**
 *  LeadKind
 */
#define kLeadKind_Hand 0x01 //0000 0001
#define kLeadKind_Chest 0x02 //0000 0010
#define kLeadKind_Wire 0x03 //0000 0100
#define kLeadKind_Wire12 0x04 //0000 1000
typedef U8 LeadKind_t;

/**
 *  TypeForFilter
 */
#define kTypeForFilter_Pass 0x01 //0000 0001
#define kTypeForFilter_Fail 0x02 //0000 0010
#define kTypeForFilter_VoiceMemo 0x04 //0000 0100
typedef U8 TypeForFilter_t;


typedef enum{
    kPassKind_Pass = 0 ,
    kPassKind_Fail,
    kPassKind_Others
}PassKind_t;

typedef enum{
    kFilterKind_Normal = 0 ,
    kFilterKind_Wide
}FilterKind_t;
#endif
