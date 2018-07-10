clear;clc;close all

%% Cancer Detection
% In this homework you will be using an ensemble of decision trees to detect 
% cancer from mass spectrometry data on protein profiles.

%% Read in the data
[x,t] = ovarian_dataset;

% recast so that the variables are column vectors
x=x';
t=vec2ind(t)';
whos

Mdl_TB = TreeBagger(...
    50,x,t,...
    'Method','classification',...
    'Surrogate','on',...
    'PredictorSelection','curvature',...
    'OOBPredictorImportance','on'...
    );

imp = Mdl_TB.OOBPermutedPredictorDeltaError;

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
barh(imp(isorted_imp(1:20)));
hold on;grid on;
barh(imp(isorted_imp(1:20)),'y');
barh(imp(isorted_imp(1:5)),'r');
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
for i=1:20
    text(...
        1.05*imp(isorted_imp(i)),i,...
        strrep(Mdl_TB.PredictorNames{isorted_imp(i)},'_',''),...
        'FontSize',10 ...
    )
end
print('-dpng','TB-importance-curvature-test.png');% save to an eps file

%%%Visualize with imagesc()

% Use the Mdl to estimate the presence/absence of cancer and plot a confusion matrix 
%t_fit=str2num(cell2mat(predict(Mdl_TB,x)));
%C = confusionmat(t, t_fit);

%imagesc(C);
%colorbar;

%print('-dpng','ConfusionMatrixTB.png');% save to an eps file


%%%Visualize with helper functions plotconfusionmatrix(), heatmap(), and numberFormatter()

% Use the Mdl to estimate the presence/absence of cancer and plot a confusion matrix 
t_fit=str2num(cell2mat(predict(Mdl_TB,x)));
ClassNames={'0','1'};
figure;
C=confusionmat(t,t_fit);

plotconfusionmatrix(C,ClassNames)
print('-dpng','ConfusionMatrixTB.png');% save to an eps file
