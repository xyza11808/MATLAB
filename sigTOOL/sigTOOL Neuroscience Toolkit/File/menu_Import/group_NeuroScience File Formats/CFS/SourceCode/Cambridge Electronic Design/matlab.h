#define FAR

/*****************************************************************************
**
** machine.h
**
** Copyright (c) Cambridge Electronic Design Limited 1991,1992
**
** This file is included at the start of 'C' or 'C++' source file to define
** things needed to make Macintosh DOS and Windows sources more compatible
**
** Revision History
**
** 10/Jun/91  PNC   First Version
**  3/Mar/92  TDB   Added support for non-Windows DOS. Now expects to be 
**                  included after windows.h.
** 23/Jun/92  GPS   Tidied up. SONAPI definitions moved to son.h
** 27/Jul/92  GPS   Made routines that need to be far in MSDOS as F_xxxxxx
**                  and mapped this to actual name. Also added LPSTR and
**                  DWORD definitions.
** 24/Feb/93  PNC   Added new defines _IS_MSDOS_ for actual msdos (not for
**                  windows) and _IS_WINDOWS_ for windows (16 or 32 bit)
**
** 14/Jun/93  KJ    Made few changes, enabling it to be used by CFS for DOS,
**                  Windows and Macintosh.
**
** 01/Oct/93  PNC   Defined _near for NT 32 bit compile as this is an invalid
**                  keyword under this compiler.
**
** 17/Dec/93  PNC   DllExport and DllImport added to enable classes to be 
**                  exported from dlls more easily in NT 32 bit linker.
**                  Also coord changed to long for 16 bit windows operation.
**
** 20/Jan/94  PNC   Added support for Borland C++ not tested by us, but
**                  tested by a customer.
**
** 25/Jan/94  MAE   Defines added for DOS that should have been there 
**                  previously and F_memmove.
**
** 27/Oct/94  MAE   Added FDBL_MAX defines.
**
** 02/Feb/95  GPS   WINNT changed to WIN32 to accomodate Windows 95.
**
** 08/Jun/95  TDB   _fstrrchr defined as strrchr for WIN32 builds.
**
** 03/May/96  KJ    LPCSTR defined as const char* for Mac builds.
**
** 29/Jul/97  TDB   Tweaked for use with Borland C++ Builder
**
** 03/Dec/98  TDB   Added F_malloc and F_free for Windows purposes
**
*****************************************************************************/

/*
** Borland C++ Builder notes:
**
** This compiler defines both __MSDOS__ and __WIN32__, I have mapped
** __WIN32__ to WIN32 so these defines are used, which work fine.
*/

/*****************************************************************************
012345678901234567890123456789012345678901234567890123456789012345678901234567
*****************************************************************************/

