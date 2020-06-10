'*************************
' SETUP
'*************************

cd "i:\forecast\moddev\" 	'set working directory
output(t,o) out 	'direct the output of text and tables to a text file that gets overwritten
close @objects  	'close all open objects to reduce clutter...
'wfclose(noerr) *

!forecastend = 2060 'last year of the forecast period
%import = "BNK"		'set to either N (if using existing wf), BNK or XLS
%dump_to_xls = "Y" 	'save to xls? "Y" or "N"

'*************************
' IMPORT
'*************************

if %import = "BNK" then

	wfcreate(wf = usfcst, page = usq) q 1950 !forecastend 'store quarterly data
	fetch(d="dbnk\us.bnk") n@us.q lf@us.q lfp@us.q ur@us.q empl@us.q gdp_r@us.q gdppc_r@us.q cpi@us.q 	'quarterly history from aremos banks
	rename *us *us_q 	'eviews drops the frequency identifies during import
	copy *us_q *us_solq 	'make a copy of the series for forecasts
	pagesave(t=excel) "dbnk\ltpdata_usq.xls" 'export all series

	pagecreate(page = usa) a 1950 !forecastend 'store annual data	
	fetch(d="dbnk\us.bnk") n@us.a lf@us.a lfp@us.a ur@us.a empl@us.a gdp_r@us.a gdppc_r@us.a cpi@us.a 	'annual history from aremos banks
	rename *us *us_a 	'eviews drops the frequency identifies during import
	copy *us_a *us_sola 	'make a copy of the series for forecasts
	pagesave(t=excel) "dbnk\ltpdata_usa.xls" 'export all series

endif 

if %import = "XLS" then

	wfopen usfcst 	'open existing workfile
	delete * 		'delete all objects in the workfile
	pageload(wf = usfcst, page = usq) "dbnk\ltpdata_usq.xls" 	'load quarterly data
	pageload(wf = usfcst, page = usa) "dbnk\ltpdata_usa.xls" 	'load annual data
	
endif

'*************************
' POPULATION
'*************************

pageselect usa 		'make the annual page active
	
	smpl @all 			'reset sample
	
	'Use Census projections
	'https://www2.census.gov/programs-surveys/popproj/datasets/2017/2017-popproj/np2017_d1.csv
	'updated with recent history (need for splines): https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/national/asrh/nc-est2017-agesex-res.csv
	'
	'
	'
'	series ncen_us_est 	'declare series
'	smpl 2010 2017 		'estimated history from Census
'	ncen_us_est.fill(s) 308745538,308758105,309338421,311644280,313993272,316234505,318622525,321039839,323405935,325719178
'	'
'	'average difference during the overlap is (207,994+278,422)/2
	'
	series ncen_us_sola 	'declare series
	smpl 2016 2060 		'projection span from Census, if necessary fill in history so that growth rates can be calculated
	ncen_us_sola.fill(s) 323127513,325511184,327891911,330268840,332639102,334998398,337341954,339665118,341963408,344234377,346481182,348695115,350872007,353008224,355100730,357147329,359146709,361098559,363003410,364862145,366676312,368447857,370178704,371871238,373527973,375151805,376746115,378314343,379860859,381390297,382907447,384415207,385917628,387418788,388922201,390430803,391947055,393472783,395009307,396557404,398117875,399690963,401276590,402874337,404483055 			
	'fill series with Census projections, if necessary fill in history so that growth rates can be calculated
	smpl @all 			'reset sample
	'
	'
	'

	ncen_us_sola = ncen_us_sola/1000 	'scale by 1000

	smpl @all 			'reset sample
	copy(o,c=q) usa\ncen_us_sola usq\n_us_solqtemp 	'interpolate annual series

	delete ncen_us_sola 	'delete temporary series

pageselect usq 		'make the quarterly page active

	smpl @all 			'reset sample

	'start addfactor transition level
	
	print n_us_q n_us_solqtemp 	'compare history and interpolated values
	%lastobs = n_us_q.@last 'end of history
	scalar n_us_solqaddif = @elem(n_us_q, %lastobs) - @elem(n_us_solqtemp, %lastobs) 	'addfactor based on difference of history and interpolated values at the end of history
	smpl {%lastobs} !forecastend 	'set sample for forecast
	n_us_solq = n_us_solqtemp + n_us_solqaddif 	'forecast is interpolated series + addfactor

	'end addfactor transition level

	'start addfactor transition growth

	smpl @all 			'reset sample
	series n_us_solqpcha = @pcha(n_us_solq) 	'calculate annual growth rate
	print @pcha(n_us_q) n_us_solqpcha

	'
	'
	'
	series n_us_solqpchaadd = 0 	'declare series
	%lastobs = n_us_q.@last 	'end of history 18Q2
	smpl {%lastobs}+1 {%lastobs}+80
	n_us_solqpchaadd.fill(s,l) na 	'add factor based on judgement
	smpl {%lastobs}+1 {%lastobs}+4
