/* This program SIMPLEW.C is a short example of creating a V2.10 CFS file
and storing some data in it.
The file produced by the program will be called SIMPLEW.CFS if you have
anothe file of that name in the current directory its contents will be lost.
This example stores 3 inerleaved data channels (similar to 1401 ADC data )
and another channel of decimal values which could be anything.
It also demonstrates the use of file and data section variables of different
types.
Started 18 Jan 1991 by JG example 2 for CFS V2.0 in C.
   Compiling instructions:
   Type  cl /AL /c SIMPLEW.C
         link /NOI /ST:20000 SIMPLEW+CFS,SIMPLEW.EXE,,llibce;
   Then type SIMPLEW to run the program.
*/

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "cfs.h"

    short    handle;                                 /* program file handle */
    short    ret;                               /* for CFS function returns */
    short    interChans[512];       /* array for 2 chans each 256 values to be
                                    used for simulated interleaved ADC data */
    TVarDesc filVars[3];          /* Array for 3 file variable descriptions */

    char*    comment = "Demonstration of C version";       /* file comments */
    char*    filName = "SIMPLEW";                              /* file name */
    char*    filExt  = ".CFS";                            /* file extension */
    char     fileName[11];                         /* name of file to write */
    short    chans = 2;                /* fictional number of data channels */
    short    sects = 3;                /* fictional number of data sections */
    long     pts   = 256;                /* fictional number of data points */


/****************************************************************************/

void InitVariables(void)
/* Set up file variable descriptions. By convention file variable 0 is a dummy
   variable and stores information about the program producing the CFS file */

{
    strncpy(fileName,filName,8);                          /* copy file name */
    strcat(fileName,filExt);                            /* append extension */
    strcpy(filVars[0].varDesc,"CED example Program");
                               /* describe program maximum of 20 characters */
    strcpy(filVars[0].varUnits,filName);    
                            /* store program name here maximum 8 characters */
    filVars[0].vType = INT2;               /* must be 1 of the 8 data types */
    filVars[0].vSize = 0;       /* size of INT2 variable will be set by CFS */
}

/****************************************************************************/

short InitChannels(short handle)
/* Initialise channels for CFS file specified by its CFS file handle 
                                                    Return 1 if ok 0 if not */
{
    short  handleNo,
           procNo,
           errNo;                                     /* for error handling */
    short  ret;                                         /* for return value */
    float  rate;                    /* mythical sampling rate, used to compute
                                  sample interval on simulated ADC channels */

    ret = 1;                                      /* return value if all ok */
     /* Set up the non varying channel information. There are to be 2 channels
                   of interleaved data. Start with the interleaved channels */
    SetFileChan(handle,0,"ECG","mV","s",INT2,EQUALSPACED,4,0);
                                                    /* set channel number 0 */

    SetFileChan(handle,1,"Blood Pressure","Pa","s",INT2,EQUALSPACED,4,0);
                                                    /* set channel number 1 */
    if (FileError(&handleNo,&procNo,&errNo)!=0)
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        return 0;
    };
/* The data section channel information for the 2 equaleSpaced channels does
   not change between data sections so set it here and the same values
                                         will be used for all data sections */
    rate = (float) 100.0;        /* sampling rate of the simulated ADC data */
    SetDSChan(handle,0,         /* parameters for 1st channel ie. channel 0 */
              0,                                     /* curent data section */
              0,                          /* offset from start of data area */
              pts,                            /* number of channel 0 points */
              (float) 0.0264,(float) 0.0,
              1/rate,                       /* interval between data points */
              (float) 0.0);                       /* time offset for chan 0 */
    SetDSChan(handle,1,0,                    /* channel 1 is like channel 0 */
              2,              /* offset from start of data area is 2 bytes. ie 
                                          interleaved with channels 0 and 1 */
              pts,(float) 0.0132,(float) 0.0,1/rate,(float) 0.0);
    if (FileError(&handleNo,&procNo,&errNo)!=0)
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        return 0;
    };
    return ret;
};                                                      /* end of InitChans */
									 
/****************************************************************************/

