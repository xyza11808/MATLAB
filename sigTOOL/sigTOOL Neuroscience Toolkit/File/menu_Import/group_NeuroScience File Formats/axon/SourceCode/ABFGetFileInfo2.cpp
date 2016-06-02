// [s1, s2]=ABFGetFileInfo2(dllname, filename)
// Supports the ABF data file formats for pClamp 10 and earlier:
// AxoScope 1 to 10, Clampex 6 to 10, Fetchex 6 and AxoTape 2.
// Works via the ABFFIO.DLL supplied by Axon Instruments.
// See http://www.moleculardevices.com/pages/software/developer_info.html
//
// ABFGetFileInfo2 returns the information in the file header
//
// Note:
// Scalars, except for bit fields, are returned as double precision floats
// Bit fields maintain the native type
// Also,
// All strings are returned as unsigned 8-bit integers
// All 2-d matrices require reshaping in MATLAB 
//		Call via ABFGetFileInfo.m to restore chars and element order 
//		automatically
//
//% -------------------------------------------------------------------------
//% Author: Malcolm Lidierth 07/07
//% Copyright © The Author & King's College London 2007-
//% -------------------------------------------------------------------------
//
// Revisions
// 21.12.09	Now returns two outputs s1. Selected fields (obsolete - do not use)
//									s2. Entire ABF header

#include <windows.h>
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

	// Obsolete - limited fields only
	const char *field_names[] = {"FileVersion", "SampleMode", "Episodes", "PToLChannelMap", "ADCSamplingSeq",
		"usSampleInterval","SamplesPerEpisode","PreTriggerSamples"};

	//ABF header fields
	const char *names1[]={"fFileVersionNumber",		//Block1
		"nOperationMode",
		"lActualAcqLength",
		"nNumPointsIgnored",
		"lActualEpisodes",
		"uFileStartDate",
		"uFileStartTimeMS",
		"lStopwatchTime",
		"fHeaderVersionNumber",
		"nFileType",
		"lDataSectionPtr",							//Block 2
		"lTagSectionPtr",
		"lNumTagEntries",
		"lScopeConfigPtr",
		"lNumScopes",
		"lDeltaArrayPtr",
		"lNumDeltas",
		"lVoiceTagPtr",
		"lVoiceTagEntries",
		"lSynchArrayPtr",
		"lSynchArraySize",
		"nDataFormat",
		"nSimultaneousScan",
		"lStatisticsConfigPtr",
		"lAnnotationSectionPtr",
		"lNumAnnotations",
		"lDACFilePtr",
		"lDACFileNumEpisodes",
		"nADCNumChannels",							//Block 3
		"fADCSequenceInterval",
		"uFileCompressionRatio",
		"bEnableFileCompression",
		"fSynchTimeUnit",
		"fSecondsPerRun",
		"lNumSamplesPerEpisode",
		"lPreTriggerSamples",
		"lEpisodesPerRun",
		"lRunsPerTrial",
		"lNumberOfTrials",
		"nAveragingMode",
		"nUndoRunCount",
		"nFirstEpisodeInRun",
		"fTriggerThreshold",
		"nTriggerSource",
		"nTriggerAction",
		"nTriggerPolarity",
		"fScopeOutputInterval",
		"fEpisodeStartToStart",
		"fRunStartToStart",
		"fTrialStartToStart",
		"lAverageCount",
		"nAutoTriggerStrategy",
		"fFirstRunDelayS",
		"nDataDisplayMode",						//Block 4
		"nChannelStatsStrategy",
		"lSamplesPerTrace",
		"lStartDisplayNum",
		"lFinishDisplayNum",
		"nShowPNRawData",
		"fStatisticsPeriod",
		"lStatisticsMeasurements",
		"nStatisticsSaveStrategy",	
		"fADCRange",									//Block 5
		"fDACRange",
		"lADCResolution",
		"lDACResolution",
		"nDigitizerADCs",
		"nDigitizerDACs",
		"nDigitizerTotalDigitalOuts",
		"nDigitizerSynchDigitalOuts",
		"nDigitizerType",	
		"nExperimentType",							//Group 6
		"nManualInfoStrategy",
		"fCellID1",
		"fCellID2",
		"fCellID3",
		"sProtocolPath",
		"sCreatorInfo",
		"sModifierInfo",
		"nCommentsEnable",
		"sFileComment",
		"nTelegraphEnable",
		"nTelegraphInstrument",
		"fTelegraphAdditGain",
		"fTelegraphFilter",
		"fTelegraphMembraneCap",
		"fTelegraphAccessResistance",
		"nTelegraphMode",
		"nTelegraphDACScaleFactorEnable",
		"nAutoAnalyseEnable",
		"FileGUID",
		"fInstrumentHoldingLevel",
		"ulFileCRC",
		"nCRCEnable",
		"nSignalType",                        // Group 7
		"nADCPtoLChannelMap",
		"nADCSamplingSeq",
		"fADCProgrammableGain",
		"fADCDisplayAmplification",
		"fADCDisplayOffset",       
		"fInstrumentScaleFactor",  
		"fInstrumentOffset",       
		"fSignalGain",
		"fSignalOffset",
		"fSignalLowpassFilter",
		"fSignalHighpassFilter",
		"nLowpassFilterType",
		"nHighpassFilterType",
		"sADCChannelName",
		"sADCUnits",
		"fDACScaleFactor",
		"fDACHoldingLevel",
		"fDACCalibrationFactor",
		"fDACCalibrationOffset",
		"sDACChannelName",
		"sDACChannelUnits",
		"nDigitalEnable",						// Group 9
		"nActiveDACChannel",                 
		"nDigitalDACChannel",
		"nDigitalHolding",
		"nDigitalInterEpisode",
		"nDigitalTrainActiveLogic",                                   
		"nDigitalValue",
		"nDigitalTrainValue",                         
		"bEpochCompression",
		"nWaveformEnable",
		"nWaveformSource",
		"nInterEpisodeLevel",
		"nEpochType",
		"fEpochInitLevel",
		"fEpochLevelInc",
		"lEpochInitDuration",
		"lEpochDurationInc",
		"fDACFileScale",					//Group 10
		"fDACFileOffset",
		"lDACFileEpisodeNum",
		"nDACFileADCNum",
		"sDACFilePath",
		"nConditEnable",					//Group 11
		"lConditNumPulses",
		"fBaselineDuration",
		"fBaselineLevel",
		"fStepDuration",
		"fStepLevel",
		"fPostTrainPeriod",
		"fPostTrainLevel",
		"nMembTestEnable",
		"fMembTestPreSettlingTimeMS",
		"fMembTestPostSettlingTimeMS",
		"nULEnable",						//Group 12
		"nULParamToVary",
		"nULRepeat",
		"sULParamValueList",
		"nStatsEnable",							//Group 13
		"nStatsActiveChannels",            // Active stats channel bit flag
		"nStatsSearchRegionFlags",          // Active stats region bit flag
		"nStatsSmoothing",
		"nStatsSmoothingEnable",
		"nStatsBaseline",
		"nStatsBaselineDAC",                    // If mode is epoch, then this holds the DAC
		"lStatsBaselineStart",
		"lStatsBaselineEnd",
		"lStatsMeasurements", // Measurement bit flag for each region
		"lStatsStart",
		"lStatsEnd",
		"nRiseBottomPercentile",
		"nRiseTopPercentile",
		"nDecayBottomPercentile",
		"nDecayTopPercentile",
		"nStatsChannelPolarity",
		"nStatsSearchMode",   // Stats mode per region: mode is cursor region, epoch etc 
		"nStatsSearchDAC",    // If mode is epoch, then this holds the DAC
		"nArithmeticEnable",					//Group 14
		"nArithmeticExpression",
		"fArithmeticUpperLimit",
		"fArithmeticLowerLimit",
		"nArithmeticADCNumA",
		"nArithmeticADCNumB",
		"fArithmeticK1",
		"fArithmeticK2",
		"fArithmeticK3",
		"fArithmeticK4",
		"fArithmeticK5",
		"fArithmeticK6",
		"sArithmeticOperator",
		"sArithmeticUnits",			
		"nPNPosition",				//Group 15
		"nPNNumPulses",
		"nPNPolarity",
		"fPNSettlingTime",
		"fPNInterpulse",
		"nLeakSubtractType",
		"fPNHoldingLevel",
		"bEnabledDuringPN",
		"nLevelHysteresis",		//Group 16
		"lTimeHysteresis",
		"nAllowExternalTags",
		"nAverageAlgorithm",
		"fAverageWeighting",
		"nUndoPromptStrategy",
		"nTrialTriggerSource",
		"nStatisticsDisplayStrategy",
		"nExternalTagType",
		"lHeaderSize",
		"nStatisticsClearStrategy",
		"lEpochPulsePeriod",		//Group 17
		"lEpochPulseWidth",
		"nCreatorMajorVersion",		//Group 18
		"nCreatorMinorVersion",
		"nCreatorBugfixVersion",
		"nCreatorBuildVersion",
		"nModifierMajorVersion",
		"nModifierMinorVersion",
		"nModifierBugfixVersion",
		"nModifierBuildVersion",
		"nLTPType",					//Group 19
		"nLTPUsageOfDAC",
		"nLTPPresynapticPulses",
		"nScopeTriggerOut",			//Group 20
		"nAlternateDACOutputState",  //Group 22
		"nAlternateDigitalOutputState", 
		"nAlternateDigitalValue",
		"nAlternateDigitalTrainValue",
		"fPostProcessLowpassFilter",	//Group 23	
		"nPostProcessLowpassFilterType",
		"fLegacyADCSequenceInterval",		//Group 24
		"fLegacyADCSecondSequenceInterval",
		"lLegacyClockChange",
		"lLegacyNumSamplesPerEpisode"
	};

