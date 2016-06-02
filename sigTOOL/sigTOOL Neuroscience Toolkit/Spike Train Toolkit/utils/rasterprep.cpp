#include <mex.h>
#include <math.h>
// #include <stdio.h>

//function [x y z]=rasterprep(trigger, spikes, duration, pretime)
// % RASTERPREP workhorse function for calculating spike correlations
// %
// % Example
// % [x y v]=RASTERPREP(trigger, spiketimes, duration, pretime)
// %
// % Inputs: trigger         the trigger times
// %         spiketimes      the spike times
// %         duration        sweep duration
// %         pretime         the pretime period
// %
// % Outputs:
// %         x            time relative to trigger
// %         y            sweep number
// %         v            if present, the interspike interval of the
// %                        relevant spike
// %
// % RASTERPREP uses all triggers and spikes (except for for the first
// % spike when interspike interval are requested). The calling function should deal
// % with end-effects where incomplete sweeps may be available.
// %
// % To calculate a post- or peri - stimulus time raster, debounce the
// % triggers before calling rasterprep. For cross-correlation, do not
// % debounce.
// %
// % See also debounce
// % -------------------------------------------------------------------------
// % Author: Malcolm Lidierth 03/08
// % Copyright © The Author & King's College London 2008-
// % -------------------------------------------------------------------------
// %
// % Help text corrected 12.12.08

void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    // From input
    // Units of time are arbitrary but should all be the same
    double *ptrigger;   //Pointer to the triggers in ML workspace
    double *pspikes;    //Pointer to the spike in ML workspace
    double duration;    // Total duration
    double pretime;     // Pretime
    
    // Pointer to buffer for result
    double *x, *y, *v;
    
    // Local variables
    double d;
    int idxs, idxt, sstart;
    int ntrig=0, nspikes=0, count;
    
    if (nrhs<3)
        mexErrMsgTxt("rasterprep mex file: Too few input arguments\n");
    
    // Get Input arguments
    ptrigger=mxGetPr(prhs[0]);
    pspikes=mxGetPr(prhs[1]);
    duration=mxGetScalar(prhs[2]);
    if (duration<=0)
        mexErrMsgTxt("rasterprep mex file: Duration must be positive");
    if (nrhs<4)
        pretime=0;
    else
        pretime=mxGetScalar(prhs[3]);
    if (pretime<0)
        mexErrMsgTxt("rasterprep mex file: Pretime should be positive");
    
    // Floating point warnings: User can switch these off in MATLAB
    // They make a difference only if the output is post-processed e.g to
    // form a JPSTH
	if (fmod(pretime,1)!=0)
		mexWarnMsgIdAndTxt("sigtool:rasterprep:tolwarn", "rasterprep mex file:\nTo avoid floating point rounding issues, pretime should be a whole number\nValue: [%20.10f]\n", pretime);

    
    // Size of input vectors
    ntrig=(int)*mxGetDimensions(prhs[0]);
    nspikes=(int)*mxGetDimensions(prhs[1]);
    if (ntrig==1 || nspikes==1)
        mexErrMsgTxt("rasterprep mex file: Timestamps must be supplied as column vectors");
    
    
    if (nlhs>2)
        // Returning interspike intervals so need to ignore the first spike
        sstart=1;
    else
        sstart=0;

    // First sweep.
    // This is used to calculate the required dimensions of the output vectors    
    
    count=0;
    
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
                if (d<=duration)
                {
                    // spike in range
                    count++;
                }
                else
                    // too late: no more spikes for this trigger
                    break;
                
            }
        }
    }
    
    
    
    // Set up outputs
    plhs[0]=mxCreateDoubleMatrix (1, count, mxREAL);
    x=mxGetPr(plhs[0]);
    if (nlhs>1)
    {
        plhs[1]=mxCreateDoubleMatrix (1, count, mxREAL);
        y=mxGetPr(plhs[1]);
    }
    if (nlhs>2)
    {
        // Returning interspike intervals so need to ignore the first spike
        // If this spike falls within a sweep the output vectors will have
        // a trailing zero
        sstart=1;
        plhs[2]=mxCreateDoubleMatrix (1, count, mxREAL);
        v=mxGetPr(plhs[2]);
    }
    else
        sstart=0;
    
    
    count=0;
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
                if (d<=duration)
                {
                    // spike in range
                    x[count]=d-pretime;
                    y[count]=idxt;
                    if (nlhs==3 & idxs>0) 
                        v[count]=pspikes[idxs]-pspikes[idxs-1];
                    count++;
                }
                else
                    // too late: no more spikes for this trigger
                    break;
                
            }
        }
    }
    
    
    
    
    
}//EOF



