
!!!!!!!!!!!!!!!!!!!!!!!!!    CANCEL OUT OF AREMOS — CNTRL+SHIFT+C
!
!!!!!!!!!!!!!!!!! INSTRUCTIONS:
! SET ASSUMPTIONS FOR OIL PRICES—THESE WILL AFFECT ROOM RATES
! Set Assumptions for RILGFCY
! SET ASSUMPTIONS FOR ARRIVALS, THEN SHARES BY ISLAND
! LOOK AT LOS
! LOOK AT PPRM
!!!!!!!!!!!!!!!!

ASSIGN nCov20Q1    LITERAL 'Y';   ! with only Chinese visitor loss and jp econ effects, only turn off to do a pre-cov scenario

obey scen_settings.cmd;

ASSIGN COMPSOL LITERAL 'QSOL20Q2base';
SET FREQ Q;  
SET PER 1980:1 2050:4;

! check to see if these are necessary
ASSIGN JOBADJ   LITERAL 'Y';
ASSIGN INCADJ   LITERAL 'N';

ASSIGN CPIFIX   LITERAL 'N';
ASSIGN PICTFIX  LITERAL 'N';
ASSIGN SHOWOCUP LITERAL 'N';

!obey #adddir|tourSA_cludge;

!!!!!************************************* MISC CLUDGE
series tgbct_r@hi.q = tgbct@hi.q*100/pictsgf@hon.q;

SET FREQ A;                    ! apparently these are needed adjust for adding up constraints
Series work:NR@NBI.A = NR@HAW.A+NR@KAU.A+NR@MAU.A; 
Series work:NR@HON.A = NR@HI.A-NR@NBI.A; 
Series work:NR@HON.SOLA = NR@HON.A;
SERIES WORK:NR@NBI.SOLA = NR@NBI.A;

SERIES WORK:VADC@NBI.A = VADC@HI.A-VADC@HON.A;
SET FREQ Q;
SERIES WORK:VADC@NBI.Q = VADC@HI.Q-VADC@HON.Q;

IF ('#JOBADJ'=='Y');
    for jobfor = eaf, e_trade;
        for loc = hi, hon, nbi;
        series<1980 2020Q1>  work:#jobfor|@#loc|.q = #blsBNK|:#jobfor|@#loc|.q;
        end;
    end;
END; ! END if;

!open bls_031920.bnk as old;
!series work:cpi@hon.q = old:cpi@hon.q;
!series work:pchssh@hon.q = old:pchssh@hon.q;
!series work:pcen@hon.q = old:pcen@hon.q;
!series work:pcfbfd@hon.q = old:pcfbfd@hon.q;
!close old;

!******************************************
! ASSUMPTIONS——
!******************************************

Tell '************ ASSUMPTION CODE FOR OIL PRICE SCENARIOS **********';

!!! load history
series WORK:poil@us.|#VRSN| = US:poil@us.q;
assign last_oil from us:poil@us.q per2;

!!! append eia forecast
series <#last_oil|+1 2050:4> work:poil@us.|#VRSN| = MISC:poiladjbns@us.q;
!Now delete values and replace with assumptions
series<2020:1 2050:4> work:poil@us.|#VRSN| = M REPEAT *;
! Q1 (57+ 50 + 32)/3 = 46
! 											20Q1                  
!series<2020:1 2020:4> work:poil@us.|#VRSN| = 49, 41;    ! interim
series<2020:1 2020:4> work:poil@us.|#VRSN| = 46,  25;  ! 3/21/20

!  merge futures prices from  https://www.theice.com/products/213/WTI-Crude-Futures/data 
!  with the STEO short run forecast from https://www.eia.gov/outlooks/steo/data/browser/#/?v=8&f=M&s=0&ctype=linechart&maptype=0

series<2022:4 2022:4> work:poil@us.|#VRSN| = MISC:poiladjbns@us.q - 21;  ! adhoc smoothing
series<2050:4 2050:4> work:poil@us.|#VRSN| = MISC:poiladjbns@us.q -8;  ! adhoc smoothing

SMOOTH WORK:Poil@us.|#VRSN = WORK:Poil@us.|#VRSN linear; 

series work:poil@us.|#VRSN|% = pchya(work:poil@us.|#VRSN|);
!
Tell '************ compare OIL PRICE SCENARIOS to previous vintage **********';

GOTO ENDcompare1;
open #COMPSOL as old;
set per 2015 2025;
 
simgp poil@us.oldsol, WORK:poil@us.|#VRSN|, poiladjbns@us.q, poil@us.q;
print us:poil@us.q, WORK:poil@us.|#VRSN|,  misc:poiladjbns@us.q, poil@us.oldsol, work:poil@us.sol%, pchya(poil@us.oldsol), poileiabQ2ns@us.q;

set calendar collapse average;

close old;

TARGET ENDcompare1;

SET PER 2005 2050;
!SERIES WORK:POIL@US.Q = WORK:POIL@US.|#VRSN|;
!SERIES WORK:POIL@US.Q% = WORK:POIL@US.|#VRSN|%;


Tell '************ ASSUMPTION CODE FOR 10 year Treasury Bond **********';

! Source data
! Futures market https://www.cmegroup.com/trading/interest-rates/us-treasury/10-year-us-treasury-note.html

!  Daily 10-Year Treasury Constant Maturity Rate
!  http://research.stlouisfed.org/fred2/series/DGS10?cid=115
  
!   Survey of Professional Forecasters      
!   http://www.philadelphiafed.org/research-and-data/real-time-center/survey-of-professional-forecasters

!2019Q2   Q3   Q4    20Q1   20Q2
!2.6     2.6  2.7    2.7    2.8

!  2019   2020  2021     2022
!  2.6   2.8    3.1     3.1

!!! load history
set per 1980 2050;
series WORK:rilgfcy10@us.|#VRSN| = US:rilgfcy10@us.q;

!***************************   Pick short-run rates' ; 
!***************************' ;
! Q3   (2.1+1.6+1.8)/3 
series <2020:1 2020:4> rilgfcy10@us.|#VRSN| = 1.3, .8;
series <2021:2 2021:2> rilgfcy10@us.|#VRSN| = 1.5;  
series <2023:2 2023:2> rilgfcy10@us.|#VRSN| = 2.2;  

!***************************   Set LR' ; 
!set freq a;
!set per 2000 2018;
!analyze rilgfcy10@us.a-pchya(cpi@us.a);
! 2.5 is 40 year average real interest rate
! But the real rate has only averaged 1.3% since 2000
!  SPF 10 year cpi inflation rate is 2.2%  as of May 2019 Q2 release

set freq q; 
set per 1980 2050;

series <2025:4 2025:4> rilgfcy10@us.|#VRSN| = 2.4; 
series <2030:4 2030:4> rilgfcy10@us.|#VRSN| = 1.3 + 1.7; 
series <2050:4 2050:4> rilgfcy10@us.|#VRSN| = 1.3 + 1.8; 
!print rilgfcy10@us.sol;

smooth rilgfcy10@us.|#VRSN| = rilgfcy10@us.|#VRSN| linear; 
!print rilgfcy10@us.sol;

! ************* Compare 10 year bond forecast to previous vintage' ;

GOTO ENDcompare2;
open #COMPSOL as old;
set per 2000 2030; 
set calendar collapse average;
!graph<go> using I:\gra\M3L1B_Y5F.gra  US:RILGFCY10@US.Q-pchya(cpi@us.q);      
graph<go> using I:\gra\M3L1B_Y5F.gra  US:RILGFCY10@US.Q, work:RILGFCY10@US.sol, old:RILGFCY10@us.oldsol;      
graph<go> using I:\gra\M3L1B_Y5F.gra  work:RILGFCY10@US.sol - pchya(cpi@us.q);

print US:RILGFCY10@US.Q , work:RILGFCY10@US.SOL, old:RILGFCY10@US.oldSOL, work:RILGFCY10@US.sol - pchya(cpi@us.q);
!pause; 
close old;

TARGET ENDcompare2;


SET FREQ Q;  SET PER 1980:1 2050;

!********************************************************************************
!   PICK SHORT-TERM SOLUTIONS FOR VISITOR ACCOMMODATION AND PERSONS PER ROOM
!********************************************************************************

!*****  @HON  *****
SERIES<1980:1 2019:4> TRMS@HON.|#VRSN| = TRMS@HON.Q;
SERIES<2020:1 2022:4> TRMS@HON.|#VRSN| = TRMS@HON.|#VRSN|[2019:4] repeat *;          

! start Number of Room Change in 2015:3 when TVR_est starts
SERIES<2015:3 2022:4> NRMCHG@HON = 0.0 REPEAT *;

!SERIES<2015:3 2019:4> TVR_EST_HON = 2713.66,  3082.21,  3424.80,  3942.61,  4355.85,  4998.91,  5583.45,  6245.43,  6721.63,  7092.48,  7463.33,  7834.18,  7853.86,  8714.37,  8502.32,  10011.02,  8853.25,  8250.295;

!SERIES<2015:3 2019:4> TVR_EST@HON = TVR_EST_HON/1000;
!SERIES<2015:3 2019:4> NRMCHG@HON = TVR_EST@HON;
SERIES<2015:3 2020:4> NRMCHG@HON = TVRMNS@HON/1000;

PRINT<2015:3 2019:4> TVRMNS@HON/1000, NRMCHG@HON;
!
!SERIES<2019:1 2019:4> NRMCHG@HON = NRMCHG@HON +  .131/4;   ! NEED TO NOT USE LAG TO WORK WITH TVR_EST

SERIES<2020:2 2020:4> NRMCHG@HON = NRMCHG@HON.1 -  8/3;   
SERIES<2021:1 2021:4> NRMCHG@HON = NRMCHG@HON.1 +  .039/4;
SERIES<2022:1 2022:4> NRMCHG@HON = NRMCHG@HON.1 +  .019/4;

SERIES<2015:3 2022:4> TRMS@HON.|#VRSN| = TRMS@HON.|#VRSN| + NRMCHG@HON.Q ;
print<2017:1 2022:4> NRMCHG@HON.Q, TVRMNS@HON/1000, TRMS@HON.SOL, TRMS@HON.Q;

!********* Add factors ***************** 
!SERIES <2020:4 2020:4> TRMS@HON.ADD = 0.01;
!SERIES <2024:1 2024:4> TRMS@HON.ADD = 0.02;
!SERIES <2050:4 2050:4> TRMS@HON.ADD = 0.025;
!SMOOTH TRMS@HON.ADD = TRMS@HON.ADD LINEAR;

IF ('#nCovBase'=='Y' or '#nCovLow'=='Y' or '#nCoVHigh'=='Y');
SERIES <2020:4 2020:4> TRMS@HON.ADD = 0.01;
SERIES <2024:1 2025:4> TRMS@HON.ADD = 0.02;
SERIES <2050:4 2050:4> TRMS@HON.ADD = 0.005;
SMOOTH TRMS@HON.ADD = TRMS@HON.ADD LINEAR;
END;

!**** @MAU  ***** 
SERIES<1980:1 2019:4> TRMS@MAU.|#VRSN| = TRMS@MAU.Q  ;          
SERIES<2020:1 2024:4> TRMS@MAU.|#VRSN| = TRMS@MAU.|#VRSN|[2019:4] repeat *;

! start Number of Room Change in 2015:3 when TVR_est starts
SERIES<2015:3 2024:4> NRMCHG@MAU = 0.0 REPEAT *;

!SERIES<2015:3 2019:4> TVR_EST_MAU = 2449.32,  2781.97,  3091.19,  3558.55,  3931.54,  4511.97,  5039.56,  5637.06,  6066.87,  6401.59,  6736.32,  7071.04,  7875.61,  7651.61,  6767.76,  9009.70,  9839.35,  9667.223;
!SERIES<2015:3 2019:4> TVR_EST@MAU = TVR_EST_MAU/1000;
SERIES<2015:3 2019:4> NRMCHG@MAU = TVRMNS@MAU/1000;
PRINT<2015:3 2019:4> TVRMNS@MAU, NRMCHG@MAU;

SERIES<2019:1 2019:4> NRMCHG@MAU = NRMCHG@MAU + .0/4;  ! NEED TO NOT USE LAG TO WORK WITH TVR_EST
SERIES<2020:1 2020:4> NRMCHG@MAU = NRMCHG@MAU.1 + .186/4 + .6/4;  ! SECOND ADDITION IS FOR TVR GROWTH
SERIES<2021:1 2021:4> NRMCHG@MAU = NRMCHG@MAU.1 + .377/4 + .3/4;  ! SECOND ADDITION IS FOR TVR GROWTH
SERIES<2022:1 2022:4> NRMCHG@MAU = NRMCHG@MAU.1 + .0/4;
SERIES<2023:1 2023:4> NRMCHG@MAU = NRMCHG@MAU.1 + .581/4;
SERIES<2024:1 2024:4> NRMCHG@MAU = NRMCHG@MAU.1 + .299/4;

SERIES<2015:3 2024:4> TRMS@MAU.|#VRSN| = TRMS@MAU.|#VRSN| + NRMCHG@MAU.Q;

Print<2017:1 2024:4> NRMCHG@MAU.Q, TVRMNS@MAU, TRMS@MAU.SOL, DIFF(TRMS@MAU.SOL), DIFF(NRMCHG@MAU);

!********* Add factors *****************
!SERIES <2021:1 2050:4> TRMS@MAU.ADD = .017;
!SERIES <2050:4 2050:4> TRMS@MAU.ADD = .017;
!SMOOTH TRMS@MAU.ADD = TRMS@MAU.ADD LINEAR;

IF ('#nCovBase'=='Y' or '#nCovLow'=='Y' or '#nCoVHigh'=='Y');
SERIES <2021:1 2021:4> TRMS@MAU.ADD = .017;
SERIES <2025:4 2025:4> TRMS@MAU.ADD = .017;
SERIES <2026:1 2026:1> TRMS@MAU.ADD = 0.0;
SERIES <2040:4 2040:4> TRMS@MAU.ADD = 0.01;
SERIES <2050:4 2050:4> TRMS@MAU.ADD = 0.01;
SMOOTH TRMS@MAU.ADD = TRMS@MAU.ADD LINEAR;
END;


!**** @HAWAII  *****
SERIES<1980:1 2019:4> TRMS@HAW.|#VRSN| = TRMS@HAW.Q  ;          
SERIES<2020:1 2022:4> TRMS@HAW.|#VRSN| = TRMS@HAW.|#VRSN|[2019:4] repeat *;

! start Number of Room Change in 2015:3 when TVR_est starts
SERIES<2015:3 2022:4> NRMCHG@HAW = 0.0 REPEAT *;

!SERIES<2015:3 2019:4> TVR_EST_HAW = 1823.76,  2071.44,  2301.69,  2649.68,  2927.41,  3359.59,  3752.44,  4197.33,  4517.37,  4766.60,  5015.84,  5265.07,  5780.62,  6115.13,  5366.57,  6368.53,  6754.31,  7001.344;
!SERIES<2015:3 2019:4> TVR_EST@HAW = TVR_EST_HAW/1000;
SERIES<2015:3 2019:4> NRMCHG@HAW = TVRMNS@HAW/1000;
PRINT<2015:3 2019:4> TVRMNS@HAW, NRMCHG@HAW;

SERIES<2019:1 2019:4> NRMCHG@HAW = NRMCHG@HAW + .0/4;   ! NEED TO NOT USE LAG TO WORK WITH TVR_EST
SERIES<2020:1 2020:4> NRMCHG@HAW = NRMCHG@HAW.1 + .249/4;   
SERIES<2021:1 2021:4> NRMCHG@HAW = NRMCHG@HAW.1 - .072/4;   
SERIES<2022:1 2022:4> NRMCHG@HAW = NRMCHG@HAW.1 + .365/4;   

SERIES<2015:3 2022:4> TRMS@HAW.|#VRSN| = TRMS@HAW.|#VRSN| + NRMCHG@HAW;
Print<2017:1 2022:4> NRMCHG@HAW.Q, TVRMNS@HAW, TRMS@HAW.SOL;

!********* add factors *****************
!SERIES <2016:1 2050:4> TRMS@HAW.ADD = .00 REPEAT 4 ;
!SERIES <2020:1 2020:4> TRMS@HAW.ADD = 0.005;
!SERIES <2050:4 2050:4> TRMS@HAW.ADD = 0.003;
!SMOOTH TRMS@HAW.ADD = TRMS@HAW.ADD LINEAR;
!simgp trms@haw.add;

IF ('#nCovBase'=='Y' or '#nCovLow'=='Y' or '#nCoVHigh'=='Y');
SERIES <2016:1 2050:4> TRMS@HAW.ADD = .00 REPEAT 4 ;
SERIES <2020:1 2020:4> TRMS@HAW.ADD = 0.005;
SERIES <2025:4 2025:4> TRMS@HAW.ADD = 0.0045;
SERIES <2026:1 2026:1> TRMS@HAW.ADD = -0.001;
SERIES <2050:4 2050:4> TRMS@HAW.ADD = 0.00;
SMOOTH TRMS@HAW.ADD = TRMS@HAW.ADD LINEAR;
END;


!************* updated all room stock assumptions except Kauai
SERIES<1980:1 2019:4> TRMS@KAU.|#VRSN| = TRMS@KAU.Q  ;          
SERIES<2020:1 2020:4> TRMS@KAU.|#VRSN| = TRMS@KAU.|#VRSN|[2019:4] repeat *;

! start Number of Room Change in 2015:3 when TVR_est starts
SERIES<2015:3 2020:4> NRMCHG@KAU = 0.0 REPEAT *;

!SERIES<2015:3 2019:4> TVR_EST_KAU =  1062.36,  1206.64,  1340.75,  1543.47,  1705.25,  1957.00,  2185.83,  2444.99,  2631.41,  2776.59,  2921.77,  3066.96,  3163.59,  3449.18,  3190.64,  3842.51,  4297.17,  4254.648;
!SERIES<2015:3 2019:4> TVR_EST@KAU = TVR_EST_KAU/1000;
SERIES<2015:3 2019:4> NRMCHG@KAU = TVRMNS@KAU/1000;
PRINT<2015:3 2019:4> TVRMNS@KAU, NRMCHG@KAU;

SERIES<2019:4 2019:4> NRMCHG@KAU = NRMCHG@KAU + .200; ! Coco Lagoon ! NEED TO NOT USE LAG TO WORK WITH TVR_EST
SERIES<2020:1 2020:4> NRMCHG@KAU = NRMCHG@KAU.1 + .150/4; ! Coco Lagoon

SERIES<2015:3 2020:4> TRMS@KAU.|#VRSN| = TRMS@KAU.|#VRSN| + NRMCHG@KAU.Q ;
Print<2017:1 2022:4> NRMCHG@KAU.Q, TVRMNS@KAU, TRMS@KAU.SOL;

!set report decimal 3; set calendar collapse total; PRINT TRMS@kau.SOL, DIFF(4,TRMS@kau.SOL), NRMCHG@kau;
!********* ROOMS *****************
!SERIES<2050:4 2050:4> TRMS@KAU.|#VRSN| = 10.65+4.5 REPEAT *;
!SMOOTH TRMS@KAU.|#VRSN| = TRMS@KAU.|#VRSN| LINEAR;

