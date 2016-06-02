CFS library in C

This library now fully supports 32-bit operation and comes with an import
file, cfs32im.pas, for use of the 32-bit DLL from Delphi.


Revision history of the CFS, in brief:

Version 2.12

The C version of the CFS routines has been modified so that it can be
compiled with any memory model. Most memory allocated for data by the
CFS functions is allocated outside is allocated outside the default data
segment and is accessed by _far pointers.
The only changes this has made to the function specification is that a _far
pointer is used to access data buffers.
This affects the functions:
        WriteData
        ReadData
        GetChanData 
The function prototypes for these functions are now

short WriteData(short handle,unsigned short dataSection, long startOffset,
       unsigned short bytes,void _far *dataADS);

unsigned short GetChanData(short handle,short channel,
    unsigned short dataSection,long firstElement,
    unsigned short numElements,void _far *dataADS,long areaSize);

short ReadData(short handle,unsigned short dataSection, long startOffset,
      unsigned short bytes,void _far *dataADS);

Compare pages 40, 49, 50 of the manual for version 2.10 Feb 1991.

The .obj files provided have been compiled using the large model.
If you wish to use another memory model you will need to compile both
msio.c and cfs.c 
Thses use the header files depends.h msio.h and cfs.h


Version 2.13  05-Feb-92
Bug fix:
  OpenCFSFile fixed so that table pointer is reset if table is not in memory.
  This avoids confusion when a previosly opened file had been open with
  a table in memory.

Other changes:
 1. Some functions rearranged so that all non ANSI functions are now in
    msio.h (.c).
 2. SetComment changed so tit can be used when editing a file.
 3. The method of handling flags has been changed. (see new DOC)
 4. File opened in edit mode is only updated if actually modified.


Version 2.20 
This version works with DOS, Windows and the Macintosh operating systems.


Version 2.30    03/09/93
Improved version with CommitCFSFile function added.
This is used to write the head and data sections info to the disk file and
to commit all the data currently in buffers for the given handle.

The file VB_CFS.TXT contains a definition of the CFS interface for
use with Visual Basic. Import into your Basic program as text.


Version 2.40   02/May/96
Added CFSFileSize function. TDataKind changed to TCFSKind to
prevent name clash with SON library. Extended file open checks
to detect file too short to be a CFS file - get BADVER error
instead of read error. Changed pointer parameters to const forms
wherever appropriate.


Version 2.50  08/Nov/96
Changed GetVarVal, SetVarVal and DSFlags so that all of these
can be used freely on new files, with 0 specifing the new DS
and other section parameters specifying the DS as expected.
These changes are in the C version only.


Version 2.51 12/May/97
Changed SetDSChan and WriteData as above, both can be used on
all data sections of a new file, with DS set to 0 or n.

Version 2.52    May/98
The internal StoreTable routine will extend the memory table if
needed - was causing failures of Append DS

Version 2.60 24/Feb/99
Now uses malloc for memory allocations in WIN32, not GlobalAlloc.
The file table will extend as required to allow unlimited files
to be open. WIN32 file I/O functions are used throughout in
WIN32 build. A bug in AppendDS - the DS lookup table was being
mispositioned, causing corrupted DS info - has been fixed.

Version 2.7 may 2003
A new channel kind, subsidiary, has been added to allow storage
of error information.
