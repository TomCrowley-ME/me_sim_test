%-------------------------------------------------------------------------%
% plot_mc_distribution.m                                                  %
%                                                                         %
% 07/21/14                                                                %
%-------------------------------------------------------------------------%

function [ data_pdf, model ] = plot_mc_distribution(data, data_description, data_unit, varargin)

if nargin > 3
    save_flag = varargin{1};
else
    save_flag = 0;
end

bin_width = range(data)/50;

if bin_width > 10
    factor = 0.1;
elseif bin_width > 1
    factor = 1;
elseif bin_width > 0.1
    factor = 10;
elseif bin_width > 0.01
    factor = 100;
end

bin_width = round(bin_width*factor)/factor;
low_point = floor(min(data)*factor)/factor;
high_point = ceil(max(data)*factor)/factor;

bin_centers = [low_point : bin_width : high_point];

n = hist(data, bin_centers);

data_pdf.x = bin_centers;
data_pdf.y = (n/sum(n))/bin_width;

figure(1); clf 
set(gcf,'Position',[405    319    1152     648])
bar(data_pdf.x, data_pdf.y,'FaceColor',[0.3906    0.5820    0.9258])
grid on; hold on;

[D, PD] = allfitdist(data);
model = PD{1};


% best fit
xs = [data_pdf.x(1) : bin_width/10 : data_pdf.x(end)];
ys = cellfun(@(PD) pdf(PD,xs), PD(1),'UniformOutput',0);

plot(xs,ys{1},'k','LineWidth', 2)

% gaussian fit
yg = pdf('norm', xs, mean(data), std(data));
plot(xs, yg, ':', 'Color', [0 0.5 0], 'LineWidth', 2)


% best fit 99% limit
lim99 = icdf(model, 0.99);

ylimit = ylim;
plot(lim99*[1 1], ylimit,'r','LineWidth',2)

% replot best fit for more prominence
plot(xs,ys{1},'k','LineWidth', 2)

xlim([-bin_width/2 data_pdf.x(end)+bin_width])



M = {'Emperical PDF',[PD{1}.DistributionName ' Fit (best)'], 'Gaussian Fit', ['Best fit 99% Boundary = ' sprintf('%.2f %s', lim99, data_unit)]};
legend_handle = legend(M, 'FontName','Courier','FontSize',12,'Location','NorthEast'); 
set(legend_handle, 'EdgeColor', 'k')
xlabel([ ' (' data_unit ')'],'FontName','Courier','FontSize',14)
title(data_description,'FontName','Courier','FontSize',16)


if save_flag
    set(figure(1),'Renderer','painters');
    print(gcf,'-depsc',sprintf( 'histogram_%s', regexprep(data_description,'\s','_') ) );
end



