# NanoindenterReader
This code has designed to read the exported spreadsheet data produced by the "MTS Nano Indenter XP" nanoindenter.
The code has multiple functions which should all be kept within the same folder.

The code to run is named NanoMainCode, the other codes are needed but should ideally not be run, but will be called upon when necessary.
NanoMainCode runs in two different modes, first is "Create" which calls on NanoDataCreater, and the other called "Load" calls NanoDataLoader.

NanoDataCreater
Should be used for converting the exported spreadsheets from the XP into a more suitable format. It does this by loading the files, and asking if you want to merge them into a single meaned result, or just mean the individual arrays (keeping the arrays as seperate data).
It will plot the resulting data and can show the associated standard deviation or standard error as error regions or error bars.
Saving the data (excl. the figures) will produce a ".mat" file which can then be used by NanoDataLoader.

NanoDataLoader
Most of the analysis and the plotting of figures for showing results is done within this code. It loads ".mat" files produced by NanoDataCreater, thus allowing for meaned data across multiple arrays and/or meaned data for each individual array to be plotted. N.B. it cannot mean the files loaded into it, as this should be done previously within NanoDataCreater with the raw spreadsheet data.
The code then can plot the selected data you would like to plot against indent depth for the files loaded, and it can then find the mean values of the data within a chosen indent depth range, and save each of the figures in the desired saving format.