IF ('#nCovBase'=='Y' or '#nCovLow'=='Y' or '#nCovHigh'=='Y');
!********* ROOMS *****************
SERIES<2025:4 2025:4> TRMS@KAU.|#VRSN| = 13.875;
SERIES<2050:4 2050:4> TRMS@KAU.|#VRSN| = 13.99 REPEAT *;
SMOOTH TRMS@KAU.|#VRSN| = TRMS@KAU.|#VRSN| LINEAR;
END;


SERIES<1980:1 2018:4> TRMS@HI.|#VRSN| = TRMS@HON.sol + trms@mau.sol + trms@kau.sol + trms@haw.sol  ;          

!** PERSONS PER ROOM: for periods that we have data on occupancy rates beyond our room stock history
!INSTRUCTION: solve the model with all short-term TRMS solutions (above) but without any add factor for PPRM (below), 
!then execute in the command line
! forc_newpprm.cmd 

!  TRUNCATE HISTORY TO ALLOW FOR TRMS_EST SAMPLE
for cnty = HI, HON,HAW,MAU,KAU;
!  series<1980:1 2017:4> PPRM@#cnty|.#vrsn| = PPRM@#cnty|.Q;
  series<1980:1 2015:2> PPRM@#cnty|.#vrsn| = PPRM@#cnty|.Q;
  series<1980:1 2015:2> OCUP%@#cnty|.#vrsn| = OCUP%@#cnty|.Q;
end;

!series<2015:3 2019:4> TVR_EST_HI = TVR_EST_Hon + TVR_EST_HAW + TVR_EST_MAU + TVR_EST_KAU;  
series<2015:3 2019:4> TVRMNS@HI = TVRMNS@Hon + TVRMNS@HAW + TVRMNS@MAU + TVRMNS@KAU;  

series<2015:3 2019:4> OCUP_diff@HI.q = -6*(TVRMNS@HI/1000/TRMS@HI.Q);
series<2019:1 2019:4> OCUP_DIFF@HI.Q = OCUP_DIFF@HI.Q[-1];

series<2015:3 2019:4> OCUP_diff@HON.q = -9.5*(TVRMNS@HON/1000/TRMS@HON.Q);
series<2019:1 2019:4> OCUP_DIFF@HON.Q = OCUP_DIFF@HON.Q[-1];

series<2015:3 2019:4> OCUP_diff@HAW.q = -5.5*(TVRMNS@HAW/1000/TRMS@HAW.Q);
series<2019:1 2019:4> OCUP_DIFF@HAW.Q = OCUP_DIFF@HAW.Q[-1];

series<2015:3 2019:4> OCUP_diff@MAU.q = (TVRMNS@MAU/1000/TRMS@MAU.Q);
series<2019:1 2019:4> OCUP_DIFF@MAU.Q = OCUP_DIFF@MAU.Q[-1];

series<2015:3 2019:4> OCUP_diff@KAU.q = 3*(TVRMNS@KAU/1000/TRMS@KAU.Q);
series<2019:1 2019:4> OCUP_DIFF@KAU.Q = OCUP_DIFF@KAU.Q[-1];

series<2015:3 2019:4> OCUP%@HI.#vrsn = OCUP%@HI.Q + OCUP_DIFF@HI.Q;
series<2015:3 2019:4> OCUP%@HON.#vrsn = OCUP%@HON.Q + OCUP_DIFF@HON.Q;
series<2015:3 2019:4> OCUP%@HAW.#vrsn = OCUP%@HAW.Q + OCUP_DIFF@HAW.Q;
series<2015:3 2019:4> OCUP%@MAU.#vrsn = OCUP%@MAU.Q + OCUP_DIFF@MAU.Q;
series<2015:3 2019:4> OCUP%@KAU.#vrsn = OCUP%@KAU.Q + OCUP_DIFF@KAU.Q;



print <2015:3 2019:4> 6*(TVRMNS@HI/1000/TRMS@HI.Q), ocup%@hi.sol-ocup%@hi.q, TRMS@HI.sol, trms@hi.q;
print <2015:3 2019:4> 9.5*(TVRMNS@hon/1000/TRMS@hon.Q), ocup%@hon.sol-ocup%@hon.q, TRMS@hon.sol, trms@hon.q;

print <2015:3 2019:4> 5.5*(TVRMNS@haw/1000/TRMS@haw.Q), ocup%@haw.sol-ocup%@haw.q, TRMS@haw.sol, trms@haw.q;

!********* PERSONS PER ROOM *******

! Oahu target is 1.7-2.3 below official
! PPRM up,  OCUP down.  Pull PPRM down, OCUP goes Up.
!HON                                           2016             17             
SERIES <2015:4 2017:4>  PPRM@HON.ADD =  -.2,  -.05 repeat 4,  -.065 repeat 4;
SERIES <2018:1 2050:4>  PPRM@HON.ADD =  .0085 repeat 4, 0 repeat 4, -0.007;
SERIES <2050:4 2050:4>  PPRM@HON.ADD =  -0.007 ;
SMOOTH PPRM@HON.ADD     = PPRM@HON.ADD LINEAR;

! PPRM up,  OCUP down.  Pull PPRM down, OCUP goes Up.
! @haw should average about 3ppt lower than official stat—  thats 36% * Average diff of 9%.
!HAW                                                  2016             17              18
SERIES <2015:3 2050:4>  PPRM@HAW.ADD =  -.22, -.22,  -.19 repeat 4,   -.25 repeat 4, -.33 repeat 4;
!										19                        20  
SERIES <2019:1 2050:4>  PPRM@HAW.ADD =  -.25, -.69, -.31, -.45,   -.3, -.3, -.4;
SERIES <2022:1 2050:4>  PPRM@HAW.ADD =  -0.42;
SERIES <2025:1 2050:4>  PPRM@HAW.ADD =  -0.445;
SERIES <2035:1 2050:4>  PPRM@HAW.ADD =  -0.558;
SERIES <2040:1 2050:4>  PPRM@HAW.ADD =  -0.62;
SERIES <2050:4 2050:4>  PPRM@HAW.ADD =  -.765;
SMOOTH PPRM@HAW.ADD     = PPRM@HAW.ADD LINEAR;

!SERIES <2018:4 2050:4> PPRM@HAW.ADD =  .0;
!SERIES <2050:4 2050:4> PPRM@HAW.ADD = -0.52;
!SMOOTH PPRM@HAW.ADD = PPRM@HAW.ADD LINEAR;

! Not clear that Mau occupancy rate should be any different from the official stats at least within +-1%
!MAU                                            2016             17             18             
SERIES <2015:3 2050:4>  PPRM@MAU.ADD =  -.25,  -.05 repeat 4,  -.075 repeat 4, -.04 repeat 4;
!MAU										19               20
SERIES <2019:1 2050:4>  PPRM@MAU.ADD =     .02, -.3, -.15, -.15, -.07 repeat 4, -.06;
SERIES <2050:4 2050:4>  PPRM@MAU.ADD =  -0.06;
SMOOTH PPRM@MAU.ADD     = PPRM@MAU.ADD LINEAR;


! PPRM up,  OCUP down.  Pull PPRM down, OCUP goes Up.
! @KAU should average about 1.3ppt lower than official stat—  thats 28% * Average diff of 4.4%.
!KAU                                      15         16               17              18             19
SERIES <2015:3 2050:4>  PPRM@KAU.ADD =  -.19, -.19, -.025 repeat 4,  -.122 repeat 4;
!KAU                                      18                  19
SERIES <2018:1 2050:4>  PPRM@KAU.ADD =  .05, -.07 repeat 3,  .13, -.27, -.15, -.15,  -.08 repeat 4, -.06; 
SERIES <2050:4 2050:4>  PPRM@KAU.ADD =  -.06;
SMOOTH PPRM@KAU.ADD     = PPRM@KAU.ADD LINEAR;

!SERIES <2018:1 2050:4> PPRM@KAU.ADD = .085 repeat 4, .08 repeat 4;
!SERIES <2050:4 2050:4> PPRM@KAU.ADD =  0.065;
!SMOOTH PPRM@KAU.ADD = PPRM@KAU.ADD LINEAR;
!


!********************************************************************************
!                     VISITORS ARRIVALS (BY CRUISE AND BY AIR)
!********************************************************************************
!!----> international cruise ship law-- they must stay in foreign port for 2 days and spend 1/2 of total cruise   so intl cruise industry will end. 
!!!Decision at end of this month
!!  Feb 4---The 2,400-passenger Pride of Hawaii, with a crew of 1,000 began service in HI in June, 2006.
!! 2400 passengers or aprox: 2400x4x12 = 115,000 passengers per year  =  1.3% of total visitors
!! monthly loss of approx 8000 passengers
!!  MAY 11, 2008--- loose pride of Aloha  with roughly the same size crew and passcount.
!!  total loss aprox 16000 per month or around 50K per qtr or near 200K per year


SERIES <2012:4 2013:4> VISCRAIR@HI.ADD =   -8;
SERIES <2014:4 2014:4> VISCRAIR@HI.ADD =   -7.5;
SERIES <2015:4 2015:4> VISCRAIR@HI.ADD =   -7;
SERIES <2020:4 2020:4> VISCRAIR@HI.ADD =   -7;
SERIES <2050:4 2050:4> VISCRAIR@HI.ADD =   -7;
SMOOTH VISCRAIR@HI.ADD = VISCRAIR@HI.ADD LINEAR;

SERIES<1990:4 2050:4>  VLOSCRAIR@HI.Q = TOUR:VLOSCRAIR@HI;  !!! need to respecify, pop 12/07
SERIES<2050:4 2050:4>  VLOSCRAIR@HI.Q = 1.05*TOUR:VLOSCRAIR@HI[2007:4];
SMOOTH VLOSCRAIR@HI.Q = VLOSCRAIR@HI.Q LINEAR;

!                       
!**************** U.S. --- 2020Q1 pre covid19                 
!                                       2020             21
SERIES <2020:1 2050:4> VISUS@HI.ADD =   85, 55, 69, 45,  80, 70, 60,  60;
SERIES <2025:4 2025:4> VISUS@HI.ADD =   60;
SERIES <2030:4 2030:4> VISUS@HI.ADD =   55;
SERIES <2050:4 2050:4> VISUS@HI.ADD =   45;
SMOOTH VISUS@HI.ADD = VISUS@HI.ADD LINEAR;

!*************** JAPAN                20Q1            21Q1
!
SERIES <2020:1 2050:4> VISJP@HI.ADD = 45, 56, 42, 54, 52, 53, 54; 
SERIES <2025:4 2025:4> VISJP@HI.ADD = 56;
SERIES <2032:4 2032:4> VISJP@HI.ADD = 56; 
SERIES <2050:4 2050:4> VISJP@HI.ADD = 58   ;
SMOOTH VISJP@HI.ADD = VISJP@HI.ADD LINEAR;

!**************** NON US NON JP VISITOR 2010
!                                       2020
SERIES <2020:1 2050:4> VISRES@HI.ADD =  -10, 9, 6;
SERIES <2050:4 2050:4> VISRES@HI.ADD = 6 ;
SMOOTH VISRES@HI.ADD = VISRES@HI.ADD LINEAR;

IF ('#nCov20Q1'=='N');
     close jpsol;
     open jpsol_pre_nCoV;
End; ! end if nCov20Q1=N
IF ('#nCov20Q1'=='Y');
! assume no chinese visitors Feb-May = 8K per month, slow recover for Q3-2021Q3. 
SERIES <2020:1 2050:4> VISRES2@HI.COR =  -14, -12, 12, 9,   1.5, 0, 0; 
SERIES <2020:1 2050:4> VISRES@HI.ADD =  VISRES@HI.ADD + VISRES2@HI.COR;
END;  ! end if nCov20Q1 = Y


IF ('#nCovBase'=='Y');     ! BASELINE
!   									2020                   21                     22              23             24
SERIES <2020:1 2050:4> visus@HI.pan =  -350, -1510, 460, 540,  195,  -550, 110, 85,   45, 25, 15, 10, -10 REPEAT 4, -25 REPEAT 4, -20 REPEAT 4; 
SERIES <2050:4 2050:4> VISUS@HI.PAN = -5;
SMOOTH VISUS@HI.PAN = VISUS@HI.PAN LINEAR;
SERIES <2020:1 2050:4> visus@HI.ADD =  visus@HI.ADD + visus@HI.pan;
!   									2020                  21                  22                 23             24            25
SERIES <2020:1 2050:4> VISJP@HI.pan =  -95, -345, -30, 0,     80, -25, 75, 30,  -25, -30, -35, -35, -35 repeat 4,  -35 repeat 4, -30 REPEAT 4, -20 repeat 4, -15; 
SERIES <2050:4 2050:4> VISJP@HI.PAN = -5;
SMOOTH VISJP@HI.PAN = VISJP@HI.PAN LINEAR;
SERIES <2020:1 2050:4> VISJP@HI.ADD =  VISJP@HI.ADD + VISJP@HI.pan;
!   									2020                  21                22            23         24      
SERIES <2020:1 2050:4> VISRES@HI.pan = -48, -350, 50,  120,   55, 25, 15, 10,   -5 repeat 4, -2 repeat 4, 0 repeat 4, 2 REPEAT 4; 
SERIES <2050:4 2050:4> VISRES@HI.PAN = 5;
SMOOTH VISRES@HI.PAN = VISRES@HI.PAN LINEAR;
SERIES <2020:1 2050:4> VISRES@HI.ADD =  VISRES@HI.ADD + VISRES@HI.pan;
END; ! end if nCovBase = Y

IF ('#nCovHigh'=='Y');     ! HIGH--- Q3 42%,  Q4 72%
!   									2020                    21                     22              23            24            25
SERIES <2020:1 2050:4> visus@HI.pan =  -350, -1510, 770, 840,   180,  -700, 155, 80,   40, 30, 15, 5, -15 REPEAT 4, -20 REPEAT 4, -20 REPEAT 4, -15; 
SERIES <2050:4 2050:4> VISUS@HI.PAN =  0;
SMOOTH VISUS@HI.PAN = VISUS@HI.PAN LINEAR;
SERIES <2020:1 2050:4> visus@HI.ADD =  visus@HI.ADD + visus@HI.pan;
!   									2020                    21                     22                   23              24
SERIES <2020:1 2050:4> VISJP@HI.pan =  -95, -345,  40,   0,     110,  -60, 110, 15,    -25, -25, -30, -30,  -30 repeat 4,  -30 repeat 4, -20 REPEAT 4, -15; 
SERIES <2050:4 2050:4> VISJP@HI.PAN = 10;
SMOOTH VISJP@HI.PAN = VISJP@HI.PAN LINEAR;
SERIES <2020:1 2050:4> VISJP@HI.ADD =  VISJP@HI.ADD + VISJP@HI.pan;
!   									2020                    21                22          23          24
SERIES <2020:1 2050:4> VISRES@HI.pan = -48, -380, 110,  190,    45, 30, 20, 10,   2 repeat 4, 2 repeat 4, 0 REPEAT 4; 
SERIES <2050:4 2050:4> VISRES@HI.PAN = 8;
SMOOTH VISRES@HI.PAN = VISRES@HI.PAN LINEAR;
SERIES <2020:1 2050:4> VISRES@HI.ADD =  VISRES@HI.ADD + VISRES@HI.pan;
END; ! end if nCovHigh = Y

IF ('#nCovLOW'=='Y');      ! LOW SCENARIO
!   									2020        Q3   Q4    21                     22                23            24           25
SERIES <2020:1 2050:4> visus@HI.pan =  -350, -1510, -10, 460,  265,  -310, -30, 70,   25, 15, 10, 0,   -25 REPEAT 4, -35 REPEAT 4, -30 REPEAT 4; 
SERIES <2050:4 2050:4> VISUS@HI.PAN = -10;
SMOOTH VISUS@HI.PAN = VISUS@HI.PAN LINEAR;
SERIES <2020:1 2050:4> visus@HI.ADD =  visus@HI.ADD + visus@HI.pan;

!   									2020        Q3    Q4     21                    22                  23             24  
SERIES <2020:1 2050:4> VISJP@HI.pan =  -95, -335,  -90,  -45,    40,  15, 40,  35,    -25, -30, -40, -45,  -45 repeat 4,  -40 repeat 4, -35 repeat 4, -30; 
SERIES <2050:4 2050:4> VISJP@HI.PAN = -5;
SMOOTH VISJP@HI.PAN = VISJP@HI.PAN LINEAR;
SERIES <2020:1 2050:4> VISJP@HI.ADD =  VISJP@HI.ADD + VISJP@HI.pan;

!   									2020       Q3   Q4     21                     22         23            24
SERIES <2020:1 2050:4> VISRES@HI.pan = -48, -375,  -35, 60,   95, 40, 30, 10,       -8 repeat 4, -6 repeat 4, -5 repeat 4, 0 repeat 4; 
SERIES <2050:4 2050:4> VISRES@HI.PAN = 0;
SMOOTH VISRES@HI.PAN = VISRES@HI.PAN LINEAR;
SERIES <2020:1 2050:4> VISRES@HI.ADD =  VISRES@HI.ADD + VISRES@HI.pan;
END; ! end if nCovLOW = Y

!********************************************************************************
!                      ROOM PRICE
!********************************************************************************
! Coronoa SERIES <2020:1 2050:4> PRM@HI.ADD =  3, 2, 1, 0;
SERIES <2020:1 2050:4> PRM@HI.ADD =  -2, -1.8, -1.6, -1.1;
SERIES <2023:1 2023:1> PRM@HI.ADD = -.6;
SERIES <2030:1 2030:1> PRM@HI.ADD = -.6;
SERIES <2050:4 2050:4> PRM@HI.ADD = 0;
SMOOTH PRM@HI.ADD = PRM@HI.ADD linear;

SERIES <2019:4 2050:4> PRM@HON.ADD =  -.5, -1;
SERIES <2030:1 2030:1> PRM@HON.ADD = -1;
SERIES <2050:4 2050:4> PRM@HON.ADD = -1;
SMOOTH PRM@HON.ADD = PRM@HON.ADD linear;
!                                      2020:1                     
SERIES <2020:1 2050:4> VEXP@HI.ADD =   190 repeat 4, 175 repeat 4, 190 repeat 4, 210;
SERIES <2050:4 2050:4> VEXP@HI.ADD = 600;
SMOOTH VEXP@HI.ADD = VEXP@HI.ADD linear;

IF ('#nCovBase'=='Y');       !BASE  
open qsol20Q1_I2 as old;
series work:prm@hi.sol = old:prm@hi.oldsol;
close old;
!    	 							 2020                      21                       22              23           24
SERIES <2020:1 2050:4> vexp@HI.pan =  0, -155, -1000, -1350,  -850, -350, -100, -100,  -100 repeat 4,  -70 repeat 4, -30 repeat 4, 0 repeat 4, 10 repeat 4, 15 repeat *; 
SERIES <2020:1 2050:4> vexp@HI.ADD =  vexp@HI.ADD + vexp@HI.pan;
END; ! end if nCovBase = Y

