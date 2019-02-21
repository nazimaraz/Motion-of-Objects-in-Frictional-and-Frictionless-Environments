clear;
clc;
close all;

StartSimulation

function StartSimulation
    masses = [5, 10, 5, 10];
    k = 5.5;
    gravitationalAcceleration = 9.80665; % Value of gravitational acceleration (meter/seconds^2)
    
    height = input('Enter the value of height(meter): '); % Value of height (meter)
    disp(newline);
    time = 0;
    
    if height <= 0
        disp('You must enter greater than 0');
        StartSimulation
        return;
    end
    
    newHeights = [1 1 1 1];
    
    instantaneousVelocities = [0, 0, 0, 0];
    
    calculatedFallTimes = [
        sqrt(2 * height / gravitationalAcceleration)
        sqrt(2 * height / gravitationalAcceleration)
        (masses(3)*lambertw(0, -exp(-(height * k^2 + gravitationalAcceleration * masses(3)^2) / (gravitationalAcceleration * masses(3)^2))) + (height * k^2 + gravitationalAcceleration * masses(3)^2) / (gravitationalAcceleration * masses(3)))/k
        (masses(4)*lambertw(0, -exp(-(height * k^2 + gravitationalAcceleration * masses(4)^2) / (gravitationalAcceleration * masses(4)^2))) + (height * k^2 + gravitationalAcceleration * masses(4)^2) / (gravitationalAcceleration * masses(4)))/k
    ];

    calculatedVelocities = [
        gravitationalAcceleration * calculatedFallTimes(1)
        gravitationalAcceleration * calculatedFallTimes(2)
        -gravitationalAcceleration * (masses(3) / k) * exp(-k * calculatedFallTimes(3) / masses(3)) + gravitationalAcceleration * masses(3) / k
        -gravitationalAcceleration * (masses(4) / k) * exp(-k * calculatedFallTimes(4) / masses(4)) + gravitationalAcceleration * masses(4) / k;
    ];
    
    isDisplayed = [false false false false];
    
    yyaxis left;
    ylabel('\color{blue}distance(m)');
    axis([0, max(calculatedFallTimes), 0, height]);
    line([max(calculatedFallTimes) / 2, max(calculatedFallTimes) / 2], [0, height], 'Color', 'black');
    
    balls = [
        animatedline('Color', 'k', 'Marker', 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
        animatedline('Color', 'g', 'Marker', 'o', 'MarkerSize', 30, 'MarkerFaceColor', 'g')
        animatedline('Color', 'r', 'Marker', 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
        animatedline('Color', 'b', 'Marker', 'o', 'MarkerSize', 30, 'MarkerFaceColor', 'b')
        ];
    
    lineOfHeights = [
        animatedline('Color', 'k')
        animatedline('Color', 'g')
        animatedline('Color', 'r')
        animatedline('Color', 'b')
        ];
    
    yyaxis right;
    ylabel('\color{red}velocity(m/s)');
    axis([0, max(calculatedFallTimes), 0, max(calculatedVelocities)]);
    
    title('Frictionless     |     Frictional    ');
    
    lineOfVelocities = [
        animatedline('Color', 'k')
        animatedline('Color', 'g')
        animatedline('Color', 'r')
        animatedline('Color', 'b')
        ];
    
    colors = {'black' 'green' 'red' 'blue'};
    maxVelocities = [0 0 gravitationalAcceleration * masses(3) / k gravitationalAcceleration * masses(4) / k];
    isReached = [false false false, false];
    reachedHeights = [0 0 0 0];
    
    t = timer;
    t.TimerFcn = @timerCallback;
    t.Period = 0.01;
    t.TasksToExecute = round(1 / t.Period * max(calculatedFallTimes)) + 10;
    t.ExecutionMode = 'fixedRate';
    start(t);
    wait(t);
 
    function timerCallback(~, ~)        
        for i = 1:length(balls)
            
            if newHeights(i) <= 0
                newHeights(i) = 0;
                if ~isDisplayed(i)
                    
                    addpoints(lineOfHeights(i), time, newHeights(i));
                    addpoints(lineOfVelocities(i), time, instantaneousVelocities(i));
                    clearpoints(balls(i));
                    addpoints(balls(i), max(calculatedFallTimes)*i/5, newHeights(i));
                
                    disp(['Calculated fall time for ' colors{i} ' ball: ' num2str(calculatedFallTimes(i)) ' seconds' newline 'Measured fall time for ' colors{i} ' ball: ' num2str(time) ' seconds']);
                    disp([newline 'Calculated final velocity for ' colors{i} ' ball: ' num2str(calculatedVelocities(i)) ' meter/seconds' newline 'Measured final velocity for ' colors{i} ' ball: ' num2str(instantaneousVelocities(i)) ' meter/seconds']);
                    if(isReached(i))
                        disp(['Height when maximum velocity is reached: ' num2str(reachedHeights(i)) ' meter/seconds']);
                    end
                    disp('=================');
                    isDisplayed(i) = true;
                end
            else
                addpoints(lineOfHeights(i), time, newHeights(i));
                addpoints(lineOfVelocities(i), time, instantaneousVelocities(i));
                clearpoints(balls(i));
                addpoints(balls(i), max(calculatedFallTimes)*i/5, newHeights(i));
            end
            
            if (i == 3 || i == 4)
                if instantaneousVelocities(i) >= maxVelocities(i) - 0.01 && ~isReached(i)
                    yyaxis left;
                    text(max(calculatedFallTimes)*i/5, newHeights(i), '\leftarrow', 'FontSize', 18);
                    isReached(i) = true;
                    reachedHeights(i) = newHeights(i);
                end
                newHeights(i) = height - (gravitationalAcceleration * (masses(i)^2 / k^2) * exp(-k * time / masses(i)) + gravitationalAcceleration * masses(i) * time / k - gravitationalAcceleration * (masses(i)^2 / k^2));
                instantaneousVelocities(i) = -gravitationalAcceleration * (masses(i) / k) * exp(-k * time / masses(i)) + gravitationalAcceleration * masses(i) / k;
            else
                newHeights(i) = height - 1/2 * gravitationalAcceleration * time^2;
                instantaneousVelocities(i) = gravitationalAcceleration * time;
            end
            
        end % end of for loop
        time = time + t.period;
    end  % end of while loop
end