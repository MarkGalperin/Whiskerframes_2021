% Each figure is a different value of theta
% Each plot on a single figure is a different value of (r1, r2)
%%%  Mitra and Mark work via Zoom together.  
%%% Wednesday, May 13, 2020

clc;
faceFrameL = 1; %  length of face frame
s = 0.5;

thetaVals = [-30:15:30];

for ii = 1 % :length(thetaVals)
    figure(ii);
    set(gcf,'color','w');
    thetaVal = thetaVals(ii);
    
    rVals_1_lower = min([-4*s*sind(thetaVal),-s*sind(thetaVal)]);
    rVals_1_upper = max([-4*s*sind(thetaVal),-s*sind(thetaVal)]);
    rVals_1_ival = (rVals_1_upper - rVals_1_lower)/5;
    
    rVals_1 = [rVals_1_lower:rVals_1_ival:rVals_1_upper];
    rVals_2 = [-0.5*faceFrameL:0.5*faceFrameL:1.5*faceFrameL];
    
    counter = 0;    
    for jj = 1:length(rVals_1)       
        for kk = 1:length(rVals_2)
            counter = counter + 1;
            rVal1 = rVals_1(jj);
            rVal2 = rVals_2(kk);
            subplot(5,6,counter);
            % plot whiskers for that combination of theta and r
            % plot x-axis and y-axis
            h = plot(rVal1,rVal2,'*');
            set(h,'LineWidth',8);
            set(gca,'Box','off');
            % ensure all plots are on the same axes
            % consider using axis('equal') (??? not sure)
            % axis([xmin,xmax,ymin,ymax]);
            set(gca,'xtick',[]); 
            set(gca,'ytick',[]); 
            tempstring = [num2str(rVal1,3), ',' num2str(rVal2,3)];
            title(tempstring);
            % ensure all plots are on the same axes
            % consider using axis('equal') (??? not sure)
            % axis([xmin,xmax,ymin,ymax]);
        end;
    end;
end;