' 	n_us_solqpchaadd.fill(s) -0.0002, -0.0006, -0.0009, -0.0009
	n_us_solqpchaadd.fill(s,l) -0.002
' 	smpl {%lastobs}+1 {%lastobs}+10
' 	n_us_solqpchaadd.fill(s,l) -0.002
 	'add factor based on judgement
	smpl @all 			'reset sample
	n_us_solqpchaadd.ipolate(type = lin) n_us_solqpchaaddint 	
	copy(o) n_us_solqpchaaddint n_us_solqpchaadd 	'extend history with interpolated values
	'
	'
	'

	%lastobs = n_us_q.@last 	'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	n_us_solq = n_us_solq(-1)*(1+n_us_solqpcha+n_us_solqpchaadd)^0.25 	'extend history using growth rate

	'end addfactor transition growth

	smpl @all 			'reset sample
	print n_us_solqaddif 	'value of addfactor
	print @pcha(n_us_solq) n_us_solq n_us_solqtemp n_us_solqpcha n_us_solqpchaadd 	'compare forecast and interpolated values after addfactoring
	copy(o,c=a) usq\n_us_solq usa\n_us_solatemp 	'aggregate quarterly series after addfactoring

	delete n_us_solqtemp n_us_solqaddif n_us_solqpcha n_us_solqpchaaddint n_us_solqpchaadd		'delete temporary series

pageselect usa 		'make the annual page active

	smpl @all 			'reset sample

	%lastobs = n_us_a.@last 'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	n_us_sola = n_us_solatemp 	'extend history with aggregated values
	smpl @all 			'reset sample

	delete n_us_solatemp 		'delete temporary series

	'calculate the 16+ US population based on: 
	'Use Census projections
	'https://www2.census.gov/programs-surveys/popproj/datasets/2017/2017-popproj/np2017_d1.csv
	'updated with recent history (need for splines): https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/national/asrh/nc-est2017-agesex-res.csv
	'
	'
	'
	series n16_us_a 	'declare series
	smpl 2010 2017 		'data span of recent history
	n16_us_a.fill(s) 243906873,246315892,248735191,251016036,253402603,255788180,258228041,260583066
	'
	'average difference during the overlap (2016-17) is (272,588+272,511)/2 = 272,550
	'
	series n16_us_sola 	'declare series
	smpl 2016 2060 		'data span of recent history combined with Census projections
	n16_us_sola.fill(s) 257955453,260310555,262550200,264792059,267049286,269282525,271511472,273756663,275962588,278018690,280054931,282067427,284005393,285905941,287783531,289630116,291415785,293243240,295043303,296814180,298553605,300259159,301929123,303562429,305158790,306719083,308245025,309738427,311201577,312637235,314048806,315438493,316810301,318168975,319519290,320865864,322213035,323564510,324923129,326291095,327670395,329062335,330468057,331888253,333322800	
	'fill series with recent history and Census data
	n16_us_sola = n16_us_sola + 272550	'adjust by the difference
	smpl 2010 2017 		'data span of recent history
	n16_us_sola = n16_us_a	'fill in history
	smpl @all 			'reset sample
	'
	'
	'

	n16_us_sola = n16_us_sola/1000 	'scale by 1000

	'the denominator for the lfp calculation should be non-institutional 16+ (http://www.bls.gov/web/empsit/cpseea01.htm)
	'the difference between 16+ and non-institutional 16+ is about 5.5 Million (CHECK THIS)

	'
	'
	'
	smpl 2010 2018 	'set sample to history
	series n16ni_us_a 	'variable for actual non-institutional 16+ history
	n16ni_us_a.fill(s) 237829,239618,243284,245679,247947,250801,253538,255079,257791		'fill in values of actual non-institutional 16+
	smpl @all 			'reset sample
	print  @pch(n16_us_sola) @pch(n16ni_us_a) n16_us_sola n16ni_us_a n16_us_sola-n16ni_us_a 	'check the difference, should be close to 5.5 Million 
	'
	'
	'

	'start addfactor transition level

	%lastobs = n16ni_us_a.@last 'end of history
	scalar n16ni_us_solaaddif = @elem(n16ni_us_a, %lastobs) - @elem(n16_us_sola, %lastobs) 	'addfactor based on difference above

	smpl @all 			'reset sample
	copy(o) n16ni_us_a n16ni_us_sola 	'initialize variable with a copy of non-institutional 16+ 
	smpl {%lastobs} !forecastend 	'set sample for forecast
	n16ni_us_sola = n16_us_sola + n16ni_us_solaaddif 	'apply addfactor

	'end addfactor transition level

	'start addfactor transition growth

	smpl @all 			'reset sample
	series n16ni_us_solapch = @pch(n16ni_us_sola) 	'calculate annual growth rate

	'
	'
	'
	smpl @all 			'reset sample
	series n16ni_us_solapchadd = 0 	'declare series
	'smpl {%lastobs}+1 {%lastobs}+20
	'n16ni_us_solapchadd.fill(s,l) na 	'add factor based on judgement
	'smpl {%lastobs}+1 {%lastobs}+1
	'n16ni_us_solapchadd.fill(s) 0 	'add factor based on judgement
	'smpl @all 			'reset sample
	n16ni_us_solapchadd.ipolate(type = lin) n16ni_us_solapchaddint 	
	copy(o) n16ni_us_solapchaddint n16ni_us_solapchadd 	'extend history with interpolated values
	'
	'
	'

	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	n16ni_us_sola = n16ni_us_sola(-1)*(1+n16ni_us_solapch+n16ni_us_solapchadd) 	'extend history using growth rate from Census projection

	'end addfactor transition growth

	smpl @all 			'reset sample
	print n16ni_us_solaaddif  	'check if the difference is similar to the 5.5 Million assumed above
	print n16ni_us_sola @pch(n16ni_us_sola) n16ni_us_a
	copy(o,c=q) usa\n16ni_us_sola usq\n16ni_us_solq 	'interpolate annual series

	delete n16ni_us_solaaddif n16ni_us_solapch n16ni_us_solapchadd n16ni_us_solapchaddint		'delete temporary series