IF ('#nCovHigh'=='Y');       !High  
open qsol20Q1_I2 as old;
series work:prm@hi.sol = old:prm@hi.oldsol;
close old;
!    	 							 2020                      21                       22
SERIES <2020:1 2050:4> vexp@HI.pan =  0, -155, -1200, -1450,  -950, -250, -100, -100,  -90 repeat 4,  -60 repeat 4, -30 repeat *; 
SERIES <2020:1 2050:4> vexp@HI.ADD =  vexp@HI.ADD + vexp@HI.pan;
END; ! end if nCovHigh = Y

IF ('#nCovLOW'=='Y');         ! LOW
open qsol20Q1_I2 as old;
series work:prm@hi.sol = old:prm@hi.oldsol;
close old;
!    	 							 2020                    21                       22
SERIES <2020:1 2050:4> vexp@HI.pan =  0, -155, -450, -850,  -1950, -350, -250, -250,  -200 repeat 4,  -100 repeat 4, -100 repeat *; 
SERIES <2020:1 2050:4> vexp@HI.ADD =  vexp@HI.ADD + vexp@HI.pan;
END; ! end if nCovLOW = Y


!********* US SHARES ***************
!HON 			                       20Q1
SERIES <2020:1 2050:4> SH_US@HON.ADD = -.001, -.001, -.001, -0.0005, 0.0004 ;
SERIES <2050:4 2050:4> SH_US@HON.ADD = 0.0005;
SMOOTH SH_US@HON.ADD = SH_US@HON.ADD LINEAR;


!MAU                                    2020
SERIES <2020:1 2050:4> SH_US@MAU.ADD = -.001, .007, .00, .00, -.0005, -.00002 repeat *;

!
!HAW                                    2020Q1                   2021       
SERIES <2020:1 2050:4> SH_US@HAW.ADD =  -.0055, .007, -.001, -.001, -.001, .0001;
SERIES <2025:4 2025:4> SH_US@HAW.ADD =  0.0001;
SERIES <2040:4 2050:4> SH_US@HAW.ADD =  0.00004;
SERIES <2050:4 2050:4> SH_US@HAW.ADD =  0.0001;
SMOOTH SH_US@HAW.ADD = SH_US@HAW.ADD LINEAR;


! KAU                                    2020                           2021                           
SERIES <2020:1 2050:4> SH_US@KAU.ADD =  -.0105, -.0095, -.0095, -.0096, -.0097, -.0098, -.0097, -.0096, -.0094  repeat *; 

!********* JP SHARES ***************
!HON                                    20
SERIES <2020:1 2050:4> SH_JP@HON.ADD = .005, .005, .00, .00;
SERIES <2050:4 2050:4> SH_JP@HON.ADD = .00;
SMOOTH SH_JP@HON.ADD = SH_JP@HON.ADD linear;


!MAU                                    19
SERIES <2019:1 2050:4> SH_JP@MAU.ADD =   .0008, -.0008, -.0009, -.001;
SERIES <2050:4 2050:4> SH_JP@MAU.ADD = -0.0007;
SMOOTH SH_JP@MAU.ADD = SH_JP@MAU.ADD linear;
!  75% increase in JP lift for year
!  146% increase in lift in Q1
!  State lift increases from Q1 to Q4: -1.3	1.7	1.5	6.0
!  M1 arrivals only increased 7.5%
!HAW                                     2020
SERIES <2020:1 2050:4> SH_JP@HAW.ADD =  -.035, -.035, -.035 repeat 4 ;
SERIES <2030:4 2030:4> SH_JP@HAW.ADD =  -.026;
SERIES <2050:4 2050:4> SH_JP@HAW.ADD =  -.005;
SMOOTH SH_JP@HAW.ADD = SH_JP@HAW.ADD LINEAR;

!KAU                                      2020
SERIES <2020:1 2050:4> SH_JP@KAU.ADD =  -.0027,  -.0026, -.0028, -.0027, -.0026;
SERIES <2050:4 2050:4> SH_JP@KAU.ADD = -0.0015;
SMOOTH SH_JP@KAU.ADD = SH_JP@KAU.ADD LINEAR;


!********* RES SHARES ***************
!HON                                    
SERIES <2019:1 2050:4> SH_RES@HON.ADD = 0.01, -.001 repeat 4, .00;
SERIES <2050:4 2050:4> SH_RES@HON.ADD = -0.08;
SMOOTH SH_RES@HON.ADD = SH_RES@HON.ADD LINEAR;

!MAU
SERIES <2020:1 2050:4> SH_RES@MAU.ADD =  -.011 repeat 4, -.01  repeat *;

!HAW
SERIES <2019:4 2050:4> SH_RES@HAW.ADD =  .001, .001;
SERIES <2050:4 2050:4> SH_RES@HAW.ADD =  0.000;
SMOOTH SH_RES@HAW.ADD = SH_RES@HAW.ADD LINEAR;

!KAU                                      20Q1             
SERIES <2020:1 2050:4> SH_RES@KAU.ADD =  -0.01, -0.011, -.012;
SERIES <2050:4 2050:4> SH_RES@KAU.ADD =  -.01 REPEAT *;
SMOOTH SH_RES@KAU.ADD = SH_RES@KAU.ADD LINEAR;


!********* LENGTH OF STAY *******

IF ('#nCovBase'=='Y');      !  BASELINE 
! HON	 							     2020               21             22
SERIES <2020:1 2050:4> VLOSUS@HON.ADD =  -.05, 19, 0, -3,  -7, -3, 1, 1,   .7, .1, 0, -.03;
SERIES <2050:1 2050:4> VLOSUS@HON.ADD =  -.02 repeat *;
SMOOTH VLOSUS@HON.ADD = VLOSUS@HON.ADD LINEAR;

!                                        18Q3           
SERIES <2018:4 2050:4> VLOSJP@HON.ADD = .35, .35, .3;
SERIES <2020:4 2020:4> VLOSJP@HON.ADD = 0.3;
SERIES <2023:4 2023:4> VLOSJP@HON.ADD = 0.29;
SERIES <2050:4 2050:4> VLOSJP@HON.ADD = 0.28 ;
SMOOTH VLOSJP@HON.ADD = VLOSJP@HON.ADD LINEAR;

SERIES <2018:4 2019:4> VLOSRES@HON.ADD = -0.3 ;
SERIES <2050:4 2050:4> VLOSRES@HON.ADD = -0.3 ;
SMOOTH VLOSRES@HON.ADD = VLOSRES@HON.ADD LINEAR;

!********* MAU LENGTH OF STAY *******
!                                       2020              2021
SERIES <2020:1 2050:4> VLOSUS@MAU.ADD = .36, 10, 8, 0,   -3, -7, -4, -3, -.46, .44;
SERIES <2023:4 2023:4> VLOSUS@MAU.ADD =  .44;
SERIES <2025:4 2025:4> VLOSUS@MAU.ADD =  .44;
SERIES <2050:1 2050:4> VLOSUS@MAU.ADD =  0.4 REPEAT *;
SMOOTH VLOSUS@MAU.ADD = VLOSUS@MAU.ADD LINEAR;

SERIES <2019:1 2050:4> VLOSJP@MAU.ADD = .11 repeat 4 ;
SERIES <2050:4 2050:4> VLOSJP@MAU.ADD =  0.08 ;
SMOOTH VLOSJP@MAU.ADD = VLOSJP@MAU.ADD LINEAR;

SERIES <2018:1 2050:4> VLOSRES@MAU.ADD =  .1;
SERIES <2050:4 2050:4> VLOSRES@MAU.ADD =  0.1;
SMOOTH VLOSRES@MAU.ADD = VLOSRES@MAU.ADD LINEAR;

!********* HAW LENGTH OF STAY *******
!                                       2020              2021
SERIES <2020:1 2050:4> VLOSUS@HAW.ADD = .9, 11, 8, 2,    -4, -4, -2, 0,   .85;
SERIES <2022:1 2050:4> VLOSUS@HAW.ADD = .85 repeat *;
SMOOTH VLOSUS@HAW.ADD = VLOSUS@HAW.ADD LINEAR;

SERIES <2020:1 2050:4> VLOSJP@HAW.ADD =  .35, .33, .3 REPEAT  *;

SERIES <2019:3 2050:4> VLOSRES@HAW.ADD =  -.3;
SERIES <2050:4 2050:4> VLOSRES@HAW.ADD =  .1 ;
SMOOTH VLOSRES@HAW.ADD = VLOSRES@HAW.ADD LINEAR;

!********* KAU LENGTH OF STAY *******
! 										20Q1   	        2021               22
SERIES <2020:1 2050:4> VLOSUS@KAU.ADD = .48, 9, 8, -3,   -9, -7, -3, -1.5, .5, 2, 1.5, 1, 0.46, .44;
SERIES <2050:4 2050:4> VLOSUS@kau.ADD = 0.4;
SMOOTH VLOSUS@KAU.ADD = VLOSUS@KAU.ADD LINEAR;

!KAU
SERIES <2018:1 2050:4> VLOSJP@KAU.ADD =  .18, .16 repeat *;

SERIES <2019:4 2050:4> VLOSRES@KAU.ADD = -.03 repeat *;

END; ! end if nCovBase = Y


!goto skiplos;
!IF ('#nCovBase'=='Y' or '#nCovLow'=='Y' or '#nCoVHigh'=='Y');
!!simgp visus@hi.q;
!open QSOL20Q1.BNK as old;
!SERIES <1990:1 2050:4> VLOSUS@HON.sol =  old:vlosus@hon.oldsol;
!SERIES <1990:1 2050:4> VLOSJP@HON.sol =  old:vlosJP@hon.oldsol;
!SERIES <1990:1 2050:4> VLOSRES@HON.sol =  old:vlosRES@hon.oldsol;
!!simgp  old:vlosus@hon.oldsol, work:vlosus@hon.sol;
!
!SERIES <1990:1 2050:4> VLOSUS@HAW.sol =  old:vlosus@HAW.oldsol;
!SERIES <1990:1 2050:4> VLOSJP@HAW.sol =  old:vlosJP@HAW.oldsol;
!SERIES <1990:1 2050:4> VLOSRES@HAW.sol =  old:vlosRES@HAW.oldsol;
!!simgp  old:vlosus@haw.oldsol, work:vlosus@haw.sol;
!
!SERIES <1990:1 2050:4> VLOSUS@MAU.sol =  old:vlosus@MAU.oldsol;
!SERIES <1990:1 2050:4> VLOSJP@MAU.sol =  old:vlosJP@MAU.oldsol;
!SERIES <1990:1 2050:4> VLOSRES@MAU.sol =  old:vlosRES@MAU.oldsol;
!!simgp  old:vlosus@mau.oldsol, work:vlosus@mau.sol;
!
!SERIES <1990:1 2050:4> VLOSUS@KAU.sol =  old:vlosus@KAU.oldsol;
!SERIES <1990:1 2050:4> VLOSJP@KAU.sol =  old:vlosJP@KAU.oldsol;
!SERIES <1990:1 2050:4> VLOSRES@KAU.sol =  old:vlosRES@KAU.oldsol;
!!simgp  old:vlosus@kau.oldsol, work:vlosus@kau.sol;
!
!close old;
!END; ! end if nCovBase = Y, or LOW or HIGH
!target skiplos;


!************************************************
!!!                 POPULATION 
!************************************************
!*** PROBLEM: data on NR are avail for 17-18, but not for NRM, NRCNM and NRCMD 
!*** SUGGESTION: 4 steps of add factoring population ***
!*** Follow the suggestion step-by-step.  when working on step 1, comment out add factors in all other steps
!*** Note: step 1 to 3 don't require often changes.


!**STEP 1: getting NRM@HI and NRCMD@HI that you want **
!Note: if you don't change add factors between 08Q3 and 09Q2, you can skip step 2 and 3.
!  see https://www.dmdc.osd.mil/appj/dwp/dwp_reports.jsp  for reports that may help predict direction of change
!
!                                         18Q3        19                        20
series <2018:3 2050:4> NRM@HI.ADD =       .15, .18,  .12, .0, -.01 repeat 2,  .005 repeat 4, .001 REPEAT 4, .003 repeat *;

! ARMY cut simulations
!series <2016:1 2050:4> NRMSEPA.add =   -.6 REPEAT 4, -.4 REPEAT 4, -.1 REPEAT 4, .1 repeat 4, .01 repeat *;
!series NRM@HI.ADD = NRM@HI.ADD + NRMSEPA.ADD;
!                                      2017    18                    19
series <2017:4 2050:4> SH_MD@HI.ADD =  .006, .01 .012, .012, .009,  .008 repeat 4, .008 repeat *;

!!!!!!!!
!!! compare births and deaths — civilian  nbir@hi.a,  ndea@hi.a
!!! to non-military civilian births and deaths.  
!!! print<2012 2019> nbircnm@hi.a%, nbircnm@hi.sola%, nbir@hi.a%;
!!! print<2012 2019> ndeacnm@hi.a%, ndeacnm@hi.sola%, ndea@hi.a%;

!!! look at US population projections from census!!!!!
!!! https://www.census.gov/data/tables/2017/demo/popproj/2017-summary-tables.html


!**STEP 2: add factoring nbirrcnm@hi and ndearcnm@hi between 16Q3 and 18Q3
! print
! set per 2014 2019; 
! RUN pop nowcast in evdev 
! print nbircnm@hi.sola%, nbir@hi.a%, pchya(ndearcnm@hi.sola), pchya(ndear@hi.a), nmigrcnm@hi.sola, nmigrcnm@hi.a, nmigr@hi.a, nr@hi.sola%, nr@hi.a%, nrm@hi.a%, nrcmd@hi.a%;
!                                        2016:4   2017                  2018            2019
series <2016:4 2050:4> NBIRRCNM@HI.ADD = -.01,   -.0285 repeat 3 -.02, -.018 repeat 4, -.01 repeat 4, -.01, -.01, -.01, -.007;
series <2050:4 2050:4> NBIRRCNM@HI.ADD = -0.01;
SMOOTH NBIRRCNM@HI.ADD = NBIRRCNM@HI.ADD LINEAR;
!
SERIES <2016:4 2050:4> NDEARCNM@HI.ADD = .008, .019 repeat 4, -.0045 repeat 4, .0045 repeat 4, .0025;
SERIES <2035:4 2035:4> NDEARCNM@HI.ADD = .006;
SERIES <2050:4 2050:4> NDEARCNM@HI.ADD = .006;
SMOOTH NDEARCNM@HI.ADD = NDEARCNM@HI.ADD LINEAR; 

print<2016 2018> census:nr@hon.a, nrcnm@hon.sola+nrcmd@hi.sola+nrm@hi.sola, nrcnm@hon.a, nrcnm@hon.sola, nrcnm@hi.a-(nr@haw.a+nr@mau.a+nr@kau.a), nrcnm@hi.a, nrcnm@hi.sola ;

!**STEP 3: getting the solution for NMIGCNM between 2016 AND 2017 so that the aggregate of components equal to the reported total in 2016 & 2017
!INTRUCTION: solve the model with add factors in step 1 and 2.  Then, run the following commands:

!set freq q; series<2017 2019> err = (nrcnm@hi.sol[-1]+nbircnm@hi.sol-ndeacnm@hi.sol+nmigcnm@hi.sol)-nrcnm@hi.q; series<2017 2019> newnmigrcnm@hi.sol = nmigrcnm@hi.sol - err/(nrcnm@hi.sol-err)*1000;  print<2017 2019> err, nmigrcnm@hi.sol, newnmigrcnm@hi.sol;
!!!!!! ------  Use value in the last column as the solution for NMIGRCNM@HI 

series <1980:1 2018:3> NMIGRCNM@HI.SOL = NMIGRCNM@HI.Q; !  2016                  2017                     2018
series <2016:4 2018:3> NMIGRCNM@HI.SOL =                   -.17,                -.12, -.07, -.02, -1.3,  -1.29, -1.28, -1.27;
!simgp nmigrcnm@hi.sol, nmigrcnm@hi.q;
!print nmigrcnm@hi.sol, nmigrcnm@hi.q;

!**STEP 4: add factoring other components of population (except NRM and NRCMD, which are done in step 1).
!                                        2018:4  2019                    20             21              22
!series <2018:4 2050:4> NMIGRCNM@HI.ADD =  -.3,   -.1, -.1, -.08, -.07,   -.03 repeat 4, -.02 repeat 4, -.02 repeat 4, -.02 repeat 4, -.0175 repeat *;
!Above commented out due to new scenarios

!!                                           18Q4    2019            2020  
series <2018:4 2050:4> SH_NRCNM@MAU.ADD =  -.00004, -.00005 repeat 4, -.00008 REPEAT 4, -.00013;
series <2050:4 2050:4> SH_NRCNM@MAU.ADD = -0.00016;
smooth SH_NRCNM@MAU.ADD = SH_NRCNM@MAU.ADD linear;

!!                                         2018Q4    2019             2020              2021
series <2018:4 2050:4> SH_NRCNM@HAW.ADD =  -.0002, -.00038 repeat 4, -.00042 REPEAT 4, -.00046, -.00049, -.0005, -.0005, -.00044 ;
series <2050:4 2050:4> SH_NRCNM@HAW.ADD = -0.00035;
smooth SH_NRCNM@HAW.ADD = SH_NRCNM@HAW.ADD linear;

IF ('#nCovbase'=='Y' or '#nCovHigh'=='Y');  !  baseNR
!                                        2016:4   2017                  2018            2019
series <2016:4 2050:4> NBIRRCNM@HI.ADD = -.01,   -.0285 repeat 3 -.02, -.018 repeat 4, -.01 repeat 4, -.01, -.03, -.02, -.015;
series <2050:4 2050:4> NBIRRCNM@HI.ADD = 0.0;
SMOOTH NBIRRCNM@HI.ADD = NBIRRCNM@HI.ADD LINEAR;
!**STEP 4: add factoring other components of population (except NRM and NRCMD, which are done in step 1).
!                                        2018:4  2019                    20                      21                   22            23            24
series <2018:4 2050:4> NMIGRCNM@HI.ADD =  -.3,   -.1, -.1, -.08, -.07,   -.03, -.1, -.3, -.4,   -.4, -.2, .9, .0,    -.4 repeat 4, -.1 repeat 4, -.0175 repeat 8, .05 repeat 4, .12 repeat 4, .05 repeat 8, -.01 repeat 8, 0 ;
!series <2030:4 2030:4> NMIGRCNM@HI.ADD = 0.2, 0;
series <2050:4 2050:4> NMIGRCNM@HI.ADD = 0.0;
SMOOTH NMIGRCNM@HI.ADD = NMIGRCNM@HI.ADD LINEAR;


!!                                         2018Q4    2019             2020              2021
series <2018:4 2050:4> SH_NRCNM@HAW.ADD =  -.0002, -.0004 repeat 4, -.00047 REPEAT 4, -.00046, -.00049, -.0005, -.0005, -.00044 ;
series <2050:4 2050:4> SH_NRCNM@HAW.ADD = -0.00035;
smooth SH_NRCNM@HAW.ADD = SH_NRCNM@HAW.ADD linear;
End; ! end 

