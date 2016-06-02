// [data, times, npoints, s]=ABFGetADCChannel(dllname, filename, channel, episode)

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
typedef BOOL (CALLBACK* READCHANNEL)(int, ABFFileHeader *, int, DWORD, float *, UINT *, int *);
typedef BOOL (CALLBACK* GETSTARTTIME)(int , const ABFFileHeader *, int, DWORD, double *, int *);
typedef void (CALLBACK* GETTIMEBASE)(const ABFFileHeader *, double, double *, UINT);
typedef BOOL (CALLBACK* FILECLOSE) (int, int *);


void ExitOnError(const char *str, int err)
{
    mexPrintf("ABFReadADCChannel: %s (#%d)\n",str, err);
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
    UINT *np;
    double StartTime;
    double *pTim;
    
    char Units[ABF_ADCUNITLEN+1];
    char Title[ABF_ADCNAMELEN+1];
    char Comment[512];
    
    //Locals
    int dim[2]={1,1};
    float *pData;
    int channel=0;
    int sweep=0;
    int start;
    int i;
    int FileType;
    const char *field_names[] = {"Title", "Units", "Comment"};
	int counter;
	int len;
	int bytes;
    
    
    //Function pointers
    ISABFFILE IsABFFile;
    READOPEN ReadOpen;
    READCHANNEL ReadChannel;
    GETSTARTTIME GetStartTime;
    GETTIMEBASE GetTimebase;
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
    
    // Channel number
    if (nrhs>=3)
    {
        channel=(int)mxGetScalar(prhs[2]);
        if (channel<0 || channel>=ABF_ADCCOUNT)
            //Channel number not in range
        {
            ExitOnError("Channel number exceeds maximum",-1);
            return;
        }
    }
    else
    {
        //No channel specified so default to zero
        channel=0;
    }
    
    //Required episodes
    if (nrhs>=4)
    {
        sweep=(int)mxGetScalar(prhs[3]);
    }
    else
    {
        //No episode specified. Set sweep=0 to load all episodes
        sweep=0;
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
    ReadChannel=(READCHANNEL)GetProcAddress(hinstLib, "ABF_ReadChannel");
    GetStartTime=(GETSTARTTIME)GetProcAddress(hinstLib, "ABF_GetStartTime");
    GetTimebase=(GETTIMEBASE)GetProcAddress(hinstLib, "ABFH_GetTimebase");
    FileClose=(FILECLOSE)GetProcAddress(hinstLib, "ABF_Close");

    
    //... and make sure they are all there
    if (IsABFFile==NULL || ReadOpen==NULL || ReadChannel==NULL || 
    GetStartTime==NULL || GetTimebase==NULL || FileClose==NULL)
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
   // mexPrintf("Operation Mode: %d\n",FileHeader.nOperationMode);
    if (Error!=0)
    {
        ExitOnError("Call to ABF_ReadOpen failed", Error);
        FreeLibrary(hinstLib);
        return;
    }
    
    
    //Build channel descriptions: title, units etc from FileHeader
    memcpy(&Units[0],FileHeader.sADCUnits[channel],ABF_ADCUNITLEN);
    memcpy(&Title[0],FileHeader.sADCChannelName[channel],ABF_ADCNAMELEN);
	Units[ABF_ADCUNITLEN]=(char)0;
	Title[ABF_ADCNAMELEN]=(char)0;
	len=511;
	counter=0;
    bytes=sprintf(&Comment[counter], "Highpass Filter %gHz ",
		FileHeader.fSignalHighpassFilter[channel]);
	len=len-bytes;
	counter=counter+bytes;
	bytes=sprintf(&Comment[counter],
		"Lowpass Filter %gHz ",FileHeader.fSignalLowpassFilter[channel]);
	len=len-bytes;
	counter=counter+bytes;
	Comment[counter]=(char)0;
    
    //How many episodes do we need to return
    if (sweep!=0)
    {
        //Load the user-specified episode
        start=sweep;
        maxEpisodes=sweep;
    }
    else
    {
        //Load all episodes
        start=1;
        maxEpisodes=FileHeader.lActualEpisodes;
    }
    
    //Make sure a requested episode is in range
    if (start>FileHeader.lActualEpisodes)
    {
        ExitOnError("Sweep does not exist", 0);
        (*FileClose)(FileHandle, &Error);
        FreeLibrary(hinstLib);
    }
    
    
    //Set up the outputs
    dim[0]=maxSamples;// From ReadOpen
    dim[1]=maxEpisodes-start+1;
    plhs[0]=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
    pData=(float *)mxGetData(plhs[0]);
    plhs[1]=mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
    pTim=(double *)mxGetData(plhs[1]);
    dim[0]=1;
    plhs[2]=mxCreateNumericArray(2, dim, mxUINT32_CLASS, mxREAL);
    np=(UINT *)mxGetData(plhs[2]);
    
    
    //Read the data - this loop will run once if we are reading only a
    //single episode
    for (episode=start; episode<=maxEpisodes; episode++, np++)
    {
        (*ReadChannel)(FileHandle, &FileHeader, channel, episode, pData, np, &Error);
        if (Error!=0)
        {
            if (Error!=ABF_EINVALIDCHANNEL)
            {
                ExitOnError("Call to ABF_ReadChannel failed", Error);
            }
            (*FileClose)(FileHandle, &Error);
            FreeLibrary(hinstLib);
            return;
        }
        if (nlhs>=2)
        {
            (*GetStartTime)(FileHandle, &FileHeader, channel, episode, &StartTime, &Error2);
            (*GetTimebase)(&FileHeader, StartTime, pTim, *np);
        }
        
        if (sweep==0)
        {
            //Reading all episodes so increment pointers
            pData+=maxSamples;
            pTim+=maxSamples;
        }

    }
    
    //Channel title, units, comment etc
    if (nlhs>=4)
    {
        dim[0]=1;
        dim[1]=1;
        plhs[3] = mxCreateStructArray(2, dim, 3, field_names);
        mxSetFieldByNumber(plhs[3],0,0,mxCreateString(Title));
        mxSetFieldByNumber(plhs[3],0,1,mxCreateString(Units));
        mxSetFieldByNumber(plhs[3],0,2,mxCreateString(Comment));
    }
    
    //Free the library
    (*FileClose)(FileHandle, &Error);
    FreeLibrary(hinstLib);
    return;
}
//*********************************************************************


