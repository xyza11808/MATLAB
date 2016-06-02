// string=ABFGetDeltas(dllname, filename)

////////////////////////////////////////////////////////
////DO NOT USE THIS - UNDER DEVELOPMENT AND UNTESTED////
////////////////////////////////////////////////////////


// Supports the ABF data file formats for pClamp 10 and earlier:
// AxoScope 1 to 10, Clampex 6 to 10, Fetchex 6 and AxoTape 2.
// Works via the ABFFIO.DLL supplied by Axon Instruments.
// See http://www.moleculardevices.com/pages/software/developer_info.html

//% -------------------------------------------------------------------------
//% Author: Malcolm Lidierth 07/07
//% Copyright © The Author & King's College London 2007-
//% -------------------------------------------------------------------------


#include "windows.h"
#include "mex.h"
#include "abffiles.h"

typedef void (CALLBACK* ISABFFILE) (const char *, int *, int *);
typedef BOOL (CALLBACK* READOPEN)(const char *, int *, UINT, ABFFileHeader *, UINT *, DWORD *, int * );
typedef BOOL (CALLBACK* READDELTAS)(int, const ABFFileHeader *, DWORD, ABFDelta *, UINT, int *);
typedef BOOL (CALLBACK* FORMATDELTA)(const ABFFileHeader *, const ABFDelta *, char *, UINT, int *);
typedef BOOL (CALLBACK* FILECLOSE) (int, int *);


void ExitOnError(const char *str, int err)
{
    mexPrintf("ABFGetFileInfo: %s (#%d)\n",str, err);
    return;
}


//MATLAB entry point
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    //*********************************************************************
    //Axon related variables
    char dllpathandname[512];
    char filename[512];
    int Error=0;
    int Error2=0;
    ABFFileHeader FileHeader;
    int FileHandle;
    UINT uFlags=0;
    UINT maxSamples=ABF_MAX_TRIAL_SAMPLES;
    DWORD maxEpisodes=0;
    DWORD episode=0;
    double *pTim;
    
    
    //Locals
    int dim[2]={1,1};
    int channel=0;
    int sweep=0;
    int i;
    int FileType;
    
    //Function pointers
    ISABFFILE IsABFFile;
    READOPEN ReadOpen;
    FILECLOSE FileClose;
    READDELTAS ReadDeltas;
    FORMATDELTA FormatDelta;
    
    UINT maxDeltas;
    ABFDelta Delta[512];
    char buffer[4096]="No Deltas";
    
    //Pointer to DLL
    HINSTANCE hinstLib;
    //*********************************************************************
    
    //Initialize outputs to zero in case of returning on error
    for (i=0;i<=nlhs;i++)
    {
        plhs[i]=mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
        pTim=(double *)mxGetPr(plhs[i]);
        *pTim=0;
    }
    
    
    //Get the input arguments
    
    // DLL path & name
    if (nrhs>=1 && mxGetClassID(prhs[0])==mxCHAR_CLASS)
    {
        mxGetString(prhs[0], &dllpathandname[0], 512);
    }
    else
    {
        ExitOnError("DLL path and name required as string",-1);
        return;
    }
    
    // ABF filename
    if (nrhs>=2 && mxGetClassID(prhs[1])==mxCHAR_CLASS)
    {
        mxGetString(prhs[1], &filename[0], 512);
    }
    else
    {
        ExitOnError("Data file path and name required as string",-1);
        return;
    }
    
    
    
    //*********************************************************************
    //Load the Axon DLL
    hinstLib = LoadLibrary(dllpathandname);
    if (hinstLib == NULL){
        ExitOnError("DLL not found",-1);
        return;
    }
    
    //Set up the pointers to the routines in the Axon Instruments DLL...
    IsABFFile=(ISABFFILE)GetProcAddress(hinstLib,"ABF_IsABFFile");
    ReadOpen=(READOPEN)GetProcAddress(hinstLib,"ABF_ReadOpen");
    ReadDeltas=(READDELTAS)GetProcAddress(hinstLib,"ABF_ReadDeltas");
    FormatDelta=(FORMATDELTA)GetProcAddress(hinstLib,"ABF_FormatDelta");
    FileClose=(FILECLOSE)GetProcAddress(hinstLib, "ABF_Close");
    
    
    //... and make sure they are all there
    if (IsABFFile==NULL || ReadOpen==NULL || ReadDeltas==NULL || FormatDelta==NULL || FileClose==NULL )
    {
        // Error
        ExitOnError("Required routines not found in DLL",-1);
        FreeLibrary(hinstLib);
        return;
    }
    
    //Check we have an ABF file and its type
    (*IsABFFile)(&filename[0], &FileType, &Error);
    if (Error!=0)
    {
        ExitOnError("Not an ABF File", Error);
        FreeLibrary(hinstLib);
        return;
    }
    
    
    //Open the file for reading
    (*ReadOpen)(&filename[0], &FileHandle, ABF_ALLOWOVERLAP, &FileHeader,
    &maxSamples, &maxEpisodes, &Error);
    if (Error!=0)
    {
        ExitOnError("Call to ABF_ReadOpen failed", Error);
        FreeLibrary(hinstLib);
        return;
    }
    if (FileHeader.lNumDeltas>=1 && FileHeader.lDeltaArrayPtr>4)
    {
        maxDeltas=FileHeader.lNumDeltas;
        if (maxDeltas>512)
        {
            maxDeltas=512;
        }
        (*ReadDeltas)(FileHandle, &FileHeader, 0, &Delta[0], maxDeltas, &Error);
        if (Error!=0)
        {
            ExitOnError("ReadDelta failed", Error);
            (*FileClose)(FileHandle, &Error);
            FreeLibrary(hinstLib);
        }

        (*FormatDelta)(&FileHeader, &Delta[0], &buffer[0], 4096, &Error);
        if (Error!=0)
        {
            ExitOnError("FormatDeltas failed", Error);
            (*FileClose)(FileHandle, &Error);
            FreeLibrary(hinstLib);
        }
    }
    
    if (nlhs>=1)
    {
        plhs[0]=mxCreateString(&buffer[0]);
    }
    
    
    //Free the library
    (*FileClose)(FileHandle, &Error);
    FreeLibrary(hinstLib);
    return;
}
//*********************************************************************