'*************************
' LABOR FORCE
'*************************

	'this section contains three stages: 1) lfp, 2) lf, 3) recalculate lfp with addfactored lf
	'use labor force participation rates from: 
	'https://www.bls.gov/spotlight/2016/a-look-at-the-future-of-the-us-labor-force-to-2060/home.htm
	'additional info:
	'https://www.bls.gov/opub/mlr/2017/article/projections-overview-and-highlights-2016-26.htm
	'https://www.frbsf.org/economic-research/publications/economic-letter/2018/november/us-labor-force-participation-rate-trend-projection/

	series lfp_us_solatemp = lf_us_a/n16ni_us_sola*100 	'calculate lfp estimate
	print lfp_us_solatemp lfp_us_a lfp_us_solatemp-lfp_us_a 	'compare the calculated lfp to actual lfp history
	'compare to http://data.bls.gov/timeseries/LNS11300000
	'the lfp_us_a numbers should equal to the annual averages at the link above

	'calculate the lfp rates based on the bls study and apply add factors: https://www.bls.gov/spotlight/2016/a-look-at-the-future-of-the-us-labor-force-to-2060/pdf/a-look-at-the-future-of-the-us-labor-force-to-2060.pdf
' 	https://www.bls.gov/opub/mlr/2019/article/projections-overview-and-highlights-2018-28.htm
' 2018: 62.9%, 2028: 61.2%
' history: 2016-17: 62.78%, 62.86%

	'
	'
	'
	series lfp_us_solabls1 	'declare series, data from table at link under chart: https://www.bls.gov/spotlight/2016/a-look-at-the-future-of-the-us-labor-force-to-2060/
