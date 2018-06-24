clear;clc;close all

%% Cancer Detection
% In this homework you will be using a neural network to detect cancer from
% mass spectrometry data on protein profiles.

%% Read in the data
[x,t] = ovarian_dataset;
whos

%%
% Each column in |x| represents one of 216 different patients.
%
% Each row in |x| represents the ion intensity level at one of the 100
% specific mass-charge values for each patient.
%
% The variable |t| has 2 rows of 216 values each of which are either [1;0],
% indicating a cancer patient, or [0;1] for a normal patient.




%% Classification Using a Feed Forward Neural Network
% You can use this information to classify the cancer and normal samples.

%%
% Create and view a 1-hidden layer feed forward neural network with 5 
% hidden layer neurons using patternnet.
trainFcn = 'trainlm';

hiddenLayerSize = 5;
net = patternnet(hiddenLayerSize,trainFcn);
net.performFcn = 'crossentropy';
%net.layers{2}.transferFcn = 'logsig';

%%
% Train the network using x as the inputs and t as the target outputs using
% the function train. The samples are automatically divided into training, 
% validation and test sets. The training set is used to teach the network.
% Training continues as long as the network continues improving on the 
% validation set. The test set provides a completely independent measure of 
% network accuracy.

[net,tr] = train(net,x,t);

%%
% Show how the network's performance improved during training using plotperform.
% Performance is measured in terms of mean squared error, and shown in log
% scale.  It should rapidly decrease as the network is trained.
% Performance is shown for each of the training, validation and test sets.
% The version of the network that did best on the validation set is identified
% after training.
% save the figure to a png file called nn-performance.png

figure
plotperform(tr)
print('nn-performance.png','-dpng');

%%
% The trained neural network can now be tested with the testing samples we
% partitioned from the main dataset. The testing data was not used in
% training in any way and hence provides an "out-of-sample" dataset to test
% the network on. This will give us a sense of how well the network will do
% when tested with data from the real world.
%
% The network outputs will be in the range 0 to 1.
% Threshold them to get 1's and 0's indicating cancer or normal patients respectively.
% Create a matrix testX with the testing input data.
% Create a vector testT with the testing target data.
% Hint: The object tr returned by the train function you should have used above 
% includes the vector testInd which are the indices of the test data points
% used in training the neural network

tr = tr
whos tr;

y = net(x);

testX = x(:, [tr.testInd]);
%testX
whos testX

testY = y([tr.testInd]);
testY
whos testY

testT = t([tr.testInd]);
testT
whos testT

test_binary_perf = crossentropy(net,testT,testY)
%whos binary_perf
test_binary_perf;

test_confusion = plotconfusion(testT,testY)
test_confusion;




%%
% One measure of how well the neural network has fit the data is the
% confusion plot.  Plot a confusion matrix across all samples.
%
% The confusion matrix shows the percentages of correct and incorrect
% classifications.  Correct classifications are the green squares on the
% matrices diagonal.  Incorrect classifications form the red squares.
%
% If the network has learned to classify properly, the percentages in the
% red squares should be very small, indicating few misclassifications.
%
% If this is not the case then further training, or training a network with
% more hidden neurons, would be advisable.
% Hint: Use plotconfusion.
% save the figure to a png file called nn-confusion.png

figure
overall_confusion = plotconfusion(t,y)
overall_confusion
print('nn-confusion.png','-dpng');


%%
% Create a Classification confusion matrix using the function confusion.
% Use this to print the overall percentages of correct and incorrect classification.

[c,cm,ind,per] = confusion(t,y);
c
cm
per


%%
% Another measure of how well the neural network has fit data is the
% receiver operating characteristic plot.  This shows how the false
% positive and true positive rates relate as the thresholding of outputs is
% varied from 0 to 1.
%
% The farther left and up the line is, the fewer false positives need to be
% accepted in order to get a high true positive rate.  The best classifiers
% will have a line going from the bottom left corner, to the top left
% corner, to the top right corner, or close to that.
%
% Class 1 indicate cancer patiencts, class 2 normal patients.
% Create a receiver operating characteristic plot.
% Hint: Use plotroc
% save the figure to a png file called nn-roc.png

figure
overall_roc = plotroc(t,y)
overall_roc
print('nn-roc.png','-dpng');

%%
% This example illustrated how neural networks can be used as classifiers
% for cancer detection. One can also experiment using techniques like
% principal component analysis to reduce the dimensionality of the data to
% be used for building neural networks to improve classifier performance.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear;clc;close all

%% Cancer Detection
% In this homework you will be using a neural network to detect cancer from
% mass spectrometry data on protein profiles.

%% Read in the data
[x,t] = ovarian_dataset;
whos

% Use Principal Component Analysis to preprocess the inputs and keep 95% of
% the variance. Hint use the function pca.
% Hint: The function pca will be expecting a column vector and x is a row vector
% so supply pca with the transpose of x, i.e. x'. Once you have kept the
% desired number of scores you will need to take the transpose of the
% scores as the neural network training function will be expecting an
% input matrix where the rows are the variables.

% Determine how many components to keep to explain the desired amount of variance.
% Save the number of components in a variable called numComponentsToKeep

[coeff,scores,latent,tsquared,explained,mu] = pca(x', 'NumComponents', 2);

%First two PCs explain 95% of the variance
%explained

numComponentsToKeep = 2;

whos scores

trainFcn = 'trainlm';

hiddenLayerSize = 5;
net = patternnet(hiddenLayerSize,trainFcn);
net.performFcn = 'crossentropy';

x_pca = scores'

[net,tr] = train(net,x_pca,t);

figure
plotperform(tr)
print('nn-performance-pca.png','-dpng');

tr = tr
%whos tr;

y = net(x_pca);

testX = x_pca(:, [tr.testInd]);
%testX
%whos testX

testY = y([tr.testInd]);
%testY
%whos testY

testT = t([tr.testInd]);
%testT
%whos testT

test_binary_perf = crossentropy(net,testT,testY)
%whos binary_perf
%test_binary_perf;

test_confusion = plotconfusion(testT,testY)
test_confusion;

figure
overall_confusion = plotconfusion(t,y)
overall_confusion
print('nn-confusion-pca.png','-dpng');

[c,cm,ind,per] = confusion(t,y);
c
cm
per

figure
overall_roc = plotroc(t,y)
overall_roc
print('nn-roc-pca.png','-dpng');
