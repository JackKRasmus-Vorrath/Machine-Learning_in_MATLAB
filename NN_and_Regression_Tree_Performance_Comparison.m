clear;clc;close all

%--------------------------------------------------------------------------
% load the data In (24 Environmental Variables) & Out (pollen)
% The names of the variables are stored in the cell array Names.
load pollen-small.mat

%--------------------------------------------------------------------------
% Split up the data to provide (1) a training dataset and (2) an 
% independent validation dataset of a size specified by the validation 
% fraction variable that you should call validation_fraction.
% Use a validation fraction of 0.1, i.e. use 10% of the dataset for 
% independent validation.
validation_fraction=0.1;

% write to the command window
disp(['Validation Fraction is: ' num2str(validation_fraction)])

% Create a random nonstratified partition for holdout validation on n 
% observations using a cvpartition object
c = cvpartition(Out,'holdout', validation_fraction);

% Create training dataset variables called InTrain & OutTrain containing 
% 90% of the input data stored in the variables In and Out.
InTrain = In(training(c,1),:);
OutTrain = Out(training(c,1));

% Find the number of records in the training dataset and save it in a variable
% called n_train
n_train = size(InTrain,1);

% Create an independent Validation dataset called InTest & OutTest
% containing 10% of the input data stored in the variables In and Out
InTest=In;
OutTest=Out;

InTest(training(c,1),:)=[];
OutTest(training(c,1))=[];

% Find the number of records in the independent Validation dataset and 
% save it in a variable called n_test
n_test = size(InTest,1);

%--------------------------------------------------------------------------
% Create a table called Data from the Input training data array, InTrain
Data=array2table(InTrain,'VariableNames',Names);

%  Add a column called Pollen to the table for the output data using OutTrain
Data.Pollen=OutTrain;


%--------------------------------------------------------------------------
% Fit 1: TreeBagger
%
% Train a regression tree bagger called Mdl_TB with 30 regression trees 
% using the entire data set specified in the Data table. Specify 
% the output variable name as 'Pollen'.
% To grow unbiased trees, specify usage of the curvature test for splitting
% predictors. In case there are missing values in the data, specify usage
% of surrogate splits.  Store the out-of-bag information for predictor
% importance estimation.
Mdl_TB = TreeBagger(...
    30,Data,'Pollen',...
    'Method','regression',...
    'Surrogate','on',...
    'PredictorSelection','curvature',...
    'OOBPredictorImportance','on'...
    );

%--------------------------------------------------------------------------
% Use the trained model, Mdl_TB, provided with the input matrix InTrain to 
% estimate the pollen values and save the results in a column vector 
% called Out_Train_TB
Out_Train_TB=predict(Mdl_TB,InTrain);

%--------------------------------------------------------------------------
% Use the trained model, Mdl_TB, provided with the independent validation data 
% input matrix InTest to estimate the pollen values and save the results in 
% a column vector called Out_Test_TB
Out_Test_TB=predict(Mdl_TB,InTest);

%--------------------------------------------------------------------------
% Save the mean square error (MSE) of the TreeBagger model Mdl_TB in a 
% variable called mseTrain_TB for the estimated pollen using as input to the 
% model Mdl_TB the training data points in the input array InTrain
mseTrain_TB=sum((Out_Train_TB - OutTrain).^2)/length(OutTrain);

%--------------------------------------------------------------------------
% Save the mean square error (MSE) of the TreeBagger model Mdl_TB in a 
% variable called mseTest_TB for the estimated pollen using as input to the 
% model Mdl_TB the independent validation data points in the input array InTest
mseTest_TB=sum((Out_Test_TB - OutTest).^2)/length(OutTest);

%--------------------------------------------------------------------------
% Save the correlation coefficient for the training data with the 
% associated TreeBagger model estimates in a variable called r_train_TB
R_train_TB=corrcoef(Out_Train_TB,OutTrain);
r_train_TB=R_train_TB(1,2);

%--------------------------------------------------------------------------
% Save the correlation coefficient for the independent testing data with the 
% associated TreeBagger model estimates in a variable called r_test
R_test=corrcoef(Out_Test_TB,OutTest);
r_test=R_test(1,2);