' 	smpl 2016 2060
' 	lfp_us_solabls1.fill(s) 62.4,62.2,62.0,61.75,61.5,61.3,61.1,60.85,60.6,60.4,60.2,60.0,59.8,59.6,59.4,59.2,59.0,58.9,58.8,58.6,58.5,58.4,58.4,58.3,58.3,58.2,58.2,58.1,58.1,58.1,58.0,58.0,58.0,57.9,57.9,57.8,57.7,57.6,57.6,57.5,57.4,57.3,57.2,57.1,57.0
	smpl 2016 2018
	lfp_us_solabls1.fill(s) 62.4,62.2,62.0
	smpl 2030 2030
	lfp_us_solabls1.fill(s) 59.4
	smpl 2040 2040
	lfp_us_solabls1.fill(s) 58.3
	smpl 2050 2050
	lfp_us_solabls1.fill(s) 57.9
	smpl 2060 2060
	lfp_us_solabls1.fill(s) 57.0
	smpl @all
	lfp_us_solabls1.ipolate(cb) lfp_us_solabls1_int
	series lfp_us_solabls2 	'declare series
	smpl 2016 2018
	lfp_us_solabls2.fill(s) 62.78,62.86,62.86
	smpl 2028 2028
	lfp_us_solabls2.fill(s) 61.2
	smpl 2016 2028
	series lfp_us_solabls_add = lfp_us_solabls2 - lfp_us_solabls1_int
	lfp_us_solabls_add.ipolate(type = lin) lfp_us_solabls_addint
	smpl 2028 2060
	lfp_us_solabls_addint = lfp_us_solabls_addint(-1)
	smpl 2016 2060
	series lfp_us_solabls = lfp_us_solabls1_int + lfp_us_solabls_addint
	smpl @all
	'
	'
	'	

	'start addfactor transition level

	%lastobs = lfp_us_solatemp.@last 'end of history
	scalar lfp_us_solaaddif = @elem(lfp_us_solatemp, %lastobs) - @elem(lfp_us_solabls, %lastobs) 	'addfactor based on difference

	smpl @all 			'reset sample
	copy(o) lfp_us_solatemp lfp_us_sola 	'initialize variable with a copy of non-institutional 16+ 
	smpl {%lastobs} !forecastend 	'set sample for forecast
	lfp_us_sola = lfp_us_solabls + lfp_us_solaaddif 	'apply addfactor

	'end addfactor transition level

	'start addfactor transition growth

	smpl @all 			'reset sample
	series lfp_us_solapch = @pch(lfp_us_sola) 	'calculate annual growth rate

	'
	'
	'
	smpl @all 			'reset sample
	series lfp_us_solapchadd = 0 	'declare series
	'smpl {%lastobs}+1 {%lastobs}+20
	'lfp_us_solapchadd.fill(s,l) na 	'add factor based on judgement
	'smpl {%lastobs}+1 {%lastobs}+1
	'lfp_us_solapchadd.fill(s) 0 	'add factor based on judgement
	'smpl @all 			'reset sample
	lfp_us_solapchadd.ipolate(type = lin) lfp_us_solapchaddint 	
	copy(o) lfp_us_solapchaddint lfp_us_solapchadd 	'extend history with interpolated values
	'
	'
	'

	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	lfp_us_sola = lfp_us_sola(-1)*(1+lfp_us_solapch+lfp_us_solapchadd) 	'extend history using growth rate from Census projection

	'end addfactor transition growth

	smpl @all 			'reset sample
	print lfp_us_a lfp_us_sola lfp_us_solatemp 	'compare forecast to interpolated series
	'copy(o,c=q) usa\lfp_us_sola usq\lfp_us_solqtemp 	'interpolate annual series
	copy(o,c=cubicf) usa\lfp_us_sola usq\lfp_us_solqtemp 	'interpolate annual series

	delete lfp_us_solatemp lfp_us_solabls lfp_us_solaaddif lfp_us_solapchadd lfp_us_solapchaddint lfp_us_solabls_add lfp_us_solabls2 lfp_us_solabls1 lfp_us_solabls1_int lfp_us_solabls_addint  	'delete temporary series

pageselect usq 		'make the quarterly page active

	smpl @all 			'reset sample

	'start addfactor transition level

	%lastobs = lfp_us_q.@last 'end of history
	scalar lfp_us_solqaddif = @elem(lfp_us_q, %lastobs) - @elem(lfp_us_solqtemp, %lastobs) 	'addfactor based on difference
	series lfp_us_solqadd = 0
	
	'
	'
	'
	'smpl {%lastobs}+1 {%lastobs}+5 	'18Q3-
	'lfp_us_solqadd.fill(s) 0  	'add factor based on judgement
	'smpl {%lastobs}+5 !forecastend
	'lfp_us_solqadd.fill(s,l) 0 	'add factor based on judgement
	'smpl {%lastobs}+1 !forecastend
	'lfp_us_solqadd = lfp_us_solqadd-0 	'adjust magnitude if necessary
	'smpl @all 			'reset sample
 	'add factor based on judgement
	'smpl @all 			'reset sample
	'lfp_us_solqadd.ipolate(type = cs, tension = 0.8) lfp_us_solqaddint 	
	'lfp_us_solqadd.ipolate(type = lin) lfp_us_solqaddint 	
	'copy(o) lfp_us_solqaddint lfp_us_solqadd 	'extend ur history with interpolated values
	'
	'
	'
	
	smpl {%lastobs} !forecastend 	'set sample for forecast
	lfp_us_solq = lfp_us_solqtemp + lfp_us_solqaddif + lfp_us_solqadd 	'apply addfactor

	'end addfactor transition level

	'start addfactor transition growth

	smpl @all 			'reset sample
	series lfp_us_solqpcha = @pcha(lfp_us_solq) 	'calculate annual growth rate
	series lfp_us_solqpchaadd = 0 	'declare series

	'
	'
	'
	smpl {%lastobs}+1 {%lastobs}+15 	'18Q4-
	lfp_us_solqpchaadd.fill(s,l) na  	'add factor based on judgement
	'smpl {%lastobs}+1 {%lastobs}+1 		'18Q4-
	'lfp_us_solqpchaadd.fill(s) 0.005  	'add factor based on judgement
	smpl {%lastobs}+1 {%lastobs}+4 		'18Q4-
