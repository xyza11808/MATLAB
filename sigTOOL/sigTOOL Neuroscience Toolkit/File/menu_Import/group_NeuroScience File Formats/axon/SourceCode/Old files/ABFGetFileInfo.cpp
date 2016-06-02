// s=ABFGetFileInfo(dllname, filename)

// Supports the ABF data file formats for pClamp 10 and earlier:
// AxoScope 1 to 10, Clampex 6 to 10, Fetchex 6 and AxoTape 2.
// Works via the ABFFIO.DLL supplied by Axon Instruments.
// See http://www.moleculardevices.com/pages/software/developer_info.html

//% -------------------------------------------------------------------------
//% Author: Malcolm Lidierth 07/07
//% Copyright © The Author & King's College London 2007-
//% -------------------------------------------------------------------------

#include "windows.h"
#include <string.h>
#include "mex.h"
#include "abffiles.h"

typedef void (CALLBACK* ISABFFILE) (const char *, int *, int *);
typedef BOOL (CALLBACK* READOPEN)(const char *, int *, UINT, ABFFileHeader *, UINT *, DWORD *, int * );
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
    
    const char *field_names[] = {"FileVersion", "SampleMode", "Episodes", "PToLChannelMap", "ADCSamplingSeq",
                                    "usSampleInterval","SamplesPerEpisode","PreTriggerSamples"};
    mxArray *ptr;
    char str[64];
    
    //Function pointers
    ISABFFILE IsABFFile;
    READOPEN ReadOpen;
    FILECLOSE FileClose;

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
    FileClose=(FILECLOSE)GetProcAddress(hinstLib, "ABF_Close");

    
    //... and make sure they are all there
    if (IsABFFile==NULL || ReadOpen==NULL || FileClose==NULL)
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
    

    //Channel title, units, comment etc
    if (nlhs>=1)
    {
        dim[0]=1;
        dim[1]=1;
        plhs[0] = mxCreateStructArray(2, dim, 8, field_names);
        mxSetFieldByNumber(plhs[0],0,0,mxCreateDoubleScalar((double)FileHeader.fFileVersionNumber));

switch (FileHeader.nOperationMode)
{
    case ABF_VARLENEVENTS:
        strcpy(str,"Variable Length");
        break;
    case ABF_FIXLENEVENTS:
        strcpy(str,"Fixed Length");
        break;
    case  ABF_GAPFREEFILE:
        strcpy(str,"Gap-Free");
        break;
    case ABF_HIGHSPEEDOSC:
        strcpy(str,"High Speed");
        break;
    case ABF_WAVEFORMFILE:
        strcpy(str,"Episodic Stimulation");
        break;
        }           
        mxSetFieldByNumber(plhs[0],0,1,mxCreateString(str));
        mxSetFieldByNumber(plhs[0],0,2,mxCreateDoubleScalar((double)FileHeader.lActualEpisodes));
        dim[0]=ABF_ADCCOUNT;
        ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
        mxSetFieldByNumber(plhs[0], 0, 3, ptr);
        memcpy((short *)mxGetPr(ptr), &FileHeader.nADCPtoLChannelMap[0], sizeof(FileHeader.nADCPtoLChannelMap));
                ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
        mxSetFieldByNumber(plhs[0], 0, 4, ptr);
        memcpy((short *)mxGetPr(ptr), &FileHeader.nADCSamplingSeq[0], sizeof(FileHeader.nADCSamplingSeq));
        mxSetFieldByNumber(plhs[0],0,5,mxCreateDoubleScalar((double)FileHeader.fADCSequenceInterval));
        mxSetFieldByNumber(plhs[0],0,6,mxCreateDoubleScalar((double)FileHeader.lNumSamplesPerEpisode));
        mxSetFieldByNumber(plhs[0],0,7,mxCreateDoubleScalar((double)FileHeader.lPreTriggerSamples));
    }
    
    //Close file and free the library
    (*FileClose)(FileHandle, &Error);
    FreeLibrary(hinstLib);
    return;
}
//*********************************************************************