#ifndef __MACHINE__
    #define __MACHINE__

    #ifdef macintosh
        #include <types.h>        /* Needed for various types               */
        #include <memory.h>       /* for NewHandle etc                      */
        #include <string.h>       /* for string manipulations               */
    #else
        #include <sys\types.h>    /* Needed for various types               */
        #include <sys\stat.h>                            /*    ditto        */
    #endif
    
    #include <float.h>        /* for LDBL_DIG                           */

    #ifdef MSDOS              /* first see if we are aiming at msdos result */
       #define _IS_MSDOS_     /* if so define our ms dos symbol             */
    #endif

    #ifdef __MSDOS__          /* Borland C++ compiler defines this          */
       #define _IS_MSDOS_     /* if so define our ms dos symbol             */
       #define _dup   dup     /* difference in library name                 */
    #endif

    #ifdef __WIN32__
       #define WIN32
    #endif

    #ifdef WIN32            /* if its windows define our windows symbol   */
       #define _IS_WINDOWS_   /* WIN32 is defined for 32-bit at moment    */
       #undef _IS_MSDOS_      /* and we arent doing msdos after all         */
    #endif

    #ifdef _INC_WINDOWS       /* the alternative windows symbolic defn      */
       #ifndef _IS_WINDOWS_   /* as above but _INC_WINDOWS is for 16 bit    */
          #define _IS_WINDOWS_
       #endif
       #undef _IS_MSDOS_      /* and we arent doing msdos after all         */
    #endif

    #ifndef WIN32
    typedef short BOOLEAN;
    #endif

    #ifndef TRUE
       #define TRUE 1
       #define FALSE 0
    #endif


    #ifdef _IS_WINDOWS_           /* Now set up for windows use             */
       #ifdef WIN32             /* if we are in NT all is SMALL           */
       #define F_memcpy memcpy    /* Define model-independent routines      */
       #define F_memmove memmove
       #define F_strlen strlen
       #define F_strcat strcat
       #define F_strcpy strcpy
       #define F_strcmp strcmp
       #define F_strncat strncat
       #define F_strncpy strncpy
       #define F_strncmp strncmp
       #define F_strchr strchr
       #define _fstrrchr strrchr 
       #define _near              /* stop compiler errors for 32 bit compile*/
       #define DllExport __declspec(dllexport)
       #define DllImport __declspec(dllimport)
       #else
       #define F_memcpy _fmemcpy  /* Define model-independent routines      */
       #define F_memmove _fmemmove
       #define F_strlen lstrlen
       #define F_strcat lstrcat
       #define F_strcpy lstrcpy
       #define F_strcmp lstrcmp
       #define F_strncat _fstrncat
       #define F_strncpy _fstrncpy
       #define F_strncmp _fstrncmp
       #define F_strchr _fstrchr
       #define DllExport
       #define DllImport
       #endif

       typedef long Coord;        /* this is LONG in the MacApp definitions */
       typedef double fdouble;
       #define FDBL_DIG DBL_DIG
       #define FDBL_MAX DBL_MAX
       typedef HGLOBAL THandle;

       #define F_malloc         malloc
       #define F_free           free

       #define M_AllocMem(x)     GlobalAlloc(GMEM_MOVEABLE,x)
       #define M_AllocClear(x)   GlobalAlloc(GMEM_MOVEABLE|GMEM_ZEROINIT,x)
       #define M_FreeMem(x)      GlobalFree(x)
       #define M_LockMem(x)      GlobalLock(x)
       #define M_MoveLockMem(x)  GlobalLock(x)
       #define M_UnlockMem(x)    (GlobalUnlock(x)==0)
       #define M_NewMemSize(x,y) (x = GlobalReAlloc(x,y,GMEM_MOVEABLE))
       #define M_GetMemSize(x)   GlobalSize(x)   
   #endif /* _IS_WINDOWS_ */

   #ifdef _IS_MSDOS_              /* and this is the stuff for MS-DOS only  */
       #define F_memcpy _fmemcpy  /* Define model-independent routines */
       #define F_memmove _fmemmove
       #define F_strlen _fstrlen
       #define F_strcat _fstrcat
       #define F_strcpy _fstrcpy
       #define F_strcmp _fstrcmp
       #define F_strncat _fstrncat
       #define F_strncpy _fstrncpy
       #define F_strncmp _fstrncmp
       #define F_strchr _fstrchr
       #define F_malloc _fmalloc
       #define F_free   _ffree
       #define F_calloc  _fcalloc
       #define F_realloc _frealloc
       #define F_msize   _fmsize
       #define FAR _far
       #define PASCAL pascal
       #define BOOL short
       #define DllExport
       #define DllImport

       typedef double fdouble;
       #define FDBL_DIG DBL_DIG
       #define FDBL_MAX DBL_MAX
       typedef char _far * LPSTR;
       typedef unsigned short WORD;
       typedef unsigned long DWORD;
       typedef unsigned char BYTE;
       typedef void _far * THandle; /* dummy to allow dos compiles          */
       typedef WORD _far * HWND;    /* dummy to allow dos compiles          */
       typedef WORD _far * LPWORD;  /* dummy to allow dos compiles          */

       #define M_AllocMem(x)     F_malloc(x)
       #define M_AllocClear(x)   F_calloc(x)
       #define M_FreeMem(x)      F_free(x)
       #define M_LockMem(x)      (x)
       #define M_MoveLockMem(x)  (x)
       #define M_UnlockMem(x)    (x != NULL)
       #define M_NewMemSize(x,y) F_realloc(x,y)
       #define M_GetMemSize(x)   F_msize(x)
    #endif  /* _IS_MSDOS_ */

    #ifdef macintosh
        #define F_memcpy memcpy
        #define F_memmove memmove
        #define F_strlen strlen
        #define F_strcat strcat
        #define F_strcpy strcpy
        #define F_strcmp strcmp
        #define F_strncat strncat
        #define F_strncpy strncpy
        #define F_strncmp strncmp
        #define F_strchr strchr
        #define FAR
        #define PASCAL
        #define _far
        #define _near
        #define DllExport
        #define DllImport

        #define FDBL_DIG LDBL_DIG
        #define FDBL_MAX LDBL_MAX
        typedef char * LPSTR;
        typedef const char * LPCSTR;
        typedef unsigned short WORD;
        typedef unsigned long  DWORD;
        typedef unsigned char  BYTE;
        typedef long double fdouble;
        typedef long Coord;     /*  Borrowed from MacApp */
        typedef Handle THandle;

        #define M_AllocMem(x)     NewHandle(x)
        #define M_AllocClear(x)   NewHandleClear(x)
        #define M_FreeMem(x)      DisposHandle(x)
        #define M_LockMem(x)      (HLock(x),*x)
        #define M_MoveLockMem(x)  (HLockHi(x),*x)
        #define M_UnlockMem(x)    (HUnlock(x),TRUE)
        #define M_NewMemSize(x,y) (SetHandleSize(x,y),MemError() == 0)
        #define M_GetMemSize(x)   GetHandleSize(x)
    #endif  /* macintosh */