' 	lfp_us_solqpchaadd.fill(s) 0.003  	'add factor based on judgement
' 	lfp_us_solqpchaadd.fill(s) 0.001  	'add factor based on judgement
	lfp_us_solqpchaadd.fill(s) -0.015, -0.012, -0.006, -0.003   	'add factor based on judgement
	smpl {%lastobs}+5 {%lastobs}+10 		'18Q4-
	lfp_us_solqpchaadd.fill(s) -0.001, 0, 0.001, 0.002, 0.004, 0.008   	'add factor based on judgement
	smpl @all 			'reset sample
	lfp_us_solqpchaadd.ipolate(type = lin) lfp_us_solqpchaaddint 	
	copy(o) lfp_us_solqpchaaddint lfp_us_solqpchaadd 	'extend history with interpolated values
	'
	'
	'

	smpl @all 			'reset sample
	copy(o) lfp_us_q lfp_us_solq 	'initialize forecast with history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	lfp_us_solq = lfp_us_solq(-1)*(1+lfp_us_solqpcha+lfp_us_solqpchaadd)^0.25 	'extend history using growth rate

	'end addfactor transition growth

	smpl @all 			'reset sample
	print lfp_us_solqaddif
	print lfp_us_q lfp_us_solqadd lfp_us_solqtemp lfp_us_solq @pcha(lfp_us_solq) 	'check forecast after addfactoring
	copy(o,c=a) usq\lfp_us_solq usa\lfp_us_solatemp 	'aggregate quarterly series after addfactoring

	delete(noerr) lfp_us_solqaddint lfp_us_solqadd lfp_us_solqaddif lfp_us_solqtemp lfp_us_solqpcha lfp_us_solqpchaadd lfp_us_solqpchaaddint 		'delete temporary series
	
pageselect usa 		'make the annual page active

	smpl @all 			'reset sample

	%lastobs = lfp_us_a.@last 'end of history
	copy(o) lfp_us_a lfp_us_sola 	'initialize forecast with history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	lfp_us_sola = lfp_us_solatemp 	'extend history with aggregated values
	smpl @all 			'reset sample

	delete lfp_us_solatemp

	'obtain lf forecast based on lfp forecast

pageselect usq 		'make the quarterly page active

	smpl @all 			'reset sample

	series lf_us_solqtemp = lfp_us_solq/100*n16ni_us_solq 	'obtain lf forecasts

	'start addfactor transition level

	%lastobs = lf_us_q.@last 'end of history
	scalar lf_us_solqaddif = @elem(lf_us_q, %lastobs) - @elem(lf_us_solqtemp, %lastobs) 	'addfactor based on difference
	series lf_us_solqadd = 0

	'
	'
	'
	'smpl XX XX
	'lf_us_solqadd.fill(s) 	'add factor based on judgement
	'smpl @all 			'reset sample
	'
	'
	'

	smpl {%lastobs} !forecastend 	'set sample for forecast
	lf_us_solq = lf_us_solqtemp + lf_us_solqaddif + lf_us_solqadd 	'apply addfactor

	'end addfactor transition level
	
	'start addfactor transition growth

	smpl @all 			'reset sample
	series lf_us_solqpcha = @pcha(lf_us_solq) 	'calculate annual growth rate
	series lf_us_solqpchaadd = 0 	'declare series

	'
	'
	'
	'smpl {%lastobs}+1 {%lastobs}+1
	'lf_us_solqpchaadd.fill(s) -0.001 	'add factor based on judgement
	'smpl @all 			'reset sample
	'lf_us_solqpchaadd.ipolate(type = lin) lf_us_solqpchaaddint 	
	'copy(o) lf_us_solqpchaaddint lf_us_solqpchaadd 	'extend history with interpolated values
	'
	'
	'

	'smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	'lf_us_solq = lf_us_solq(-1)*(1+lf_us_solqpcha+lf_us_solqpchaadd)^0.25 	'extend history using growth rate

	'end addfactor transition growth

	smpl @all 			'reset sample
	print lf_us_solqaddif
	print  @pcha(lf_us_solq) lf_us_solq lf_us_solqtemp lf_us_solqadd 	'check forecast after addfactoring
	copy(o,c=a) usq\lf_us_solq usa\lf_us_solatemp 	'aggregate quarterly series after addfactoring

	delete(noerr) lf_us_solqadd lf_us_solqaddif lf_us_solqpcha lf_us_solqpchaadd lf_us_solqpchaaddint lf_us_solqtemp 	'delete temporary series
	
