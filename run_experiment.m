% run_experiment - Entry point wrapper for organized experiment runner
% This file provides backward compatibility by calling the organized version
clc;
clear all;
close all;
% clear import;
clear

% Add the main directory to path to access organized files
addpath('main');
addpath('gui');
addpath('control');
addpath('utils');
addpath('monitoring');
addpath('data-collection');

% Call start_experiment from the current directory
start_experiment