IF ('#nCovLow'=='Y');
!                                        2016:4   2017                  2018            2019           2020
series <2016:4 2050:4> NBIRRCNM@HI.ADD = -.01,   -.0285 repeat 3 -.02, -.018 repeat 4, -.01 repeat 4, -.01, -.03, -.02, -.015;
series <2050:4 2050:4> NBIRRCNM@HI.ADD = 0.0;
SMOOTH NBIRRCNM@HI.ADD = NBIRRCNM@HI.ADD LINEAR;
!**STEP 4: add factoring other components of population (except NRM and NRCMD, which are done in step 1).
!                                        2018:4  2019                    20                        21                    22
series <2018:4 2050:4> NMIGRCNM@HI.ADD =  -.3,   -.1, -.1, -.08, -.07,   -.03, -.15, -1.5, -.7,   -.8, -1.2, 2.5, 1.5,   -.6 repeat 4, -.2 repeat 4, -.1 repeat 4, .12 repeat 4, .05 repeat 8, -.01 repeat 8, 0;
series <2050:4 2050:4> NMIGRCNM@HI.ADD = 0.0;
SMOOTH NMIGRCNM@HI.ADD = NMIGRCNM@HI.ADD LINEAR;

!!                                         2018Q4    2019             2020              2021
series <2018:4 2050:4> SH_NRCNM@HAW.ADD =  -.0002, -.0004 repeat 4, -.00047 REPEAT 4, -.00046, -.00049, -.0005, -.0005, -.00044 ;
series <2050:4 2050:4> SH_NRCNM@HAW.ADD = -0.00035;
smooth SH_NRCNM@HAW.ADD = SH_NRCNM@HAW.ADD linear;
End; ! end 

!!                                         2018Q4
series <2018:4 2050:4> SH_NRCNM@KAU.ADD =  .000072;
series <2050:4 2050:4> SH_NRCNM@KAU.ADD = -0.000001;
smooth SH_NRCNM@KAU.ADD = SH_NRCNM@KAU.ADD linear;

!************************************************
!                LABOR FORCE
!************************************************
!                                    2020              21           
SERIES <2020:1 2050:4> LF@HI.ADD = -.1, -.1, -.3, -.5, 0 repeat 4, .13 repeat 4, .14 repeat *;
SERIES <2020:1 2050:4> LF@NBI.ADD = 0 repeat  4,    .15 repeat 4, .15 repeat *;

! ############   HIGH
IF ('#nCovHigh'=='Y');  
!          				             20Q2           21             22           23            24            25
SERIES <2020:2 2050:4> LF@HI.ADD =  -3, -2, -1,    .85 repeat 4,   .7 repeat 4,  0 repeat 4, .15 repeat 4, .1 repeat *;   
!2.5 repeat 4;
!  -4 repeat 4,  8 repeat 4,  -15 repeat 4, .5 repeat *;
SERIES <2020:2 2050:4> LF@NBI.ADD = -2, -1, -1,    -.2 repeat 4,  .65 repeat 4,  .45 repeat 4, .15 repeat *;

SERIES <2021:1 2050:4> E_NF@HAW.ADD = .04 repeat *;
SERIES <2021:1 2050:4> E_NF@KAU.ADD = .01 repeat *;

END; ! end if nCovHIGH = Y

! ############   LFLOW
IF ('#nCovLow'=='Y');  
!  LF NBI UP ---> LF HON DOWN and UR Down
!  LF UP  --- UR UP
!  LF down  --- UR down
!          				             20Q2          21             22             23            24            25
!SERIES <2020:2 2050:4> LF@HI.ADD =  -3, -10, 5,   4, -2, -2, -1,  -1 repeat 4,  0 repeat 4,  .15 repeat 4, .1 repeat *;   
SERIES <2020:2 2050:4> LF@HI.ADD =  -3, -14, 5,    4, 3, 2, 1,   0 repeat 4,     0 repeat 4,  .1 repeat 4, .1 repeat 4, .05 REPEAT 4, .01 REPEAT *;   
SERIES <2020:2 2050:4> LF@NBI.ADD = -2, -7,  -3,   0, 1, 1, .7,  -.35 repeat 4,  .3 repeat 4, .2 repeat 4, .1 repeat 4, .04 repeat 4, .01 REPEAT 4, .0 repeat 4, .01 repeat *;
!SERIES <2020:2 2050:4> LF@NBI.ADD = -2, -7,  -3,   0, 1, 1, .7,  -.35 repeat 4,  .3 repeat 4, .3 repeat *;

SERIES <2021:1 2050:4> E_NF@HAW.ADD = .02 repeat 5, .015 REPEAT *;
SERIES <2021:1 2050:4> E_NF@KAU.ADD = .01 repeat 5, .008 REPEAT *;
END; ! end if nCovLOW = Y

! ############   LFbase
IF ('#nCovBase'=='Y');  
!          				             20Q2           21             22           23            24            25
SERIES <2020:2 2050:4> LF@HI.ADD =  -3, -2, -1,    .85 repeat 4,   .7 repeat 4,  0 repeat 4, .15 repeat 4, .1 repeat 4 .05 repeat 4, .01 repeat *;   
SERIES <2020:2 2050:4> LF@NBI.ADD = -2, -1, -1,    -.2 repeat 4,  .65 repeat 4,  .45 repeat 4, .15 repeat 4, .07 repeat 4, .01 repeat 4, -.01 REPEAT 4, -.02 repeat 4, -.04 repeat *;

SERIES <2021:1 2050:4> E_NF@HAW.ADD = .02 repeat 5, .015 REPEAT *;
SERIES <2021:1 2050:4> E_NF@KAU.ADD = .01 repeat 5, .008 REPEAT *;

END; ! end if nCovBase = Y


! 3/14/20 — EMPLOYMENT IS NOW IDENTITY/Behavioral FORCED TO GROW AT SAME RATE AS E_NF

!************************************************
!                      CPI
!************************************************

!                                        2018
SERIES <2019:4 2049:4> PCHSSH@HON.ADD = -2, -2.1 repeat 4, -2.2 ;
SERIES <2050:4 2050:4> PCHSSH@HON.ADD = -.8;
smooth PCHSSH@hon.add = PCHSSH@hon.add linear;

SERIES <2017:1 2049:4> PCFBFD@HON.ADD = .9 repeat 2, 0 repeat 2, 0 repeat *;

SERIES <2020:1 2049:4>  PCEN@HON.ADD =   0 repeat 4, -.3 repeat *;

!                                      2019      20              21
SERIES <2019:4 2050:4> CPI@HON.ADD =  -1.2,      -.35 repeat 4,  -.5 repeat 4, -.4 repeat 8, -.3 repeat  * ;

! ##################  BASE
IF ('#nCovBase'=='Y');  
!                                         20           21                       22
SERIES <2020:2 2050:4> PCHSSH@HON.ADD =  -5, 0, 15,   -1.5, -8.5, -7.5, -4.3,  -1.5, -3, -4.5, -1, -1.5 , -1;
SERIES <2050:4 2050:4> PCHSSH@HON.ADD =   -.4;
smooth PCHSSH@hon.add = PCHSSH@hon.add linear;

!                                         20             21              22
SERIES <2020:2 2050:4> CPI@HON.ADD =     -1.4 repeat 3,  -1.3 repeat 4,  -1.4 repeat 4, -1.5 repeat  4, -1.2 repeat 4, -1 repeat * ;

open qsol20Q1;
SERIES PCFBFD@HON.SOL = PCFBFD@HON.OLDSOL;
CLOSE QSOL20Q1;
END; ! end if nCovBase = Y

! ##################  HIGH LOW
IF ('#nCovLow'=='Y' or '#nCovHigh'=='Y');  
!                                         20           21                     22
SERIES <2020:2 2050:4> PCHSSH@HON.ADD =  -5, 0, 15,   -1.5, -8.5, -7, -4,    -1, -3, -4.5, -1, -1.5 , -1;
SERIES <2050:4 2050:4> PCHSSH@HON.ADD =   -.4;
smooth PCHSSH@hon.add = PCHSSH@hon.add linear;

!                                         20             21              22
SERIES <2020:2 2050:4> CPI@HON.ADD =     -1.4 repeat 3,  -1.3 repeat 4,  -1.4 repeat 4, -1.5 repeat  4, -1.2 repeat 4, -1 repeat * ;

open qsol20Q1;
SERIES PCFBFD@HON.SOL = PCFBFD@HON.OLDSOL;
CLOSE QSOL20Q1;
END; ! end if nCovBase = Y




!************************************************
!                 JOBS and STATE INCOME
!************************************************
!!! BEGIN WITH TOURISM RELATED AND PROGRESS TO AGG. DEMAND DRIVEN


!***************    ACCOMODATIONS AND FOOD SERVICES    ************************ 	DON'T TOUCH
!                                       19Q1                 20             21          
SERIES <2019:1 2050:4> EAF@HI.ADD =    -.3, -.73, -.8, -1,  -1 repeat 4;
SERIES <2050:4 2050:4> EAF@HI.ADD = -.6;
SMOOTH EAF@HI.ADD = EAF@HI.ADD LINEAR;
!                                      19                  20                    21
SERIES <2019:1 2050:4> EAF@HON.ADD =  .25, .25, .25, .15,  .15, .15, .15, .2,  .22 repeat 4, .25;
SERIES <2050:4 2050:4> EAF@HON.ADD = .3;
SMOOTH EAF@HON.ADD = EAF@HON.ADD LINEAR;
!                                      19Q4 
SERIES <2019:4 2050:4> YLAF_R@HI.ADD =  -4, -6, -6, -5, -4;
SERIES <2050:4 2050:4> YLAF_R@HI.ADD = -5;
SMOOTH YLAF_R@HI.ADD = YLAF_R@HI.ADD LINEAR;

! ############  EAFBASE
IF ('#nCovBase'=='Y');  !           20Q2               21                 22                23
SERIES <2020:2 2050:4> EAF@HI.PAN = -29, 4, 0,        13, 9, 5, 3,       1.5, 1, .5, .35,   .4 repeat 8, .2 repeat 4,  .1 repeat *; 
SERIES <2020:2 2050:4> EAF@HI.ADD =  EAF@HI.ADD + EAF@HI.pan;
!                                    20Q2              21                     22                 23            24            25
SERIES <2020:2 2050:4> EAF@HON.PAN = -24, 3, 4.5,      6.5, 4, -1.6, -.6,   -.6, -.4 repeat 3,  -.2 repeat 4, -.1 REPEAT 4, -.25 repeat 4, -.25 repeat 4, -.2 repeat 4, -.1 repeat 4;
SERIES <2050:4 2050:4> EAF@HON.PAN = .25;
SMOOTH EAF@HON.PAN = EAF@HON.PAN LINEAR;
SERIES <2020:2 2050:4> EAF@HON.ADD =  EAF@HON.ADD + EAF@HON.pan;
!                                      2020                  21                  22
SERIES <2020:1 2050:4> YLAF_R@HI.PAN = 10, 270, -40, -210,  -140, -80, -50, 0,  0 repeat 12;
SERIES <2030:1 2030:4> YLAF_R@HI.PAN = 1.3 REPEAT 4;
SERIES <2050:1 2050:4> YLAF_R@HI.PAN = 4 REPEAT 4;
SMOOTH YLAF_R@HI.PAN = YLAF_R@HI.PAN LINEAR;
SERIES <2020:1 2050:4> YLAF_R@HI.ADD =  YLAF_R@HI.ADD + YLAF_R@HI.pan;
END; ! end ncovBASE —  EAF

! ############  HIGH
IF ('#nCovHIGH'=='Y');  !           20Q2               21                     22              23
SERIES <2020:2 2050:4> EAF@HI.PAN = -27, 13, 12,       8, 6, 3, 2,           1, .5, .4, .3,   .3 repeat *; 
SERIES <2020:2 2050:4> EAF@HI.ADD =  EAF@HI.ADD + EAF@HI.pan;
!                                    20Q2              21                     22                 23
SERIES <2020:2 2050:4> EAF@HON.PAN = -20, 8, 11,       1, 0, 0, -.5,        -.3, -.15 repeat 3,  -.1 repeat 4, .0 REPEAT 4, .05 repeat 4; 
SERIES <2050:4 2050:4> EAF@HON.PAN = .3;
SMOOTH EAF@HON.PAN = EAF@HON.PAN LINEAR;
SERIES <2020:2 2050:4> EAF@HON.ADD =  EAF@HON.ADD + EAF@HON.pan;
!                                      2020                  21                  22
SERIES <2020:1 2050:4> YLAF_R@HI.PAN = 10, 270, -140, -290,  -120, -20, 0, 0,  0 repeat 4;
SERIES <2025:4 2025:4> YLAF_R@HI.PAN = 0;
SERIES <2050:1 2050:4> YLAF_R@HI.PAN = 4 REPEAT 4;
SMOOTH YLAF_R@HI.PAN = YLAF_R@HI.PAN LINEAR;
SERIES <2020:1 2050:4> YLAF_R@HI.ADD =  YLAF_R@HI.ADD + YLAF_R@HI.pan;
END; ! end ncovHIGH —  EAF

! ************* nCoVLow— EAFLOW
IF ('#nCovLow'=='Y');  !           20Q2               21                 22                    23
SERIES <2020:2 2050:4> EAF@HI.PAN = -27, -4, 8,       13, 9, 5, 4,       2.5, 1.5, .5, .35,   .4 repeat *; 
SERIES <2020:2 2050:4> EAF@HI.ADD =  EAF@HI.ADD + EAF@HI.pan;
!                                    20Q2              21                     22                 23              24             25
SERIES <2020:2 2050:4> EAF@HON.PAN = -20, 0, 5,      6.5, 5.5, -1.6, -.6,   -.6, -.4 repeat 3,  -.25 repeat 4, -.15 REPEAT 4, -.1 repeat 4;
SERIES <2030:4 2030:4> EAF@HON.PAN = -.08;
SERIES <2050:4 2050:4> EAF@HON.PAN = .4;
SMOOTH EAF@HON.PAN = EAF@HON.PAN LINEAR;
SERIES <2020:2 2050:4> EAF@HON.ADD =  EAF@HON.ADD + EAF@HON.pan;
!                                      2020                  21                     22           23
SERIES <2020:1 2050:4> YLAF_R@HI.PAN = 10, 270, 100, -190,  -180, -110, -70, -20,  -15 repeat 4, 0 repeat 12;
SERIES <2030:1 2030:4> YLAF_R@HI.PAN = 1 REPEAT 4;
SERIES <2050:1 2050:4> YLAF_R@HI.PAN = 2 REPEAT 4;
SMOOTH YLAF_R@HI.PAN = YLAF_R@HI.PAN LINEAR;
SERIES <2020:1 2050:4> YLAF_R@HI.ADD =  YLAF_R@HI.ADD + YLAF_R@HI.pan;
END; ! end ncovLow —  EAF

!***************    TRADE    **************************************************
!                                        20Q1         21Q1
SERIES <2020:1 2050:4> E_TRADE@HI.ADD =  0 repeat 4, .03 repeat 4, .01 repeat 4 , 0 repeat *;
!                                          19Q1                 20Q1
SERIES <2019:1 2050:4> E_TRADE@HON.ADD =  .0, -1, -.6, .1,    .05, 0.08, -.012, -.015,  -.02 repeat 3, -.008;
SERIES <2030:1 2030:4> E_TRADE@HON.ADD =   -.003 REPEAT 4;
SERIES <2050:1 2050:4> E_TRADE@HON.ADD =   -.008 REPEAT 4;
SMOOTH E_TRADE@HON.ADD = E_TRADE@HON.ADD LINEAR;
!                                            19 
SERIES <2019:3 2050:4> YL_TRADE_R@HI.ADD =   -10, -15, 5, 1;
SERIES <2050:1 2050:4> YL_TRADE_R@HI.ADD =   1.7 REPEAT 4;
SMOOTH YL_TRADE_R@HI.ADD = YL_TRADE_R@HI.ADD LINEAR;

! ************* BASE--- TRADEBASE
IF ('#nCovBASE'=='Y');  !                 20Q2             21                  22              23           24
SERIES <2020:2 2050:4> E_TRADE@HI.pan =  -11.5, 8,  3,    -2 , -1, 0, 0 ,    -.1 repeat 4,    0 repeat 4,  .03 repeat 4, .025;
SERIES <2035:4 2035:4> E_TRADE@HI.pan =  -.015;
SERIES <2040:1 2040:1> E_TRADE@HI.pan =  -0.035;
SERIES <2045:1 2045:1> E_TRADE@HI.pan =  -0.03;
SERIES <2050:4 2050:4> E_TRADE@HI.pan =  -0.03;
SMOOTH E_TRADE@HI.pan = E_TRADE@HI.pan LINEAR;
SERIES <2020:1 2050:4> E_TRADE@HI.ADD =  E_TRADE@HI.ADD + E_TRADE@HI.pan;

SERIES <2020:2 2050:4> E_TRADE@HOn.pan = -20, 14,  -11,   18,  -8, 0, 0,     -.25, -.3 repeat 3,  -.0 repeat 4, 0 repeat 4, .02 repeat 4, .03 REPEAT 4, .03 REPEAT 4; 
SERIES <2040:1 2040:1> E_TRADE@hoN.pan =   0.003;
SERIES <2045:1 2045:1> E_TRADE@hoN.pan =   0.005;
SERIES <2050:4 2050:4> E_TRADE@hoN.pan =   0.005;
SMOOTH E_TRADE@hoN.pan = E_TRADE@hoN.pan LINEAR;
SERIES <2020:1 2050:4> E_TRADE@HOn.ADD =  E_TRADE@HOn.ADD + E_TRADE@HON.pan*.69;
!                 							2020                   21                   22               23           24            25
SERIES <2020:1 2050:4> YL_TRADE_R@HI.pan = -30, -105, 330, -485,  -100, 100, 35, 25 ,   5 repeat 4,     .75 repeat 4, 1.5 repeat 4, 1 repeat 4, .5 repeat 4; 
SERIES <2030:4 2030:4> YL_TRADE_R@HI.pan =   0.75;
SERIES <2035:4 2035:4> YL_TRADE_R@HI.pan =   1;
SERIES <2040:4 2040:4> YL_TRADE_R@HI.pan =   .9;
SERIES <2045:4 2045:4> YL_TRADE_R@HI.pan =   .3;
SERIES <2050:4 2050:4> YL_TRADE_R@HI.pan =   -.5;
SMOOTH YL_TRADE_R@HI.pan = YL_TRADE_R@HI.pan LINEAR;
SERIES <2020:1 2050:4> YL_TRADE_R@HI.ADD =  YL_TRADE_R@HI.ADD + YL_TRADE_R@HI.pan;
END; 

! ############## HIGH--- TRADEhigh
IF ('#nCovHIGH'=='Y');  !                 20Q2            21                      22               23             24
SERIES <2020:2 2050:4> E_TRADE@HI.pan =  -39, 29.5,  5,  -8.5 , -.5, -.3, -.2,   -.15 repeat 4,    .02 repeat 4,  .05 repeat 4, .03;
SERIES <2035:4 2035:4> E_TRADE@HI.pan =  -.015;
SERIES <2040:1 2040:1> E_TRADE@HI.pan =  -0.035;
SERIES <2045:1 2045:1> E_TRADE@HI.pan =  -0.03;
SERIES <2050:4 2050:4> E_TRADE@HI.pan =  -0.03;
SMOOTH E_TRADE@HI.pan = E_TRADE@HI.pan LINEAR;
SERIES <2020:1 2050:4> E_TRADE@HI.ADD =  E_TRADE@HI.ADD + E_TRADE@HI.pan;