'	%lastobs = lfp_us_q.@last 	'end of history
'	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
'	lfp_us_solq = lf_us_solq/n16ni_us_solq*100 	'recalculate lfp using lf forecast
'	smpl @all 			'reset sample

	'delete n16ni_us_solq 	'delete temporary series

pageselect usa 		'make the annual page active

	smpl @all 			'reset sample

	%lastobs = lf_us_a.@last 	'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	lf_us_sola = lf_us_solatemp 	'extend history with aggregated values
	smpl @all 			'reset sample
	
'	%lastobs = lfp_us_a.@last 	'end of history
'	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
'	lfp_us_sola = lf_us_sola/n16ni_us_sola*100 	'recalculate lfp using lf forecast
'	smpl @all 			'reset sample

	delete lf_us_solatemp 'n16ni_us_sola 	'delete temporary series

'*************************
' UNEMPLOYMENT RATE AND EMPLOYMENT
'*************************

pageselect usq 		'make the quarterly page active

	smpl @all 			'reset sample

	'
	'
	'
	smpl 2025 !forecastend 	'long end
	ur_us_solq = 4.3 	'nairu
	smpl 2020q2 2020q4 	'short term
	'ur_us_solq.fill(s) 3.75, 3.7, 3.65, 3.65 	'ur values based on judgement (addfactor)
	'ur_us_solq.fill(s) 3.75, 3.75, 3.77, 3.8 	'ur values based on judgement (addfactor)
' 	ur_us_solq.fill(s) 3.55, 3.6, 3.65, 3.7 	'ur values based on judgement (addfactor)
' 	ur_us_solq.fill(s) 3.6, 3.8, 4.3, 4.8 	'ur values based on judgement (addfactor)
' 	ur_us_solq.fill(s) 4, 10, 8, 6.5 	'ur values based on judgement (addfactor)
	ur_us_solq.fill(s) 14, 11.5, 10 	'ur values based on judgement (addfactor)
	smpl 2021q1 2021q4 	'short term
' 	ur_us_solq.fill(s) 5.1, 5.2, 5.2, 5.1 	'ur values based on judgement (addfactor)
' 	ur_us_solq.fill(s) 6.0, 5.8, 5.6, 5.4 	'ur values based on judgement (addfactor)
	ur_us_solq.fill(s) 8.0, 7, 6.5, 6 	'ur values based on judgement (addfactor)
	'
	'
	'

	smpl @all 			'reset sample
	'interpolate the ur series
	'ur_us_solq.ipolate(type = cb) ur_us_solqint
	ur_us_solq.ipolate(type = lin) ur_us_solqint 	
	'ur_us_solq.ipolate(type = cs, tension = 0.99) ur_us_solqint 	
	copy(o) ur_us_solqint ur_us_solq 	'extend ur history with interpolated values

	%lastobs = empl_us_q.@last 	'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	empl_us_solq = (1-ur_us_solq/100)*lf_us_solq 	'obtain employment forecast

	smpl @all
	copy(o,c=a) usq\ur_us_solq usa\ur_us_sola 	'aggregate quarterly series
	copy(o,c=a) usq\empl_us_solq usa\empl_us_sola 	'aggregate quarterly series

	delete ur_us_solqint 	'delete temporary series

'*************************
' PRODUCTIVITY AND GDP
'*************************


	'
	'
	'
' 	'cludge fix
' 	smpl 2019q4 2019q4
' 	gdp_r_us_q = gdp_r_us_q(-1) * 1.021^0.25
' 	gdp_r_us_solq = gdp_r_us_solq(-1) * 1.021^0.25
' 	smpl @all
	'
	'
	'
	
	series prod_us_q = gdp_r_us_q/empl_us_q 	'calculate historical productivity
	series prod_us_qpca = @pca(prod_us_q) 		'calculate historical productivity growth
	copy(o) prod_us_q prod_us_solq 	'make a copy of the series for forecasts
	copy(o) prod_us_qpca prod_us_solqpca 	'make a copy of the series for forecasts
	print prod_us_qpca (@exp((@log(prod_us_q)-@lag(@log(prod_us_q),40))/10)-1)*100 (@exp((@log(prod_us_q)-@lag(@log(prod_us_q),80))/20)-1)*100 (@exp((@log(prod_us_q)-@lag(@log(prod_us_q),120))/30)-1)*100 	'moving averages of 10, 20, and 30 year annual productivity growth

	'
	'
	'
	'productivity growth values based on judgment (addfactor)