%--------------------------------------------------------------------------
% Calculate the error for the training dataset in a variable called eTrain_TB
% and calculate the error for the testing dataset in a variable called eTest_TB. 
eTrain_TB=Out_Train_TB - OutTrain;
eTest_TB=Out_Test_TB - OutTest;


%--------------------------------------------------------------------------
% Fit 2: Neural Network
%
% Now do a neural network fit using Levenberg-Marquardt backpropagation
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations

% Levenberg-Marquardt backpropagation
trainFcn = 'trainlm';

% Create a Fitting Network with 10 nodes in the hidden layer
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of the training Data as follows:
% 70% of the data used for Training, 
% 15% of the Data used for Validation, Testing
% 15% of the Data used for Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,InTrain',OutTrain');

% Use the trained neural network, net, provided with the input matrix, InTrain, to 
% estimate the pollen values and save the results in a column vector 
% called Out_Train_NN
Out_Train_NN = net(InTrain')';

% Use the trained neural network, net, provided with the independent validation data 
% input matrix, InTest, to estimate the pollen values and save the results in 
% a column vector called Out_Test_NN
Out_Test_NN = net(InTest')';

% Save the mean square error (MSE) of the trained neural network, net, in a 
% variable called mseTrain_NN for the estimated pollen using as input to the 
% model the training data points in the input array InTrain
mseTrain_NN=sum((Out_Train_NN - OutTrain).^2)/length(OutTrain);

% Save the mean square error (MSE) of the trained neural network, net, in a 
% variable called mseTest_NN for the estimated pollen using as input to the 
% model the independent validation data points in the input array InTest
mseTest_NN=sum((Out_Test_NN - OutTest).^2)/length(OutTest);

% Save the correlation coefficient for the training data with the 
% associated Neural Network Model estimates in a variable called r_train_NN
R_train_NN=corrcoef(Out_Train_NN,OutTrain);
r_train_NN=R_train_NN(1,2);

% Save the correlation coefficient for the independent testing data with the 
% associated Neural Network Model estimates in a variable called r_test_NN
R_test_NN=corrcoef(Out_Test_NN,OutTest);
r_test_NN=R_test_NN(1,2);

% Calculate the error for the training dataset in a variable called eTrain_NN
% and calculate the error for the testing dataset in a variable called eTest_NN
% then plot an error histogram using ploterrhist
eTrain_NN = Out_Train_NN - OutTrain;
eTest_NN = Out_Test_NN - OutTest;

figure
ploterrhist(eTrain_NN,'Training',eTest_NN,'Test')
grid on
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('nn-errhist-m.png','-dpng')

% Create an error histogram comparing eTest_TB and eTest_NN
% save to a png file called errhist-m.png
figure
ploterrhist(eTest_TB,'Testing TB',eTest_NN,'Testing NN','bins',20)
grid on
%legend_text={...
%   ('Testing TB'),...
%   ('Testing NN')...
%    };
legend('Location','best');
xlabel('Errors','fontsize',20);
ylabel('Instances','fontsize',20);
title('Error Histogram with 20 Bins','fontsize',25);
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('errhist-m.png','-dpng')

% Create a scatter diagram and label the axes and add a legend which
% contains the correlation coefficients for each scatter line
% save to a png file called scatter-m.png
figure
plot(OutTrain,OutTrain,'LineWidth',5)
hold on
scatter(OutTrain,Out_Train_TB,10,'og','filled')
scatter(OutTest,Out_Test_TB,10,'or','filled')
scatter(OutTrain,Out_Train_NN,10,'xg')
scatter(OutTest,Out_Test_NN,10,'xr')
hold off
grid on
legend_text={...
    ('1:1'),...
    ['TB Training Data (R ' num2str(r_train_TB,2) ')'],...
    ['TB Testing Data (R ' num2str(r_test,2) ')'],...
    ['NN Training Data (R ' num2str(r_train_NN,2) ')'],...
    ['NN Testing Data (R ' num2str(r_test_NN,2) ')'],...
    };
legend(legend_text,'Location','best');
xlabel('Actual Pollen','fontsize',20);
ylabel('Estimated Pollen','fontsize',20);
title('Scatter Diagram','fontsize',25);
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('scatter-m.png','-dpng')
