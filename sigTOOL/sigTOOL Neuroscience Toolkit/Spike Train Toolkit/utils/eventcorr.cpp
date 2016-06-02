#include <mex.h>
#include <math.h>
// #include <stdio.h>

// MATLAB calling convention:
// function [pbin tb]=eventcorr(trigger, spikes, binwidth, nsweeps, duration, pretime)
//
// % EVENTCORR workhorse function for calculating spike correlations
// %
// % Example
// % [pbin tb]=EVENTCORR(trigger, spiketimes, binwidth, nsweeps,  duration, pretime)
// %
// % Inputs: trigger         the trigger times
// %         spiketimes      the spike times
// %         binwidth        binwidth for the histogram
// %         nsweeps         the number of triggers per histogram, zero for a
// %                         single histogram using all triggers
// %         duration        sweep duration
// %         pretime         the pretime period
// %
// % Outputs:
// %         pbin            the histogram counts as number of spikes
// %         tb              the timebase for the correlation
// %
// % EVENTCORR uses all triggers and spikes. The calling function should deal
// % with end-effects where incomplete sweeps may be available.
// %
// % To calculate a post- or peri - stimulus time histogram, debounce the
// % triggers before calling eventcorr. For cross-correlation, do not
// % debounce.
// %
// % See also debounce
// % -------------------------------------------------------------------------
// % Author: Malcolm Lidierth 03/08
// % Copyright © The Author & King's College London 2008-
// % -------------------------------------------------------------------------

void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    // From input
    // Units of time are arbitrary but should all be the same
    double *ptrigger;   //Pointer to the triggers in ML workspace
    double *pspikes;    //Pointer to the spike in ML workspace
    double binwidth;    // Binwidth
    int nsweeps;        // Number of sweeps per correlation
    double duration;    // Total duration
    double pretime;     // Pretime
    
    // Pointer to buffer for result
    mxArray *temp;
    
    // Local variables
    double *r;
    double d;
    int rdim, thissweep, nrows, ncols;
    int idxs, idxt, idxt1, idxt2, sstart;
    int ntrig=0, nspikes=0, bin=0, count;
    
    if (nrhs<6)
        mexErrMsgTxt("eventcorr mex file: Too few input arguments\n");
    
	// Get Input arguments
    ptrigger=mxGetPr(prhs[0]);
    pspikes=mxGetPr(prhs[1]);
    binwidth=mxGetScalar(prhs[2]);
    if (binwidth<=0)
        mexErrMsgTxt("eventcorr mex file: Binwidth must be positive");
    nsweeps=(int) mxGetScalar(prhs[3]);
    duration=mxGetScalar(prhs[4]);
    if (duration<=0)
        mexErrMsgTxt("eventcorr mex file: Duration must be positive");
    pretime=mxGetScalar(prhs[5]);
    if (pretime<0)
        mexErrMsgTxt("eventcorr mex file: Pretime should be positive");

	// Floating point warnings: User can switch these off in MATLAB
	if (fmod(binwidth,1)!=0 || fmod(duration,1)!=0 || fmod(pretime,1)!=0)
		mexWarnMsgIdAndTxt("sigtool:eventcorr:tolwarn", "eventcorr mex file:\nTo avoid floating point rounding issues, binwidth duration and pretime should be whole numbers\nValues: [%20.10f %20.10f %20.10f]\n", binwidth, duration, pretime);

	if (fmod(pretime/binwidth,1)!=0)
		mexWarnMsgIdAndTxt("sigTOOL:eventcorr:pretime", "eventcorr mex file:\nPretime is not an exact multiple of the binwidth\nValues: [%20.10f %20.10f]", pretime, binwidth);
    
    
    // Size of input vectors
    ntrig=(int)*mxGetDimensions(prhs[0]);
    nspikes=(int)*mxGetDimensions(prhs[1]);
    if (ntrig==1 || nspikes==1)
        mexErrMsgTxt("eventcorr mex file: Timestamps must be supplied as column vectors");
    
    // Set up buffer for correlation
    // NB work with n*m matrices, transpose to m*n at end using MATLAB
    ncols=(int)(duration/binwidth);
    if (nsweeps==0 || ntrig<nsweeps)
    {
        // Single result
        nrows=1;
        temp=mxCreateDoubleMatrix(ncols, 1, mxREAL);
    }
    else
    {
        // Multiple
        nrows=ntrig/nsweeps;
        temp=mxCreateDoubleMatrix(ncols, nrows, mxREAL);
    }
    
    // Return timebase if required
    if (nlhs>1)
    {
        plhs[1]=mxCreateDoubleMatrix (1, ncols, mxREAL);
        r=mxGetPr(plhs[1]);
        for (bin=0; bin<ncols; bin++){
            r[bin]=-pretime+(bin*binwidth);
        }
    }
    
    // Now calculate the correlation
    r=mxGetPr(temp);
    if (r==NULL)
        mexErrMsgTxt("eventcorr mex file: mxGetPr returned NULL");
    
    sstart=0;
    count=0;
    thissweep=0;
    if (nsweeps==0)
    {
        // Use all available triggers
        for (idxt=0; idxt<ntrig; idxt++)
        {
            for (idxs=sstart; idxs<nspikes; idxs++)
            {
                d=pspikes[idxs]-(ptrigger[idxt]-pretime);
                if (d<0)
                    //ignore this spike for subsequent triggers
                    sstart=idxs;
                else
                {
                    // d positive or zero - no need for floor here
                    bin=(int)(d/binwidth);
                    if (bin<ncols)
                    {
                        // spike in range
                        r[bin]++;
                        count++;
                    }
                    else
                        // too late: no more spikes for this trigger
                        break;
                    
                }
            }
        }
    }
    else
    {    // Use nsweeps triggers per correlation
        for (idxt1=0; idxt1<ntrig-nsweeps; idxt1=idxt1+nsweeps)
        {
            for (idxt2=idxt1; idxt2<idxt1+nsweeps; idxt2++)
            {
                for (idxs=sstart; idxs<nspikes; idxs++)
                {
                    d=pspikes[idxs]-(ptrigger[idxt2]-pretime);
                    if (d<0)
                        sstart=idxs;
                    else
                    {
                        bin=(int)(d/binwidth);
                        if (bin<ncols)
                        {
                            // Add offset into matrix: Remember this is C
                            // so we are presently working with a transposed
                            // copy relative to MATLAB
                            rdim=thissweep*ncols;
                            r[bin+rdim]++;
                            count++;
                        }
                        else
                            break;
                    }
                }
            }
            thissweep++;
        }
    }
    
    // Transpose temp and return on LHS using MATLAB
    mexCallMATLAB(1,&plhs[0],1,&temp,"transpose");
    // Free buffer memory
    mxDestroyArray(temp);
    
    
}//EOF