#endif /* not defined __MACHINE__ */

/***************************************************************************** 
**
** cfs.h
**                                                               78 cols --->*
** Header file for MSC version of CFS functions.
** Definitions of the structures and routines for the CFS filing             *
** system. This is the include file for standard use, all access             *
** is by means of functions - no access to the internal CFS data. The file   *
** machine.h provides some common definitions across separate platforms,     *
** note that the MS variants are designed to accomodate medium model - far   *
** pointers are explicitly used where necessary.
**
** CFSAPI Don't declare this to give a pascal type on the Mac, there is a MPW
**        compiler bug that corrupts floats passed to pascal functions!!!!!!
**
*/

#ifndef __CFS__
#define __CFS__

#include "machine.h"

#ifdef macintosh                /* define CFSCONVERT in here if you want it */
    #include <Types.h>
    #include <Files.h>
    #include <Errors.h>
    #define  USEHANDLES
    #define  CFSAPI(type) type
    #undef   LLIO                   /* LLIO is not used for Mac             */
#endif                              /* End of the Mac stuff, now for DOS    */

#ifdef _IS_MSDOS_
    #define  qDebug 0               /* only used to debug Mac stuff         */
    #undef   USEHANDLES
    #include <malloc.h>
    #include <dos.h>
    #include <io.h>                         /* MSC I/O function definitions */
    #include <fcntl.h>
    #include <errno.h>
    #define  LLIO                   /* We can use LLIO for MSC/DOS          */
    #define  CFSAPI(type) type _pascal
#endif

#ifdef _IS_WINDOWS_
    #include <io.h>                         /* MSC I/O function definitions */
    #include <fcntl.h>
    #define  qDebug 0               /* only used to debug Mac stuff         */
    #define  CFSAPI(type) type WINAPI
    #ifdef WIN32
      #undef   LLIO
      #undef   USEHANDLES
    #else
      #define  LLIO                     /* We can use LLIO for MSC/Windows  */
      #define  USEHANDLES               /* use handles under 16-bit windows */
    #endif
#endif

#define FILEVAR 0              /* Constants to indicate whether variable is */
#define DSVAR   1                         /* file or data section variable. */
#define INT1    0                            /* DATA VARIABLE STORAGE TYPES */
#define WRD1    1
#define INT2    2
#define WRD2    3
#define INT4    4
#define RL4     5
#define RL8     6
#define LSTR    7
#define SUBSIDIARY 2                            /* Chan Data Storage types */
#define MATRIX  1
#define EQUALSPACED 0                            /* Chan Data Storage types */

