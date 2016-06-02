// [data, npoints, s]=ABFGetDACChannel(dllname, filename, channel, episode)

// Supports the ABF and ATF data file formats for pClamp 10 and earlier:
// AxoScope 1 to 10, Clampex 6 to 10, Fetchex 6 and AxoTape 2.
// Works via the ABFFIO.DLL supplied by Axon Instruments.
// See http://www.moleculardevices.com/pages/software/developer_info.html

//% -------------------------------------------------------------------------
//% Author: Malcolm Lidierth 07/07
//% Copyright © The Author & King's College London 2007-
//% -------------------------------------------------------------------------

//%
//% 22.10.08 File now closed on exit

#include "windows.h"
#include "mex.h"
#include "abffiles.h"


typedef BOOL (CALLBACK* READOPEN)(const char *, int *, UINT, ABFFileHeader *, UINT *, DWORD *, int * );
typedef BOOL (CALLBACK* READDACCHANNEL)(int, ABFFileHeader *, int, DWORD, float *, int *);
typedef BOOL (CALLBACK* FILECLOSE) (int, int *);

void ExitOnError(const char *str)
{
    mexPrintf("ABFReadDACChannel: %s\n",str);
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
    //ABFFileHeader *pFH=&FileHeader;
    int FileHandle;
    UINT uFlags=0;
    UINT maxSamples=ABF_MAX_TRIAL_SAMPLES;
    DWORD maxEpisodes=0;
    UINT Samples=0;
    DWORD episode=0;
    UINT npoints[8192];//TODO dynamically allocate this?
    UINT *np;
    double *pTim;
    char Units[ABF_DACUNITLEN];
    char Title[ABF_DACNAMELEN];

    
    //Locals
    int dim[2]={1,1};
    int i;
    float *pData;
    int channel=0;
    int sweep=0;
    int start;
    const char *field_names[] = {"Title", "Units"};
    
    //Function pointers
    READOPEN ReadOpen;
    READDACCHANNEL ReadDACChannel;
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
        ExitOnError("DLL path and name required as string");
        return;
    }
    
    // ABF filename
    if (nrhs>=2 && mxGetClassID(prhs[1])==mxCHAR_CLASS)
    {
        mxGetString(prhs[1], &filename[0], 512);
    }
    else
    {
        ExitOnError("Data file path and name required as string");
        return;
    }
    
    // Channel number
    if (nrhs>=3)
    {
        channel=(int)mxGetScalar(prhs[2]);
        if (channel<0 || channel>=ABF_DACCOUNT) 
        //Channel number not in range
        {
            ExitOnError("Channel number exceeds maximum");
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
        ExitOnError("DLL not found");
        return;
    }
    
    //Set up the pointers to the routines in the Axon Instruments DLL...
    ReadOpen=(READOPEN)GetProcAddress(hinstLib,"ABF_ReadOpen");
    ReadDACChannel=(READDACCHANNEL)GetProcAddress(hinstLib, "ABF_GetWaveform");
	FileClose=(FILECLOSE)GetProcAddress(hinstLib, "ABF_Close");

    if (ReadOpen==NULL || ReadDACChannel==NULL || FileClose==NULL)
    {
        // Error
        ExitOnError("Required routines not found in DLL");
        return;
    }
    
    //Open the file for reading
    (*ReadOpen)(&filename[0], &FileHandle, ABF_ALLOWOVERLAP, &FileHeader,
    &maxSamples, &maxEpisodes, &Error);
    if (Error!=0)
    {
        ExitOnError("Call to ABF_ReadOpen failed");
		(*FileClose)(FileHandle, &Error);
		FreeLibrary(hinstLib);
        return;
    }
    
    //Build channel descriptions: title, units etc from FileHeader
    memcpy(&Units[0],FileHeader.sDACChannelUnits[channel],ABF_DACUNITLEN);
    Units[ABF_DACUNITLEN]=0;
    memcpy(&Title[0],FileHeader.sDACChannelName[channel],ABF_DACNAMELEN);
    Title[ABF_DACNAMELEN]=0;
    
    //How many episodes do we need to return
    if (sweep!=0)
    {
        //Load the user-specified episode
        start=sweep;
        maxEpisodes=sweep;
    }
    else
    {
        //Load all epsiodes
        start=1;
    }
    
    
    //Set up the outputs
    // Data
    Samples=FileHeader.lNumSamplesPerEpisode/FileHeader.nADCNumChannels;
    dim[0]=Samples;
    dim[1]=maxEpisodes-start+1;
    plhs[0]=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
    pData=(float *)mxGetData(plhs[0]);
    // Sample counts
    dim[0]=1;
    plhs[1]=mxCreateNumericArray(2, dim, mxUINT32_CLASS, mxREAL);
    np=(UINT *)mxGetData(plhs[1]);
    
    
    //Read the data - this loop will run once if we are reading only a 
    //single episode
    for (episode=start; episode<=maxEpisodes; episode++)
    {
        (*ReadDACChannel)(FileHandle, &FileHeader, channel, episode, pData, &Error);
        if (Error!=0)
        {
            Samples=0;
        }
        if (sweep==0)
        {
            //Reading all episodes...
            npoints[episode-1]=Samples;
            pData=pData+Samples;
        }
        else
        {
            //...or just one
            npoints[0]=Samples;
        }
    }
    
    // Return sample lengths in output 2
    if (nlhs>=2)
    {
        for (episode=start; episode<=maxEpisodes; episode++)
        {
            *np++=npoints[episode-start];
        }
    }
    
    dim[0]=1;
    dim[1]=1;
    plhs[2] = mxCreateStructArray(2, dim, 2, field_names);
    mxSetFieldByNumber(plhs[2],0,0,mxCreateString(Title));
    mxSetFieldByNumber(plhs[2],0,1,mxCreateString(Units));
    
    //Free the library
	(*FileClose)(FileHandle, &Error);
    FreeLibrary(hinstLib);
    return;
}



