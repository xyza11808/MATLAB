# Microsoft Developer Studio Generated NMAKE File, Format Version 4.10
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=CFS32 - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to CFS32 - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "CFS32 - Win32 Release" && "$(CFG)" != "CFS32 - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "CFS32.mak" CFG="CFS32 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "CFS32 - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "CFS32 - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "CFS32 - Win32 Release"
CPP=cl.exe
RSC=rc.exe
MTL=mktyplib.exe

!IF  "$(CFG)" == "CFS32 - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "WinRel"
# PROP BASE Intermediate_Dir "WinRel"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "WinRel"
# PROP Intermediate_Dir "WinRel"
OUTDIR=.\WinRel
INTDIR=.\WinRel

ALL : ".\CFS32.dll"

CLEAN : 
	-@erase ".\CFS32.dll"
	-@erase ".\WinRel\CFS32.exp"
	-@erase ".\WinRel\CFS32.lib"
	-@erase ".\WinRel\CFSDLL.OBJ"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /YX /c
# ADD CPP /nologo /MD /W3 /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /c
# SUBTRACT CPP /Fr /YX
CPP_PROJ=/nologo /MD /W3 /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\WinRel/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x809 /d "NDEBUG"
# ADD RSC /l 0x809 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/CFS32.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 /nologo /subsystem:windows /dll /pdb:none /machine:I386 /out:"CFS32.dll"
LINK32_FLAGS=/nologo /subsystem:windows /dll /pdb:none /machine:I386\
 /def:".\CFS32.DEF" /out:"CFS32.dll" /implib:"$(OUTDIR)/CFS32.lib" 
DEF_FILE= \
	".\CFS32.DEF"
LINK32_OBJS= \
	".\WinRel\CFSDLL.OBJ"

".\CFS32.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "CFS32 - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "WinDebug"
# PROP BASE Intermediate_Dir "WinDebug"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "WinDebug"
# PROP Intermediate_Dir "WinDebug"
OUTDIR=.\WinDebug
INTDIR=.\WinDebug

ALL : "$(OUTDIR)\CFS32.dll"

CLEAN : 
	-@erase "$(OUTDIR)\CFS32.dll"
	-@erase "$(OUTDIR)\CFS32.ilk"
	-@erase ".\WinDebug\CFS32.exp"
	-@erase ".\WinDebug\CFS32.lib"
	-@erase ".\WinDebug\CFS32.pdb"
	-@erase ".\WinDebug\CFSDLL.OBJ"
	-@erase ".\WinDebug\vc40.idb"
	-@erase ".\WinDebug\vc40.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MT /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /c
# ADD CPP /nologo /MDd /W3 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /MDd /W3 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/CFS32.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\WinDebug/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x809 /d "_DEBUG"
# ADD RSC /l 0x809 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/CFS32.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 /nologo /subsystem:windows /dll /debug /machine:I386 /out:"..\Signal\Windebug\CFS32.dll"
LINK32_FLAGS=/nologo /subsystem:windows /dll /incremental:yes\
 /pdb:"$(OUTDIR)/CFS32.pdb" /debug /machine:I386 /def:".\CFS32.DEF"\
 /out:"..\Signal\Windebug\CFS32.dll" /implib:"$(OUTDIR)/CFS32.lib" 
DEF_FILE= \
	".\CFS32.DEF"
LINK32_OBJS= \
	".\WinDebug\CFSDLL.OBJ"

"$(OUTDIR)\CFS32.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "CFS32 - Win32 Release"
# Name "CFS32 - Win32 Debug"

!IF  "$(CFG)" == "CFS32 - Win32 Release"

!ELSEIF  "$(CFG)" == "CFS32 - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\CFS32.DEF

!IF  "$(CFG)" == "CFS32 - Win32 Release"

!ELSEIF  "$(CFG)" == "CFS32 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\CFSDLL.C
DEP_CPP_CFSDL=\
	".\Cfs.c"\
	".\Cfs.h"\
	{$(INCLUDE)}"\Errors.h"\
	{$(INCLUDE)}"\machine.h"\
	
NODEP_CPP_CFSDL=\
	".\CfsConv.h"\
	

!IF  "$(CFG)" == "CFS32 - Win32 Release"


".\WinRel\CFSDLL.OBJ" : $(SOURCE) $(DEP_CPP_CFSDL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "CFS32 - Win32 Debug"


".\WinDebug\CFSDLL.OBJ" : $(SOURCE) $(DEP_CPP_CFSDL) "$(INTDIR)"


!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
