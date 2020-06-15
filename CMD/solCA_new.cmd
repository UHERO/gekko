!Solves County-Allocation model

CLOSE *;
CLEAR WORK; 

ASSIGN VRSN         LITERAL 'SOL';       !version: SOL, HIGH, LOW   (baseline, high, low) (Do not use SOLA. 'A' will be appended later in the program.)
ASSIGN LOAD         LITERAL 'Y';         !Y or N  If Y, solbnk and exogbnk will be cleared.
ASSIGN ADDFAC       LITERAL 'Y';         ! Y or N -- obey addfactors?  
ASSIGN INTERP       LITERAL 'Y';         ! Y or N -- INTERPOLATE INCOME?  

ASSIGN SOL_STRT     LITERAL '2002';
ASSIGN SOL_END      LITERAL '2050';

!************************************************
!No need to change anything from here

ASSIGN MODBNK           LITERAL 'CAMOD';
ASSIGN MODFILE          LITERAL 'CAMOD';

IF ('#VRSN'=='SOL');
  !OPEN <PROTECT YES>  QSOLX, ASOLX, #BLSBNK|, #BEABNK|, CENSUS, USSOL, JPSOL, CAMOD1, CAMOD2 , DUMMY, PROC, US, ASOL, QSOL;
  OPEN <PROTECT YES>  QSOLX, ASOLX, #BLSBNK|, #BEABNK|; !, CENSUS, USSOL, JPSOL, CAMOD1, CAMOD2 , DUMMY, PROC, US, ASOL, QSOL;
  ASSIGN SOLBNK       LITERAL 'CASOL';      !Different bnks for diff scens as it is easier to CLEAR bnk before saving
  ASSIGN SOLBNKQ      LITERAL 'CAQSOL';
END;


SET FREQUENCY A;
SET PERIOD 1970 2050;


!************************************************
! SOLVE COMMAND
!************************************************

if ('#addfac'=='Y');
  !obey  #adddir|ADD_CA|#vrsn|.cmd;
  obey  #adddir|ADD_CA|#vrsn|_new.cmd;
end;

OPEN <PROTEC YES> #MODBNK|;
SET MODEL #MODFILE|;
SOLVE <ANNUAL #SOL_STRT #SOL_END ADJUST YES FEEDBACK NO EXOSAVE YES USEACTUAL YES TYPE=DYNAMIC INTERVAL=INFORM COMMENTARY=ALL CONTINUE NO SOLUTION=|#VRSN|A ADDFACTORS=ADD BASELINE=A>;
CLOSE #MODBNK|;

!************************************************
! TRANSFORMATIONS
!************************************************

INDEX WORK:*.|#VRSN|A  BIGLST2;
FOR MYVAR = #BIGLST2;
tell "#MYVAR|";
    !ASSIGN TYPE     FROM  |#MYVAR|.A  TYPE;
    !IF ('#TYPE' == 'L');
        SERIES  #MYVAR|.|#VRSN|A% = PCH(#MYVAR|.|#VRSN|A);
    !END;
END;

!************************************************
! Interpolation of Income
!************************************************

!IF ('#INTERP'=='Y');
!     Set FREQ Q;
!     OPEN <PROTECT YES> ASOL, QSOL;
!     Interpolate Y@HON.|#VRSN = Y@HON.|#VRSN|A  Linear Average;
!     Interpolate YS@HON.|#VRSN = YS@HON.|#VRSN|A  Linear Average;
!     SERIES Y@NBI.|#VRSN  =  Y@HI.|#VRSN - Y@HON.|#VRSN;
!
!     SERIES Y_R@NBI.|#VRSN  = 100*Y@NBI.|#VRSN/CPI@HON.Q;
!     SERIES Y_R@HON.|#VRSN  = 100*Y@HON.|#VRSN/CPI@HON.Q;
!     SERIES YS_R@HON.|#VRSN  = 100*YS@HON.|#VRSN/CPI@HON.Q;
!
!
!print y@hi.sol-(y@hon.sol+y@nbi.sol),  y_r@hi.sol-(y_r@hon.sol+y_r@nbi.sol);
!print y@hi.sola-(y@hon.sola+y@nbi.sola),  y_r@hi.sola-(y_r@hon.sola+y_r@nbi.sola);
!
! 
!LIST Q_SER = E_NF, Y, Y_R;
!LIST Q_CNTY = MAU, KAU, HAW;
!
!  SET FREQ Q;
!  FOR MYVAR=#Q_SER;
!    FOR CNTY = #Q_CNTY;
!     Interpolate #MYVAR|@|#CNTY|.|#VRSN = #MYVAR|@|#CNTY|.|#VRSN|A  Linear Average;
!    END;
!  END;
!
!  PRINT<2015 2018> PCHYA(E_NF@MAU.SOL), #BLSBNK|:E_NF@MAU.Q%;
!  
!  OPEN <PROTECT YES> #BLSBNK|; 
!  FOR MYVAR=E_NF;
!    FOR CNTY = #Q_CNTY;
!    ASSIGN SER_END FROM #BLSBNK|:#MYVAR|@|#CNTY|.Q PER2;
!     SERIES <#SOL_STRT #SER_END> #MYVAR|@|#CNTY|.|#VRSN = #BLSBNK|:#MYVAR|@|#CNTY|.Q;
!    END;
!  END;
!  PRINT<2015 2018> PCHYA(E_NF@MAU.SOL), #BLSBNK|:E_NF@MAU.Q%;
!    
!     SET FREQ A;
!END;


!************************************************
! LOAD
!************************************************

IF ('#LOAD'=='Y');

    OPEN <PROTECT NO> #SOLBNK;
    CLEAR #SOLBNK;

    COPY WORK:*.|#VRSN|A   AS  #SOLBNK|:*.|#VRSN|A;
    COPY WORK:*.|#VRSN|A%  AS  #SOLBNK|:*.|#VRSN|A%;
    COPY WORK:*.ADD        AS  #SOLBNK|:*.ADD;

    OPEN <PROTECT YES> #SOLBNK;

!    OPEN <PROTECT NO> #SOLBNKQ;
!    CLEAR #SOLBNKQ;
!    COPY WORK:*.|#VRSN  AS  #SOLBNKQ|:*.|#VRSN;
!    OPEN <PROTECT YES> #SOLBNKQ;

END;

!************************************************

SET PER 1995 2007;
TELL "";
TELL "REPORT: VERSION=#VRSN, LOAD=#LOAD, ADDFAC=#ADDFAC";
TELL "REPORT: END OF solCA.CMD";