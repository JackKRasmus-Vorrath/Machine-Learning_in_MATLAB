clear;clc;close all

% Load in the Fisher Iris Data
% Fisher's iris data set contains species (species) and 
% measurements (meas) on sepal length, sepal width, petal length, 
% and petal width for 150 iris specimens. The data set contains 50 
% specimens from each of three species: setosa, versicolor, and 
% virginica.

load fisheriris
x = meas(:,1:4);

% Plot the input data using gscatter.
% Use only the last two columns makes it easier to plot.
% Label the X & Y axes appropriately, add a Legend,
% add grid lines, save the data to a color encapsulated 
% postscript file called IrisData.eps

gscatter(x(:,3),x(:,4),species)
legend('Location','southeast')
grid on
title('Actual Data','FontSize',30)
xlabel('Petal Length','FontSize',20)
ylabel('Petal Width','FontSize',20)
set(gca,'TickDir','out'); set(gca,'LineWidth',2);set(gca,'FontSize',12);
print('-depsc2','IrisData.eps');


% Create a Self-Organizing Map with 3 classes to classify the irises
% First, set up an SOM called net with 3 classes

net = selforgmap([3 1]);


% Train the SOM

[net,tr] = train(net,x');

% Use the Network to classify each record 

icluster_som = vec2ind(net(x'))';

% Plot the results
% save the data to a color encapsulated 
% postscript file called SOM.eps

figure
gscatter(x(:,3),x(:,4),icluster_som)
legend('Location','southeast');grid on
title('SOM Classes','FontSize',30)
xlabel('Petal Length','FontSize',20)
ylabel('Petal Width','FontSize',20)
set(gca,'TickDir','out'); set(gca,'LineWidth',2);set(gca,'FontSize',12); 
print('-depsc2','SOM.eps');
