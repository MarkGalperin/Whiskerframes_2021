%% This script processes the .whisker files from o'connor data and converts to an easier filetype
% Goal: take the .whiskers files and output new .mat files with whisker
% geometry in homogenous coordinates, contained in a cell array indexed by
% time and wid.
% This was performed succesfully on 11/13/21
clear;
clc;

%% Include files
addpath('../src')
addpath('../src/whisk')


%% get all videos from hard drive
hdpath = 'D:/MarkG_WhiskerVids/';
directories = {'KS0282A_31aug16/KS0282A_31aug16/',...
               'KS0286A_09sep16/KS0286A_09sep16/',...
               'KS0355B_25mar17/KS0355B_25mar17/',...
               'KS0422C_09feb18/KS0422C_09feb18/'};
dirnames = {'aug16','sep16','mar17','feb18'};

%output path
outpath = '../data/janelia/whiskers/';

for di = 1:length(directories)
    %get directory
    DIR = dir([hdpath,directories{di}]);
    %scan directory to get tif files
    NAMES = {DIR.name};
    filenames = {};
    for ii = 1:length(NAMES)
        filestr = NAMES{ii};
        if length(filestr) > 8 && strcmp('.whiskers',filestr(end-8:end))
            filenames = [filenames;filestr];
        end
    end
    
    %iterate over .tif files...
    nfiles = length(filenames);
    for ii = 1:nfiles
        %get input ad output path
        wpath = [hdpath,directories{di},filenames{ii}];
        path_out = [outpath,dirnames{di},'/',filenames{ii}(1:end-9)];
        
        %display status
        fprintf('CONVERTING WHISKER FILE (%d/%d) FROM THE DATASET "%s" \n',ii,nfiles,dirnames{di});
        fprintf('Input path: %s \n',wpath);
        fprintf('Output path: %s \n \n',path_out);
        
        %load whisker file
        WSK = LoadWhiskers(wpath);
        
        %extract relevant arrays
        time = [WSK.time];
        id = [WSK.id];
        
        %get time and max number of WIDs (+1 because wid is indexed from 0)
        Nwid = max(id) + 1;
        T = max(time) + 1;
        
        %initialize cell array
        PTS_out = num2cell(nan(T,Nwid));
        SCORES_out = num2cell(nan(T,Nwid));
        THICK_out = num2cell(nan(T,Nwid));
        
        %loop over every row...
        for jj = 1:length(WSK)
            %status
            fprintf('(%d/%d) \n',jj,length(WSK));
            
            %get time, wid, x,y
            t = WSK(jj).time;
            wid = WSK(jj).id;
            x = WSK(jj).x;
            y = WSK(jj).y;
            
            %assign into arrays
            PTS = [x';y';ones(1,length(x))];
            THICK = WSK(ii).thick;
            SCORES = WSK(ii).scores;
            
            %log
            PTS_out{t+1,wid+1} = PTS;
            SCORES_out{t+1,wid+1} = THICK;
            THICK_out{t+1,wid+1} = SCORES;
        end
        
        %save struct
        S.WSK_points = PTS_out;
        S.WSK_thick = THICK_out;
        S.WSK_scr = SCORES_out;
        
        %save
        save(path_out,'-struct','S');
        
    end
    
end

