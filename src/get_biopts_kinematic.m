function data_out = get_biopts_kinematic(clip,convert)
    % *** KINEMATIC BIOLOGICAL POINTS ***
    % This function takes the biological datasets and produces arrays of
    % points for inputting into the search experiment.
    %
    % Takes Input1: time?
    %       Input2: kljfsdljds
    % 
    % Returns   data_out:
    %
    %% Dataset 
    path = sprintf('kinematic_filtangles/clip_%03d_filtangles.mat',clip);
    DATA = importdata(path);
%     DATA = fopen(path);
    %right-side data
    rfront = DATA.rfrontwf;
    rback = DATA.rbackwf;
    %left-side data
    lfront = DATA.rfrontwf;
    lback = DATA.rbackwf;
    
    %% Conversion
    if convert == true
        %first, convert to 0-normal degrees, then to radians
        rfront = (90-rfront)*(pi/180);
        rback = (90-rback)*(pi/180);
        lfront = (90-lfront)*(pi/180);
        lback = (90-lback)*(pi/180);
    elseif convert == 'keepdegrees'
        rfront = 90-rfront;
        rback = 90-rback;
        lfront = 90-lfront;
        lback = 90-lback;
    end
    
    %% Format output (I FUTZED WITH THIS. GET CLEAR!!)
%     data_out = [rback,rfront,lback,lfront];
    data_out = [rfront,rback,lfront,lback];

    
end
