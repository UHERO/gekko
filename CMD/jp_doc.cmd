
!ASSIGN DBNK LITERAL 'JP';

OPEN <PRIMARY YES> #DBNK|.BNK; 

STRUCTURE SERIES ORIGIN 'ORIGIN SOURCE OF DATA' 200 A, UNITS 20 A, FTC 1 A, TYPE 1 A; 
ASSIGN CURRFREQ CURRENT FREQUENCY;

IF ('#CURRFREQ'=='MONTHLY');   ASSIGN MYFREQ LITERAL 'M'; END;
IF ('#CURRFREQ'=='QUARTERLY'); ASSIGN MYFREQ LITERAL 'Q'; END;
IF ('#CURRFREQ'=='ANNUAL');    ASSIGN MYFREQ LITERAL 'A'; END;

    IF ('#MYFREQ'=='M' OR '#MYFREQ'=='Q');
    ASSIGN  SEASNAME   LITERAL ' (SEAS.ADJ.)';
    ELSE
    ASSIGN  SEASNAME   LITERAL '';
    END;

!*****************************

ASSIGN AVAIL EXIST CPI@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES CPI@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/cpi/index.htm', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES CPI@JP.|#MYFREQ|  'CONSUMER PRICE INDEX , JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST CPINS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES CPINS@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/cpi/index.htm', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES CPINS@JP.|#MYFREQ|  'CONSUMER PRICE INDEX , JAPAN' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST CPICORE@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES CPICORE@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/cpi/index.htm', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES CPICORE@JP.|#MYFREQ|  'CORE CONSUMER PRICE INDEX , JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST CPICORENS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES CPICORENS@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/cpi/index.htm', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES CPICORENS@JP.|#MYFREQ|  'CORE CONSUMER PRICE INDEX , JAPAN' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST INF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES INF@JP.|#MYFREQ| (ORIGIN='year-to-year percent change in Japanese CPI', UNITS='%', FTC = 'A', TYPE = '%');
SERIES INF@JP.|#MYFREQ|  'INFLATION RATE, JAPAN|#SEASNAME|' SOURCE='CALC';
END;


ASSIGN AVAIL EXIST INFCORE@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES INFCORE@JP.|#MYFREQ| (ORIGIN='year-to-year percent change in Jaoanese Core CPI', UNITS='%', FTC = 'A', TYPE = '%');
SERIES INFCORE@JP.|#MYFREQ|  'CORE INFLATION RATE, JAPAN|#SEASNAME|' SOURCE='CALC';
END;


ASSIGN AVAIL EXIST EMPL@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES EMPL@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/roudou/index.htm', UNITS='Thous', FTC = 'A', TYPE = 'L');
SERIES EMPL@JP.|#MYFREQ|  'EMPLOYMENT, JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST E_NF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES E_NF@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/roudou/index.htm', UNITS='Thous', FTC = 'A', TYPE = 'L');
SERIES E_NF@JP.|#MYFREQ|  'NONFARM JOBS, JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST LFP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES LFP@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/roudou/index.htm', UNITS='%', FTC = 'A', TYPE = '%');
SERIES LFP@JP.|#MYFREQ|  'LABOR FORCE PARTICIPATION RATE, JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST LFPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES LFPNS@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/roudou/index.htm', UNITS='%', FTC = 'A', TYPE = '%');
SERIES LFPNS@JP.|#MYFREQ|  'LABOR FORCE PARTICIPATION RATE, JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST LF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES LF@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/roudou/index.htm', UNITS='Thous', FTC = 'A', TYPE = 'L');
SERIES LF@JP.|#MYFREQ|  'LABOR FOURCE, JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST UR@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES UR@JP.|#MYFREQ| (ORIGIN='http://www.stat.go.jp/english/data/roudou/index.htm', UNITS='%', FTC = 'A', TYPE = '%');
SERIES UR@JP.|#MYFREQ|  'UNEMPLOYMENT RATE, JAPAN|#SEASNAME|' SOURCE='SBMIAC';
END;


