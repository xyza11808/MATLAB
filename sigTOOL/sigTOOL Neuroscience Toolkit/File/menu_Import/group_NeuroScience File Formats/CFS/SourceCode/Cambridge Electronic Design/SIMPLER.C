/* This program SIMPLER.C is a short example of reading an existing
   CFS file. The program askes for a file name, checks that it is a V2.10
   CFS file and then prints out information on the file contents.
   Started 16 Jan 1991    JG. example 1 for cfs V2.0 in C.

   Compiling instructions:
   Type    cl /AL /c SIMPLER.C
           link /NOI SIMPLER+CFS,simpler.exe,,llibce;

   Then type SIMPLER to run the program
*/

#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include "cfs.h"

                                       /* total number of points to display */
#define TotPts 40


typedef union
/* variable type used in DisplayChan for reading TotPts items of channel 
                                                                       data */
{
    char    onebyte[TotPts];
    short   twobyte[TotPts];
    long    fourbyte[TotPts];
    float   realv[TotPts];
    double  doubv[TotPts];
}   TChanTen;

    short   handle;                                      /* CFS file handle */
    short   ret;                                       /* for return values */
    short   channels,fileVars,DSVars;  /* numbers of channels and variables */
    short   i;                                             /* loop variable */
    char    fName[40];                /* for file name (with optional path) */
    TSFlags flagSet;
    WORD    DSLoop;                                /* another loop variable */
    WORD    dataSections;                        /* number of data sections */

/****************************************************************************/

long SystemTime(void)
                   /* Gets system time and converts it to hundreds of a sec */

{
    long    hr;
    long    min;
    long    sec;
    long    s100;
    struct _dostime_t  time;

    _dos_gettime(&time);                                /* get current time */

    hr    = (long) time.hour;                   /* convert string to number */
    min   = (long) time.minute;
    sec   = (long) time.second;
    s100  = (long) time.hsecond;

    return (long) (hr*360000 + min*6000 + sec*100 + s100);   /* system time */
}

/****************************************************************************/

void MyDelay(int delTime)
/* Delays a specified number of miliseconds or until key pressed on the
                                                                   keyboard */
{
    long    lDone;
    div_t   div_result;
    
    div_result = div(delTime,10);               /* convert to 1/100 th secs */
    delTime    = div_result.quot;
    lDone      = SystemTime() + delTime;                /* 'Now' plus delay */

    while ((SystemTime() < lDone) && (_kbhit() == 0));
    while (_kbhit() != 0)
        _getch();
}
/****************************************************************************/

short DisplayVar(short handle,short varNo,TDataKind varKind,unsigned short
                                                                  dataSection)
