function [YPTS,ANG] = preprocess_dlc_gsf(base,tip)
    % *** TITLE OF THE THING ***
    % Takes Input1: sdfhjksdf
    %       Input2: kljfsdljds
    % 
    % Returns Output1: dslkfjsdlkj
    %         Output2: dfkhsdkjfhs
    %% define a "pack" for this code to make this code compatible again
    N = length(base); %number of whiskers
    pack = [];
    for ii = 1:N
        pack = horzcat(pack,[transpose(base(ii).x),...
                            transpose(base(ii).y),...
                            transpose(tip(ii).x),...
                            transpose(tip(ii).y)]);
    end
    
    %% getting points and angles to input into search frame
    T = size(pack,1);
    %initialize arrays
    Ps = zeros(T,3,N);
    angles = zeros(T,N);

    for ii = 1:T
        %index the pack
        x_base = pack(ii,1:4:20);
        y_base = pack(ii,2:4:20);
        x_tip = pack(ii,3:4:20);
        y_tip = pack(ii,4:4:20);
        
        %base points in homogenous form
        P_base = [x_base;y_base;ones(1,N)];
        P_tip  = [x_tip;y_tip;ones(1,N)];

        %get angles
        %angle = atan((x_tip-x_base)./(y_tip-y_base));
        angle = atan2((y_tip-y_base),(x_tip-x_base));

        %log values
        Ps(ii,:,:) = P_base;
        angles(ii,:) = angle; %SWAPPED THE SIGN
    end
    
    %% Inputting into getsearchframe
    ANG = zeros(size(Ps,1),size(angles,2)); %change to T,N?
    YPTS = zeros(size(Ps,1),size(angles,2));
    for ii = 1:size(Ps,1)
        %get points and angles
        P = squeeze(Ps(ii,:,:));
        a = angles(ii,:);

        % do the stuff
        regtype='deming';
        rowselect = 'A';
        [~,P2,ang2,~] = get_searchframe(P,a,regtype,rowselect,false);
        YPTS(ii,:) = P2(2,:);
        ANG(ii,:) = ang2;
    end
    
end