'	smpl 2018q4 2018q4
'	prod_us_solqpca.fill(s) 0.25
' 	smpl 2019q4 2019q4
' '	prod_us_solqpca.fill(s) 1.8, 1.7, 1.6, 1.5
' 	prod_us_solqpca.fill(s) -0.1
	smpl 2020q2 2020q4
'	prod_us_solqpca.fill(s) 1.45, 1.4, 1.4, 1.4
' 	prod_us_solqpca.fill(s) 0.9, 1.2, 1.1, 1.3
' 	prod_us_solqpca.fill(s) -0.2, -0.2, 0.6, 1.2
' 	prod_us_solqpca.fill(s) -0.2, -8.2, 0.5, 3.5
' 	prod_us_solqpca.fill(s) -9, 0.5, 3.5
	prod_us_solqpca.fill(s) 6, -1, 1
	smpl 2021q1 2021q4
	prod_us_solqpca.fill(s) 1.2, 1.4, 1.5, 1.6
	smpl 2022q1 2022q4
	prod_us_solqpca.fill(s) 1.6, 1.5, 1.4, 1.3
	smpl 2023q1 2023q4
	prod_us_solqpca.fill(s) 1.2, 1.2, 1.2, 1.2
	smpl 2024q1 !forecastend
	prod_us_solqpca.fill(s, l) 1.2

	'smpl 2017q3 !forecastend
	'prod_us_solqpca.fill(s, l) 1.4
	'
	'
	'

	'interpolate the productivity series
	'prod_us_solqpca.ipolate(type = cb) prod_us_solqpcaint
	prod_us_solqpca.ipolate(type = lin) prod_us_solqpcaint 	
	'prod_us_solqpca.ipolate(type = cs, tension = 0.99) prod_us_solqpcaint 	
	copy(o) prod_us_solqpcaint prod_us_solqpca 	'extend productivity growth history with interpolated values

	%lastobs = gdp_r_us_q.@last 	'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	prod_us_solq = prod_us_solq(-1) * ((1+prod_us_solqpca/100)^0.25) 	'extend productivity using growth
	gdp_r_us_solq = prod_us_solq * empl_us_solq 	'obtain gdp forecast
	%lastobs = gdppc_r_us_q.@last 	'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	gdppc_r_us_solq = gdp_r_us_solq / n_us_solq * 1000 * 1000 	'obtain gdppc forecast

	smpl @all 			'reset sample
	copy(o,c=a) usq\gdp_r_us_solq usa\gdp_r_us_sola 	'aggregate quarterly series

	delete prod_us_qpca prod_us_solqpca prod_us_solqpcaint

pageselect usa 		'make the annual page active

	smpl @all 			'reset sample

	series prod_us_a = gdp_r_us_a/empl_us_a 	'annual historical productivity
	series prod_us_sola = gdp_r_us_sola/empl_us_sola 	'annual productivity forecast
	gdppc_r_us_sola = gdp_r_us_sola / n_us_sola * 1000 * 1000 	'obtain annual gdppc forecast

'*************************
' CPI
'*************************

pageselect usq 		'make the quarterly page active

	smpl @all 			'reset sample

	series cpi_us_solqpca = @pca(cpi_us_solq) 	'calculate annualized inflation

	'
	'
	'
	'annualized inflation values based on judgment (addfactor)xz
' 	smpl 2020q1 2020q2
' 	cpi_us_solqpca.fill(s) 1.5, 1.3
' 	cpi_us_solqpca = cpi_us_solqpca '+ 0.05
' 	smpl 2020q1 2020q4
' 	cpi_us_solqpca.fill(s) 1.2, 0.0, 0.0, 0.0
' 	cpi_us_solqpca = cpi_us_solqpca '+ 0.05
' 	smpl 2021q1 2021q1
' 	cpi_us_solqpca.fill(s) 0.5
' 	smpl 2023q4 !forecastend
' 	cpi_us_solqpca = 2.0
' 	smpl @all 			'reset sample
	smpl 2020q2 2020q4
	cpi_us_solqpca.fill(s) -3.5, 0, 0.5
	smpl 2024q4 !forecastend
	cpi_us_solqpca = 2.0
	smpl @all 			'reset sample
	'
	'
	'

	'interpolate the inflation series
	'cpi_us_solqpca.ipolate(type = cb) cpi_us_solqpcaint
	cpi_us_solqpca.ipolate(type = lin) cpi_us_solqpcaint
	'cpi_us_solqpca.ipolate(type = cs, tension = 0.99) cpi_us_solqpcaint 	
	copy(o) cpi_us_solqpcaint cpi_us_solqpca 	'extend inflation history with interpolated values

	%lastobs = cpi_us_q.@last 	'end of history
	smpl {%lastobs}+1 !forecastend 	'set sample for forecast
	cpi_us_solq = cpi_us_solq(-1) * ((1+cpi_us_solqpca/100)^0.25) 	'extend cpi using inflation

	smpl @all 			'reset sample
	copy(o,c=a) usq\cpi_us_solq usa\cpi_us_sola 	'aggregate quarterly series

	delete cpi_us_solqpca cpi_us_solqpcaint


