clear;clc;close all

%--------------------------------------------------------------------------
% load the data In (24 Environmental Variables) & Out (pollen)
% The names of the variables are stored in the cell array Names.
load pollen-small.mat

All=[In Out];

% Now split up the data into a training and an independent validation
% portion
validation_fraction=0.1;

% write to the command window
disp(['Validation Fraction is: ' num2str(validation_fraction)])

nskip=floor(1/validation_fraction);
disp(['nskip is ' num2str(nskip)])
ichoose=1:nskip:length(Out);

% Training Data
In_train=In;
Out_train=Out;



%alternative partitioning procedure
c = cvpartition(Out,'HoldOut',validation_fraction);
%partition_idx1 = training(c);
%partition_idx2 = test(c);
%In_train_Partition = In(partition_idx1,:);
%Out_train_Partition = Out(partition_idx1,:);
%In_test_Partition = In(partition_idx2,:);
%Out_test_Partition = Out(partition_idx2,:);



In_train(ichoose,:)=[];
Out_train(ichoose)=[];

% Independent Validation Data
In_test=In(ichoose,:);
Out_test=Out(ichoose);    

%length of train and test data
n_train = length(In_train);
n_test = length(In_test);


% Create a table called Data from the Input array In_train
Data=array2table(In_train,'VariableNames',Names);

% Add a column to the table for the output data called Pollen
Data.Pollen=Out_train;    

%--------------------------------------------------------------------------
% Now train a regression tree bagger called Mdl with 100 regression trees 
% using the training data set this time specified in the Data table. Specify 
% the output variable name as 'Pollen'.
% To grow unbiased trees, specify usage of the curvature test for splitting
% predictors. In case there are missing values in the data, specify usage
% of surrogate splits.  Store the out-of-bag information for predictor
% importance estimation.
Mdl = TreeBagger(...
    30,Data,'Pollen',...
    'Method','regression',...
    'Surrogate','on',...
    'PredictorSelection','curvature',...
    'OOBPredictorImportance','on'...
    );

%--------------------------------------------------------------------------
% Use the trained model, Mdl, provided with the input matrix In_train to 
% estimate the pollen values and save the results in a column vector 
% called Out_train_estimate
Out_train_estimate=predict(Mdl,In_train);
Out_test_estimate=predict(Mdl,In_test);

%--------------------------------------------------------------------------
% calculate the mean square error (MSE) of the test and training points
mse_Train=sum((Out_train_estimate-Out_train).^2)/length(Out_train)
mse_Test=sum((Out_test_estimate-Out_test).^2)/length(Out_test)


%--------------------------------------------------------------------------
% calculate the correlation coefficients for the training and test data 
% sets with the associated linear fits hint: check out the function corrcoef
R_train = corrcoef(Out_train_estimate,Out_train)
R_test = corrcoef(Out_test_estimate,Out_test)
r_train=R_train(1,2)
r_test=R_test(1,2)



%--------------------------------------------------------------------------
% |TreeBagger| stores predictor importance estimates in the property
% |OOBPermutedPredictorDeltaError|. Compare the estimates using a bar
% graph.
imp = Mdl.OOBPermutedPredictorDeltaError;

%--------------------------------------------------------------------------
% sort the importances into descending order, with the most important first
% Hint: look up the function sort with the option 'descend'
[sorted_imp,isorted_imp] = sort(imp,'descend');

%--------------------------------------------------------------------------
% Draw a horizontal bar chart showing the variables in descending order of
% importance. Hint: look up the function barh.
% Label each variable with its name. 
% Hints: (1) Look up the function text. (2) Variable names are held in 
% Mdl.PredictorNames
figure;
barh(imp(isorted_imp));
hold on;grid on;
barh(imp(isorted_imp(1:5)),'y');
barh(imp(isorted_imp(1:3)),'r');
title('Predictor Importance Estimates');
xlabel('Estimates with Curvature Tests');
ylabel('Predictors');
set(gca,'FontSize',20); 
set(gca,'TickDir','out'); 
set(gca,'LineWidth',2);
ax = gca;
ax.YDir='reverse';
ax.XScale = 'log';
xlim([0.08 4])
ylim([.25 24.75])
% label the bars
for i=1:length(Mdl.PredictorNames)
    text(...
        1.05*imp(isorted_imp(i)),i,...
        strrep(Mdl.PredictorNames{isorted_imp(i)},'_',''),...
        'FontSize',10 ...
    )
end
print('-dpng','input-importance-curvature-test.png');% save to an eps file




%--------------------------------------------------------------------------
% Find the error of our estimate
Error_train=Out_train-Out_train_estimate;


%--------------------------------------------------------------------------
% Plot an error histogram using ploterrhist
% save to a png file called nn-errhist-m.png
figure
ploterrhist(Error_train,'Training')
grid on
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('tb-errhist-m.png','-dpng')




%--------------------------------------------------------------------------
% Create a scatter diagram and label the axis 
% save to a png file called tb-scatter-m.png
figure
plot(Out_train,Out_train,'LineWidth',5)
hold on
%errorbar(Out_train,Out_train_estimate,'og')
%errorbar(Out_test,Out_test_estimate,'or')
scatter(Out_train,Out_train_estimate,'og')
scatter(Out_test,Out_test_estimate,'or')
hold off
grid on
legend_text={...
    ['1:1'],...
    ['Training Data (R ' num2str(r_train,2) ')'],...
    ['Validation Data (R ' num2str(r_test,2) ')'],...
    };
legend(legend_text,'Location','southeast');
xlabel('Actual Pollen','fontsize',20);
ylabel('Estimated Pollen','fontsize',20);
title('Scatter Diagram','fontsize',25);
xlim([0 max(Out_train)])
ylim([0 max(Out_train)])
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('tb-scatter-m.png','-dpng')