/* Function to display all information for a file or DS variable
                                                    Return 1 if ok 0 if not */
{
    short    handleNo;
    short    procNo;
    short    errNo;                                   /* for error handling */
    TVarDesc var;                        /*to hold the variable description */
    short    ret;                                       /* for return value */
    char     onebyte;                           /* for INT1 and WRD1 values */
    short    twobyte;                           /* for INT2 and WRD2 values */
    long     fourbyte;                                   /* for INT4 values */
    float    realv;                                       /* for RL4 values */
    double   doubv;                                       /* for RL8 values */
    char     s[256];                                   /* for string values */

    ret = 1;                                      /* return value if all ok */
                            /* use function to look at varaible description */
    GetVarDesc(handle,                                   /* CFS file handle */
               varNo,                                    /* variable number */
               varKind,                                 /* FILEVAR or DSVAR */ 
               &var.vSize,                  /* for return of variables size */
               &var.vType,     /* for return of variable type INT1,WRD1 etc.*/
               var.varUnits,                /* for return of variable units */
               var.varDesc); /* for return of users description of variable */
    if (FileError(&handleNo,&procNo,&errNo)!=0)         /* check for errors */
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        ret = 0;                                  /* return value if not ok */
    }
    else               /* report details and get and display variable value */
    {
        if (varKind==DSVAR)
            printf("\nData Section %u data section ",dataSection);
        else
            printf("\nFile ");               /* start with kind of variable */
        printf("variable %d",varNo);                      /* and its number */
        printf("\nUnits %s",var.varUnits);                  /* report units */
        printf("\nDescription %s",var.varDesc); /* report users description */
     /* space needed for return value depends on type so print type, get value
                                         and print value all in case satement.
             NB errors in GetVarVal are not tested until after value report */

        switch (var.vType)
        {
            case INT1 : printf("\nType INT1");
                        GetVarVal(handle,varNo,varKind,dataSection,&onebyte);
                        printf("\nValue %d\n",(int)onebyte);
                        break;
            case WRD1 : printf("\nType WRD1");
                        GetVarVal(handle,varNo,varKind,dataSection,&onebyte);
                        printf("\nValue %u\n",(int)onebyte);
                        break;
            case INT2 : printf("\nType INT2");
                        GetVarVal(handle,varNo,varKind,dataSection,&twobyte);
                        printf("\nValue %d\n",(int)twobyte);
                        break;
            case WRD2 : printf("\nType WRD2");
                        GetVarVal(handle,varNo,varKind,dataSection,&twobyte);
                        printf("\nValue %u\n",(int)twobyte);
                        break;
            case INT4 : printf("\nType INT4");
                        GetVarVal(handle,varNo,varKind,dataSection,&fourbyte);
                        printf("\nValue %ld\n",fourbyte);
                        break;
            case RL4  : printf("\nType RL4");
                        GetVarVal(handle,varNo,varKind,dataSection,&realv);
                        printf("\nValue %f\n",(double)realv);
                        break;
            case RL8  : printf("\nType RL8");
                        GetVarVal(handle,varNo,varKind,dataSection,&doubv);
                        printf("\nValue %f\n",doubv);
                        break;
            case LSTR : printf("\nType LSTR");
                        GetVarVal(handle,varNo,varKind,dataSection,s);
                        printf("\nValue %s\n",s);
                        break;
            default   : printf("\nUndocumented error\n");
                        ret=0;
                        break;
        };
        if (FileError(&handleNo,&procNo,&errNo)!=0)     /* check for errors */
        {
            printf("\nError %d %d %d",handleNo,procNo,errNo);
            ret = 0;                              /* return value if not ok */
        }
    }
   return ret;
};                                                     /* end of DisplayVar */
       
/****************************************************************************/

short DisplayChan(short handle,short chanNo,unsigned short dataSection)
/* Display channel information from CFS file, specified by its CFS file
   handle for chaneel and data section specified 
   return 1 if ok 0 if not.*/
{
    short     ret;                                      /* for return value */
    short     handleNo,
              procNo,errNo;                           /* for error handling */
    TDesc     chName;                                       /* channel name */
    TUnits    yUnits,xUnits;                               /* channel units */
    short     spacing,other;                  /* channel storage parameters */
    unsigned  short npoints;            /* points parameter for GetChanData */
    TChanTen  chData;    /* union suitable for recieving any 'type' of data */
    TDataType dataType;                 /* channel data type INT1,WRD1 etc. */
    TDataKind dataKind;              /* channel kind, EQUALSPACED or MATRIX */
    unsigned  short i;                                    /* loop parameter */

    ret = 1;                                      /* return value if all ok */
    GetFileChan(handle,                                  /* CFS file handle */
                chanNo,                                   /* channel number */
                chName,                       /* for return of channel name */
                yUnits,xUnits,               /* for return of channel units */
                &dataType,               /* for return of channel data type */
                &dataKind,               /* for return of channel data kind */
                &spacing,             /* for return of channel data spacing */
                &other);               /* for return of matrix channel info */
    if (FileError(&handleNo,&procNo,&errNo)!=0)         /* check for errors */
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        ret = 0;                                  /* return value if not ok */
    }
    else                           /* report constant info for this channel */
        printf("Channel: %3d      %s\n",chanNo,chName);

                              /* ask for the first 40 points of the channel */
        npoints = GetChanData(handle,chanNo,dataSection,        /* as above */
                              0,TotPts,      /* first 40ish points required */
                              &chData,   /* location to which to write data */
                              320);
                                /* size of this variable (chData) 320 bytes */
        if (FileError(&handleNo,&procNo,&errNo)!=0)     /* check for errors */
	    {
            printf("\nError %d %d %d",handleNo,procNo,errNo);
            ret = 0;                              /* return value if not ok */
        }
        for (i = 0;i < npoints; i++)                      /* for each point */

	    {
            switch (dataType)           /* print type in appropriate format */
		    {
                case INT1 : printf("%8d",(int)chData.onebyte[i]);
                     break;
                case WRD1 : printf("%8u",(int)chData.onebyte[i]);
                     break;
                case INT2 : printf("%8d",(int)chData.twobyte[i]);
                     break;
                case WRD2 : printf("%8u",(int)chData.twobyte[i]);
                     break;
                case INT4 : printf("%8ld",chData.fourbyte[i]);
                     break;
                case RL4  : printf("%f8.2",(double)chData.realv[i]);
                     break;
                case RL8  : printf("%8.2f",chData.doubv[i]);
                     break;
                case LSTR : printf("%c",(int)chData.onebyte[i]);
                     break;
                default   : printf("Error?");
                return 0;
            };
        }
    printf("\n");
    return ret;
}