'*************************
' GROWTH RATES
'*************************

	'delete n16ni_us_solq
	wfsave(type=a) "dbnk\ussolqeviews" @keep *_solq @drop *_q

	frml n_us_solqpca = @pca(n_us_solq)
	frml n16ni_us_solqpca = @pca(n16ni_us_solq)
	frml lf_us_solqpca = @pca(lf_us_solq)
	frml lfp_us_solqpca = @pca(lfp_us_solq)
	'frml ur_us_solqpca = @pca(ur_us_solq)
	frml empl_us_solqpca = @pca(empl_us_solq)
	frml prod_us_solqpca = @pca(prod_us_solq)
	frml gdp_r_us_solqpca = @pca(gdp_r_us_solq)
	frml gdppc_r_us_solqpca = @pca(gdppc_r_us_solq)
	frml cpi_us_solqpca = @pca(cpi_us_solq)

if %dump_to_xls = "Y" then

	pagesave(t=excel) "dbnk\ltpfcst_usq.xls" @keep *solq 	'export all forecast levels
	pagesave(t=excel) "dbnk\ltpfcstall_usq.xls" 'export all series
	
endif

pageselect usa 		'make the annual page active

	smpl @all 			'reset sample

	delete n16ni_us_sola
	wfsave(type=a) "dbnk\ussolaeviews" @keep *_sola @drop *_a

	frml n_us_solapcy = @pcy(n_us_sola)
	'frml n16ni_us_solapcy = @pcy(n16ni_us_sola)
	frml lf_us_solapcy = @pcy(lf_us_sola)
	frml lfp_us_solapcy = @pcy(lfp_us_sola)
	'frml ur_us_solapcy = @pcy(ur_us_sola)
	frml empl_us_ssolapcy = @pcy(empl_us_sola)
	frml prod_us_solapcy = @pcy(prod_us_sola)
	frml gdp_r_us_solapcy = @pcy(gdp_r_us_sola)
	frml gdppc_r_us_solapcy = @pcy(gdppc_r_us_sola)
	frml cpi_us_solapcy = @pcy(cpi_us_sola)

if %dump_to_xls = "Y" then

	pagesave(t=excel) "dbnk\ltpfcst_usa.xls" @keep *sola 	'export all forecast levels
	pagesave(t=excel) "dbnk\ltpfcstall_usa.xls" 'export all series
	
endif

wfsave usfcst

pageselect usq 		'make the annual page active

	smpl @all 			'reset sample

	graph gra01_q_n.line(x) n_us_solqpca n_us_solq n_us_q
	'graph gra011_q_n16ni.line(x) n16ni_us_solqpca n16ni_us_solq
	graph gra02_q_lf.line(x) lf_us_solqpca lf_us_solq lf_us_q
	graph gra03_q_lfp.line(x) lfp_us_solqpca lfp_us_solq lfp_us_q
	graph gra04_q_ur.line ur_us_solq ur_us_q
	graph gra05_q_empl.line(x) empl_us_solqpca empl_us_solq empl_us_q
	graph gra06_q_prod.line(x) prod_us_solqpca prod_us_solq prod_us_q
	graph gra07_q_gdp_r.line(x) gdp_r_us_solqpca gdp_r_us_solq gdp_r_us_q
	graph gra08_q_gdppc_r.line(x) gdppc_r_us_solqpca gdppc_r_us_solq gdppc_r_us_q
	graph gra09_q_cpi.line(x) cpi_us_solqpca cpi_us_solq cpi_us_q

	spool qgraph
	qgraph.append gra01_q_n gra02_q_lf gra03_q_lfp gra04_q_ur gra05_q_empl gra06_q_prod gra07_q_gdp_r gra08_q_gdppc_r gra09_q_cpi
