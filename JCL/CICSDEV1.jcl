//CICSDEV1 JOB (ACCTINFO),'CICS DEV REGION 1',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID,
//             REGION=0M,
//             TIME=1440
//*-------------------------------------------------------------------*
//* JOB NAME  : CICSDEV1                                              *
//* DESCRIPTION: STARTUP JCL FOR CICS DEVELOPMENT REGION 1           *
//*              CALLS COMMON PROC CICS$61 WITH REGION-SPECIFIC       *
//*              SYMBOLIC OVERRIDES.                                   *
//*                                                                    *
//* REGION DETAILS:                                                    *
//*   REGION NAME : CICSDEV1                                          *
//*   PURPOSE     : CICS 6.1 DEVELOPMENT / INTEGRATION ENVIRONMENT    *
//*   VTAM APPLID : CICSDEV1                                          *
//*   SIT MEMBER  : CDEV1SIT  (in SYS1.CICSTS61.CICS.SDFHPARM)      *
//*   CICSPLEX    : DEVPLEX  (XCF GROUP: DEVPLXG1)                    *
//*   LPAR        : ANY (proc CICS$61 is LPAR-independent)            *
//*                                                                    *
//* DATASET QUALIFIERS:                                                *
//*   CICS SYSTEM : CICSTS61.CICS                                     *
//*   REGION DATA : CICS.REGIONS                                      *
//*   APP LOADLIB : APP.DEV.LOADLIB                                   *
//*                                                                    *
//* CHANGE LOG:                                                        *
//*   DATE       AUTHOR        DESCRIPTION                            *
//*   2026-02-19 MIGRATION-TM  INITIAL VERSION FOR CICS TS 6.1        *
//*-------------------------------------------------------------------*
//*
//* JCLLIB ORDER TELLS JES WHERE TO SEARCH FOR PROC CICS$61           *
//*
//             JCLLIB ORDER=(SYS1.CICSTS61.CICS.SDFHPROCL,           +
//             CICS.PROCLIB,SYS1.PROCLIB)
//*-------------------------------------------------------------------*
//* EXECUTE COMMON CICS 6.1 STARTUP PROC WITH CICSDEV1 OVERRIDES      *
//*                                                                    *
//* ALL SYMBOLICS BELOW ARE REGION-SPECIFIC VALUES THAT OVERRIDE THE  *
//* DEFAULTS DEFINED IN PROC CICS$61.                                  *
//*-------------------------------------------------------------------*
//CICSREG  EXEC CICS$61,
//*          -- REGION IDENTIFICATION --
//             RGNNAME=CICSDEV1,         /* Region job/address space  */+
//             APPLID=CICSDEV1,          /* VTAM Application ID       */+
//*          -- SIT MEMBER --
//             SITMBR=CDEV1SIT,          /* SIT member in SDFHPARM    */+
//*          -- DATASET HIGH-LEVEL QUALIFIERS --
//             HLQCICS=CICSTS61.CICS,    /* CICS 6.1 product HLQ      */+
//             HLQREGN=CICS.REGIONS,     /* Region VSAM datasets HLQ  */+
//             HLQAPP=APP.DEV.LOADLIB,   /* Application load library  */+
//*          -- CICSPLEX SM --
//             GRPNAME=DEVPLXG1,         /* XCF coupling group name   */+
//             PLXNAME=DEVPLEX,          /* CICSPlex SM plex name     */+
//*          -- PERFORMANCE / OUTPUT --
//             CICSSTOR=256M,            /* CICS region storage size  */+
//             SYSOUT=A,                 /* SYSOUT class for JES DDs  */+
//             MSGLVL=1                  /* 1=standard message level  */
//*-------------------------------------------------------------------*
//* DFHRPL OVERRIDE - EXTEND APPLICATION LOAD LIBRARY CONCATENATION   *
//*   This override appends region-specific libraries on top of the   *
//*   base DFHRPL defined in CICS$61. List in search-order priority.  *
//*-------------------------------------------------------------------*
//CICSREG.DFHRPL DD  DSN=APP.DEV.LOADLIB.CICSDEV1,DISP=SHR
//               DD  DSN=APP.DEV.LOADLIB.SHARED,DISP=SHR
//               DD  DSN=APP.DEV.LOADLIB,DISP=SHR
//               DD  DSN=CICSTS61.CICS.SDFHLOAD,DISP=SHR
//*-------------------------------------------------------------------*
//* SYSIN OVERRIDE - SIT PARAMETER OVERRIDES FOR CICSDEV1             *
//*   Additional SIT overrides are supplied via dataset CDEVY1SIT.    *
//*-------------------------------------------------------------------*
//CICSREG.SYSIN DD  DSN=CDEVY1SIT,DISP=SHR
//*-------------------------------------------------------------------*
//* END OF CICSDEV1 STARTUP JCL                                       *
//*-------------------------------------------------------------------*
