clear;clc;close all

%--------------------------------------------------------------------------
% Set up the variables we will use.
% Create 2000 random x values between -1 and +1 and save them in a vector called x.
% Create 2000 random y values between -1 and +1 and save them in a vector called y.
% Use the randomn x and y values to create a highly non-linear function z=x^5 + y^4 - x^4 - y^3 

% percentage noise
noise_p = .1;
%--------------------------------------------------------------------------
% Set up the some test data
n = 1000;
x = 2*(rand(n,1)-0.5);
y = 2*(rand(n,1)-0.5);
noise = noise_p*2*(rand(n,1)-0.5);
z = (x.^5 + y.^4 - x.^4 - y.^3);
z = z+z*noise_p;


%--------------------------------------------------------------------------
% Set up the training dataset for the neural network using x & y as the inputs
% saved in a row matrix called In (i.e. the two rows of In are x & y).
% Set up the output row matrix called Out containing z.
% Input

In = [x y]';



% Output (target)
Out = z';

%--------------------------------------------------------------------------
% Now do neural network fit using Levenberg-Marquardt backpropagation
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.

% Create a Fitting Network with 10 nodes in the hidden layer

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

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

[net,tr] = train(net,In,Out);

% Use the trained network, net, provided with the input matrix In to 
% estimate the z values and save the results in a column vector called z

z_nn = net(In)';

% Calculate the error in a variable called e and plot an error histogram using ploterrhist

e = sum((z_nn - z).^2)/length(z)


R_train = corrcoef(z,z_nn)
r_train=R_train(1,2)


% save to a png file called nn-errhist-m.png

figure
ploterrhist(e,'Training')
grid on
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('nn-errhist-m.png','-dpng')

% Create a scatter diagram and label the axis

% save to a png file called nn-scatter-m.png

figure
plot(z,z,'LineWidth',10)
hold on
scatter(z,z_nn,10,'og','filled')
hold off
grid on
legend_text={...
    ['1:1'],...
    ['Training Data (R ' num2str(r_train,2) ')']...
    };
legend(legend_text,'Location','southeast');
xlabel('Actual z','fontsize',20);
ylabel('Estimated z','fontsize',20);
title('Scatter Diagram','fontsize',25);
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('nn-scatter-m.png','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
plot(z,z,'LineWidth',10)
hold on
scatterhist(z,z_nn,10)
hold off
grid on
legend_text={...
    ['1:1'],...
    ['Training Data (R ' num2str(r_train,2) ')']...
    };
legend(legend_text,'Location','southeast');
xlabel('Actual z','fontsize',20);
ylabel('Estimated z','fontsize',20);
title('Scatter Diagram','fontsize',25);
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('nn-scatter-marginal-m.png','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%z_nn_ptile = prctile(z_nn, [1:100]);

z_nn_qtile = quantile(z_nn, [0 0.25 0.50 0.75 1.00]);
qtile_labels = cellstr(num2str(z_nn_qtile'));

figure
qqplot(z,z_nn,[1:100])
text(z_nn_qtile,z_nn_qtile,qtile_labels,'VerticalAlignment','bottom','HorizontalAlignment','right')
hold off
grid on

xlabel('Actual z','fontsize',20);
ylabel('Estimated z','fontsize',20);
title('QQ Plot: Actual vs. Estimated, with Estimate Quantiles','fontsize',25);
set(gca,'FontSize',16)
set(gca,'LineWidth',2);  
print('nn-qq-m.png','-dpng')