SERIES <2020:2 2050:4> E_TRADE@HOn.pan = -48, 26,  4,     24,  -16, -4, -.8,     -.55, -.45, -.25, -.15,  .06 repeat 4, 0.08 repeat 4, .03 repeat 4; 
SERIES <2030:1 2030:1> E_TRADE@hoN.pan =   0.05;
SERIES <2035:1 2035:1> E_TRADE@hoN.pan =   0.03;
SERIES <2040:1 2040:1> E_TRADE@hoN.pan =   0.0;
SERIES <2050:4 2050:4> E_TRADE@hoN.pan =   .00;
SMOOTH E_TRADE@hoN.pan = E_TRADE@hoN.pan LINEAR;
SERIES <2020:1 2050:4> E_TRADE@HOn.ADD =  E_TRADE@HOn.ADD + E_TRADE@HON.pan*.69;
!                 							2020                   21                    22
SERIES <2020:1 2050:4> YL_TRADE_R@HI.pan = -30, -305, 280, -165,   -50, 260, -25, -9 ,   -3, -1 repeat 3, .75 repeat 4, 1.5 repeat *; 
SERIES <2020:1 2050:4> YL_TRADE_R@HI.ADD =  YL_TRADE_R@HI.ADD + YL_TRADE_R@HI.pan;
END; 

! ************* Low--- TRADElow
IF ('#nCovLow'=='Y');  !                 20Q2             21                       22            23               24  
SERIES <2020:2 2050:4> E_TRADE@HI.pan =  -39, 15.5,  8,   1.1 , -.5, -.35, -.4,  -.34 repeat 4,    -.15 repeat 4,  -.05 repeat 4, .0 repeat *;
SERIES <2020:1 2050:4> E_TRADE@HI.ADD =  E_TRADE@HI.ADD + E_TRADE@HI.pan;

SERIES <2020:2 2050:4> E_TRADE@HOn.pan = -48, 10,  6,     19,  3, -2.5, -1.5,      -.5, -.43 repeat 3,  -.25 repeat 4, -0.1 repeat 4, .0 repeat 4; 
SERIES <2030:4 2030:4> E_TRADE@hoN.pan =   0.029;
SERIES <2040:1 2040:1> E_TRADE@hoN.pan =   0.055;
SERIES <2045:1 2045:1> E_TRADE@hoN.pan =   0.015;
SERIES <2050:4 2050:4> E_TRADE@hoN.pan =   0.013;
SMOOTH E_TRADE@hoN.pan = E_TRADE@hoN.pan LINEAR;
SERIES <2020:1 2050:4> E_TRADE@HOn.ADD =  E_TRADE@HOn.ADD + E_TRADE@HON.pan*.69;

!                 							20Q1 Q2              21                    22
SERIES <2020:1 2050:4> YL_TRADE_R@HI.pan = -30, -325, 70, -15,  -140, 230, 85, 35 ,   5 repeat 4, .75 repeat 4, 1.5 repeat 8, 1 repeat 4, 0 repeat *; 
SERIES <2020:1 2050:4> YL_TRADE_R@HI.ADD =  YL_TRADE_R@HI.ADD + YL_TRADE_R@HI.pan;
END; 

!***************    TRANSPORTATION AND  UTILITIES    **************************
!                                     20Q1
SERIES <2020:1 2050:4> E_TU@HI.ADD =  -.15 repeat 4,  -.08, -.07, -.05, 0,  .001;
SERIES <2025:4 2025:4> E_TU@HI.ADD = 0;
SERIES <2050:4 2050:4> E_TU@HI.ADD = 0;
SMOOTH E_TU@HI.ADD = E_TU@HI.ADD LINEAR;

!                                      20Q1 
SERIES <2020:1 2050:4> E_TU@HON.ADD =  -.15 repeat 4,  -.08, -.08, -.05, 0,  .001;
SERIES <2025:4 2025:4> E_TU@HON.ADD = 0;
SERIES <2050:4 2050:4> E_TU@HON.ADD = 0;
SMOOTH E_TU@HON.ADD = E_TU@HON.ADD LINEAR;

!                                         19Q4
SERIES <2019:4 2050:4>  YL_TU_R@HI.ADD =  5,    3, 2, 1, 0;
SERIES <2023:1 2023:4>  YL_TU_R@HI.ADD = .8 REPEAT 4;
SERIES <2030:1 2030:4>  YL_TU_R@HI.ADD = -.3 REPEAT *;
SERIES <2040:1 2040:4>  YL_TU_R@HI.ADD = -.8 REPEAT *;
SERIES <2050:1 2050:4>  YL_TU_R@HI.ADD = -1.5 REPEAT *;
SMOOTH YL_TU_R@HI.ADD = YL_TU_R@HI.ADD LINEAR;


! ###################  BASE ---- E_TUBASE
IF ('#nCovBase'=='Y');  ! 			  20Q2                  21                       22                     23             24             25
SERIES <2020:2 2050:4> E_TU@HI.pan =   7.6,  9.9,  -1.5,   -7, -10, -2.2, -1.2,   -.75, -.65, -.55, -.36,  -.3 repeat 4, -.13 repeat 4, -.08 REPEAT 4, -.16; 
SERIES <2030:4 2030:4> E_TU@HI.pan =  .018;
SMOOTH E_TU@HI.pan = E_TU@HI.pan LINEAR;
SERIES <2020:2 2050:4> E_TU@HI.ADD =  E_TU@HI.ADD + E_TU@HI.pan;
! 			                          20Q2                21                       22                    23 
SERIES <2020:2 2050:4> E_TU@HON.pan =  3.5,  9.8, -.5,   -5.5, -8.7, -1.9, -1,     -.7, -.55, -.45, -.3,  -.23 repeat 4, -.11 repeat 4, -.1 REPEAT 4, -.13; 
SERIES <2030:4 2030:4> E_TU@HON.pan =  .005;
SMOOTH E_TU@HON.pan = E_TU@HON.pan LINEAR;
SERIES <2020:2 2050:4> E_TU@HON.ADD =  E_TU@HON.ADD + E_TU@HON.pan;

! 			                             20            21                    22               23
SERIES <2020:1 2050:4> YL_TU_R@HI.pan = -8 repeat 4,   30, 170, -115, -40,  -30, -5 repeat 4, 0 repeat 8;
SERIES <2050:4 2050:4> YL_TU_R@HI.pan =   2;
SMOOTH YL_TU_R@HI.pan = YL_TU_R@HI.pan LINEAR;
 
SERIES <2020:1 2050:4> YL_TU_R@HI.ADD =  YL_TU_R@HI.ADD + YL_TU_R@HI.pan;
END; ! end if nCovBase = Y

! ################# HIGH ---- TRANSPORT & UTIL
IF ('#nCovHIGH'=='Y');  ! 			  20Q2               21                       22                      23              24
SERIES <2020:2 2050:4> E_TU@HI.pan =   7.5,  9.9,  -4,  -8.2, -10.2, -1.5, -.5,  -.35, -.34, -.34, -.33,  -.13 repeat 4, -.05 repeat 4, -.0 REPEAT *;   SERIES <2020:2 2050:4> E_TU@HI.ADD =  E_TU@HI.ADD + E_TU@HI.pan;
! 			                          20Q2                21                       22                      23 
SERIES <2020:2 2050:4> E_TU@HON.pan =  3.5,  9.8, -3,   -6.5, -8.9, -1.3, -.33,    -.33, -.3, -.26, -.22,  -.11 repeat 4, -.035 REPEAT 4, 0 repeat 4; SERIES <2030:4 2030:4> E_TU@HON.pan =  -.01;
SMOOTH E_TU@HON.pan = E_TU@HON.pan LINEAR;
SERIES <2020:2 2050:4> E_TU@HON.ADD =  E_TU@HON.ADD + E_TU@HON.pan;
! 			                             20            21                    22
SERIES <2020:1 2050:4> YL_TU_R@HI.pan = -8 repeat 4,   30, 170, -165, -40,  0 repeat 4, 0 repeat 8; 
SERIES <2050:4 2050:4> YL_TU_R@HI.pan =   2;
SMOOTH YL_TU_R@HI.pan = YL_TU_R@HI.pan LINEAR;
SERIES <2020:1 2050:4> YL_TU_R@HI.ADD =  YL_TU_R@HI.ADD + YL_TU_R@HI.pan;
END; ! end if nCovHIGH = Y


! ************* TULow ---- TRANSPORT & UTIL
IF ('#nCovLow'=='Y');  ! 			  20Q2                 21                      22                    23                    24
SERIES <2020:2 2050:4> E_TU@HI.pan =   7.5,  12.3,  2.5,   -7, -12, -6.2, -2,    -.75, -.7, -.66, -.6,  -.5, -.45, -.2 -.2 , -.25 repeat 4, -.14 REPEAT 4; 
SERIES <2030:4 2030:4> E_TU@HI.pan =  .018;
SMOOTH E_TU@HI.pan = E_TU@HI.pan LINEAR;
SERIES <2020:2 2050:4> E_TU@HI.ADD =  E_TU@HI.ADD + E_TU@HI.pan;

! 			                          20Q2                21                         22                      23 
SERIES <2020:2 2050:4> E_TU@HON.pan =  3.3,  10.5,  3.5,   -5.3, -10.2, -5.2, -1.7,  -.7, -.55, -.53, -.45,  -.36 repeat 3,   -.2 repeat 4, -.1 REPEAT 4; 
SERIES <2030:4 2030:4> E_TU@HON.pan =  .005;
SERIES <2035:4 2035:4> E_TU@HON.pan =   0;
SERIES <2050:4 2050:4> E_TU@HON.pan =   .001;
SMOOTH E_TU@HON.pan = E_TU@HON.pan LINEAR;
SERIES <2020:2 2050:4> E_TU@HON.ADD =  E_TU@HON.ADD + E_TU@HON.pan;

! 			                             20            21                   22
SERIES <2020:1 2050:4> YL_TU_R@HI.pan = -8 repeat 4,   30, 170, -15, -90,  -30, -35, -30, -5,  0 repeat 12;
SERIES <2050:4 2050:4> YL_TU_R@HI.pan =   1.7;
SMOOTH YL_TU_R@HI.pan = YL_TU_R@HI.pan LINEAR;
 
SERIES <2020:1 2050:4> YL_TU_R@HI.ADD =  YL_TU_R@HI.ADD + YL_TU_R@HI.pan;
END; ! end if nCovLow = Y


!***************    HEALTH     ************************************************
!                                    20            21
SERIES <2020:1 2050:4> EHC@HI.ADD =  .0 repeat 4, -.05 repeat 4, .02 REPEAT 4, .03 REPEAT 4, .04 repeat *;
!                                    2019                     20            21
SERIES <2019:1 2050:4> EHC@NBI.ADD =  -.08, .15, .05 , .002, .0 REPEAT 4, .00 repeat *;

!                                      19          20
SERIES <2019:3 2050:4> YLHC_R@HI.ADD = 19, 16, 14, 16 REPEAT 3, 16 repeat 4, 16 repeat 4, 16;
SERIES <2050:4 2050:4> YLHC_R@HI.ADD = 45; 
SMOOTH YLHC_R@HI.ADD = YLHC_R@HI.ADD LINEAR;

! ################# HIGH
IF ('#nCovHIGH'=='Y');  !            20Q2               21          22
SERIES <2020:2 2050:4> EHC@HI.PAN =   -8,  7.9,  2,    -.5 repeat 4, 0 repeat 4, -.05 repeat *; 
SERIES <2020:1 2050:4> ehc@HI.ADD =  ehc@HI.ADD + ehc@HI.pan;

!                                    20Q2                21                     22
SERIES <2020:2 2050:4> EHC@NBI.PAN =  -2, 0, 2,         .25, .2, -.4, -.2, .0 repeat *; 
SERIES <2020:1 2050:4> ehc@NBI.ADD =  ehc@NBI.ADD + ehc@NBI.pan;

!                                       20Q1                  21                     22
SERIES <2020:1 2050:4> YLHC_R@HI.PAN = -1.5, -1.5, 90, -105,  -20, 90, -15, -15, -10,  0 repeat *; 
SERIES <2020:1 2050:4> YLHC_R@HI.ADD =  YLHC_R@HI.ADD + YLHC_R@HI.pan;
END; 
! ################# BASEHC
IF ('#nCovBase'=='Y');  !            20Q2               21          22
SERIES <2020:2 2050:4> EHC@HI.PAN =   -8,  5.9,  0,     .4 repeat 4, 0 repeat 4, -.05 repeat 12, -.01 repeat *; 
SERIES <2020:1 2050:4> ehc@HI.ADD =  ehc@HI.ADD + ehc@HI.pan;

!                                    20Q2                 21                     22
SERIES <2020:2 2050:4> EHC@NBI.PAN =  -2, -.25, 1.7,     .1, .25, -.2, -.1, .0 repeat *; 
SERIES <2020:1 2050:4> ehc@NBI.ADD =  ehc@NBI.ADD + ehc@NBI.pan;

!                                       20Q1                  21                     22
SERIES <2020:1 2050:4> YLHC_R@HI.PAN = -1.5, -1.5, 90, -65,   5, 60, -15, -15, -10,  0 repeat *; 
SERIES <2020:1 2050:4> YLHC_R@HI.ADD =  YLHC_R@HI.ADD + YLHC_R@HI.pan;
END; 


! ################# LOW
IF ('#nCovLow'=='Y');  !            20Q2                21          22
SERIES <2020:2 2050:4> EHC@HI.PAN =   -8,  1.8,  3,     .4 repeat 4, 0 repeat 4, -.05 repeat *; 
SERIES <2020:1 2050:4> ehc@HI.ADD =  ehc@HI.ADD + ehc@HI.pan;

!                                    20Q2                 21                     22
SERIES <2020:2 2050:4> EHC@NBI.PAN =  -2.2, -1.3,  1.9,  .7, .25, -.2, -.1, .0 repeat *; 
SERIES <2020:1 2050:4> ehc@NBI.ADD =  ehc@NBI.ADD + ehc@NBI.pan;

!                                       20Q1                  21                     22
SERIES <2020:1 2050:4> YLHC_R@HI.PAN = -1.5, -4.5, 70, -5,    -35, 60, -15, -15, -10,  0 repeat *; 
SERIES <2020:1 2050:4> YLHC_R@HI.ADD =  YLHC_R@HI.ADD + YLHC_R@HI.pan;
END; 
!

!***************    FEDERAL GOV    ********************************************
!!									     Census
!!                                       20Q1   Q2   Q3     Q4       21Q1    Q2   Q3
!SERIES <2020:1 2050:4> EGVFD@HI.ADD =    .02,   .6, -.55,  -.007,     .00, .00, -.07, .15, .05;
!SERIES <2050:4 2050:4> EGVFD@HI.ADD =   -.13;
!SMOOTH EGVFD@HI.ADD = EGVFD@HI.ADD LINEAR;

!!                                       20Q1
SERIES <2020:1 2050:4> EGVFD@HON.ADD =   -.1, .009 repeat 3, .016 repeat 4, .014;
SERIES <2050:4 2050:4> EGVFD@HON.ADD =   .016;
SMOOTH EGVFD@HON.ADD = EGVFD@HON.ADD LINEAR;

!!                                        19Q2      20Q1						
SERIES <2019:3 2050:4> YLGVFD_R@HI.ADD =  7, 0,    -1, -1, -1 repeat 4, -1.2  repeat 8, -1.3 repeat *;

!!!! military get their pay raises 1st quarter every year
!SERIES <2017:4 2050:4> YLGVML_R@HI.ADD =  0, -9 repeat 4, -5 repeat 4, -6.5;
!SERIES <2050:4 2050:4> YLGVML_R@HI.ADD =   -15;
!SMOOTH YLGVML_R@HI.ADD = YLGVML_R@HI.ADD LINEAR;

IF ('#nCovHIGH'=='Y');  !  HIGH Scen
!!									     Census
!!                                       20Q2       Q4       21Q1    Q2   Q3
SERIES <2020:2 2050:4> EGVFD@HI.ADD =    .3, -.3,  -.25,     -.2, -.2, -.07, .1, .07, .03;
SERIES <2050:4 2050:4> EGVFD@HI.ADD =   -.13;
SMOOTH EGVFD@HI.ADD = EGVFD@HI.ADD LINEAR;
!!                                       20Q2
SERIES <2020:1 2050:4> EGVFD@HON.ADD =   -.1  .009 repeat 3,        .01 repeat 4, .014;
SERIES <2050:4 2050:4> EGVFD@HON.ADD =   .016;
SMOOTH EGVFD@HON.ADD = EGVFD@HON.ADD LINEAR;
!!                                        20Q1						
SERIES <2020:1 2050:4> YLGVFD_R@HI.ADD =  -1, -4, -7, -6,   -3.5 repeat 4,  -1.5  repeat 4, -1 repeat 4, -1 repeat *;

!!!! military get their pay raises 1st quarter every year
SERIES <2020:1 2050:4> YLGVML_R@HI.ADD =  0, -20, -6.5;
SERIES <2025:4 2025:4> YLGVML_R@HI.ADD =   -9, -11;
SERIES <2030:4 2030:4> YLGVML_R@HI.ADD =   -11;
SERIES <2035:4 2035:4> YLGVML_R@HI.ADD =   -8;
SERIES <2040:4 2040:4> YLGVML_R@HI.ADD =   -13;
SERIES <2050:4 2050:4> YLGVML_R@HI.ADD =   -14;
SMOOTH YLGVML_R@HI.ADD = YLGVML_R@HI.ADD LINEAR;
!SERIES <2020:1 2050:4> YLGVML_R@HI.ADD =  0, -20;
!SERIES <2050:4 2050:4> YLGVML_R@HI.ADD =   -155;
!SMOOTH YLGVML_R@HI.ADD = YLGVML_R@HI.ADD LINEAR;
END; ! end if nCovHIGH = Y

IF ('#nCovBase'=='Y');  !  BASE Scen
!!									     Census
!!                                       20Q2       Q4       21Q1    Q2   Q3      22
SERIES <2020:2 2050:4> EGVFD@HI.ADD =    .3, -.3,  -.25,     -.2, -.2, -.07, .1, .07, .03;
SERIES <2025:1 2025:4> EGVFD@HI.ADD =   .03 repeat 4, -.05;
SERIES <2030:1 2030:4> EGVFD@HI.ADD =   -.029 repeat 4;
SERIES <2050:1 2050:4> EGVFD@HI.ADD =   -.1 repeat 4;
SMOOTH EGVFD@HI.ADD = EGVFD@HI.ADD LINEAR;

!!                                       20Q2
SERIES <2020:1 2050:4> EGVFD@HON.ADD =   -.1  .009 repeat 3,        .01 repeat 4, .014;
SERIES <2050:4 2050:4> EGVFD@HON.ADD =   .01;
SMOOTH EGVFD@HON.ADD = EGVFD@HON.ADD LINEAR;
!!                                        20Q1						
SERIES <2020:1 2050:4> YLGVFD_R@HI.ADD =  -1, -4, -7, -6,   -3.5 repeat 4,  -1.5  repeat 4, -1 repeat 4, -1 repeat *;