short SetFileVars(short handle)
/* set the values for the file variable for which descriptions have been
                                          provided. Return 1 if ok 0 if not */
{
    short   handleNo,
            procNo,
            errNo;                                    /* for error handling */
    short   ret;                                        /* for return value */
    short   fVar0;                          /* for value of file variable 0 */

    ret   = 1;                                        /* return value if ok */
    fVar0 = 210;     /* the value of this variable is 100 times version no. */
    SetVarVal(handle,                                    /* CFS file handle */
              0,                                    /* File variable number */
              FILEVAR,                                     /* variable kind */
              0,                               /* data section not relevant */
              &fVar0);              /* pointer to value for file variable 0 */
    if (FileError(&handleNo,&procNo,&errNo)!=0)
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        ret = 0;
    };
    
    return ret;
};                                                    /* end of SetFileVars */

/****************************************************************************/

void MakeUpData(short*  interChans)          /* pointer to interleaved data */
/* Invent some channel data and values for the data section variables.
   This is all stuff that can vary between data sections */
{
    int     i,j,t;                                             /* for loops */

         /* first some values for the interleaved data channels 0,1, (INT2) */
    for (i = 0;i < pts;i ++)                /* for each item in the channel */
         for (j = 0;j < chans;j ++)                     /* for each channel */
         {
              t = i*1024;                    /* Generate a sort of sawtooth */
              if (j > 0)               /* Make the second channel different */
                 t = abs(t);
              interChans[2*i+j] = (short) t;            /* arbitrary values */
         }
    return;
};                                                     /* end of MakeUpData */

/****************************************************************************/

short DoSection(short ds,short handle)
                                         /* writes one data section to disk */
{
    short    ret;                                       /* for return value */

                                                      /* write data to file */
    ret = WriteData(handle,                              /* CFS file handle */
                    0,                  /* data section number not relevant */
                    0,       /* offset from start of data section for write */
                    1024,         /* number of bytes to write for INT2 data */
                    interChans);                        /* pointer tot data */
    if (ret < 0)                                  /* return value if not ok */
    {
        printf("\nError writing interleaved channel data to CFS file %d",ret);
        return ret;
    };

    ret = InsertDS(handle,0,noFlags);
                                   /* insert current data section, no flags */
    if (ret < 0) 
    {
        printf ("\nError inserting data section %u %d",ds,ret);
        return ret;
    };
    return 0;
}                                                      /* end of do section */

/****************************************************************************/

short SetUpAndGo(short handle)   /* sets data channel information and writes */
{
    short dS;                                        /* data section number */
    short  ret;

    ret = InitChannels(handle);           /* Initialise channel information */
    if (ret == 0)
        return ret;
    ret = SetFileVars(handle);         /* Set values for the file variables */
    if (ret == 0)
        return ret;
 
    MakeUpData(interChans);        /* pointer to array for interleaved data */
    for (dS = 1;dS <= sects;dS ++)
                                             /* for each of 3 data sections */
    {
         ret = DoSection(dS,handle);           /* now write 3 data sections */
         if (ret != 0)
             return ret;
    }
    return 0;
}

/****************************************************************************/

void SaySomething(void)                  /* describe the file to be written */
{
printf("\n               SimpleW - CFS example writing program\n\n");
printf("The file %s%s is now being written. It contains dummy\n", filName,filExt);
printf("data consisting of %d data sections of %d channels\n",sects,chans);
printf("of waveform data.\n\n");
printf("There is also 1 variable stored in the file header.\n\n");
printf("To examine the file use the program SimpleR.\n\n");
}

/***********************   M A I N   B O D Y    *****************************/

main(void)
{
    SaySomething();                        /* tell the user what's going on */
    InitVariables();
              /* initialise variable descriptions prior to opening the file */
    handle = CreateCFSFile(fileName,                       /* CFS file name */
                           comment,
                               /* CFS file comment maximum of 72 characters */
                           1,     /* CFS file block size (usually 1 or 512) */
                           chans,/* number of channels to be stored in file */
                           filVars,   /* pointer to array of file variables */
                           filVars,     /* pointer to array of DS variables */
                           1,                   /* number of file variables */
                           0);          /* number of data section variables */
    if (handle < 0) 
    {
        printf("\nError creating file %d",handle);
        return 0;
    }
    else
    {
        ret = SetUpAndGo(handle);                     /* do everything else */
        if (ret < 0) 
            printf("\nError writing to file %d",ret);
    }
    ret = CloseCFSFile(handle);
    if (ret < 0) 
        printf("\nError closing file %d",ret);
    return 0;
};
 
 
 
 
 
 
 
 
