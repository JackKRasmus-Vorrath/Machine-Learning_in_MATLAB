function [] = plotconfusionmatrix(confmat,ClassLabels)


% Calculate percentages & set up each grid cell's labels
confmat_sum=sum(confmat);
nconfmat=size(confmat);
for i=1:nconfmat(1)
    for j=1:nconfmat(2)
        pconfmat(i,j)=100*confmat(i,j)./confmat_sum(1,j);
        if confmat(i,j)>0
            label_matrix{i,j}=[...
                num2str(pconfmat(i,j),'%0.0f') '% ' ...
                '(' char(numberFormatter(confmat(i,j),'###,###')) ')'...
                ];
        else
            label_matrix{i,j}='';
        end
    end
end
disp('Percentage Confusion Matrix');
disp(pconfmat);

[hImage, hText, hXText] = heatmap(...
    pconfmat, ClassLabels, ClassLabels, label_matrix,...
    'Colormap','winter',...
    'ShowAllTicks',1,...
    'FontSize',11,...
    'TickFontSize',16,...
    'GridLines','-'...
    );

% Set up the colormap
ncolors=100;
r=linspace(1,0.5,ncolors);
g=linspace(0.75,1,ncolors);
b=zeros(size(g));
map=[r' g' b'];
map(1,:)=1;
colormap(map)
c = colorbar;
title(c,'%')
xlabel('Predicted Class','FontSize',30)
ylabel('True Class','FontSize',30)
