%% This script processes the TIFF stacks from o'connor data and converts to .avi
% Requires "Multipage TIFF stack" add-on by YoonOh Tak
% This was performed succesfully on 11/13/21
clear;
clc;

%% get all videos from hard drive
hdpath = 'D:/MarkG_WhiskerVids/';
directories = {'KS0282A_31aug16/KS0282A_31aug16/',...
               'KS0286A_09sep16/KS0286A_09sep16/',...
               'KS0355B_25mar17/KS0355B_25mar17/',...
               'KS0422C_09feb18/KS0422C_09feb18/'};
dirnames = {'aug16','sep16','mar17','feb18'};

%output path
outpath = '../data/janelia/videos/';

for di = 1:length(directories)
    %get directory
    DIR = dir([hdpath,directories{di}]);
    %scan directory to get tif files
    NAMES = {DIR.name};
    filenames = {};
    for ii = 1:length(NAMES)
        filestr = NAMES{ii};
        if length(filestr) > 4 && strcmp('.tif',filestr(end-3:end))
            filenames = [filenames;filestr];
        end
    end
    
    %iterate over .tif files...
    nfiles = length(filenames);
    for ii = 1:nfiles
        %get input ad output path
        tpath = [hdpath,directories{di},filenames{ii}];
        path_out = [outpath,dirnames{di},'/',filenames{ii}(1:end-4)];
        
        %display status
        fprintf('CONVERTING VIDEO (%d/%d) FROM THE DATASET "%s" \n',ii,nfiles,dirnames{di});
        fprintf('Input path: %s \n',tpath);
        fprintf('Output path: %s \n \n',path_out);
        
        %load tiff
        oimg = loadtiff(tpath);
        outputVideo = VideoWriter(path_out);
        open(outputVideo);

        for t = 1:length(oimg)
           img = oimg(:,:,t);
           fprintf('Writing frame (%d/%d) \n',t,length(oimg));
           writeVideo(outputVideo,img)
        end

        close(outputVideo);
        
    end
    
end