#define NFIELD 229

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
		// Set up the obsolete limited structure
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

	if (nlhs>=2)
		// Return the entire ABF file header
	{
		dim[0]=1;
		dim[1]=1;
		plhs[1] = mxCreateStructArray(2, dim, NFIELD, names1);
		double field=0;
		//GROUP 1
		//  float    fFileVersionNumber;
		//short    nOperationMode;
		//long     lActualAcqLength;
		//short    nNumPointsIgnored;
		//long     lActualEpisodes;
		//UINT     uFileStartDate;         // YYYYMMDD
		//UINT     uFileStartTimeMS;
		//long     lStopwatchTime;
		//float    fHeaderVersionNumber;
		//short    nFileType;

		mxSetFieldByNumber(plhs[1],0,0,mxCreateDoubleScalar((double)FileHeader.fFileVersionNumber));
		mxSetFieldByNumber(plhs[1],0,1,mxCreateDoubleScalar((double)FileHeader.nOperationMode));
		mxSetFieldByNumber(plhs[1],0,2,mxCreateDoubleScalar((double)FileHeader.lActualAcqLength));
		mxSetFieldByNumber(plhs[1],0,3,mxCreateDoubleScalar((double)FileHeader.lActualEpisodes));
		mxSetFieldByNumber(plhs[1],0,4,mxCreateDoubleScalar((double)FileHeader.nNumPointsIgnored));
		mxSetFieldByNumber(plhs[1],0,5,mxCreateDoubleScalar((double)FileHeader.uFileStartDate));
		mxSetFieldByNumber(plhs[1],0,6,mxCreateDoubleScalar((double)FileHeader.uFileStartTimeMS));
		mxSetFieldByNumber(plhs[1],0,7,mxCreateDoubleScalar((double)FileHeader.lStopwatchTime));
		mxSetFieldByNumber(plhs[1],0,8,mxCreateDoubleScalar((double)FileHeader.fHeaderVersionNumber));
		mxSetFieldByNumber(plhs[1],0,9,mxCreateDoubleScalar((double)FileHeader.nFileType));

		// GROUP #2 - File Structure
		//long     lDataSectionPtr;
		//long     lTagSectionPtr;
		//long     lNumTagEntries;
		//long     lScopeConfigPtr;
		//long     lNumScopes;
		//long     lDeltaArrayPtr;
		//long     lNumDeltas;
		//long     lVoiceTagPtr;
		//long     lVoiceTagEntries;
		//long     lSynchArrayPtr;
		//long     lSynchArraySize;
		//short    nDataFormat;
		//short    nSimultaneousScan;
		//long     lStatisticsConfigPtr;
		//long     lAnnotationSectionPtr;
		//long     lNumAnnotations;
		//long     lDACFilePtr[ABF_DACCOUNT];
		//long     lDACFileNumEpisodes[ABF_DACCOUNT];

		mxArray *p;
		int k;
		mxSetFieldByNumber(plhs[1],0,10,mxCreateDoubleScalar((double)FileHeader.lDataSectionPtr));
		mxSetFieldByNumber(plhs[1],0,11,mxCreateDoubleScalar((double)FileHeader.lTagSectionPtr));
		mxSetFieldByNumber(plhs[1],0,12,mxCreateDoubleScalar((double)FileHeader.lNumTagEntries));
		mxSetFieldByNumber(plhs[1],0,13,mxCreateDoubleScalar((double)FileHeader.lScopeConfigPtr));
		mxSetFieldByNumber(plhs[1],0,14,mxCreateDoubleScalar((double)FileHeader.lNumScopes));
		mxSetFieldByNumber(plhs[1],0,15,mxCreateDoubleScalar((double)FileHeader.lDeltaArrayPtr));
		mxSetFieldByNumber(plhs[1],0,16,mxCreateDoubleScalar((double)FileHeader.lNumDeltas));
		mxSetFieldByNumber(plhs[1],0,17,mxCreateDoubleScalar((double)FileHeader.lVoiceTagPtr));
		mxSetFieldByNumber(plhs[1],0,18,mxCreateDoubleScalar((double)FileHeader.lVoiceTagEntries));
		mxSetFieldByNumber(plhs[1],0,19,mxCreateDoubleScalar((double)FileHeader.lSynchArrayPtr));
		mxSetFieldByNumber(plhs[1],0,20,mxCreateDoubleScalar((double)FileHeader.lSynchArraySize));
		mxSetFieldByNumber(plhs[1],0,21,mxCreateDoubleScalar((double)FileHeader.nDataFormat));
		mxSetFieldByNumber(plhs[1],0,22,mxCreateDoubleScalar((double)FileHeader.nSimultaneousScan));
		mxSetFieldByNumber(plhs[1],0,23,mxCreateDoubleScalar((double)FileHeader.lStatisticsConfigPtr));
		mxSetFieldByNumber(plhs[1],0,24,mxCreateDoubleScalar((double)FileHeader.lAnnotationSectionPtr));
		mxSetFieldByNumber(plhs[1],0,25,mxCreateDoubleScalar((double)FileHeader.lNumAnnotations));

		dim[0]=1;
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,26,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lDACFilePtr[0], sizeof(FileHeader.lDACFilePtr));

		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,27,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lDACFileNumEpisodes[0], sizeof(FileHeader.lDACFileNumEpisodes));

		// GROUP #3 - Trial hierarchy information
		//short    nADCNumChannels;
		//float    fADCSequenceInterval;
		//UINT     uFileCompressionRatio;
		//bool     bEnableFileCompression;
		//float    fSynchTimeUnit;
		//float    fSecondsPerRun;
		//long     lNumSamplesPerEpisode;
		//long     lPreTriggerSamples;
		//long     lEpisodesPerRun;
		//long     lRunsPerTrial;
		//long     lNumberOfTrials;
		//short    nAveragingMode;
		//short    nUndoRunCount;
		//short    nFirstEpisodeInRun;
		//float    fTriggerThreshold;
		//short    nTriggerSource;
		//short    nTriggerAction;
		//short    nTriggerPolarity;
		//float    fScopeOutputInterval;
		//float    fEpisodeStartToStart;
		//float    fRunStartToStart;
		//float    fTrialStartToStart;
		//long     lAverageCount;
		//short    nAutoTriggerStrategy;
		//float    fFirstRunDelayS;


		mxSetFieldByNumber(plhs[1],0,28,mxCreateDoubleScalar((double)FileHeader.nADCNumChannels));
		mxSetFieldByNumber(plhs[1],0,29,mxCreateDoubleScalar((double)FileHeader.fADCSequenceInterval));
		mxSetFieldByNumber(plhs[1],0,30,mxCreateDoubleScalar((double)FileHeader.uFileCompressionRatio));
		mxSetFieldByNumber(plhs[1],0,31,mxCreateDoubleScalar((double)FileHeader.bEnableFileCompression));
		mxSetFieldByNumber(plhs[1],0,32,mxCreateDoubleScalar((double)FileHeader.fSynchTimeUnit));
		mxSetFieldByNumber(plhs[1],0,33,mxCreateDoubleScalar((double)FileHeader.fSecondsPerRun));
		mxSetFieldByNumber(plhs[1],0,34,mxCreateDoubleScalar((double)FileHeader.lNumSamplesPerEpisode));
		mxSetFieldByNumber(plhs[1],0,35,mxCreateDoubleScalar((double)FileHeader.lPreTriggerSamples));
		mxSetFieldByNumber(plhs[1],0,36,mxCreateDoubleScalar((double)FileHeader.lEpisodesPerRun));
		mxSetFieldByNumber(plhs[1],0,37,mxCreateDoubleScalar((double)FileHeader.lRunsPerTrial));
		mxSetFieldByNumber(plhs[1],0,38,mxCreateDoubleScalar((double)FileHeader.lNumberOfTrials));
		mxSetFieldByNumber(plhs[1],0,39,mxCreateDoubleScalar((double)FileHeader.nAveragingMode));
		mxSetFieldByNumber(plhs[1],0,40,mxCreateDoubleScalar((double)FileHeader.nUndoRunCount));
		mxSetFieldByNumber(plhs[1],0,41,mxCreateDoubleScalar((double)FileHeader.nFirstEpisodeInRun));
		mxSetFieldByNumber(plhs[1],0,42,mxCreateDoubleScalar((double)FileHeader.fTriggerThreshold));
		mxSetFieldByNumber(plhs[1],0,43,mxCreateDoubleScalar((double)FileHeader.nTriggerSource));
		mxSetFieldByNumber(plhs[1],0,44,mxCreateDoubleScalar((double)FileHeader.nTriggerAction));
		mxSetFieldByNumber(plhs[1],0,45,mxCreateDoubleScalar((double)FileHeader.nTriggerPolarity));
		mxSetFieldByNumber(plhs[1],0,46,mxCreateDoubleScalar((double)FileHeader.fScopeOutputInterval));
		mxSetFieldByNumber(plhs[1],0,47,mxCreateDoubleScalar((double)FileHeader.fEpisodeStartToStart));
		mxSetFieldByNumber(plhs[1],0,48,mxCreateDoubleScalar((double)FileHeader.fRunStartToStart));
		mxSetFieldByNumber(plhs[1],0,49,mxCreateDoubleScalar((double)FileHeader.fTrialStartToStart));
		mxSetFieldByNumber(plhs[1],0,50,mxCreateDoubleScalar((double)FileHeader.lAverageCount));
		mxSetFieldByNumber(plhs[1],0,51,mxCreateDoubleScalar((double)FileHeader.nAutoTriggerStrategy));
		mxSetFieldByNumber(plhs[1],0,52,mxCreateDoubleScalar((double)FileHeader.fFirstRunDelayS));

		// GROUP #4 - Display Parameters
		//short    nDataDisplayMode;
		//short    nChannelStatsStrategy;
		//long     lSamplesPerTrace;
		//long     lStartDisplayNum;
		//long     lFinishDisplayNum;
		//short    nShowPNRawData;
		//float    fStatisticsPeriod;
		//long     lStatisticsMeasurements;
		//short    nStatisticsSaveStrategy;

		mxSetFieldByNumber(plhs[1],0,53,mxCreateDoubleScalar((double)FileHeader.nDataDisplayMode));
		mxSetFieldByNumber(plhs[1],0,54,mxCreateDoubleScalar((double)FileHeader.nChannelStatsStrategy));
		mxSetFieldByNumber(plhs[1],0,55,mxCreateDoubleScalar((double)FileHeader.lSamplesPerTrace));
		mxSetFieldByNumber(plhs[1],0,56,mxCreateDoubleScalar((double)FileHeader.lStartDisplayNum));
		mxSetFieldByNumber(plhs[1],0,57,mxCreateDoubleScalar((double)FileHeader.lFinishDisplayNum));
		mxSetFieldByNumber(plhs[1],0,58,mxCreateDoubleScalar((double)FileHeader.nShowPNRawData));
		mxSetFieldByNumber(plhs[1],0,59,mxCreateDoubleScalar((double)FileHeader.fStatisticsPeriod));
		mxSetFieldByNumber(plhs[1],0,60,mxCreateDoubleScalar((double)FileHeader.lStatisticsMeasurements));
		mxSetFieldByNumber(plhs[1],0,61,mxCreateDoubleScalar((double)FileHeader.nStatisticsSaveStrategy));


		// GROUP #5 - Hardware information
		//float    fADCRange;
		//float    fDACRange;
		//long     lADCResolution;
		//long     lDACResolution;
		//short    nDigitizerADCs;
		//short    nDigitizerDACs;
		//short    nDigitizerTotalDigitalOuts;
		//short    nDigitizerSynchDigitalOuts;
		//short    nDigitizerType;

		mxSetFieldByNumber(plhs[1],0,62,mxCreateDoubleScalar((double)FileHeader.fADCRange));
		mxSetFieldByNumber(plhs[1],0,63,mxCreateDoubleScalar((double)FileHeader.fDACRange));
		mxSetFieldByNumber(plhs[1],0,64,mxCreateDoubleScalar((double)FileHeader.lADCResolution));
		mxSetFieldByNumber(plhs[1],0,65,mxCreateDoubleScalar((double)FileHeader.lDACResolution));
		mxSetFieldByNumber(plhs[1],0,66,mxCreateDoubleScalar((double)FileHeader.nDigitizerADCs));
		mxSetFieldByNumber(plhs[1],0,67,mxCreateDoubleScalar((double)FileHeader.nDigitizerDACs));
		mxSetFieldByNumber(plhs[1],0,68,mxCreateDoubleScalar((double)FileHeader.nDigitizerTotalDigitalOuts));
		mxSetFieldByNumber(plhs[1],0,69,mxCreateDoubleScalar((double)FileHeader.nDigitizerSynchDigitalOuts));
		mxSetFieldByNumber(plhs[1],0,70,mxCreateDoubleScalar((double)FileHeader.nDigitizerType));

		// GROUP #6 Environmental Information
		//short    nExperimentType;
		//short    nManualInfoStrategy;
		//float    fCellID1;
		//float    fCellID2;
		//float    fCellID3;
		//char     sProtocolPath[ABF_PATHLEN];
		//char     sCreatorInfo[ABF_CREATORINFOLEN];
		//char     sModifierInfo[ABF_CREATORINFOLEN];
		//short    nCommentsEnable;
		//char     sFileComment[ABF_FILECOMMENTLEN];
		//short    nTelegraphEnable[ABF_ADCCOUNT];
		//short    nTelegraphInstrument[ABF_ADCCOUNT];
		//float    fTelegraphAdditGain[ABF_ADCCOUNT];
		//float    fTelegraphFilter[ABF_ADCCOUNT];
		//float    fTelegraphMembraneCap[ABF_ADCCOUNT];
		//float    fTelegraphAccessResistance[ABF_ADCCOUNT];
		//short    nTelegraphMode[ABF_ADCCOUNT];
		//short    nTelegraphDACScaleFactorEnable[ABF_DACCOUNT];
		//short    nAutoAnalyseEnable;
		//GUID     FileGUID;
		//float    fInstrumentHoldingLevel[ABF_DACCOUNT];
		//unsigned long ulFileCRC;
		//short    nCRCEnable;



		mxSetFieldByNumber(plhs[1],0,71,mxCreateDoubleScalar((double)FileHeader.nExperimentType));
		mxSetFieldByNumber(plhs[1],0,72,mxCreateDoubleScalar((double)FileHeader.nManualInfoStrategy));
		mxSetFieldByNumber(plhs[1],0,73,mxCreateDoubleScalar((double)FileHeader.fCellID1));
		mxSetFieldByNumber(plhs[1],0,74,mxCreateDoubleScalar((double)FileHeader.fCellID2));
		mxSetFieldByNumber(plhs[1],0,75,mxCreateDoubleScalar((double)FileHeader.fCellID3));

		dim[0]=1;
		dim[1]=ABF_PATHLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,76,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sProtocolPath[0], sizeof(FileHeader.sProtocolPath));

		dim[0]=1;
		dim[1]=ABF_CREATORINFOLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,77,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sCreatorInfo[0], sizeof(FileHeader.sCreatorInfo));

		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,78,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sModifierInfo[0], sizeof(FileHeader.sModifierInfo));


		mxSetFieldByNumber(plhs[1],0,79,mxCreateDoubleScalar((double)FileHeader.nCommentsEnable));

		dim[1]=ABF_FILECOMMENTLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,80,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sFileComment[0], sizeof(FileHeader.sFileComment));


		dim[0]=1;
		dim[1]=ABF_ADCCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,81,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nTelegraphEnable[0], sizeof(FileHeader.nTelegraphEnable));

		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,82,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nTelegraphInstrument[0], sizeof(FileHeader.nTelegraphInstrument));


		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,83,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fTelegraphAdditGain[0], sizeof(FileHeader.fTelegraphAdditGain));

		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,84,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fTelegraphFilter[0], sizeof(FileHeader.fTelegraphFilter));

		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,85,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fTelegraphMembraneCap[0], sizeof(FileHeader.fTelegraphMembraneCap));

		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,86,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fTelegraphAccessResistance[0], sizeof(FileHeader.fTelegraphAccessResistance));

		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,87,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nTelegraphMode[0], sizeof(FileHeader.nTelegraphMode));

		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,88,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nTelegraphDACScaleFactorEnable[0], sizeof(FileHeader.nTelegraphDACScaleFactorEnable));

		mxSetFieldByNumber(plhs[1],0,89,mxCreateDoubleScalar((double)FileHeader.nAutoAnalyseEnable));

		dim[1]=2;
		ptr=mxCreateNumericArray(2, dim, mxINT64_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,90,ptr);
		memcpy((long long *)mxGetPr(ptr), &FileHeader.FileGUID, sizeof(FileHeader.FileGUID));

		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,91,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fInstrumentHoldingLevel[0], sizeof(FileHeader.fInstrumentHoldingLevel));

		mxSetFieldByNumber(plhs[1],0,92,mxCreateDoubleScalar((double)FileHeader.ulFileCRC));
		mxSetFieldByNumber(plhs[1],0,93,mxCreateDoubleScalar((double)FileHeader.nCRCEnable));


		// GROUP #7 - Multi-channel information
		//short    nSignalType;                        // why is this only single channel ?
		//short    nADCPtoLChannelMap[ABF_ADCCOUNT];
		//short    nADCSamplingSeq[ABF_ADCCOUNT];
		//float    fADCProgrammableGain[ABF_ADCCOUNT];
		//float    fADCDisplayAmplification[ABF_ADCCOUNT];
		//float    fADCDisplayOffset[ABF_ADCCOUNT];       
		//float    fInstrumentScaleFactor[ABF_ADCCOUNT];  
		//float    fInstrumentOffset[ABF_ADCCOUNT];       
		//float    fSignalGain[ABF_ADCCOUNT];
		//float    fSignalOffset[ABF_ADCCOUNT];
		//float    fSignalLowpassFilter[ABF_ADCCOUNT];
		//float    fSignalHighpassFilter[ABF_ADCCOUNT];
		//char     nLowpassFilterType[ABF_ADCCOUNT];
		//char     nHighpassFilterType[ABF_ADCCOUNT];
		//  char     sADCChannelName[ABF_ADCCOUNT][ABF_ADCNAMELEN];
		//char     sADCUnits[ABF_ADCCOUNT][ABF_ADCUNITLEN];
		//float    fDACScaleFactor[ABF_DACCOUNT];
		//float    fDACHoldingLevel[ABF_DACCOUNT];
		//float    fDACCalibrationFactor[ABF_DACCOUNT];
		//float    fDACCalibrationOffset[ABF_DACCOUNT];
		//char     sDACChannelName[ABF_DACCOUNT][ABF_DACNAMELEN];
		//char     sDACChannelUnits[ABF_DACCOUNT][ABF_DACUNITLEN];

		//1
		mxSetFieldByNumber(plhs[1],0,94,mxCreateDoubleScalar((double)FileHeader.nSignalType));

		//2
		dim[1]=ABF_ADCCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,95,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nADCPtoLChannelMap[0], sizeof(FileHeader.nADCPtoLChannelMap));

		//3
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,96,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nADCSamplingSeq[0], sizeof(FileHeader.nADCSamplingSeq));

		//4
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,97,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fADCProgrammableGain[0], sizeof(FileHeader.fADCProgrammableGain));

		//5
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,98,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fADCDisplayAmplification[0], sizeof(FileHeader.fADCDisplayAmplification));

		//6
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,99,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fADCDisplayOffset[0], sizeof(FileHeader.fADCDisplayOffset));

		//7
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,100,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fInstrumentScaleFactor[0], sizeof(FileHeader.fInstrumentScaleFactor));

		//8
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,101,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fInstrumentOffset[0], sizeof(FileHeader.fInstrumentOffset));

		//9
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,102,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fSignalGain[0], sizeof(FileHeader.fSignalGain));

		//10
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,103,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fSignalOffset[0], sizeof(FileHeader.fSignalOffset));

		//11
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,104,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fSignalLowpassFilter[0], sizeof(FileHeader.fSignalLowpassFilter));

		//12
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,105,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fSignalHighpassFilter[0], sizeof(FileHeader.fSignalHighpassFilter));

		//13
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,106,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.nLowpassFilterType[0], sizeof(FileHeader.nLowpassFilterType));

		//14
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,107,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.nHighpassFilterType[0], sizeof(FileHeader.nHighpassFilterType));

		//15
		//char(reshape(h.sADCChannelName,10,16)')
		dim[0]=ABF_ADCCOUNT;
		dim[1]=ABF_ADCNAMELEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,108,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sADCChannelName[0], sizeof(FileHeader.sADCChannelName));

		//16
		//char(reshape(h.sADCUnits,8,16)')
		dim[1]=ABF_ADCUNITLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,109,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sADCUnits[0], sizeof(FileHeader.sADCUnits));


		//17
		dim[0]=1;
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,110,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fDACScaleFactor[0], sizeof(FileHeader.fDACScaleFactor));


		//18
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,111,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fDACHoldingLevel[0], sizeof(FileHeader.fDACHoldingLevel));

		//19
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,112,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fDACCalibrationFactor[0], sizeof(FileHeader.fDACCalibrationFactor));


		//20
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,113,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fDACCalibrationOffset[0], sizeof(FileHeader.fDACCalibrationOffset));

		//21
		dim[0]=ABF_DACCOUNT;
		dim[1]=ABF_DACNAMELEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,114,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sDACChannelName[0], sizeof(FileHeader.sDACChannelName));

		//22
		dim[1]=ABF_DACUNITLEN;//Added 13.03.10
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,115,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sDACChannelUnits[0], sizeof(FileHeader.sDACChannelUnits));

		// Group 9
		//  short    nDigitalEnable;
		//short    nActiveDACChannel;                     // should retire !
		//short    nDigitalDACChannel;
		//short    nDigitalHolding;
		//short    nDigitalInterEpisode;
		//short    nDigitalTrainActiveLogic;  
		//short    nDigitalValue[ABF_EPOCHCOUNT];
		//short    nDigitalTrainValue[ABF_EPOCHCOUNT];                         
		//bool     bEpochCompression[ABF_EPOCHCOUNT];
		//short    nWaveformEnable[ABF_DACCOUNT];
		//short    nWaveformSource[ABF_DACCOUNT];
		//short    nInterEpisodeLevel[ABF_DACCOUNT];
		//short    nEpochType[ABF_DACCOUNT][ABF_EPOCHCOUNT];
		//float    fEpochInitLevel[ABF_DACCOUNT][ABF_EPOCHCOUNT];
		//float    fEpochLevelInc[ABF_DACCOUNT][ABF_EPOCHCOUNT];
		//long     lEpochInitDuration[ABF_DACCOUNT][ABF_EPOCHCOUNT];
		//long     lEpochDurationInc[ABF_DACCOUNT][ABF_EPOCHCOUNT];

		//1-6
		mxSetFieldByNumber(plhs[1],0,116,mxCreateDoubleScalar((double)FileHeader.nDigitalEnable));
		mxSetFieldByNumber(plhs[1],0,117,mxCreateDoubleScalar((double)FileHeader.nActiveDACChannel));
		mxSetFieldByNumber(plhs[1],0,118,mxCreateDoubleScalar((double)FileHeader.nDigitalDACChannel));
		mxSetFieldByNumber(plhs[1],0,119,mxCreateDoubleScalar((double)FileHeader.nDigitalHolding));
		mxSetFieldByNumber(plhs[1],0,120,mxCreateDoubleScalar((double)FileHeader.nDigitalInterEpisode));
		mxSetFieldByNumber(plhs[1],0,121,mxCreateDoubleScalar((double)FileHeader.nDigitalTrainActiveLogic));

		//7
		dim[0]=1;
		dim[1]=ABF_EPOCHCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,122,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nDigitalValue[0], sizeof(FileHeader.nDigitalValue));

		//8
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,123,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nDigitalTrainValue[0], sizeof(FileHeader.nDigitalTrainValue));

		//9 Recast this to logical: N.B. 1 byte size for bool is Microsoft specific
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,124,ptr);
		memcpy((bool *)mxGetPr(ptr), &FileHeader.bEpochCompression[0], sizeof(FileHeader.bEpochCompression));

		//10
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,125,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nWaveformEnable[0], sizeof(FileHeader.nWaveformEnable));

		//11
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,126,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nWaveformSource[0], sizeof(FileHeader.nWaveformSource));

		//12
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,127,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nInterEpisodeLevel[0], sizeof(FileHeader.nInterEpisodeLevel));

		//13
		dim[0]=ABF_DACCOUNT;
		dim[1]=ABF_EPOCHCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,128,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nEpochType[0], sizeof(FileHeader.nEpochType));

		//14
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,129,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fEpochInitLevel[0], sizeof(FileHeader.fEpochInitLevel));

		//15
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,130,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fEpochLevelInc[0], sizeof(FileHeader.fEpochLevelInc));


		//16
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,131,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lEpochInitDuration[0], sizeof(FileHeader.lEpochInitDuration));

		//17
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,132,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lEpochDurationInc[0], sizeof(FileHeader.lEpochDurationInc));

		// GROUP #10 - DAC Output File
		//float    fDACFileScale[ABF_DACCOUNT];
		//float    fDACFileOffset[ABF_DACCOUNT];
		//long     lDACFileEpisodeNum[ABF_DACCOUNT];
		//short    nDACFileADCNum[ABF_DACCOUNT];
		//char     sDACFilePath[ABF_DACCOUNT][ABF_PATHLEN];

		//1
		dim[0]=1;
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,133,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fDACFileScale[0], sizeof(FileHeader.fDACFileScale));

		//2
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,134,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fDACFileOffset[0], sizeof(FileHeader.fDACFileOffset));

		//3
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,135,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lDACFileEpisodeNum[0], sizeof(FileHeader.lDACFileEpisodeNum));

		//4
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,136,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nDACFileADCNum[0], sizeof(FileHeader.nDACFileADCNum));

		//5
		dim[0]=ABF_DACCOUNT;
		dim[1]=ABF_PATHLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,137,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sDACFilePath[0], sizeof(FileHeader.sDACFilePath));


		// GROUP #11 - Presweep (conditioning) pulse train
		//short    nConditEnable[ABF_DACCOUNT];
		//long     lConditNumPulses[ABF_DACCOUNT];
		//float    fBaselineDuration[ABF_DACCOUNT];
		//float    fBaselineLevel[ABF_DACCOUNT];
		//float    fStepDuration[ABF_DACCOUNT];
		//float    fStepLevel[ABF_DACCOUNT];
		//float    fPostTrainPeriod[ABF_DACCOUNT];
		//float    fPostTrainLevel[ABF_DACCOUNT];
		//short    nMembTestEnable[ABF_DACCOUNT];
		//float    fMembTestPreSettlingTimeMS[ABF_DACCOUNT];
		//float    fMembTestPostSettlingTimeMS[ABF_DACCOUNT];

		//1
		dim[0]=1;
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,138,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nConditEnable[0], sizeof(FileHeader.nConditEnable));

		//2
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,139,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lConditNumPulses[0], sizeof(FileHeader.lConditNumPulses));

		//3
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,140,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fBaselineDuration[0], sizeof(FileHeader.fBaselineDuration));

		//4
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,141,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fBaselineLevel[0], sizeof(FileHeader.fBaselineLevel));

		//5
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,142,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fStepDuration[0], sizeof(FileHeader.fStepDuration));

		//6
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,143,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fStepLevel[0], sizeof(FileHeader.fStepLevel));

		//7
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,144,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fPostTrainPeriod[0], sizeof(FileHeader.fPostTrainPeriod));

		//8
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,145,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fPostTrainLevel[0], sizeof(FileHeader.fPostTrainLevel));

		//9
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,146,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nMembTestEnable[0], sizeof(FileHeader.nMembTestEnable));

		//10
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,147,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fMembTestPreSettlingTimeMS[0], sizeof(FileHeader.fMembTestPreSettlingTimeMS));

		//11
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,148,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fMembTestPostSettlingTimeMS[0], sizeof(FileHeader.fMembTestPostSettlingTimeMS));

		// GROUP #12 - Variable parameter user list
		//short    nULEnable[ABF_USERLISTCOUNT];
		//short    nULParamToVary[ABF_USERLISTCOUNT];
		//short    nULRepeat[ABF_USERLISTCOUNT];
		//char     sULParamValueList[ABF_USERLISTCOUNT][ABF_USERLISTLEN];

		//1
		dim[0]=1;
		dim[1]=ABF_USERLISTCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,149,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nULEnable[0], sizeof(FileHeader.nULEnable));

		//2
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,150,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nULParamToVary[0], sizeof(FileHeader.nULParamToVary));

		//3
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,151,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nULRepeat[0], sizeof(FileHeader.nULRepeat));

		//4
		dim[0]=ABF_USERLISTCOUNT;
		dim[1]=ABF_USERLISTLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,152,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sULParamValueList[0], sizeof(FileHeader.sULParamValueList));


		// GROUP #13 - Statistics measurements
		//short    nStatsEnable;
		//unsigned short nStatsActiveChannels;             // Active stats channel bit flag
		//unsigned short nStatsSearchRegionFlags;          // Active stats region bit flag
		//short    nStatsSmoothing;
		//short    nStatsSmoothingEnable;
		//short    nStatsBaseline;
		//short    nStatsBaselineDAC;                      // If mode is epoch, then this holds the DAC
		//long     lStatsBaselineStart;
		//long     lStatsBaselineEnd;
		//long     lStatsMeasurements[ABF_STATS_REGIONS];  // Measurement bit flag for each region
		//long     lStatsStart[ABF_STATS_REGIONS];
		//long     lStatsEnd[ABF_STATS_REGIONS];
		//short    nRiseBottomPercentile[ABF_STATS_REGIONS];
		//short    nRiseTopPercentile[ABF_STATS_REGIONS];
		//short    nDecayBottomPercentile[ABF_STATS_REGIONS];
		//short    nDecayTopPercentile[ABF_STATS_REGIONS];
		//short    nStatsChannelPolarity[ABF_ADCCOUNT];
		//short    nStatsSearchMode[ABF_STATS_REGIONS];    // Stats mode per region: mode is cursor region, epoch etc 
		//short    nStatsSearchDAC[ABF_STATS_REGIONS];     // If mode is epoch, then this holds the DAC

		//1
		mxSetFieldByNumber(plhs[1],0,153,mxCreateDoubleScalar((double)FileHeader.nStatsEnable));

		//2 Maintain bitmap type
		dim[0]=1;
		dim[1]=1;
		ptr=mxCreateNumericArray(2, dim, mxUINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,154,ptr);
		memcpy((unsigned short *)mxGetPr(ptr), &FileHeader.nStatsActiveChannels, sizeof(FileHeader.nStatsActiveChannels));

		//3
		ptr=mxCreateNumericArray(2, dim, mxUINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,155,ptr);
		memcpy((unsigned short *)mxGetPr(ptr), &FileHeader.nStatsSearchRegionFlags, sizeof(FileHeader.nStatsSearchRegionFlags));

		//4-9
		mxSetFieldByNumber(plhs[1],0,156,mxCreateDoubleScalar((double)FileHeader.nStatsSmoothing));
		mxSetFieldByNumber(plhs[1],0,157,mxCreateDoubleScalar((double)FileHeader.nStatsSmoothingEnable));
		mxSetFieldByNumber(plhs[1],0,158,mxCreateDoubleScalar((double)FileHeader.nStatsBaseline));
		mxSetFieldByNumber(plhs[1],0,159,mxCreateDoubleScalar((double)FileHeader.nStatsBaselineDAC));
		mxSetFieldByNumber(plhs[1],0,160,mxCreateDoubleScalar((double)FileHeader.lStatsBaselineStart));
		mxSetFieldByNumber(plhs[1],0,161,mxCreateDoubleScalar((double)FileHeader.lStatsBaselineEnd));

		//5
		dim[0]=1;
		dim[1]=ABF_STATS_REGIONS;
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,162,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lStatsMeasurements[0], sizeof(FileHeader.lStatsMeasurements));

		//6
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,163,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lStatsStart[0], sizeof(FileHeader.lStatsStart));

		//7
		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,164,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lStatsEnd[0], sizeof(FileHeader.lStatsEnd));

		//8
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,165,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nRiseBottomPercentile[0], sizeof(FileHeader.nRiseBottomPercentile));

		//9
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,166,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nRiseTopPercentile[0], sizeof(FileHeader.nRiseTopPercentile));

		//10
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,167,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nDecayBottomPercentile[0], sizeof(FileHeader.nDecayBottomPercentile));

		//11
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,168,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nDecayTopPercentile[0], sizeof(FileHeader.nDecayTopPercentile));

		//12
		dim[1]=ABF_ADCCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,169,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nStatsChannelPolarity[0], sizeof(FileHeader.nStatsChannelPolarity));

		//13
		dim[1]=ABF_STATS_REGIONS;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,170,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nStatsSearchMode[0], sizeof(FileHeader.nStatsSearchMode));

		//14
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,171,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nStatsSearchDAC[0], sizeof(FileHeader.nStatsSearchDAC));

		// GROUP #14 - Channel Arithmetic
		//short    nArithmeticEnable;
		//short    nArithmeticExpression;
		//float    fArithmeticUpperLimit;
		//float    fArithmeticLowerLimit;
		//short    nArithmeticADCNumA;
		//short    nArithmeticADCNumB;
		//float    fArithmeticK1;
		//float    fArithmeticK2;
		//float    fArithmeticK3;
		//float    fArithmeticK4;
		//float    fArithmeticK5;
		//float    fArithmeticK6;
		//char     sArithmeticOperator[ABF_ARITHMETICOPLEN];
		//char     sArithmeticUnits[ABF_ARITHMETICUNITSLEN];

		//1-13
		mxSetFieldByNumber(plhs[1],0,172,mxCreateDoubleScalar((double)FileHeader.nArithmeticEnable));
		mxSetFieldByNumber(plhs[1],0,173,mxCreateDoubleScalar((double)FileHeader.nArithmeticExpression));
		mxSetFieldByNumber(plhs[1],0,174,mxCreateDoubleScalar((double)FileHeader.fArithmeticUpperLimit));
		mxSetFieldByNumber(plhs[1],0,175,mxCreateDoubleScalar((double)FileHeader.fArithmeticLowerLimit));
		mxSetFieldByNumber(plhs[1],0,176,mxCreateDoubleScalar((double)FileHeader.nArithmeticADCNumA));
		mxSetFieldByNumber(plhs[1],0,177,mxCreateDoubleScalar((double)FileHeader.nArithmeticADCNumB));
		mxSetFieldByNumber(plhs[1],0,178,mxCreateDoubleScalar((double)FileHeader.fArithmeticK1));
		mxSetFieldByNumber(plhs[1],0,179,mxCreateDoubleScalar((double)FileHeader.fArithmeticK2));
		mxSetFieldByNumber(plhs[1],0,180,mxCreateDoubleScalar((double)FileHeader.fArithmeticK3));
		mxSetFieldByNumber(plhs[1],0,181,mxCreateDoubleScalar((double)FileHeader.fArithmeticK4));
		mxSetFieldByNumber(plhs[1],0,182,mxCreateDoubleScalar((double)FileHeader.fArithmeticK5));
		mxSetFieldByNumber(plhs[1],0,183,mxCreateDoubleScalar((double)FileHeader.fArithmeticK6));

		//14
		dim[0]=1;
		dim[1]=ABF_ARITHMETICOPLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,184,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sArithmeticOperator, sizeof(FileHeader.sArithmeticOperator));

		//15
		dim[1]=ABF_ARITHMETICUNITSLEN;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,185,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.sArithmeticUnits, sizeof(FileHeader.sArithmeticUnits));

		// GROUP #15 - Leak subtraction
		//short    nPNPosition;
		//short    nPNNumPulses;
		//short    nPNPolarity;
		//float    fPNSettlingTime;
		//float    fPNInterpulse;
		//short    nLeakSubtractType[ABF_DACCOUNT];
		//float    fPNHoldingLevel[ABF_DACCOUNT];
		//bool     bEnabledDuringPN[ABF_ADCCOUNT];

		mxSetFieldByNumber(plhs[1],0,186,mxCreateDoubleScalar((double)FileHeader.nPNPosition));
		mxSetFieldByNumber(plhs[1],0,187,mxCreateDoubleScalar((double)FileHeader.nPNNumPulses));
		mxSetFieldByNumber(plhs[1],0,188,mxCreateDoubleScalar((double)FileHeader.nPNPolarity));
		mxSetFieldByNumber(plhs[1],0,189,mxCreateDoubleScalar((double)FileHeader.fPNSettlingTime));
		mxSetFieldByNumber(plhs[1],0,190,mxCreateDoubleScalar((double)FileHeader.fPNInterpulse));

		dim[0]=1;
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,191,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nLeakSubtractType, sizeof(FileHeader.nLeakSubtractType));

		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,192,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fPNHoldingLevel, sizeof(FileHeader.fPNHoldingLevel));

        dim[1]=ABF_ADCCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,193,ptr);
		memcpy((bool *)mxGetPr(ptr), &FileHeader.bEnabledDuringPN, sizeof(FileHeader.bEnabledDuringPN));

		// GROUP #16 - Miscellaneous variables
		//short    nLevelHysteresis;
		//long     lTimeHysteresis;
		//short    nAllowExternalTags;
		//short    nAverageAlgorithm;
		//float    fAverageWeighting;
		//short    nUndoPromptStrategy;
		//short    nTrialTriggerSource;
		//short    nStatisticsDisplayStrategy;
		//short    nExternalTagType;
		//long     lHeaderSize;
		//short    nStatisticsClearStrategy;
		mxSetFieldByNumber(plhs[1],0,194,mxCreateDoubleScalar((double)FileHeader.nLevelHysteresis));
		mxSetFieldByNumber(plhs[1],0,195,mxCreateDoubleScalar((double)FileHeader.lTimeHysteresis));
		mxSetFieldByNumber(plhs[1],0,196,mxCreateDoubleScalar((double)FileHeader.nAllowExternalTags));
		mxSetFieldByNumber(plhs[1],0,197,mxCreateDoubleScalar((double)FileHeader.nAverageAlgorithm));
		mxSetFieldByNumber(plhs[1],0,198,mxCreateDoubleScalar((double)FileHeader.fAverageWeighting));
		mxSetFieldByNumber(plhs[1],0,199,mxCreateDoubleScalar((double)FileHeader.nUndoPromptStrategy));
		mxSetFieldByNumber(plhs[1],0,200,mxCreateDoubleScalar((double)FileHeader.nTrialTriggerSource));
		mxSetFieldByNumber(plhs[1],0,201,mxCreateDoubleScalar((double)FileHeader.nStatisticsDisplayStrategy));
		mxSetFieldByNumber(plhs[1],0,202,mxCreateDoubleScalar((double)FileHeader.nExternalTagType));
		mxSetFieldByNumber(plhs[1],0,203,mxCreateDoubleScalar((double)FileHeader.lHeaderSize));
		mxSetFieldByNumber(plhs[1],0,204,mxCreateDoubleScalar((double)FileHeader.nStatisticsClearStrategy));


		// GROUP #17 - Trains parameters
		//long     lEpochPulsePeriod[ABF_DACCOUNT][ABF_EPOCHCOUNT];
		//long     lEpochPulseWidth [ABF_DACCOUNT][ABF_EPOCHCOUNT];

		dim[0]=ABF_DACCOUNT;
		dim[1]=ABF_EPOCHCOUNT;

		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,205,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lEpochPulsePeriod, sizeof(FileHeader.lEpochPulsePeriod));

		ptr=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,206,ptr);
		memcpy((long *)mxGetPr(ptr), &FileHeader.lEpochPulseWidth, sizeof(FileHeader.lEpochPulseWidth));

		// GROUP #18 - Application version data
		//short    nCreatorMajorVersion;
		//short    nCreatorMinorVersion;
		//short    nCreatorBugfixVersion;
		//short    nCreatorBuildVersion;
		//short    nModifierMajorVersion;
		//short    nModifierMinorVersion;
		//short    nModifierBugfixVersion;
		//short    nModifierBuildVersion;
		mxSetFieldByNumber(plhs[1],0,207,mxCreateDoubleScalar((double)FileHeader.nCreatorMajorVersion));
		mxSetFieldByNumber(plhs[1],0,208,mxCreateDoubleScalar((double)FileHeader.nCreatorMinorVersion));
		mxSetFieldByNumber(plhs[1],0,209,mxCreateDoubleScalar((double)FileHeader.nCreatorBugfixVersion));
		mxSetFieldByNumber(plhs[1],0,210,mxCreateDoubleScalar((double)FileHeader.nCreatorBuildVersion));
		mxSetFieldByNumber(plhs[1],0,211,mxCreateDoubleScalar((double)FileHeader.nModifierMajorVersion));
		mxSetFieldByNumber(plhs[1],0,212,mxCreateDoubleScalar((double)FileHeader.nModifierMinorVersion));
		mxSetFieldByNumber(plhs[1],0,213,mxCreateDoubleScalar((double)FileHeader.nModifierBugfixVersion));
		mxSetFieldByNumber(plhs[1],0,214,mxCreateDoubleScalar((double)FileHeader.nModifierBuildVersion));

		// GROUP #19 - LTP protocol
		//short    nLTPType;
		//short    nLTPUsageOfDAC[ABF_DACCOUNT];
		//short    nLTPPresynapticPulses[ABF_DACCOUNT];

		mxSetFieldByNumber(plhs[1],0,215,mxCreateDoubleScalar((double)FileHeader.nLTPType));

		dim[0]=1;
		dim[1]=ABF_DACCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,216,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nLTPUsageOfDAC, sizeof(FileHeader.nLTPUsageOfDAC));

		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,217,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nLTPPresynapticPulses, sizeof(FileHeader.nLTPPresynapticPulses));

		// GROUP #20 - Digidata 132x Trigger out flag
		//short    nScopeTriggerOut;
		mxSetFieldByNumber(plhs[1],0,218,mxCreateDoubleScalar((double)FileHeader.nScopeTriggerOut));

		// GROUP #22 - Alternating episodic mode
		//short    nAlternateDACOutputState;
		//short    nAlternateDigitalOutputState;
		//short    nAlternateDigitalValue[ABF_EPOCHCOUNT];
		//short    nAlternateDigitalTrainValue[ABF_EPOCHCOUNT];

		mxSetFieldByNumber(plhs[1],0,219,mxCreateDoubleScalar((double)FileHeader.nAlternateDACOutputState));
		mxSetFieldByNumber(plhs[1],0,220,mxCreateDoubleScalar((double)FileHeader.nAlternateDigitalOutputState));
		dim[0]=1;
		dim[1]=ABF_EPOCHCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,221,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nAlternateDigitalValue, sizeof(FileHeader.nAlternateDigitalValue));

		ptr=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,222,ptr);
		memcpy((short *)mxGetPr(ptr), &FileHeader.nAlternateDigitalTrainValue, sizeof(FileHeader.nAlternateDigitalTrainValue));

		// GROUP #23 - Post-processing actions
		//float    fPostProcessLowpassFilter[ABF_ADCCOUNT];
		//char     nPostProcessLowpassFilterType[ABF_ADCCOUNT];

		dim[0]=1;
		dim[1]=ABF_ADCCOUNT;
		ptr=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,223,ptr);
		memcpy((float *)mxGetPr(ptr), &FileHeader.fPostProcessLowpassFilter, sizeof(FileHeader.fPostProcessLowpassFilter));

		ptr=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
		mxSetFieldByNumber(plhs[1],0,224,ptr);
		memcpy((char *)mxGetPr(ptr), &FileHeader.nPostProcessLowpassFilterType, sizeof(FileHeader.nPostProcessLowpassFilterType));


		// GROUP #24 - Legacy gear shift info
		//float    fLegacyADCSequenceInterval;
		//float    fLegacyADCSecondSequenceInterval;
		//long     lLegacyClockChange;
		//long     lLegacyNumSamplesPerEpisode;
		mxSetFieldByNumber(plhs[1],0,225,mxCreateDoubleScalar((double)FileHeader.fLegacyADCSequenceInterval));
		mxSetFieldByNumber(plhs[1],0,226,mxCreateDoubleScalar((double)FileHeader.fLegacyADCSecondSequenceInterval));
		mxSetFieldByNumber(plhs[1],0,227,mxCreateDoubleScalar((double)FileHeader.lLegacyClockChange));
		mxSetFieldByNumber(plhs[1],0,228,mxCreateDoubleScalar((double)FileHeader.lLegacyNumSamplesPerEpisode));

	}
	//Close file and free the library
	(*FileClose)(FileHandle, &Error);
	FreeLibrary(hinstLib);
	return;
}
//*********************************************************************