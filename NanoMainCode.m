%% Nanoindentation Matlab Code
% By Robert J Scales - robert.scales@mansfield.ox.ac.uk
% This is the code which should be run when using the collection of scripts
% (i.e. functions) as they are built to work off from this.
%
% This is designed to operate in two different primary functions, the
% "import" mode which interprets a valid set of nanoindentation data and
% generates a structure which can be saved. It's main goal is not to plot
% data but to generate easily read and pre-processed data which can then be
% plotted by the next discussed mode.
%
% The "plot" mode uses the structures made by "import" and plots them as
% seperated lines of data. In this mode one can obtain the mean value
% within a certain indent depth range, and one can save and plot desired
% values against nanoindentation depth.

%% Clean Slate Section
% Clears the command window
clc

% Closes all figures
close all

% Clears all variables except for SettingsDone in NanoImport.
clearvars('-except','SettingsDone');

% The below clears all of the 'Do Not Show This Again' for
% preference diaglogue boxes.
%   uisetpref('clearall');

%% NanoMainCode Settings

% Setting this to true allows debugging messages to pop up within the
% command window following code that is run.
% It is useful to turn on to see what the code is doing.
debugON = false;

% To change pre-defined settings in the code change the values within this
% function. There are options to change certain settings within the latter
% scripts that run.
[PlotAesthetics,DefaultDlg,USS] = SettingsFunction;

% This titles all of the dialogue boxes ran in this script.
code_title = 'Nanoindentation Main Code';

%% Main Section

% The code either generates data for samples(s), which is the "Create"
% action, or it grabs the outputted ".mat" files from "Create" which can
% contain either one sample, multiple samples, or the mean across multiple
% samples (using the mean option for Agilent files).
CreateOrLoad = questdlg('What action do you want to do?',code_title,'Import','Plot','Save Figures');

switch CreateOrLoad
    case 'Import'
        NanoImport(debugON,DefaultDlg,USS)
    case 'Plot'
        ChooseSaveType = true;
        DfltImgFmtType = 'png';
        NanoPlotter(debugON,PlotAesthetics,DefaultDlg,ChooseSaveType,DfltImgFmtType)
    otherwise
        errordlg('No action was chosen! Code will terminate!')
        return
end


%% InBuilt Functions

function [PlotAesthetics,DefaultDlg,USS] = SettingsFunction
    % This sets the font size for all text in all of the figures!
    set(0,'defaultAxesFontSize',20);
    % This sets the marker size for all text in all of the figures!
    set(0,'defaultLineMarkerSize',12);
    
    % The below are non-crucial settings which have been decided to not be
    % editable via dialogue boxes when running the script.
    PlotAesthetics.capsize = 0;
    PlotAesthetics.linewidth = 2;
    PlotAesthetics.facealpha = 0.25;

    % The default settings used by John Waite's (ex Oxford DPhil) Matlab
    % code were:
    % FormatAnswer = 'Line + Error Bars';
    % StdDevWeightingMode = 'N-1';
    % ErrorPlotMode = Standard deviation';
    % These have mainly been used, however the 'Line + Error Region' option
    % looks better aesthetically.
    
    % Default Dialogue Box Choices - You can change this if you want to speed
    % things up when choosing in the dialogue boxes. The meaning of these
    % are explained when looking at NanoDataCreater.
    DefaultDlg.FormatAnswer = 'Line + Error Region';
    DefaultDlg.StdDevWeightingMode = 'N-1';
    DefaultDlg.ErrorPlotMode = 'Standard deviation';
    DefaultDlg.MeanSamples = 'No';

    % Script Settings - These are selected if you select 'Use Scipt Settings'!
    % This a good way to have the same settings for data analysis for
    % consistency, also speeds up time!
    USS.bins = 50;
    USS.FormatAnswer = 'Line + Error Region';
    USS.w = 0;
    USS.ErrorPlotMode = 'Standard deviation';
end
