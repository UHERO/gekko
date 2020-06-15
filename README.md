# Gekko
AREMOS alternative

## Contents

* Gekko.pdf is the user manual with detailed description of commands etc. See also http://t-t.dk/gekko/.
* Gekko.plist.zip is a compressed file containing code highlighting and other features for BBEdit/Textwrangler. Unzip it and place it into your `~//Library/Application Support/BBEdit/Language Modules` folder and restart your editor.
* The folder names should be self-explanatory: 
  * `BUGS_FEATURES`: open and solved bugs in Gekko and feature requests; 
  * `demo`: demo code from the Gekko website; 
  * `CMD`: code developed by UHERO; 
  * `DATA`: imported, exported data and databanks; 
  * `FIGURES`: pdf figures produced by the command files.
  
## Status
  
06/14/2020
The code for county allocation is essentially complete. There are some small discrepancies between AREMOS and GEKKO growth in 2020 and 2021, but those are likely due to some rounding in the addfactor.

06/10/2020
The command file for the US forecast (USSOL) is essentially complete: it showcases all important steps of the data workflow, including data import/export, data modifications (addfactoring, working with different frequencies, etc.), and generation of figures. The codebase does not illustrate any simultaneous equation modeling yet.