ASSIGN AVAIL EXIST IP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES IP@JP.|#MYFREQ| (ORIGIN='http://www.meti.go.jp/english/statistics/index.html', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES IP@JP.|#MYFREQ|  'INDUSTRIAL PRODUCTION, JAPAN|#SEASNAME|' SOURCE='METI';
END;


ASSIGN AVAIL EXIST IPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES IPNS@JP.|#MYFREQ| (ORIGIN='http://www.meti.go.jp/english/statistics/index.html', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES IPNS@JP.|#MYFREQ|  'INDUSTRIAL PRODUCTION, JAPAN' SOURCE='METI';
END;


ASSIGN AVAIL EXIST IPMN@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES IPMN@JP.|#MYFREQ| (ORIGIN='http://www.meti.go.jp/english/statistics/index.html', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES IPMN@JP.|#MYFREQ|  'MANUFACTURING PRODUCTION, JAPAN|#SEASNAME|' SOURCE='METI';
END;


ASSIGN AVAIL EXIST IPMNNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES IPMNNS@JP.|#MYFREQ| (ORIGIN='http://www.meti.go.jp/english/statistics/index.html', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES IPMNNS@JP.|#MYFREQ|  'MANUFACTURING PRODUCTION, JAPAN' SOURCE='METI';
END;


ASSIGN AVAIL EXIST R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES R@JP.|#MYFREQ| (ORIGIN='http://www2.boj.or.jp/en/dlong/stat/data/cdab0720.txt', UNITS='%', FTC = 'A', TYPE = '%');
SERIES R@JP.|#MYFREQ|  'SHORT-TERM (CALL) INTEREST RATE, JAPAN' SOURCE='BOJ';
END;


ASSIGN AVAIL EXIST STKNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES STKNS@JP.|#MYFREQ| (ORIGIN='http://www2.boj.or.jp/en/dlong/etc/data/ehstock.txt', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES STKNS@JP.|#MYFREQ|  'EQUITY PRICE INDEX (NIKKEI), JAPAN' SOURCE='BOJ';
END;


ASSIGN AVAIL EXIST YXR@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES YXR@JP.|#MYFREQ| (ORIGIN='http://research.stlouisfed.org/fred2/series/EXJPUS', UNITS='Yen/Dollar', FTC = 'A', TYPE = 'L');
SERIES YXR@JP.|#MYFREQ|  'YEN-DOLLAR EXCHANGE RATE, JAPAN' SOURCE='SLFED';
END;


ASSIGN AVAIL EXIST N@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES N@JP.|#MYFREQ| (ORIGIN='http://esa.un.org/unpp/ ', UNITS='Thous', FTC = 'A', TYPE = 'L');
SERIES N@JP.|#MYFREQ|  'TOTAL POPULATION, JAPAN' SOURCE='UN';
END;


ASSIGN AVAIL EXIST N15_UN@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES N15_UN@JP.|#MYFREQ| (ORIGIN='http://esa.un.org/unpp/', UNITS='Thous', FTC = 'A', TYPE = 'L');
SERIES N15_UN@JP.|#MYFREQ|  '15+ POPULATION, JAPAN' SOURCE='UN';
END;


ASSIGN AVAIL EXIST INFGDPDEF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES INFGDPDEF@JP.|#MYFREQ| (ORIGIN='PCHYA(GDPDEF@JP)', UNITS='%', FTC = 'A', TYPE = '%');
SERIES INFGDPDEF@JP.|#MYFREQ|  'GDP DEFLATOR INFLATION RATE, JAPAN' SOURCE='CALC';
END;


ASSIGN AVAIL EXIST STK@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES STK@JP.|#MYFREQ| (ORIGIN='http://www2.boj.or.jp/en/dlong/etc/data/ehstock.txt', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES STK@JP.|#MYFREQ|  'EQUITY PRICE INDEX (NIKKEI), JAPAN|#SEASNAME|' SOURCE='BOJ';
END;


ASSIGN AVAIL EXIST YXR_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES YXR_R@JP.|#MYFREQ| (ORIGIN='YXR@JP*CPI@US/CPI@JP', UNITS='Yen/Dollar', FTC = 'A', TYPE = 'L');
SERIES YXR_R@JP.|#MYFREQ|  'YEN-DOLLAR REAL EXCHANGE RATE, JAPAN' SOURCE='CALC';
END;



