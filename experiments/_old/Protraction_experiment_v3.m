%% PROTRACTION MAP EXPERIMENT
% This experiment will determine how well the whisker frames mechanism can
% replicate an arbitrary biological input 
clear;
clc;

%% Including downloaded code
addpath('./deming');

%% TEMPORARILY DISABLING PLOTS
set(0,'DefaultFigureVisible','off');

%% Plot config
x_lim = [-3,3];
y_lim = [-3,3];
x_lins = linspace(x_lim(1),x_lim(2));
y_lins = linspace(y_lim(1),y_lim(2));

%% Setting some parameters (s should be fixed. theta will be looped)...
s = 0.45; %s is the fraction of one frame length to the other
thmax = 2*atan(sqrt((1-s)/(1+s)));
% th_deg = -63;
% th = th_deg*(pi/180); %for testing purposes
% w1 = s*sin(th);
% w2 = 1-s*cos(th);

%Display parameters
fprintf('s is %1.1f \n',s)
fprintf('theta_max is %1.1f rad, (%1.1f degrees).\n',thmax, thmax*(180/pi))

%% SEARCH FRAME
%input points (result should be column vectors in homogenous coordinates 
%               with a 4th row indicating the associated whisker angle)
% pts = [[-1;-1;1],[0;-0.5;1],[1;0;1],[2;1;1],[3;2.5;1]]; %dummy points
% ang_in = [-80,-40,-10,15,20]*(pi/180);

%fetch data for row
rowselect = 'E';
[pts,ang_in] = get_biopts_static(rowselect);

%regression type ('SSR' or 'deming')
regtype='deming';

[V,P,ang,SF_figure] = get_searchframe(pts,ang_in,regtype,rowselect,true);

%% Plotting the contours...
%protractionmap contours
plot_PMap(x_lim,y_lim)
set(gca,'Color','k')

%% Data Logs
err_log = [];
param_log = [];

%% Loop
for th = -0.01:-0.05:-thmax   %-thmax:0.05:thmax
    %w values...
    w1 = s*sin(th);
    w2 = 1-s*cos(th); 
    al = atan(w1/w2);
    
    %% Tangent line
    Ytan = (-w2/w1)*(x_lins+(w2/(4*w1)));
    %hold on
    %plot(x_lins,Ytan,'-c','LineWidth',2)
    
    %%FOR NOW: JUST USE a y point from -ymax to ymax as your point
    for Yi = y_lim(1):0.1:y_lim(2)
        %getting Xi
        Xi = -Yi*(w1/w2)-(w2/(4*w1));
        %% Looping over scale...
        for F = 1%[0.5:0.5:7]
            %% Transformation
            T = [[F*cos(al);F*sin(al);0],[F*-sin(al);F*cos(al);0],[Xi;Yi;1]];
            %transforming the points...
            V_p = T*V;
            
            %% Getting the error and PLOTTING
            N = size(V,2);
            err = zeros(1,N);
            for ii = 1:N
                %plotting the point
                %plot(V_p(1,ii),V_p(2,ii),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
                
                %Error calculation
                err(ii) = abs(ProtractionMap(V_p(1,ii),V_p(2,ii)) - ang(ii));
            end
            
            %Record parameters
            params = [th,Yi,F];
            
            %append to data logs...
            err_log = [err_log ; err];
            param_log = [param_log ; params];
        end
    end
end

%% Error minimum and index
err_sums = err_log*ones(size(err_log,2),1);
[ERR_MIN,IND] = min(err_sums);

%% Plotting the error-minimum
%fetching the optimal configuration
PRMS = param_log(IND,:);
for th = PRMS(1) %-thmax:0.1:thmax
    %w values...
    w1 = s*sin(th);
    w2 = 1-s*cos(th); 
    al = atan(w1/w2);
    %%Tangent line
    Ytan = (-w2/w1)*(x_lins+(w2/(4*w1)));
    hold on
    plot(x_lins,Ytan,'-c','LineWidth',2)
    %%FOR NOW: JUST USE a y point from -ymax to ymax as your point
    for Yi = PRMS(2)
        %getting Xi
        Xi = -Yi*(w1/w2)-(w2/(4*w1));
        %Looping over scale...
        for F = PRMS(3)
            %making the transform
            T = [[F*cos(al);F*sin(al);0],[F*-sin(al);F*cos(al);0],[Xi;Yi;1]];
            %transforming the points...
            V_p = T*V;
            P_p = T*P;
            %%PLOTTING
            N = size(V_p,2);
            for ii = 1:N
                %plotting little unit vectors under the point to show (TODO: REVIEW THIS. I SWITCHED IT UP)
                    %biological...
                    bio = ProtractionMap(V_p(1,ii),V_p(2,ii));
                    plot([P_p(1,ii), P_p(1,ii)+0.5*cos(al+bio)],[P_p(2,ii), P_p(2,ii)+0.5*sin(al+bio)],'g','LineWidth',3)
                    %ideal
                    plot([V_p(1,ii), V_p(1,ii)+0.5*cos(al+ang(ii))],[V_p(2,ii), V_p(2,ii)+0.5*sin(al+ang(ii))],'r','LineWidth',3)

                %plotting the point
                plot(V_p(1,ii),V_p(2,ii),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
            end
        end
    end
end
%% Saving the plot...
XYp_figure = gca;

%% Back-solving for r
%Getting the position. This is the vector "a" as reffered to in the paper
a_x = (-w1/w2)*PRMS(2) - (w2/(4*w1));
a = [a_x,PRMS(2)];

%using a, calculate line slopes m1, m2, m3...
m1 = 2*(a(1) + sqrt(a(1)^2 - a(2)));
m2 = 2*(a(1) - sqrt(a(1)^2 - a(2)));
m3 = tan(atan(m1)+PRMS(1));

%Getting the b vector
b_1 = (m2*a(1)-a(2)-(m3^2)/4)/(m2-m3);
b = [b_1, m2*(b_1-a(1))+a(2)];

%r magnitude
r_mag = norm(b-a)*PRMS(3);

%getting gamma (angle between lines one and two, angle of r vector)
gam = pi + atan(m2) - atan(m1);

%getting r vector
r = r_mag * [-sin(gam) , cos(gam)];


%% Plotting the error-minimum in {xy}
%parameters
numwhiskers = N;

%call fxn
XY_figure = plot_xy(s,r,PRMS(1),numwhiskers);


%% Saving the figures...
path = 'C:\Users\markg\Box Sync\_____RatSealBots\Hardware_Undergrad_Documents\Whisker_Frames_Galperin\Galperin_manuscript\MATLAB\Figure_output\test';

%filenames (at the moment: based on row)
SF_filename = sprintf('row%c_searchframe',rowselect);
XYp_filename = sprintf('row%c_xyp',rowselect);
XY_filename = sprintf('row%c_xy',rowselect);

%save plots
saveas(SF_figure, fullfile(path, SF_filename), 'png');
saveas(XYp_figure, fullfile(path, XYp_filename), 'png');
saveas(XY_figure, fullfile(path, XY_filename), 'png');
