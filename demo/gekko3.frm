// Info: Simple model for use with Gekko guided tour
// Date: 15-02-2016 15:05:00
// Signature: Ga5pUuM73FiarlDzuZLHrw
//
// See www.t-t.dk/gekko/guide.html
// The corresponding databank (gekko.gcm) can also be found there.
//
// Variables are to be thought of in fixed prices (quantities)
// y: Gross domestic product (GDP)
// c: Consumption
// g: Government consumption
// x: Net exports
//
// Eq1: GDP identity
// Eq2: Consumption function
// Eq3: Philips curve effect on net exports (via GDP, unemployment, wages, prices, competitiveness)
//

FRML _I              y  =  c + g + x;
FRML _GJ_D           c  =  0.6*y + 0.1*c[-1];
FRML _GJD        dif(x) = -0.2*(y[-2] - 500);



// ------------------------------------------------------------------------------------------------
varlist$
y
Gross domestic product (GDP)
(fixed prices/volumes)
Source: Gekko artificial data
Identity: y = c + g + x
----------
c
Private consumption
(fixed prices/volumes)
Source: Gekko artificial data

----------
x
Net exports (exports minus imports)
(fixed prices/volumes)
Source: Gekko artificial data

----------
g
Government consumption
(fixed prices/volumes)
Source: Gekko artificial data

----------