ASSIGN AVAIL EXIST CSCFNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES CSCFNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/stat/', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES CSCFNS@JP.|#MYFREQ|  'CONSUMER CONFIDENCE INDEX, JAPAN' SOURCE='ESRI';
END;

ASSIGN AVAIL EXIST CSCF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES CSCF@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/stat/', UNITS='index', FTC = 'A', TYPE = 'L');
SERIES CSCF@JP.|#MYFREQ|  'CONSUMER CONFIDENCE INDEX, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


!*************************  GDP BLOCK ****************************************

ASSIGN AVAIL EXIST GDPDEF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDPDEF@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='index', FTC = 'N', TYPE = 'L');
SERIES GDPDEF@JP.|#MYFREQ|  'GDP DEFLATOR, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;

ASSIGN AVAIL EXIST GNIDEF@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNIDEF@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='index', FTC = 'N', TYPE = 'L');
SERIES GNIDEF@JP.|#MYFREQ|  'GNI DEFLATOR, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;

ASSIGN AVAIL EXIST GDPPC@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDPPC@JP.|#MYFREQ| (ORIGIN='Japan Real GDP divided by Population', UNITS='YenThous', FTC = 'A', TYPE = 'L');
SERIES GDPPC@JP.|#MYFREQ|  'PER CAPITA GDP, JAPAN|#SEASNAME|' SOURCE='CALC';
END;


ASSIGN AVAIL EXIST GNIPC@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNIPC@JP.|#MYFREQ| (ORIGIN='Japan Real GDP divided by Population', UNITS='YenThous', FTC = 'A', TYPE = 'L');
SERIES GNIPC@JP.|#MYFREQ|  'PER CAPITA GNI, JAPAN|#SEASNAME|' SOURCE='CALC';
END;


ASSIGN AVAIL EXIST GDPPC_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDPPC_R@JP.|#MYFREQ| (ORIGIN='Japan Real GDP divided by Population', UNITS='05YenThou', FTC = 'A', TYPE = 'L');
SERIES GDPPC_R@JP.|#MYFREQ|  'REAL PER CAPITA GDP, JAPAN|#SEASNAME|' SOURCE='CALC';
END;


ASSIGN AVAIL EXIST GNIPC_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNIPC_R@JP.|#MYFREQ| (ORIGIN='Japan Real GDP divided by Population', UNITS='95YenThou', FTC = 'A', TYPE = 'L');
SERIES GNIPC_R@JP.|#MYFREQ|  'REAL PER CAPITA GNI, JAPAN|#SEASNAME|' SOURCE='CALC';
END;





!---- components of GDP



!---------------------------
ASSIGN AVAIL EXIST GDP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP@JP.|#MYFREQ|  'GROSS DOMESTIC PRODUCT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDPNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDPNS@JP.|#MYFREQ|  'GROSS DOMESTIC PRODUCT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_R@JP.|#MYFREQ|  'REAL GROSS DOMESTIC PRODUCT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_RNS@JP.|#MYFREQ|  'REAL GROSS DOMESTIC PRODUCT, JAPAN' SOURCE='ESRI';
END;