/****************************************************************************/

short DisplayFileInfo(short handle)
                             /*  displays the more general file information */

{
    short     handleNo,
              procNo,
              errNo;                                  /* for error handling */
    char      time[9],
              date[9];                            /* time & date of comment */
    char      comment[72];                               /* comment on file */
    short     ret;

    ret = 1;
            /* Get file parameters giving numbers of channels, file variables,
                                   data section variables and data sections */
    GetGenInfo(handle,time,date,comment);     /* get time and date of creation
                                                                and comment */
    time[8] = '\0';                              /* add a NULL for printing */
    date[8] = '\0';
    if (FileError(&handleNo,&procNo,&errNo)!=0)          /* check for error */
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        return 0;                                          /* fail if error */
    }
    GetFileInfo(handle,&channels,&fileVars,&DSVars,&dataSections);
    if (FileError(&handleNo,&procNo,&errNo)!=0)          /* check for error */
    {
        printf("\nError %d %d %d",handleNo,procNo,errNo);
        return 0;                                          /* fail if error */
    }


    printf("\n                         File information\n");
    printf("\nFile %s created on %s at %s\n",fName,date,time);
    if (comment != NULL)
       printf("comment: %s\n",comment);
    printf("%4d channel(s)\n",channels);
    printf("%4d file variable(s)\n",fileVars);
    printf("%4d data section variable(s)\n",DSVars);
    printf("%4d data section(s)\n",dataSections);
    return ret;

}

/***********************   M A I N   B O D Y    *****************************/

main(void)
{
    printf("\nFile name to read > ");               /* ask for file by name */
    scanf(" %s",fName);                               /* read name supplied */
    handle = OpenCFSFile(fName,   /* attempt to open named file as CFS V2.0 */
                         0,                           /* open for read only */
                         1);          /* store data section table in memory */
    if (handle<0)                       /* if not sucessful report and fail */
    {
        printf("\nError %d File not opened",handle); 
        return 0;
    }
                                         /* Report general file information */
    ret = DisplayFileInfo(handle);  /* identify file by its CFS file handle */
    if (ret == 0)
        return 0;                                          /* fail if error */

    MyDelay(4000);
    for (i = 0;i < fileVars;i ++)
    {
         ret = DisplayVar(handle,i,FILEVAR,0);
         if (ret == 0) 
             return 0;
    }
    MyDelay(4000);
                                                   /* For each data section */
                                    /* Report on each data section variable */
    for (DSLoop = 1;DSLoop <= dataSections;DSLoop ++)
    {
        printf("\nData Section %3d\n",DSLoop);
                                             /* display data section number */
        for (i = 0;i < DSVars;i ++)
        {        
             ret = DisplayVar(handle,i,DSVAR,DSLoop);
             if (ret == 0)
                 return 0;                                 /* fail if error */
        };
       /* Report an all channel info including 1st 40 value of each channel */      
        for (i = 0;i < channels;i ++)
        {     
             ret = DisplayChan(handle,i,DSLoop);
             if (ret == 0)
                 return 0;                                 /* fail if error */
        };
        DSFlags(handle,DSLoop,(short)0,&flagSet);  /* get DS flags if exist */
        for (i = 0;i <= 15 ;i ++)
            if ((flagSet & DSFlagValue(i)) != 0) /* if valid flag, print it */
                printf("\nFlag exists %u \n",(flagSet & DSFlagValue(i)));
        MyDelay(4000);
    };

    ret = CloseCFSFile(handle);       /* Close CFS file and realease handle */
    if (ret != 0)
        printf("\nError. File closing failed\n");
    return 0;
};