!!!! military get their pay raises 1st quarter every year
SERIES <2020:1 2050:4> YLGVML_R@HI.ADD =  0, -20, -6.5;
SERIES <2025:4 2025:4> YLGVML_R@HI.ADD =   -9, -11;
SERIES <2030:4 2030:4> YLGVML_R@HI.ADD =   -11;
SERIES <2035:4 2035:4> YLGVML_R@HI.ADD =   -8;
SERIES <2040:4 2040:4> YLGVML_R@HI.ADD =   -13;
SERIES <2050:4 2050:4> YLGVML_R@HI.ADD =   -14;
SMOOTH YLGVML_R@HI.ADD = YLGVML_R@HI.ADD LINEAR;
END; ! end if nCovBase = Y


IF ('#nCovLow'=='Y');  !  Low Scen
!!                                       20Q2       Q4       21Q1    Q2   Q3      22
SERIES <2020:2 2050:4> EGVFD@HI.ADD =    .3, -.3,  -.25,     -.2, -.2, -.07, .1, .07, .03;
SERIES <2025:1 2025:4> EGVFD@HI.ADD =   .03 repeat 4, -.05;
SERIES <2030:1 2030:4> EGVFD@HI.ADD =   -.035 repeat 4;
SERIES <2050:1 2050:4> EGVFD@HI.ADD =   -.13 repeat 4;
SMOOTH EGVFD@HI.ADD = EGVFD@HI.ADD LINEAR;

!!                                       20Q2
SERIES <2020:1 2050:4> EGVFD@HON.ADD =   -.1  .009 repeat 3,        .01 repeat 4, .014;
SERIES <2050:4 2050:4> EGVFD@HON.ADD =   .016;
SMOOTH EGVFD@HON.ADD = EGVFD@HON.ADD LINEAR;

!!                                        20Q1						
SERIES <2020:1 2050:4> YLGVFD_R@HI.ADD =  -1, -4, -7, -6,   -3.5 repeat 4,  -1.5  repeat 4, -1 repeat 4, -1 repeat 4, -2 repeat *;

!!!! military get their pay raises 1st quarter every year
!SERIES <2020:1 2050:4> YLGVML_R@HI.ADD =  0, -20;
!SERIES <2050:4 2050:4> YLGVML_R@HI.ADD =   -155;
SERIES <2020:1 2050:4> YLGVML_R@HI.ADD =  0, -20, -6.5;
SERIES <2025:4 2025:4> YLGVML_R@HI.ADD =   -9, -11;
SERIES <2030:4 2030:4> YLGVML_R@HI.ADD =   -11;
SERIES <2035:4 2035:4> YLGVML_R@HI.ADD =   -8;
SERIES <2040:4 2040:4> YLGVML_R@HI.ADD =   -13;
SERIES <2050:4 2050:4> YLGVML_R@HI.ADD =   -14;
SMOOTH YLGVML_R@HI.ADD = YLGVML_R@HI.ADD LINEAR;
END; ! end if nCovLow = Y



!***************    STATE AND LOCAL GOV    ************************************
!				                        20Q2 
SERIES <2020:2 2050:4> E_GVSL@HI.ADD =  -.2, -.2;
SERIES <2050:1 2050:4> E_GVSL@HI.ADD = -0.2 REPEAT 4; 
SMOOTH E_GVSL@HI.ADD = E_GVSL@HI.ADD LINEAR;
!				                         20Q2
SERIES <2020:2 2050:4> E_GVSL@HON.ADD = -.15 REPEAT 3, -.13; 
SERIES <2050:1 2050:4> E_GVSL@HON.ADD = -0.14 REPEAT 4; 
SMOOTH E_GVSL@HON.ADD = E_GVSL@HON.ADD LINEAR;
!                                        19:3
SERIES<2019:3 2050:4> YL_GVSL_R@HI.ADD = 25, 30, 50, 50, 45, 45;
SERIES<2050:1 2050:4> YL_GVSL_R@HI.ADD = 60 REPEAT 4;
SMOOTH YL_GVSL_R@HI.ADD = YL_GVSL_R@HI.ADD LINEAR;


! ####################  GVSLHIGH
IF ('#nCovHIGH'=='Y');  !  HIGH Scen
!                                       20Q2              21              22
SERIES <2020:2 2050:4> E_GVSL@HI.pan = -.2, .2, .2,       -.1 repeat 4,    -.1 repeat 4, .005 repeat *;
SERIES <2020:2 2050:4> E_GVSL@HI.ADD =   E_GVSL@HI.ADD + 1.3*E_GVSL@HI.pan;

SERIES <2020:2 2050:4> E_GVSL@HON.pan = -.2, .15, .15,    -.1 repeat 4, -.13 repeat 4, -.025 repeat *;
SERIES <2020:2 2050:4> E_GVSL@HON.ADD =  E_GVSL@HON.ADD + E_GVSL@HON.pan;

!				                         20Q1             21Q1          22            23 
SERIES <2020:1 2050:4> YL_GVSL_R@HI.pan = -26 REPEAT 4,  -26 repeat 4, -13 repeat 4, -12 repeat 4, -10 repeat 4, -6 REPEAT *;
SERIES <2020:1 2050:4> YL_GVSL_R@HI.ADD =   YL_GVSL_R@HI.ADD + YL_GVSL_R@HI.pan;

END; ! end if nCovHIGH = Y

! ####################  GVSLBASE
IF ('#nCovBase'=='Y'); 
!                                       20Q2             21              22            23-25
SERIES <2020:2 2050:4> E_GVSL@HI.pan = -.2, -.2, -.2,  -.2 repeat 4,    -.1 repeat 4, .005 repeat 12, .008 repeat *;
SERIES <2020:2 2050:4> E_GVSL@HI.ADD =   E_GVSL@HI.ADD + 1.3*E_GVSL@HI.pan;
!
SERIES <2020:2 2050:4> E_GVSL@HON.pan = -.2, -.2, -.2,  -.185 repeat 4, -.13 repeat 4, -.025 repeat 8, -.015 REPEAT 4, -.01 REPEAT *;
SERIES <2020:2 2050:4> E_GVSL@HON.ADD =  E_GVSL@HON.ADD + E_GVSL@HON.pan;
!				                         20Q1             21Q1          22            23 
SERIES <2020:1 2050:4> YL_GVSL_R@HI.pan = -26 REPEAT 4,  -26 repeat 4, -13 repeat 4, -12 repeat 4, -10 repeat 4, -6 REPEAT *;
SERIES <2020:1 2050:4> YL_GVSL_R@HI.ADD =   YL_GVSL_R@HI.ADD + YL_GVSL_R@HI.pan;
!
END; ! end if nCovBase = Y

! ####################  GVSLLOW
IF ('#nCovLow'=='Y');  !  Low Scen
!                                       20Q2             21              22
SERIES <2020:2 2050:4> E_GVSL@HI.pan = -.2, -.2, -.2,  -.2 repeat 4,    -.1 repeat 4, .005 repeat *;
SERIES <2020:2 2050:4> E_GVSL@HI.ADD =   E_GVSL@HI.ADD + 1.3*E_GVSL@HI.pan;
!
SERIES <2020:2 2050:4> E_GVSL@HON.pan = -.2, -.2, -.2,  -.185 repeat 4, -.13 repeat 4, -.025 repeat 4, -.01 repeat 4, -.015 repeat *;
SERIES <2020:2 2050:4> E_GVSL@HON.ADD =  E_GVSL@HON.ADD + E_GVSL@HON.pan;
!				                         20Q1             21Q1          22            23 
SERIES <2020:1 2050:4> YL_GVSL_R@HI.pan = -28 REPEAT 4,  -28 repeat 4, -15 repeat 4, -13 repeat 4, -12 repeat 4, -8 REPEAT 4;
SERIES<2050:1 2050:4> YL_GVSL_R@HI.PAN = -12 REPEAT 4;
SMOOTH YL_GVSL_R@HI.PAN = YL_GVSL_R@HI.PAN LINEAR;
SERIES <2020:1 2050:4> YL_GVSL_R@HI.ADD =   YL_GVSL_R@HI.ADD + YL_GVSL_R@HI.pan;
! furlough
!                                         2020                   2021         2022                2023
!SERIES <2020:1 2050:4> YL_GVSL_R@HI.pan = -36, -280, -100, -70,  0 repeat 4,  -12, 200, 90, -20, -40, -20, -10, -5 , -2 REPEAT *;
!SERIES <2020:1 2050:4> YL_GVSL_R@HI.ADD =   YL_GVSL_R@HI.ADD + YL_GVSL_R@HI.pan;
END; ! end if nCovLow = Y



!***************    FINANCE INSURANCE AND REALESTATE    ***********************
!                                      	2020
SERIES <2020:1 2050:4>  E_FIR@HI.ADD =  .05, .06, .07, .08, .05;
SERIES <2025:4 2025:4>  E_FIR@HI.ADD =  .03;
SERIES <2030:4 2030:4>  E_FIR@HI.ADD =  .03;
SERIES <2050:4 2050:4>  E_FIR@HI.ADD =  .03 ;
SMOOTH E_FIR@HI.ADD = E_FIR@HI.ADD LINEAR;

!                                        2019                     2020
SERIES <2019:1 2020:4>  E_FIR@NBI.ADD =  -.04, -.03, .0, .01,  .015, .015, .015, .017 ;
SERIES <2030:4 2030:4>  E_FIR@NIB.ADD =  .017;
SERIES <2050:4 2050:4>  E_FIR@NBI.ADD =  .044;
SMOOTH E_FIR@NBI.ADD = E_FIR@NBI.ADD LINEAR;

SERIES <2019:1 2050:4>  YL_FIR_R@HI.ADD = 12, 8, 6, 6, 9; 
SERIES <2050:4 2050:4>  YL_FIR_R@HI.ADD = 20;
SMOOTH YL_FIR_R@HI.ADD = YL_FIR_R@HI.ADD LINEAR;

! ###############  HIGH
IF ('#nCovHIGH'=='Y'); ! ** e_fir      20Q2              21                   22
SERIES <2020:2 2050:4> E_FIR@HI.pan =  -.4, 0, .55,     .15, .05, 0, 0,     .03 repeat *;
SERIES <2020:2 2050:4> E_FIR@HI.ADD =   E_FIR@HI.ADD + E_FIR@HI.pan;
!                                       20Q2             21                        22
SERIES <2020:2 2050:4> E_FIR@NBI.pan =  0, .04, -.04,   -.015 repeat 4,  .0 repeat 4, .0 repeat 4, .005 repeat *;  
SERIES <2020:2 2050:4> E_FIR@NBI.ADD = E_FIR@NBI.ADD + E_FIR@NBI.pan;

!SERIES <1990:1 2050:4> YL_FIR_R@HI.ADD =   YL_FIR_R@HI.ADD + 65*E_FIR@HI.pan;
END; ! end if nCovHIGH = Y

! ###############  FIRBASE
IF ('#nCovBase'=='Y'); ! ** e_fir      20Q2              21                   22
SERIES <2020:2 2050:4> E_FIR@HI.pan =  -.4, -0.2, .4,   .15, .05, 0, 0,     .03 repeat 12, 0.01;
SERIES <2030:1 2030:4> E_FIR@HI.PAN =  .0 REPEAT 4;
SERIES <2050:4 2050:4> E_FIR@HI.PAN = -0.005;
SMOOTH E_FIR@HI.PAN = E_FIR@HI.PAN LINEAR;
SERIES <2020:2 2050:4> E_FIR@HI.ADD =   E_FIR@HI.ADD + E_FIR@HI.pan;
!                                       20Q2             21                        22
SERIES <2020:2 2050:4> E_FIR@NBI.pan =  0, .04, -.05,   -.02, -.02, -.02, -.015,  -.01 repeat 4, -.01 repeat 4, -.005 repeat 4;  
SERIES <2030:4 2030:4> E_FIR@NBI.PAN =  .012;
SERIES <2035:4 2035:4> E_FIR@NBI.PAN =  .01;
SERIES <2040:4 2040:4> E_FIR@NBI.PAN =  .01;
SERIES <2050:4 2050:4> E_FIR@NBI.PAN =  0.00;
SMOOTH E_FIR@NBI.PAN = E_FIR@NBI.PAN LINEAR;

SERIES <2020:2 2050:4> E_FIR@NBI.ADD = E_FIR@NBI.ADD + E_FIR@NBI.pan;

!SERIES <1990:1 2050:4> YL_FIR_R@HI.ADD =   YL_FIR_R@HI.ADD + 65*E_FIR@HI.pan;
END; ! end if nCovBase = Y

! ###############  LOW
IF ('#nCovLow'=='Y'); ! ** e_fir      20Q2              21                   22
SERIES <2020:2 2050:4> E_FIR@HI.pan =  -.4, -0.2, .5,   .15, .1, .05, 0,     .03 repeat 12, .01;
SERIES <2030:1 2030:4> E_FIR@HI.PAN =  .0 REPEAT 4;
SERIES <2050:4 2050:4> E_FIR@HI.PAN = -0.005;
SMOOTH E_FIR@HI.PAN = E_FIR@HI.PAN LINEAR;
SERIES <2020:2 2050:4> E_FIR@HI.ADD =   E_FIR@HI.ADD + E_FIR@HI.pan;

!                                       20Q2             21                        22
SERIES <2020:2 2050:4> E_FIR@NBI.pan =  0, .04, -.05,   -.02, -.02, -.02, -.015,  -.01 repeat 4, -.01 repeat 4, -.005 repeat 4;  
SERIES <2030:4 2030:4> E_FIR@NBI.PAN =  .005;
SERIES <2035:4 2035:4> E_FIR@NBI.PAN =  .005;
SERIES <2040:4 2040:4> E_FIR@NBI.PAN =  .005;
SERIES <2050:4 2050:4> E_FIR@NBI.PAN =  0.00;
SMOOTH E_FIR@NBI.PAN = E_FIR@NBI.PAN LINEAR;
SERIES <2020:2 2050:4> E_FIR@NBI.ADD = E_FIR@NBI.ADD + E_FIR@NBI.pan;

SERIES <1990:1 2050:4> YL_FIR_R@HI.ADD =   YL_FIR_R@HI.ADD;
SERIES <1925:1 2050:4> YL_FIR_R@HI.ADD =   YL_FIR_R@HI.ADD - 4;
END; ! end if nCovLow = Y



