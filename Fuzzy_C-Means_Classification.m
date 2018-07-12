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

% Find 3 clusters using fuzzy c-means clustering.

[centers,U] = fcm(x,3);

% Classify each data point into the cluster with the largest membership value.

maxU = max(U);
index1 = find(U(1,:) == maxU);
index2 = find(U(2,:) == maxU);
index3 = find(U(3,:) == maxU);

% Plot the results of the fuzzy clustering.
% Use only the last two columns makes it easier to plot.
% Label the X & Y axes appropriately, add a Legend,
% add grid lines. Add the center points of each fuzzy cluster
% save the data to a color encapsulated 
% postscript file called FuzzyCMean.eps

figure
scatter(x(index1,3),x(index1,4),'or','filled')
hold on
scatter(x(index2,3),x(index2,4),'og','filled')
scatter(x(index3,3),x(index3,4),'ob','filled')
legend('Location','southeast')
title('Fuzzy Classes','FontSize',30)
xlabel('Petal Length','FontSize',20)
ylabel('Petal Width','FontSize',20)
plot(centers(1,3),centers(1,4),'xr','MarkerSize',15,'LineWidth',3)
plot(centers(2,3),centers(2,4),'xg','MarkerSize',15,'LineWidth',3)
plot(centers(3,3),centers(3,4),'xb','MarkerSize',15,'LineWidth',3)
hold off
grid on
set(gca,'TickDir','out'); set(gca,'LineWidth',2);set(gca,'FontSize',12); 
print('-depsc2','FuzzyCMean.eps');