!---------------------------
ASSIGN AVAIL EXIST GNI@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNI@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GNI@JP.|#MYFREQ|  'GROSS NATIONAL INCOME, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GNINS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNINS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GNINS@JP.|#MYFREQ|  'GROSS NATIONAL INCOME, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GNI_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNI_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GNI_R@JP.|#MYFREQ|  'REAL GROSS NATIONAL INCOME, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GNI_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GNI_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GNI_RNS@JP.|#MYFREQ|  'REAL GROSS NATIONAL INCOME, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_CP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CP@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_CP@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE CONSUMPTION, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_CPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CPNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_CPNS@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE CONSUMPTION, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_CP_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CP_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_CP_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE CONSUMPTION, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_CP_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CP_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_CP_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE CONSUMPTION, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_IRSP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IRSP@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IRSP@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE RESIDENTIAL INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IRSPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IRSPNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_IRSPNS@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE RESIDENTIAL INVESTMENT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IRSP_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IRSP_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IRSP_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE RESIDENTIAL INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IRSP_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IRSP_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IRSP_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE RESIDENTIAL INVESTMENT, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_INRP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_INRP@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_INRP@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE NONRESIDENTIAL INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_INRPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_INRPNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_INRPNS@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE NONRESIDENTIAL INVESTMENT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_INRP_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_INRP_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_INRP_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE NONRESIDENTIAL INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_INRP_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_INRP_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_INRP_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE NONRESIDENTIAL INVESTMENT, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_IIVP@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVP@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVP@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE CHANGES IN INVENTORIES, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IIVPNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVPNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVPNS@JP.|#MYFREQ|  'GDP COMPONENTS, PRIVATE CHANGES IN INVENTORIES, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IIVP_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVP_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVP_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE CHANGES IN INVENTORIES, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IIVP_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVP_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVP_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PRIVATE CHANGES IN INVENTORIES, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_CG@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CG@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_CG@JP.|#MYFREQ|  'GDP COMPONENTS, GOVERNMENT CONSUMPTION, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_CGNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CGNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_CGNS@JP.|#MYFREQ|  'GDP COMPONENTS, GOVERNMENT CONSUMPTION, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_CG_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CG_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_CG_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, GOVERNMENT CONSUMPTION, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_CG_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_CG_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_CG_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, GOVERNMENT CONSUMPTION, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_IFXG@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFXG@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFXG@JP.|#MYFREQ|  'GDP COMPONENTS, PUBLIC FIXED INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IFXGNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFXGNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFXGNS@JP.|#MYFREQ|  'GDP COMPONENTS, PUBLIC FIXED INVESTMENT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IFXG_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFXG_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFXG_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PUBLIC FIXED INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IFXG_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFXG_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFXG_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PUBLIC FIXED INVESTMENT, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_IIVG@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVG@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVG@JP.|#MYFREQ|  'GDP COMPONENTS, PUBLIC CHANGES IN INVENTORIES, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IIVGNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVGNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVGNS@JP.|#MYFREQ|  'GDP COMPONENTS, PUBLIC CHANGES IN INVENTORIES, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IIVG_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVG_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVG_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PUBLIC CHANGES IN INVENTORIES, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IIVG_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IIVG_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IIVG_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, PUBLIC CHANGES IN INVENTORIES, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_NX@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_NX@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_NX@JP.|#MYFREQ|  'GDP COMPONENTS, NET EXPORT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_NXNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_NXNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_NXNS@JP.|#MYFREQ|  'GDP COMPONENTS, NET EXPORT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_NX_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_NX_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_NX_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, NET EXPORT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_NX_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_NX_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_NX_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, NET EXPORT, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_EX@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_EX@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_EX@JP.|#MYFREQ|  'GDP COMPONENTS, EXPORT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_EXNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_EXNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_EXNS@JP.|#MYFREQ|  'GDP COMPONENTS, EXPORT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_EX_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_EX_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_EX_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, EXPORT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_EX_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_EX_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_EX_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, EXPORT, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_IM@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IM@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IM@JP.|#MYFREQ|  'GDP COMPONENTS, IMPORT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IMNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IMNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_IMNS@JP.|#MYFREQ|  'GDP COMPONENTS, IMPORT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IM_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IM_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IM_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, IMPORT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IM_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IM_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IM_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, IMPORT, JAPAN' SOURCE='ESRI';
END;

!---------------------------
ASSIGN AVAIL EXIST GDP_IFX@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFX@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFX@JP.|#MYFREQ|  'GDP COMPONENTS, FIXED INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IFXNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFXNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='Yenbil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFXNS@JP.|#MYFREQ|  'GDP COMPONENTS, FIXED INVESTMENT, JAPAN' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IFX_R@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFX_R@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFX_R@JP.|#MYFREQ|  'REAL GDP COMPONENTS, FIXED INVESTMENT, JAPAN|#SEASNAME|' SOURCE='ESRI';
END;


