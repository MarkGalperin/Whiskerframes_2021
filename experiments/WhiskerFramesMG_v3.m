% Each figure is a different value of theta
% Each plot on a single figure is a different value of (r1, r2)
%%% Mitra and Mark work via Zoom together 5/13/20
%%% Most recent update 7/13/20

clear
clc;
faceFrameL = 1; % length of face frame
s = 0.5;        % length ratio
N = 5;          % number of whiskers plotted through face frame

thetaVals = [-30:15:30];

for ii = 1:length(thetaVals)
    figure(ii);
    set(gcf,'color','w');
    thetaVal = thetaVals(ii);
    
    %rVals_1_lower = min([-4*s*sind(thetaVal),-s*sind(thetaVal)]);
    %rVals_1_upper = max([-4*s*sind(thetaVal),-s*sind(thetaVal)]);
    rVals_1_lower = -1;
    rVals_1_upper = -0.25;
    rVals_1_ival = (rVals_1_upper - rVals_1_lower)/5;
    
    rVals_1 = [rVals_1_lower:rVals_1_ival:rVals_1_upper];
    rVals_2 = [-0.5*faceFrameL:0.5*faceFrameL:1.5*faceFrameL];
    
    counter = 0;    
    for jj = 1:length(rVals_1)       
        for kk = 1:length(rVals_2)
            counter = counter + 1;
            rVal1 = rVals_1(jj);
            rVal2 = rVals_2(kk);
            wVal1 = s*sind(thetaVal);
            wVal2 = 1-s*cosd(thetaVal);
            
            subplot(6,5,counter);
            %axes...
            axisrange_x = [-1.5,.5];
            axisrange_y = [-.5,2];
            xlim([axisrange_x(1),axisrange_x(2)]);
            ylim([axisrange_y(1),axisrange_y(2)]);
            
            
            hold on
            
            % plot x-axis and y-axis
            
            xaxis = plot(axisrange_x,[0,0],'color','black'); %x-axis
            yaxis = plot([0,0],axisrange_y,'color','black'); %y-axis
            set(xaxis,'LineWidth',1);
            set(yaxis,'LineWidth',1);
            
            %plotting r
            h = plot(rVal1,rVal2,'*');
            set(h,'LineWidth',1);
            
            %Plotting the frames
            FF = plot([0,0],[0,faceFrameL],'color','black');
            set(FF,'LineWidth',2);
            CF_tip = [rVal1-s*faceFrameL*sind(thetaVal),rVal2+s*faceFrameL*cosd(thetaVal)];
            CF = plot([rVal1,CF_tip(1)],[rVal2,CF_tip(2)], 'color','black');
            set(CF,'LineWidth',2);
            
            %whisker lines 
            for Kwskr = 0:faceFrameL/(N-1):faceFrameL
                %u vector values...
                uVal1 = wVal1*Kwskr-rVal1;
                uVal2 = wVal2*Kwskr-rVal2;
                
                whisky1 = (uVal2/uVal1)*axisrange_x(1)+Kwskr;
                whisky2 = (uVal2/uVal1)*axisrange_x(2)+Kwskr;
                tempPlot = plot(axisrange_x,[whisky1,whisky2],'color','cyan');
                set(tempPlot,'LineWidth',1)
            end;
            
            %plotting the protraction and spread
            y_pts = axisrange_y(1):0.01:axisrange_y(2);
            protraction = atan((rVal2 - wVal1*y_pts)./(rVal1+wVal1*y_pts));
            protraction_norm = protraction./max(protraction);
            spread = 1;
            
            test = plot(protraction_norm,y_pts);
            set(test,'LineWidth',2)
            
            %no box
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
            %Axis limits
            %xlim([-3,2]);
            %ylim([-2,1]);
            
        end;
    end;
end;