#define noFlags 0                                 /* Declare a default flag */

/* Definitions of bits for DS flags */

#define FLAG7   1
#define FLAG6   2
#define FLAG5   4
#define FLAG4   8
#define FLAG3   16
#define FLAG2   32
#define FLAG1   64
#define FLAG0   128
#define FLAG15  256
#define FLAG14  512
#define FLAG13  1024
#define FLAG12  2048
#define FLAG11  4096
#define FLAG10  8192
#define FLAG9   16384
#define FLAG8   32768


/* define numbers of characters in various string types */

#define DESCCHARS    20
#define FNAMECHARS   12
#define COMMENTCHARS 72
#define UNITCHARS    8

/*character arrays used in data structure */

typedef char  TDataType;
typedef char  TCFSKind;
typedef char  TDesc[DESCCHARS+2];        /* Names in descriptions, 20 chars */
typedef char  TFileName[FNAMECHARS+2];              /* File names, 12 chars */
typedef char  TComment[COMMENTCHARS+2];            /* Comment, 72 chars max */
typedef char  TUnits[UNITCHARS+2];                    /* For units, 8 chars */

/* other types for users benefit */

typedef WORD TSFlags;

/*  for data and data section variables */

#if defined(_IS_MSDOS_) || defined(_IS_WINDOWS_)
#pragma pack(1)
#endif

typedef struct
{
   TDesc     varDesc;                      /* users description of variable */
   TDataType vType;                               /* one of 8 types allowed */
   char      zeroByte;                       /* for MS Pascal compatibility */
   TUnits    varUnits;                              /* users name for units */
   short     vSize;  /* for type lstr gives no. of chars +1 for length byte */
} TVarDesc;

#if defined(_IS_MSDOS_) || defined(_IS_WINDOWS_)
#pragma pack()
#endif


typedef char           FAR * TpStr;
typedef const char     FAR * TpCStr;
typedef short          FAR * TpShort;
typedef float          FAR * TpFloat;
typedef long           FAR * TpLong;
typedef void           FAR * TpVoid;
typedef TSFlags        FAR * TpFlags;
typedef TDataType      FAR * TpDType;
typedef TCFSKind       FAR * TpDKind;
typedef TVarDesc       FAR * TpVDesc;
typedef const TVarDesc FAR * TpCVDesc;
typedef THandle        FAR * TpHandle;
typedef signed char    FAR * TpSStr;
typedef WORD           FAR * TpUShort;

#ifdef macintosh
    typedef int     fDef;        /* file handle means something else on Mac */
#else
  #ifdef WIN32
    typedef HANDLE  fDef;                              /* WIN32 file handle */
  #else
    #ifdef LLIO
      typedef short fDef;                                    /* file handle */
    #else
      typedef FILE* fDef;                              /* stream identifier */
    #endif
  #endif
#endif