ASSIGN AVAIL EXIST GDP_IFX_RNS@JP;
IF ('#AVAIL' == '1');
DOCUMENT SERIES GDP_IFX_RNS@JP.|#MYFREQ| (ORIGIN='http://www.esri.cao.go.jp/en/sna/menu.html', UNITS='2005YenBil', FTC = 'A', TYPE = 'L');
SERIES GDP_IFX_RNS@JP.|#MYFREQ|  'REAL GDP COMPONENTS, FIXED INVESTMENT, JAPAN' SOURCE='ESRI';
END;
!---------------------------



!*************************  TANKAN BLOCK  ************************************

!IF ('#MYFREQ'<>'A'); ! NO TANKAN DATA FOR ANNUAL

FOR IND= TKBSC, TKEMP;  ! EACH INDEX
 IF ('#IND'=='TKBSC');
  ASSIGN INDNAME LITERAL 'TANKAN BUSINESS CONDITIONS DIFFUSION INDEX';
 ELSE 
  ASSIGN INDNAME LITERAL 'TANKAN EMPLOYMENT CONDITIONS DIFFUSION INDEX';
 END;
 
FOR SIZE = A,L,M,S;
 IF ('#SIZE'=='A');
  ASSIGN SIZENAME LITERAL 'ALL ENTERPRISES';
 ELSE IF ('#SIZE'=='L');
  ASSIGN SIZENAME LITERAL 'LARGE ENTERPRISES';
 ELSE IF ('#SIZE'=='M');
  ASSIGN SIZENAME LITERAL 'MEDIUM-SIZED ENTERPRISES';
 ELSE IF ('#SIZE'=='S');
  ASSIGN SIZENAME LITERAL 'SMALL ENTERPRISES';
 END; END; END; END;

FOR TYPE = NS@JP, _NS@JP, @JP, _@JP;
 IF (('#TYPE'=='NS@JP') OR ('#TYPE'=='@JP'));
  ASSIGN TYPENAME LITERAL 'ACTUAL';
 ELSE 
  ASSIGN TYPENAME LITERAL 'LAST PERIOD FORECASTED';
 END;

ASSIGN AVAIL EXIST |#IND|#SIZE|#TYPE;
IF ('#AVAIL' == '1');
DOCUMENT SERIES |#IND|#SIZE|#TYPE|.|#MYFREQ| (ORIGIN='http://www.boj.or.jp/en/theme/research/stat/tk/index.htm', UNITS='%', FTC = 'A', TYPE = '%');
SERIES |#IND|#SIZE|#TYPE|.|#MYFREQ|  '|#INDNAME|, |#SIZENAME|, ALL INDUSTRIES, |#TYPENAME|.' SOURCE='BOJ';
END;

ASSIGN AVAIL EXIST |#IND|#SIZE|MN|#TYPE;
IF ('#AVAIL' == '1');
DOCUMENT SERIES |#IND|#SIZE|MN|#TYPE|.|#MYFREQ| (ORIGIN='http://www.boj.or.jp/en/theme/research/stat/tk/index.htm', UNITS='%', FTC = 'A', TYPE = '%');
SERIES |#IND|#SIZE|MN|#TYPE|.|#MYFREQ|  '|#INDNAME|, |#SIZENAME|, MANUFACTURING, |#TYPENAME|.' SOURCE='BOJ';
END;

ASSIGN AVAIL EXIST |#IND|#SIZE|NM|#TYPE;
IF ('#AVAIL' == '1');
DOCUMENT SERIES |#IND|#SIZE|NM|#TYPE|.|#MYFREQ| (ORIGIN='http://www.boj.or.jp/en/theme/research/stat/tk/index.htm', UNITS='%', FTC = 'A', TYPE = '%');
SERIES |#IND|#SIZE|NM|#TYPE|.|#MYFREQ|  '|#INDNAME|, |#SIZENAME|, NONMANUFACTURING, |#TYPENAME|.' SOURCE='BOJ';
END;

END; !TYPE
END; !SIZE
END; !IND
!END; !IF ('#MYFREQ'<>'A');


!***************************** END TANKAN BLOCK *******************************





!*****************************

OPEN <PROTECT YES> #DBNK;
TELL "REPORT: END OF JP_DOC.CMD";