!***************    OTHER SERVICES -- `    *********************************
!                                        2020
SERIES <2020:1 2050:4>  E_ELSE@HI.ADD =   -6.65;
SERIES <2030:1 2030:1>  E_ELSE@HI.ADD =  -8.3;
SERIES <2035:1 2035:1>  E_ELSE@HI.ADD =  -10;
SERIES <2050:4 2050:4>  E_ELSE@HI.ADD =  -10.8;
SMOOTH E_ELSE@HI.ADD = E_ELSE@HI.ADD LINEAR;
!                                         2019
SERIES <2019:1 2050:4>  E_ELSE@NBI.ADD =  -.8 REPEAT 4, -1 REPEAT 4, -.85 REPEAT 4, -.99;
!SERIES <2030:1 2030:4>  E_ELSE@NBI.ADD =  -1.07;
SERIES <2050:4 2050:4>  E_ELSE@NBI.ADD =  -1.15;
SMOOTH E_ELSE@NBI.ADD = E_ELSE@NBI.ADD LINEAR;
!                                          20                    21
SERIES <2019:4 2050:4> YL_ELSE_R@HI.ADD =  -20 repeat 4, 0 repeat *;
!

! ###############  HIGH
IF ('#nCovHIGH'=='Y');
series<2000Q1 2050Q4> E_ELSE@HI.SOL = E_ELSE@HI.Q;
!                                     20Q2                 21                          22                          23                          24
series<2020Q2 2025Q4> E_ELSE@HI.SOL = 110.9, 116.8, 122.1, 127.3, 131.3, 133.3, 134.6, 134.7, 134.7, 134.9, 135.1, 135.2, 135.3, 135.5, 135.7, 135.8, 135.9, 136.1, 136.3, 136.4, 136.5, 136.7, 136.9;
series<2050Q4 2050Q4> E_ELSE@HI.SOL = 155;
SMOOTH E_ELSE@HI.SOL = E_ELSE@HI.SOL LINEAR;
!                                      20Q2                 21                    22   
SERIES <2020:2 2050:4> E_else@NBI.pan = -7.3, -1.3, -1.2,  -.3, 4, 0, 1.5,       1.1, .4, .2, .1,   .05 repeat 4, .05 repeat  4, .06 repeat *;
SERIES <2020:2 2050:4> E_ELSE@NBI.ADD =  E_ELSE@NBI.ADD + E_else@NBI.pan;

!                                   20                      21                   22   
SERIES <2020:1 2050:4> YL_ELSE_R =  100, 830, -890, -190,  -80, -40, -15 repeat 4, -5  repeat * ;
SERIES <2020:1 2050:4> YL_ELSE_R@HI.ADD =   YL_ELSE_R@HI.ADD + YL_ELSE_R;

END; ! end if nCovHIGH = Y

! ###############  BASE
IF ('#nCovBase'=='Y');
series<2000Q1 2050Q4> E_ELSE@HI.SOL = E_ELSE@HI.Q;
!                                     20Q2                 21                          22                          23                          24
series<2020Q2 2025Q4> E_ELSE@HI.SOL = 110.9, 116.8, 122.1, 127.3, 131.3, 133.3, 134.6, 134.7, 134.7, 134.9, 135.1, 135.2, 135.3, 135.5, 135.7, 135.8, 135.9, 136.1, 136.3, 136.4, 136.5, 136.7, 136.9;
series<2050Q4 2050Q4> E_ELSE@HI.SOL = 152;
SMOOTH E_ELSE@HI.SOL = E_ELSE@HI.SOL LINEAR;
!                                      20Q2                    21                    22   
SERIES <2020:2 2050:4> E_else@NBI.pan = -7.3, -2, -3,        -.4, 3.5, .5, 2.5,    1.3, .7, .6, .4,  .2 repeat 4, .05 repeat  *;
SERIES <2020:2 2050:4> E_ELSE@NBI.ADD =  E_ELSE@NBI.ADD + E_else@NBI.pan;

!                                   20                      21                   22   
SERIES <2020:1 2050:4> YL_ELSE_R =  100, 830, -670, -180,  -220, -50, -15 repeat 4, -5  repeat 4 ;
SERIES <2050:1 2050:4> YL_ELSE_R =  -10 repeat 4;
SMOOTH YL_ELSE_R = YL_ELSE_R LINEAR;
SERIES <2020:1 2050:4> YL_ELSE_R@HI.ADD =   YL_ELSE_R@HI.ADD + YL_ELSE_R;

END; ! end if nCovBase = Y

! ###############  LOW
IF ('#nCovLow'=='Y');!  ##### LOW
series<2000Q1 2050Q4> E_ELSE@HI.SOL = E_ELSE@HI.Q;
!                                     20Q2                 21                          22                          23                          24
series<2020Q2 2025Q4> E_ELSE@HI.SOL = 110.9, 108.4, 113.7, 120.1, 124.2, 126.0, 127.4, 127.5, 127.7, 127.9, 128.2, 128.2, 128.2, 128.3, 128.5, 128.5, 128.6, 128.7, 128.9, 128.9, 129.0, 129.2, 129.3, 129.5, 129.8, 130.0, 130.3;
series<2050Q4 2050Q4> E_ELSE@HI.SOL = 145;
SMOOTH E_ELSE@HI.SOL = E_ELSE@HI.SOL LINEAR;
!                                      20Q2                    21                    22   
SERIES <2020:2 2050:4> E_else@NBI.pan = -7.2,  -4.2, -4,       -1.3, 2.5, .5, 2.5,   1.3, .7, .6, .4,  .2 repeat 4, .05 repeat  *;
SERIES <2020:2 2050:4> E_ELSE@NBI.ADD =  E_ELSE@NBI.ADD + E_else@NBI.pan;
!                                   20                    21                   22   
SERIES <2020:1 2050:4> YL_ELSE_R =  100, 830, 0, -540,   -250, -170, -50 repeat 4,   -15  repeat 4;
SERIES <2050:1 2050:4> YL_ELSE_R =  0 repeat 4;
SMOOTH YL_ELSE_R = YL_ELSE_R LINEAR;
SERIES <2020:1 2050:4> YL_ELSE_R@HI.ADD =   YL_ELSE_R@HI.ADD + YL_ELSE_R;
END; ! end if nCovLow = Y




!***************    CONSTRUCTION    *******************************************

!!! check to make sure famsize forecast matches ymed@hon.a/(y@hon.sola/nr@hon.sola);
!print<2012 2016> famsize@hon.sola, ymed@hon.a/(sh_ypc@hon.sola*y@hi.sola/nr@hi.sola), YMED@HON.A, famsize@hon.sola*(sh_ypc@hon.sola*y@hi.sola)/nr@hi.sola;

! No longer use family size.  new ymedc@hon.eq

! *** INCOME SHARE ***
SERIES <2016:1 2050:4> SH_YPC@HON.ADD = .0003 repeat 3, .0004 ;
SERIES <2050:4 2050:4> SH_YPC@HON.ADD = .0004 ;
SMOOTH SH_YPC@HON.ADD = SH_YPC@HON.ADD LINEAR;


SERIES <2018:1 2050:4> YMEDC@HON.ADD =  .9, .7, .6, .5, -.2, .1, .4, .3, -.01 repeat *;

!SERIES <2019:4 2050:4> RMORT@US.ADD =  .1;
SERIES <2020:1 2050:4> RMORT@US.ADD =  .0, -.03, -.02, .0, .025, .025;
SERIES <2050:4 2050:4> RMORT@US.ADD = .0;
SMOOTH RMORT@US.ADD = RMORT@US.ADD LINEAR;


! *** MEDIAN HOME/CONDO PRICES ON OAHU ***
!                                            20                    21              22           23            24 
SERIES <2020:1 2050:4> PMKBSGF@HON.ADD =    -22, -3, -1.5, -1.3,  -2.75 repeat 4,  -6 repeat 4,  -6 repeat 4, -5 repeat 4,  -5 repeat 4, -3 repeat 8, -1 repeat 4;   

!                                          20               21              22-23          24           25
SERIES <2020:1 2049:4> PMKBCON@HON.ADD =   -5, -4, -4, -4,  -1 repeat 4,  -1 repeat 8, -1.25 repeat 4, -1 repeat * ;


! ################ HIGH
IF ('#nCovHIGH'=='Y');
!                                          20                   21                  22            23              24            25 
SERIES <2020:1 2050:4> PMKBSGF@HON.ADD =   -22, -16, -15, -10,  75, -20, -15, -0,  -8 repeat 4,  -7 repeat 4, -6 repeat 4,   -6 repeat *;   
!                                          20                  21            22             23          24           25
SERIES <2020:1 2049:4> PMKBCON@HON.ADD =   -5, -11, -11, -15,  0 repeat 4,  5 repeat 4,   -3 repeat 4, -1 repeat * ;
END; ! end if nCovHIGH = Y


! ################ BASE
IF ('#nCovBase'=='Y');
!                                          20                   21                   22             23              24            25 
SERIES <2020:1 2050:4> PMKBSGF@HON.ADD =   -22, -16, -15, -10,  105, -20, -15, -12,  -13 repeat 4,  -7 repeat 4, -5 repeat 4,   -4 repeat 4, -5;   
SERIES <2035:1 2035:4>  PMKBSGF@HON.ADD =  -3;
SERIES <2050:4 2050:4>  PMKBSGF@HON.ADD =  -10;
SMOOTH PMKBSGF@HON.ADD = PMKBSGF@HON.ADD LINEAR;
!                                          20                   21                    22             23          24           25
SERIES <2020:1 2049:4> PMKBCON@HON.ADD =   -5, -11, -11, -15,   2 repeat 4,           1 repeat 4,   -1 repeat 4, -1 repeat 4, 0 repeat * ;
END; ! end if nCovBase = Y

!!!!! ###### LOW home price
IF ('#nCovLow'=='Y');
!                                          20                   21                  22            23              24            25 
SERIES <2020:1 2050:4> PMKBSGF@HON.ADD =   -22, -16, -15, -10,  75, -20, -15, -0,  -8 repeat 4,  -7 repeat 4, -6 repeat 4,   -6 repeat *;   
!                                          20                  21            22             23          24           25
SERIES <2020:1 2049:4> PMKBCON@HON.ADD =   -5, -11, -11, -15,  0 repeat 4,  5 repeat 4,   -3 repeat 4, -1 repeat * ;
!
END; ! end if nCovLow = Y



! *** RESALES ***
SERIES <2007:1 2050:4>  KRSGF@HI.ADD =    0 REPEAT 10, 10 REPEAT 4; 
SERIES <2050:1 2050:4>  KRSGF@HI.ADD =    500 repeat 4; 
SMOOTH KRSGF@HI.ADD = KRSGF@HI.ADD LINEAR;

! *** NON RESIDENTIAL PERMITS ***            20                 21
!SERIES <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  1, -15, 13, -1;
!SERIES <2035:4 2035:4> KPPRVNRSD_R@HI.ADD =  6 ;
!SERIES <2050:4 2050:4> KPPRVNRSD_R@HI.ADD =  1.5 ;
!SMOOTH KPPRVNRSD_R@HI.ADD = KPPRVNRSD_R@HI.ADD LINEAR;

! *** RESIDENTIAL PERMITS ***		       19Q4  20              21               22              23           24         25        26
SERIES <2019:4 2050:4> KPPRVRSD_R@HI.ADD = -1,   2, 10, 3, -5,   -6, -1, -4, -8,  -7, -5 repeat 3,  -5 repeat 4, -3 repeat 4, 0 REPEAT 4,   4 REPEAT 4, 8 REPEAT 8 ;

!!!!!!!!   simulation to close Housing Gap
!SERIES <2017:1 2050:4>   RSDGAP.add =  50 repeat 20;
!SERIES KPPRVRSD_R@HI.ADD = KPPRVRSD_R@HI.ADD + RSDGAP.ADD;  

! *** GOV PERMITS ***  					19Q3    20              21	
SERIES <2019:3 2050:4> KPGOV_R@HI.ADD = 0, 0,   7, 26, 35, 45,  35, 30, 20, 10, 5, 0;
SERIES <2025:4 2025:4> KPGOV_R@HI.ADD =  0;
SERIES <2030:4 2030:4> KPGOV_R@HI.ADD =  0;
SERIES <2050:4 2050:4> KPGOV_R@HI.ADD =  0;
SMOOTH KPGOV_R@HI.ADD = KPGOV_R@HI.ADD LINEAR;

! *** CONSTRUCTION COST INDEX ***          20              21 
!SERIES <2020:1 2050:4>  PICTSGF@HON.ADD =  -5 repeat 4, -.5;
!SERIES <2050:4 2050:4>  PICTSGF@HON.ADD = -1.5;
!SMOOTH PICTSGF@HON.ADD = PICTSGF@HON.ADD LINEAR;

! *** CONTRACTING JOBS ***
!                                      19Q1                  2020                2021           2022           2023-2024     2025           2027-8         2029-30
SERIES <2019:1 2050:4> ECT@HI.ADD =    1.3, 1.4, 1.5, 1.5,   1.6, 1.2, 1, .8,  .9 repeat 4,   .7 repeat 4,    .7 repeat 8,  .8 repeat 4,   .6 repeat 8,  .3 repeat 8, .1 REPEAT *;
!		 				               2019          	    2020                  2021          2022           23-24
SERIES <2019:1 2050:4> ECT@HON.ADD =  .08, .08, .06, .03,   .04,  .04, 0.05, .05,  .04,  .0 repeat 4, .0 repeat 4,  .025 repeat 8, .06 repeat 4, .01 repeat *;

! *** TAX ***                            19Q1                               20
SERIES <2019:1 2050:4> TGBCT@HI.ADD =    185000, 150000, 130000, 110000,  -4000 repeat 4,  -6000 repeat *;

! *** INCOME ***
SERIES <2019:1 2050:4> YL_CTMI_R@HI.ADD =  7, 5, 6, 6, 6 repeat 3, 6, 4 repeat 4, 0 repeat 4, -1 repeat 4 ;   
SERIES <2050:1 2050:4> YL_CTMI_R@HI.ADD =  0 REPEAT *;
SMOOTH YL_CTMI_R@HI.ADD = YL_CTMI_R@HI.ADD LINEAR;


! ################ HIGH ************ CONTRACTING
IF ('#nCovHIGH'=='Y');  !              20             21                    22
!NON RES
!SERIES <2020:1 2050:4> KPPRVNRSD.pan =  0 repeat 4,   15, -30, -35, 0,      7, 3 repeat 3, 1 repeat 4, 0 repeat *; 
!SERIES <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  KPPRVNRSD_R@HI.ADD + KPPRVNRSD.pan;
SERIES <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  1, -15,13,-1, 14, -30.8,-35.7,-0.5,  6.6, 2.7, 2.8,2.9,  1,1.2,1.3,1.4, 0.5,0.6,0.8,0.9, 1, 1.10,1.2,1.3; 
SERIES <2028:4 2028:4> KPPRVNRSD_R@HI.ADD =  0;
SERIES <2035:4 2035:4> KPPRVNRSD_R@HI.ADD =  1.5;
SERIES <2045:4 2045:4> KPPRVNRSD_R@HI.ADD =  .75; 
SERIES <2050:4 2050:4> KPPRVNRSD_R@HI.ADD =  1;
smooth <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  KPPRVNRSD_R@HI.ADD;

! RESIDENTIAL 						  20              21                     22
SERIES <2020:1 2050:4> KPPRVRSD.pan = -5 repeat 4,    5, -10, -40, -7,     -16 repeat 4, -12 repeat 4, -8 repeat 4, -6 repeat *; 
SERIES <2020:1 2050:4> KPPRVRSD_R@HI.ADD =  KPPRVRSD_R@HI.ADD + KPPRVRSD.pan;

!GOV                                     20Q1        21             22             23             24             25
SERIES <2020:1 2050:4> KPGOV_R@HI.ADD = 7,29,35,25, 125,100,30,15,  30,25,25,25,  -30 repeat 4, -25 repeat 4, -15 repeat 4;  
SERIES <2050:4 2050:4> KPGOV_R@HI.ADD = 0;
SMOOTH KPGOV_R@HI.ADD = KPGOV_R@HI.ADD LINEAR;

!JOBS                                  20Q2             21                  22                       23
SERIES <2020:2 2050:4> ECT@HI.pan =   -4.5, 1.6, 1.2,   .9, .7, .6, .2,       .15, .15, .2, .4,         .3 repeat 4,       .3 repeat *;
SERIES <2020:1 2050:4> ECT@HI.ADD =  ECT@HI.ADD + ECT@HI.pan;
!                                      20Q2             21                    22                        23
SERIES <2020:2 2050:4> ECT@HON.pan = -3.7, 2.1, 1.2,    -.1, .02, -.55, .25,  -.05, -.05, -.05, -.05,   .1, .0 REPEAT 3,  -0.01 repeat  *;
SERIES <2020:1 2050:4> ECT@HON.ADD =  ECT@HON.ADD + ECT@HON.pan;

! *** INCOME ***
SERIES <2020:1 2050:4> YL_CTMI_R@HI.ADD =  4, 6, -6, -6, -.5 repeat 4, 0 repeat 4, -.5 repeat 4 ;   
SERIES <2050:1 2050:4> YL_CTMI_R@HI.ADD =  0 REPEAT *;
SMOOTH YL_CTMI_R@HI.ADD = YL_CTMI_R@HI.ADD LINEAR;

! *** CONSTRUCTION COST INDEX ***          20              21 
SERIES <2020:1 2050:4>  PICTSGF@HON.ADD =  -3 repeat 4, -.5 repeat 4;
!SERIES <2050:4 2050:4>  PICTSGF@HON.ADD = -1.5;
!SMOOTH PICTSGF@HON.ADD = PICTSGF@HON.ADD LINEAR;
!
END; ! end if nCovHIGH = Y


! ################ BASE ************ CONTRACTING
IF ('#nCovBase'=='Y');  
!NON RES                                     20            21                     22                  23             24               25
SERIES <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  1, -15,13,-1, 14, -30.8,-35.7,-0.5,  6.6, 2.7, 2.8,2.9,  1,1.2,1.3,1.4, 0.5,0.6,0.8,0.9, 1, 1.10,1.2,1.3; 
SERIES <2028:4 2028:4> KPPRVNRSD_R@HI.ADD =  0;
SERIES <2035:4 2035:4> KPPRVNRSD_R@HI.ADD =  1.5;
SERIES <2045:4 2045:4> KPPRVNRSD_R@HI.ADD =  .75; 
SERIES <2050:4 2050:4> KPPRVNRSD_R@HI.ADD =  1;
smooth <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  KPPRVNRSD_R@HI.ADD;

! RESIDENTIAL 						  20              21                     22                  23
SERIES <2020:1 2050:4> KPPRVRSD.pan = -5 repeat 4,    5, -10, -40, -7,     -16, -15, -14, -12,  -6 repeat 4,  -6 repeat 4, -8 repeat *; 
SERIES <2020:1 2050:4> KPPRVRSD_R@HI.ADD =  KPPRVRSD_R@HI.ADD + KPPRVRSD.pan;

!GOV                                     20Q1        21             22             23             24             25
SERIES <2020:1 2050:4> KPGOV_R@HI.ADD = 7,29,35,25, 125,100,30,15,  30,25,25,25,  -30 repeat 4, -25 repeat 4, -15 repeat 4;  
SERIES <2050:4 2050:4> KPGOV_R@HI.ADD = 0;
SMOOTH KPGOV_R@HI.ADD = KPGOV_R@HI.ADD LINEAR;

!JOBS                                  20Q2             21                  22                       23                 24
SERIES <2020:2 2050:4> ECT@HI.pan =   -4.5, .5, .5,    .9, 1, .8, .5,      .05, .1, .1, .2,         .33 repeat 4,       .3 repeat 4;
!SERIES <2030:4 2030:4> ECT@HI.PAN = .3;
!SERIES <2040:4 2040:4> ECT@HI.PAN = .5;
SERIES <2050:4 2050:4> ECT@HI.PAN = .3;
SMOOTH ECT@HI.PAN = ECT@HI.PAN LINEAR;
SERIES <2020:1 2050:4> ECT@HI.ADD =  ECT@HI.ADD + ECT@HI.pan;
!                                      20Q2             21                  22                       23
SERIES <2020:2 2050:4> ECT@HON.pan = -3.7, 1.5, .8,   .45, .4, -.4, .17,  -.17, -.11, -.1, -.05,     .12, .0 REPEAT 3,  0.01 repeat 4, .0 repeat *;
SERIES <2020:1 2050:4> ECT@HON.ADD =  ECT@HON.ADD + ECT@HON.pan;

! *** INCOME ***
SERIES <2020:1 2050:4> YL_CTMI_R@HI.ADD =  4, 6, -6, -6, -.5 repeat 4, 0 repeat 4, -.5 repeat 4 ;   
SERIES <2050:1 2050:4> YL_CTMI_R@HI.ADD =  0 REPEAT *;
SMOOTH YL_CTMI_R@HI.ADD = YL_CTMI_R@HI.ADD LINEAR;

! *** CONSTRUCTION COST INDEX ***          20              21 
SERIES <2020:1 2050:4>  PICTSGF@HON.ADD =  -3 repeat 4, -.5 repeat 4;
SERIES <2030:4 2030:4>  PICTSGF@HON.ADD = 0;
SERIES <2040:4 2040:4>  PICTSGF@HON.ADD = -.5;
SERIES <2050:4 2050:4>  PICTSGF@HON.ADD = -.5;
SMOOTH PICTSGF@HON.ADD = PICTSGF@HON.ADD LINEAR;
!
END; ! end if nCovBase = Y

! ################ LOW ************ CONTRACTING
IF ('#nCovLow'=='Y');  !              20             21                    22
!NON RES
SERIES <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  1, -15,13,-1, 14.1, -30.8,-35.7,-0.5,  6.6, 2.7, 2.8,2.9,  1,1.2,1.3,1.4, 0.5,0.6,0.8,0.9, 1, 1.10,1.2,1.3; 
SERIES <2028:4 2028:4> KPPRVNRSD_R@HI.ADD =  0; !2.7
SERIES <2035:4 2035:4> KPPRVNRSD_R@HI.ADD =  1.5; !6
SERIES <2045:4 2045:4> KPPRVNRSD_R@HI.ADD =  .75; !3
SERIES <2050:4 2050:4> KPPRVNRSD_R@HI.ADD =  1; !1.5
smooth <2020:1 2050:4> KPPRVNRSD_R@HI.ADD =  KPPRVNRSD_R@HI.ADD;

! RESIDENTIAL 						  20              21                     22
SERIES <2020:1 2050:4> KPPRVRSD.pan = -5 repeat 4,    5, -10, -40, -7,     -16 repeat 4, -12 repeat 4, -8 repeat 4, -6 repeat *; 
SERIES <2020:1 2050:4> KPPRVRSD_R@HI.ADD =  KPPRVRSD_R@HI.ADD + KPPRVRSD.pan;

!GOV                                     20Q1        21             22             23             24             25
SERIES <2020:1 2050:4> KPGOV_R@HI.ADD = 7,29,35,25, 125,100,30,15,  30,25,25,25,  -30 repeat 4, -25 repeat 4, -15 repeat 4;  
SERIES <2050:4 2050:4> KPGOV_R@HI.ADD = 0;
SMOOTH KPGOV_R@HI.ADD = KPGOV_R@HI.ADD LINEAR;

!GOV                                 2020             21               22
!SERIES <2020:1 2050:4> KPGOV.pan =   0, 3, 0, -20,    90, 70, 10, 5,   25 repeat 4, -30 repeat 4, -25 REPEAT 4,  -15 repeat *; 
!SERIES <2020:1 2050:4> KPGOV_R@HI.ADD =  KPGOV_R@HI.ADD + KPGOV.pan;

!JOBS                                  20Q2             21                  22                       23
SERIES <2020:2 2050:4> ECT@HI.pan =   -4.5, .5, .5,    .9, 1, 1, .6,       .15, .15, .2, .4,         .3 repeat 4,       .3 repeat *;
SERIES <2020:1 2050:4> ECT@HI.ADD =  ECT@HI.ADD + ECT@HI.pan;
!                                      20Q2             21                  22                       23
SERIES <2020:2 2050:4> ECT@HON.pan = -3.7, 1.5, .8,   .45, .4, -.4, .17,  -.17, -.11, -.1, -.05,     .15, .0 REPEAT 3,  -0.05 repeat 4, -.02 repeat *;
SERIES <2020:1 2050:4> ECT@HON.ADD =  ECT@HON.ADD + ECT@HON.pan;

! *** INCOME ***
SERIES <2020:1 2050:4> YL_CTMI_R@HI.ADD =  4, 6, -6, -6, -.5 repeat 4, 0 repeat 4, -.5 repeat 4 ;   
SERIES <2050:1 2050:4> YL_CTMI_R@HI.ADD =  0 REPEAT *;
SMOOTH YL_CTMI_R@HI.ADD = YL_CTMI_R@HI.ADD LINEAR;

! *** CONSTRUCTION COST INDEX ***          20              21 
SERIES <2020:1 2050:4>  PICTSGF@HON.ADD =  -3 repeat 4, -.5 repeat 4;
!SERIES <2050:4 2050:4>  PICTSGF@HON.ADD = -1.5;
!SMOOTH PICTSGF@HON.ADD = PICTSGF@HON.ADD LINEAR;

END; ! end if nCovLow = Y





!goto taxskip;
!***************************** TAXES
! 
!pause;
SET PER 1980:1 2050:4;
SET FREQ m;
!!! fill in missing months

series TDGFTEMP.m = tdgfns@hi.m;
series<2010:1 2020:6> tdgftemp.m = tdgfns@hi.m;
series <2020:1 2020:6> tdgftemp.m = 845534.4, 503444, 441968.19, 540185, 424346, 352428; ! -- submitted
!series <2020:1 2020:6> tdgftemp.m = 845534.4, 503444, 441968.19, 540185, 317027, 266999;   ! -- based on new calcs
print <2019:6 2020:6> tdgfns@hi.m, tdgftemp.m, pchya(tdgftemp.m);

set freq q;
set calendar collapse total;
set calculation missing 0;
series work:tdgftemp.q = TDGFTEMP.m;
set calculation missing 0;

series work:tdgf@hi.q = tax:tdgf@hi.q;

series<2020:1 2020:2> work:tdgf@hi.q = work:tdgf@hi.4*(1+PCHYA(tdgftemp.q)/100);
print <2019 2022> work:tdgf@hi.q, tax:tdgf@hi.q, pchya(work:tdgf@hi.q);

set report column 10; 
print <2018 2022> tax:tdgfns@hi.q/1000, work:tdgftemp.q/1000, pchya(tdgftemp.q), pchya(work:tdgf@hi.q);

SET PER 2000 2022; Print <Format=ROWS Shift Yearend=2019:2 Showend> TDGF@HI.Q/1000, PCHYA(TDGF@HI.Q) Width=8 Convert=TOTAL Annual;

!pause;
set per 1980:1 2050:4;
target taxskip;

!                                      20Q3           2021
series <2020:3 2050:4> tdgf@hi.add  =  55000, 65000, 110000, 150000, 0, 0, -9000 repeat *;
!series <2050:4 2050:4> tdgf@hi.add  =  0 repeat *;
!smooth tdgf@hi.add = tdgf@hi.add linear; 



!***************    AGRICULTURE    ********************************************

!                                       17
SERIES <2019:1 2050:4>  YLAG_R@HI.ADD =  0;
SERIES <2050:4 2050:4>  YLAG_R@HI.ADD = 0;
SMOOTH YLAG_R@HI.ADD =  YLAG_R@HI.ADD LINEAR;

!                                       19--- nbi income ends 1 yr before state
SERIES <2019:1 2050:4> YLAG_R@NBI.ADD = -.5 repeat 4, -.5 repeat 4, .0 REPEAT 4, 0 repeat *;


SERIES<2011:1 2050:4> YPJAG_R@HI.ADD = .5 REPEAT 4;
SERIES<2050:1 2050:4> YPJAG_R@HI.ADD = 3 REPEAT 4;
SMOOTH YPJAG_R@HI.ADD = YPJAG_R@HI.ADD LINEAR;

SERIES<2011:1 2050:4> YPJAG_R@NBI.ADD = .15 REPEAT 4;
SERIES<2050:1 2050:4> YPJAG_R@NBI.ADD = .12 REPEAT 4;
SMOOTH YPJAG_R@NBI.ADD = YPJAG_R@NBI.ADD LINEAR;

! ############### HIGH
IF ('#nCovHIGH'=='Y');  !              20Q1                   21           22
SERIES <2020:1 2050:4>  YLAG_R@HI.ADD =  -7, -14, -9, 0,     6, 4, 3, 3,   3 repeat 4, .25 repeat 4, 0 repeat *;

SERIES <2020:1 2050:4> YLAG_R@NBI.ADD =  2 repeat 4,         -2 repeat 4, -.6 REPEAT 4, .25 repeat 4, .05 repeat *;

END; ! end if nCovHIGH = Y

! ############### BASE
IF ('#nCovBase'=='Y');  !              20Q1                   21           22
SERIES <2020:1 2050:4>  YLAG_R@HI.ADD =  -7, -14, -9, 0,     6, 4, 3, 3,   3 repeat 4, .25 repeat 4, 0 repeat *;

SERIES <2020:1 2050:4> YLAG_R@NBI.ADD =  2 repeat 4,         -2 repeat 4, -.6 REPEAT 4, .25 repeat 4, .05 repeat *;

END; ! end if nCovBase = Y

! ############### LOW 
IF ('#nCovLow'=='Y');  !              20Q1                   21           22
SERIES <2020:1 2050:4>  YLAG_R@HI.ADD =  -7, -14, -9, 0,     6, 4, 3, 3,   3 repeat 4, .25 repeat 4, 0 repeat *;

SERIES <2020:1 2050:4> YLAG_R@NBI.ADD =  2 repeat 4,         -2 repeat 4, -.6 REPEAT 4, .25 repeat 4, .05 repeat *;

END; ! end if nCovLow = Y



!***************    MANUFACTURING    ******************************************

!                                    20Q1
SERIES <2020:1 2050:4> EMN@HI.ADD = .08 repeat *;
!                                    20Q1                  20Q2
SERIES <2020:1 2050:4> EMN@NBI.ADD = .02, -.05, .05, .03,  .023 REPEAT 4, .023 repeat *;


!!!! this equation needs to be respecified!
!                                       18
SERIES <2019:3 2050:4> YLMN_R@HI.ADD =   -9, -8, -8.7;
!SERIES <2029:4 2029:4> YLMN_R@HI.ADD =  -9.8;
SERIES <2050:4 2050:4> YLMN_R@HI.ADD =  -12;
SMOOTH YLMN_R@HI.ADD =  YLMN_R@HI.ADD LINEAR;

IF ('#nCovBase'=='Y' or '#nCovLow'=='Y' or '#nCovHIGH'=='Y');
!                                    20Q2           2021             22
SERIES <2020:2 2050:4> EMN@HI.pan = -3.1, .9, .6,  .25 repeat 4,    .05 REPEAT 4, .0 repeat *;
SERIES <2020:1 2050:4> EMN@HI.ADD =   EMN@HI.ADD + EMN@HI.pan;

SERIES <2020:2 2050:4> EMN@NBI.pan = -.65, .15, .17,  .07 REPEAT 4, .015 repeat 4, .0 repeat  *;
SERIES <2020:1 2050:4> EMN@NBI.ADD =   EMN@NBI.ADD + EMN@NBI.pan;

!                                      20Q1           2021           2022               2023
SERIES <2020:1 2050:4> YLMN_R@HI.pan = 0, 1, 7, 6,    2, 18, 1, -1,  .1, .1, .1, .2,   .7 repeat 8, .5 repeat 4;
SERIES <2030:1 2030:4> YLMN_R@HI.PAN = .1 REPEAT 4;
SERIES <2040:1 2040:4> YLMN_R@HI.PAN = .0 REPEAT 4;
SERIES <2045:1 2045:4> YLMN_R@HI.PAN = -.25 REPEAT 4;
SERIES <2050:1 2050:4> YLMN_R@HI.PAN = -.15 REPEAT 4;
SMOOTH YLMN_R@HI.PAN = YLMN_R@HI.PAN LINEAR;
SERIES <2020:1 2050:4> YLMN_R@HI.ADD =   YLMN_R@HI.ADD + YLMN_R@HI.pan;
END; ! end if nCovBase = Y






!***************    NON LABOR INCOME    ***************************************

! SOCIAL SECURITY TAX EQUATION IS NOW BEHAVIORAL AND MUST BE RE-ESTIMATED EVERY YEAR

SERIES <2017:2 2050:4> YSOCSEC@HI.ADD =  -1;
SERIES <2050:4 2050:4> YSOCSEC@HI.ADD =  50 REPEAT 4;
SMOOTH YSOCSEC@HI.ADD = YSOCSEC@HI.ADD LINEAR;

!                                       19
SERIES <2019:3 2050:4> YDIV_R@HI.ADD =  70, 65, 85, 85, 85, 80;
!SERIES <2025:1 2025:4> YDIV_R@HI.ADD =  60 ;
!SERIES <2035:1 2035:4> YDIV_R@HI.ADD =  -10;
SERIES <2050:1 2050:4> YDIV_R@HI.ADD = -75 REPEAT *;
SMOOTH YDIV_R@HI.ADD = YDIV_R@HI.ADD LINEAR;

! ################  DIvHIGH
IF ('#nCovHIGH'=='Y');  
!                                        2020                  21                     22                 23  
!SERIES <2020:1 2050:4> YDIV_R@HI.pan =  -40,  -150, -80, 30,   350, -180, -150, -80,  -60, -30, -5, -0,  5 repeat 4, 5 repeat *; 
SERIES <2020:1 2050:4> YDIV_R@HI.pan =  -40,  -150, -80, 30,   350, -180, -150, -100,  -110, -40, -5, -0,  5 repeat 4, 5 repeat *; SERIES <2020:1 2050:4> YDIV_R@HI.ADD =  YDIV_R@HI.ADD + YDIV_R@HI.pan;
END; ! end if nCovBase = Y

! ################  DivBASE
IF ('#nCovBase'=='Y');  
!                                        2020                  21                      22                   23           24
SERIES <2020:1 2050:4> YDIV_R@HI.pan =  -40,  -150, -80, 30,   360, -80, -130, -110,  -140, -80, -60, -40, -10 repeat 4, -15 repeat 4, -5 repeat *; 
SERIES <2020:1 2050:4> YDIV_R@HI.ADD =  YDIV_R@HI.ADD + YDIV_R@HI.pan;
END; ! end if nCovBase = Y

! ################  DivLOW
IF ('#nCovLow'=='Y');  
!                                        2020                  21                      22                   23            24             25
SERIES <2020:1 2050:4> YDIV_R@HI.pan =  -40,  -150, -80,  30,   360, -80, -130, -100,  -150, -90, -70, -50, -10 repeat 4, -15 repeat 4, -5 repeat 4, -10 repeat 4, -15 repeat 4, -20 REPEAT *; 
SERIES <2020:1 2050:4> YDIV_R@HI.ADD =  YDIV_R@HI.ADD + YDIV_R@HI.pan;
!
END; ! end DivLOW

!					                       2017
SERIES <2019:3 2050:4>  YTRNSF_R@HI.ADD =  -10, -5, 25, 20, 15, 4;  
SERIES <2050:4 2050:4> YTRNSF_R@HI.ADD = -17;
SMOOTH YTRNSF_R@HI.ADD = YTRNSF_R@HI.ADD LINEAR;

!                                   19Q1
SERIES <2019:1 2050:4> YS@HI.ADD =  -200, -150 repeat 3, 0 repeat 4, -50 repeat 4, -60 repeat *;
!-80 REPEAT 4, -10 REPEAT 4;


! ###################  HIGH
IF ('#nCovHIGH'=='Y');  !           2020                   21            22
!SERIES <2020:1 2050:4> YS@HI.pan = -30,  -750, -450, 100,  00 repeat 4,  1 repeat *; 
!SERIES <2020:1 2050:4> YS@HI.ADD =  YS@HI.ADD + YS@HI.pan;

! transfer payments shock

SERIES <2020:1 2050:4> YTRNSF_URonly = 200,  1730, -2080, -30,    20, 1 repeat 4,  1 repeat *; 
SERIES <2020:1 2050:4> YTRNSF_R@HI.ADD =  YTRNSF_R@HI.ADD + YTRNSF_URonly;

! TAX Rebates see ITEP.org               20Q1                    21
SERIES <2020:1 2050:4> YTRNSF_R@HI.pan =  0,  765, 0, -935,     45,  5.5 repeat 4,  1 repeat *; 
SERIES <2020:1 2050:4> YTRNSF_R@HI.ADD =  YTRNSF_R@HI.ADD + YTRNSF_R@HI.pan;
END; ! end if nCovHIGH = Y


! ###################  TRNSFBASE
IF ('#nCovBase'=='Y');  !           2020                   21            22
!SERIES <2020:1 2050:4> YS@HI.pan = -30,  -750, -450, 100,  00 repeat 4,  1 repeat *; 
!SERIES <2020:1 2050:4> YS@HI.ADD =  YS@HI.ADD + YS@HI.pan;

! transfer payments shock

SERIES <2020:1 2050:4> YTRNSF_URonly = 200,  1730, -2080, -30,    20, 1 repeat 4,  1 repeat *; 
SERIES <2020:1 2050:4> YTRNSF_R@HI.ADD =  YTRNSF_R@HI.ADD + YTRNSF_URonly;

! TAX Rebates see ITEP.org               20Q1                    21                 22-24
SERIES <2020:1 2050:4> YTRNSF_R@HI.pan =  0,  765, 0, -935,     45,  5.5 repeat 4,  1 repeat 12, -20 repeat 4, -40 repeat 4; 
SERIES <2030:1 2030:4> YTRNSF_R@HI.pan = -10 repeat 4;
SERIES <2040:1 2040:4> YTRNSF_R@HI.pan = -3 repeat 4;
SERIES <2050:1 2050:4> YTRNSF_R@HI.pan = -0 repeat 4;
SMOOTH YTRNSF_R@HI.pan = YTRNSF_R@HI.pan LINEAR;

SERIES <2020:1 2050:4> YTRNSF_R@HI.ADD =  YTRNSF_R@HI.ADD + YTRNSF_R@HI.pan;
END; ! end if nCovBase = Y


! ###################  LOW
IF ('#nCovLow'=='Y');  !           2020                   21            22
!SERIES <2020:1 2050:4> YS@HI.pan = -30,  -750, -450, 100,  00 repeat 4,  1 repeat *; 
!SERIES <2020:1 2050:4> YS@HI.ADD =  YS@HI.ADD + YS@HI.pan;

! transfer payments shock

SERIES <2020:1 2050:4> YTRNSF_URonly = 200,  1730, -2080, -30,    20, 1 repeat 4,  1 repeat *; 
SERIES <2020:1 2050:4> YTRNSF_R@HI.ADD =  YTRNSF_R@HI.ADD + YTRNSF_URonly;

! TAX Rebates see ITEP.org               20Q1                    21
SERIES <2020:1 2050:4> YTRNSF_R@HI.pan =  0,  765, 0, -935,     45,  5.5 repeat 4,  1 repeat 12, -30 repeat 4, -40 repeat 4; 
SERIES <2030:1 2030:4> YTRNSF_R@HI.pan = -10 repeat 4;
SERIES <2040:1 2040:4> YTRNSF_R@HI.pan = -3 repeat 4;
SERIES <2050:4 2050:4> YTRNSF_R@HI.pan = 0;
SMOOTH YTRNSF_R@HI.pan = YTRNSF_R@HI.pan LINEAR;
SERIES <2020:1 2050:4> YTRNSF_R@HI.ADD =  YTRNSF_R@HI.ADD + YTRNSF_R@HI.pan;


END; ! end if nCovLow = Y



!!********************************************************************************
!!   CALCULATE HISTORY OF REAL INCOME    !!!CPI@HON.SOL MUST BE IN QSOL.BNK (running solQ twice) !!!
!!********************************************************************************
!!PROBLEM: The ending period of CPI may be before the ending period of nominal income
!!As a result, the history of real income would end before the nominal income.
!

IF ('#CPIFIX'=='Y');

open<pro> #SOLBNK;
assign nom_end  from y@hi.q per2;
assign real_end from y_r@hi.q per2;

!TELL '**********************************  nomial end #NOM_END'; 
!TELL '**********************************  REAL END = #REAL_END'; 

if ('#nom_end'<>'#real_end');
  assign avail exist #SOLBNK|:CPI@HON.SOL;
!TELL '**********************************  nomial end #NOM_END'; 
!TELL '**********************************  REAL END = #REAL_END'; 
  if ('#avail'=='1');
    index y*_r@hi.q allreal;
    for myvar = #allreal;
      assign serslength  literal length('#myvar');        
      assign piece1      literal piece('#myvar',1,search('#myvar','@')-3); !anything before _R@ -> This approach is better than using strip('_R') since other series MAY have _R, which doesn't mean real.
      assign piece2      literal piece('#myvar',search('#myvar','@'),#serslength);
      assign mynom       literal concat('#piece1','#piece2');
      series work:#myvar = #BEABNK|:#myvar|.q;
      set databank modify extend; !If the program stops at the next line, this set-databank command is going to change your default. 
      series work:#myvar|.q = #BEABNK|:#mynom|.q / #SOLBNK|:cpi@hon.sol * 100;
      set databank modify update;
    end;
  end;
end;
close #SOLBNK; !bank must be closed before solving the model
END;  !  END CPIFIX;
!
!NOTE: not using this because the model is solved faster when cpi is imposed (using imposeCPI.cmd) 

IF ('#PICTFIX'=='Y');

open<pro> #SOLBNK;
assign nom_end  from KPPRVRSD@hi.q per2;
assign real_end from KPPRVRSD_r@hi.q per2;
if ('#nom_end'<>'#real_end');
  assign avail exist #SOLBNK|:PICTSGF@HON.SOL;
  if ('#avail'=='1');
    index KP*_r@hi.q allreal;
    for myvar = #allreal;
      assign serslength  literal length('#myvar');        
      assign piece1      literal piece('#myvar',1,search('#myvar','@')-3); !anything before _R@ -> This approach is better than using strip('_R') since other series MAY have _R, which doesn't mean real.
      assign piece2      literal piece('#myvar',search('#myvar','@'),#serslength);
      assign mynom       literal concat('#piece1','#piece2');
      series work:#myvar = MISC|:#myvar|.q;
      set databank modify extend; !If the program stops at the next line, this set-databank command is going to change your default. 
      series work:#myvar = MISC|:#mynom|.q / #SOLBNK|:PICTSGF@hon.sol * 100;
      set databank modify update;
    end;  ! END FOR MYVAR
  end;   ! END IF AVAIL
end;    !  END IF NOMEND
close #SOLBNK; !bank must be closed before solving the model
END;  !  END CPIFIX;

TARGET THEEND;

SET SAVEFILE SAVE NO;

!TELL "**********************************  HIGH =  #nCovHigh"; 
!TELL "**********************************  BASE =  #nCovBase"; 
!TELL "**********************************  LOW  =  #nCovLOW"; 