#ifdef __cplusplus
extern "C" {
#endif

/*
** Now definitions of the functions defined in the code
*/

#if defined(_IS_MSDOS_) || defined(_IS_WINDOWS_)
CFSAPI(short) CreateCFSFile(TpCStr   fname,
                            TpCStr   comment,
                            WORD     blocksize,
                            short    channels,
                            TpCVDesc fileArray,
                            TpCVDesc DSArray,
                            short    fileVars,
                            short    DSVars);
#endif

#ifdef macintosh
CFSAPI(short) CreateCFSFile(ConstStr255Param   fname,          
                            TpCStr   comment,   
                            WORD     blockSize, 
                            short    channels,  
                            TpCVDesc fileArray, 
                            TpCVDesc DSArray,   
                            short    fileVars,  
                            short    DSVars,    
                            short    vRefNum,   
                            long     dirID,     
                            OSType   creator,   
                            OSType   fileType);  
#endif

CFSAPI(void)  SetFileChan(short     handle,
                          short     channel,
                          TpCStr    channelName,
                          TpCStr    yUnits,
                          TpCStr    xUnits,
                          TDataType dataType,
                          TCFSKind  dataKind,
                          short     spacing,
                          short     other);

CFSAPI(void)  SetDSChan(short handle,
                        short channel,
                        WORD  dataSection,
                        long  startOffset,
                        long  points,
                        float yScale,
                        float yOffset,
                        float xScale,
                        float xOffset);

CFSAPI(short) WriteData(short  handle,
                        WORD   dataSection,
                        long   startOffset,
                        WORD   bytes,
                        TpVoid dataADS);

CFSAPI(short) ClearDS(short   handle);

CFSAPI(void)  SetWriteData(short  handle,
                           long   startOffset,
                           long   bytes);

CFSAPI(long)  CFSFileSize(short  handle);

CFSAPI(short) InsertDS(short   handle,
                       WORD    dataSection,
                       TSFlags flagSet);

CFSAPI(short) AppendDS(short   handle,
                       long    lSize,
                       TSFlags flagSet);

CFSAPI(void)  RemoveDS(short  handle,
                       WORD   dataSection);

CFSAPI(void)  SetComment(short  handle,
                         TpCStr comment);

CFSAPI(void)  SetVarVal(short  handle,
                        short  varNo,
                        short  varKind,
                        WORD   dataSection,
                        TpVoid varADS);

CFSAPI(short) CloseCFSFile(short  handle);

#if defined(_IS_MSDOS_) || defined(_IS_WINDOWS_)
CFSAPI(short) OpenCFSFile(TpCStr  fname,
                          short   enableWrite,
                          short   memoryTable);
#endif

#ifdef macintosh
CFSAPI(short) OpenCFSFile(ConstStr255Param   fname,
                          short   enableWrite,
                          short   memoryTable,    
                          short   vRefNum,   
                          long    dirID);

#endif

CFSAPI(void) GetGenInfo(short   handle,
                        TpStr   time,
                        TpStr   date,
                        TpStr   comment);

CFSAPI(void) GetFileInfo(short    handle,
                         TpShort  channels,
                         TpShort  fileVars,
                         TpShort  DSVars,
                         TpUShort dataSections);

CFSAPI(void) GetVarDesc(short   handle,
                        short   varNo,
                        short   varKind,
                        TpShort varSize,
                        TpDType varType,
                        TpStr   units,
                        TpStr   description);

CFSAPI(void) GetVarVal(short  handle,
                       short  varNo,
                       short  varKind,
                       WORD   dataSection,
                       TpVoid varADS);

CFSAPI(void) GetFileChan(short   handle, 
                         short   channel,
                         TpStr   channelName,
                         TpStr   yUnits,
                         TpStr   xUnits,
                         TpDType dataType,
                         TpDKind dataKind,
                         TpShort spacing,
                         TpShort other);

CFSAPI(void) GetDSChan(short   handle,
                       short   channel,
                       WORD    dataSection,
                       TpLong  startOffset,
                       TpLong  points,
                       TpFloat yScale,
                       TpFloat yOffset,
                       TpFloat xScale,
                       TpFloat xOffset);

CFSAPI(WORD) GetChanData(short  handle,
                         short  channel,
                         WORD   dataSection,
                         long   firstElement,
                         WORD   numberElements,
                         TpVoid dataADS,
                         long   areaSize);

CFSAPI(long) GetDSSize(short  handle,
                       WORD   dataSection);

CFSAPI(short) ReadData(short  handle,
                       WORD   dataSection,
                       long   startOffest,
                       WORD   bytes,
                       TpVoid dataADS);

CFSAPI(WORD) DSFlagValue(int   nflag);

CFSAPI(void) DSFlags(short   handle,
                     WORD    dataSection,
                     short   setIt,
                     TpFlags pflagSet);

CFSAPI(short) FileError(TpShort handleNo,
                        TpShort procNo,
                        TpShort errNo);

CFSAPI(short) CommitCFSFile(short handle);

#ifdef __cplusplus
}
#endif

#endif /* __CFS__ */
