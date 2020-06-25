# Gekko
AREMOS alternative

## Contents

* Gekko.pdf is the user manual with detailed description of commands etc. See also http://t-t.dk/gekko/.
* Gekko.plist.zip is a compressed file containing code highlighting and other features for BBEdit/Textwrangler. Unzip it and place it into your `~//Library/Application Support/BBEdit/Language Modules` folder and restart your editor.
* The folder names should be self-explanatory: 
  * `BUGS_FEATURES`: open and solved bugs in Gekko and feature requests; 
  * `demo`: demo code from the Gekko website; 
  * `CMD`: code developed by UHERO, main file names listed below; 
      * `LIB.gcm`: functions developed for UHERO needs; 
      * `USSOL.gcm`: deterministic model for the US economy; 
      * `CASOL.gcm`: deterministic allocation of aggregate forecasts to the industry and county level; 
          * `EQUCA.gcm`: equations for the county allocation; 
          * `REDISTCA.gcm`: redistribution of excess allocation error; 
      * `SIM_PLOT.gcm`: plots of long-run simulations incl. comparison plots; 
  * `DATA`: imported, exported data and databanks; 
  * `FIGURES`: pdf figures produced by the command files.
  
## Status
  
06/25/2020
Add ghostscript in SIM_PLOT to combine individual pdfs into a single file. Explore additional data export options.

006/20/2020
Load, combine and export scenarios, plot scenarios, new function for calculating multi-year average growth.

06/16/2020
County allocation cleaned up, added county comparison figures indexed to 100 in the last year of history.

06/14/2020
The code for county allocation is essentially complete. There are some small discrepancies between AREMOS and GEKKO growth in 2020 and 2021, but those are likely due to some rounding in the addfactor.

06/10/2020
The command file for the US forecast (USSOL) is essentially complete: it showcases all important steps of the data workflow, including data import/export, data modifications (addfactoring, working with different frequencies, etc.), and generation of figures. The codebase does not illustrate any simultaneous equation modeling yet.
