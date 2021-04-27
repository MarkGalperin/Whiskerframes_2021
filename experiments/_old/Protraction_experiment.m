%% Plotting ProtractionMAP
%bounds
x = -10:.05:10;
y = x;

%function
[X,Y] = meshgrid(x,y);
m1 = 2*X+2*sqrt(X.*X-Y);
m2 = 2*X-2*sqrt(X.*X-Y);
Z = pi/2 - (atan(m1)-atan(m2));

%Filtering out complex numbers
for m = 1:length(Z(1,:))
    for n = 1:length(Z(:,1))
        if isreal(Z(m,n)) == false
            Z(m,n) = NaN;
        end
    end
end

%% Protraction function
b = ProtractionMap(27,-.25);

%% Point input
%input points (result should be column vectors in homogenous coordinates 
%               with a 4th row indicating the associated whisker angle)
Vh = [0,-2,1; 0,-1,1; 0,0,1; 0,1,1; 0,2,1; 0,3,1];
V = transpose(Vh);
V(4,:) = [-0.3218, -0.1231, 0.1176, 0.3808, 0.6331,0.8481]; %corresponding angles of emergence (radians, between +/- pi/2)

%% Plotting the search Frame
hold on
plot([0 1],[0 0],'b','MarkerEdgeColor','red','LineWidth',2)
plot([0 0],[0 1],'b','MarkerEdgeColor','red','LineWidth',2)
plot(V(1,:),V(2,:),'o','MarkerEdgeColor','black','MarkerFaceColor',[1 1 1]);
axis equal
xlim([min(V(1,:))-3, max(V(1,:))+3])
ylim([min(V(2,:))-3, max(V(2,:))+3])

%% Plotting the contours...
%protractionmap contours
figure;
contourf(X,Y,Z,20)
colorbar('AxisLocation','in')
axis('square')


%% Data Log
LOG = zeros(5,1);

%% Loop
for o1 = -10:10
    for o2 = -10:10
        for t = -pi/4:pi/12:pi/4
            for expo = 0
                %% Reference frame for the input points
                %origin o, Translation matrix T
                o = [o1;o2];  %o is a column vector
                T = [1, 0, o(1) ; 
                     0, 1, o(2) ; 
                     0, 0, 1   ];
                %Scale factor f, scale matrix F
                f = 4^expo;
                F = [.1 0 0 ;
                     0 .1 0
                     0 0 1];
                
                %angle t, corresponding rotation matrix R
                R = [cos(t), -sin(t), 0 ; 
                     sin(t), cos(t) 0   ; 
                     0, 0, 1           ];

                %% Point calculation
                P = T*F*R*V(1:3,:);   %full transformation, excluding last row of V

                %% Skip if any lie inside the parabola
                if any((P(1,:).^2 - P(2,:)) < 0) %if, for any point in P, y > x^2
                    continue %skips out of the for loop 
                end

                %% Error calculation
                N = length(P(1,:));
                err = zeros(1,N);
                for i = 1:N
                    % simple error between the theoretical angle (ProtractionMap)
                    % and the points' angles (absolute value)
                    err(i) = abs(ProtractionMap(P(1,i),P(2,i)) - V(4,i));
                end

                %error
                err_sum = sum(err)/N;

                %% Logging data...
                log = [o(1);o(2);t;f;err_sum];
                LOG = [LOG,log]; % fix this when you know how many things you're looping over!

    %             %% Plotting the points...
    %             hold on
    % 
    %             %plotting the points
    %             test = plot(P(1,:),P(2,:),'o','MarkerEdgeColor','black','MarkerFaceColor',[1 1 1]);
    %             set(test)
    % 
    %             %error annotation
    %             annotation('textbox', [0.75, 0.1, 0.1, 0.1], 'String', "Sum error = " + err_sum)
            end
        end
    end
end

%% Error-minimizing configuration
LOG(:,1) = []; %delete the first column
[ERR_MIN,ERR_IND] = min(LOG(4,:));

%getting the error minimum parameters
errmin = LOG(:,ERR_IND);
Tmin =  [1, 0, errmin(1) ; 
         0, 1, errmin(2) ; 
         0, 0, 1   ];
Rmin  = [cos(errmin(3)), -sin(errmin(3)), 0 ; 
         sin(errmin(3)), cos(errmin(3)) 0   ; 
         0, 0, 1           ];
Fmin = [errmin(4) 0 0 ;
        0 errmin(4) 0 ;
        0 0 1];
%recalculating points...
Pmin = Tmin*Fmin*Rmin*V(1:3,:);
     
%plotting the error minimum
hold on
test = plot(Pmin(1,:),Pmin(2,:),'o','MarkerEdgeColor','black','MarkerFaceColor',[1 1 1]);
set(test)

%error annotation
annotation('textbox', [0.75, 0.1, 0.1, 0.1], 'String', "Sum error = " + errmin(5))
