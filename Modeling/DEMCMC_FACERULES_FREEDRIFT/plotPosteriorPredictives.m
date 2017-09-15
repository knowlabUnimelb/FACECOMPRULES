%% Posterior predictive check
figure
subplotloc = [3 6 2 5 9 8 1 4 7];
n.items = 9;
nd = 10000;
[nr, nc] = nsubplots(n.items);
cnt = 1;
n.burnin = n.mc - 750;
for k = 1:n.items
    subplot(nr,nc,subplotloc(k)); 
    n.simsamps = 20;
    
    % Select samples and get posterior samples
    simdata.rt = []; simdata.resp = []; 
    for i = round(linspace(n.burnin, n.mc, n.simsamps))
        for vi = 1:9
            eval(sprintf('v%d  = theta.(''v%d'')(datasample(1:n.chains, 1),i);',vi, vi))
        end

        A    = theta.('A')(datasample(1:n.chains, 1),i);
        bMa1 = theta.('bMa1')(datasample(1:n.chains, 1),i);
        bMa2 = theta.('bMa2')(datasample(1:n.chains, 1),i);
        s    = theta.('s')(datasample(1:n.chains, 1),i);
        t0   = theta.('t0')(datasample(1:n.chains, 1),i);
        
        parmstr = 'v1, v2, v3, v4, v5, v6, v7, v8, v9, A, bMa1, bMa2, s, t0';
        
%         eval(sprintf('[tmp.rt, tmp.resp] = sim%s(nd, x, stoppingrule, %s);', model(1:end-2), parmstr))
       eval(sprintf('[tmp, simparms] = generateTestData(model, nd, data.stimloc, %s);', parmstr)) 

        simdata.rt = [simdata.rt; tmp.rt(tmp.item == k)];
        simdata.resp = [simdata.resp; tmp.resp(tmp.item == k)];
    end
    
    % Histogram actual data
    tmp.datart = data.rt(data.item == k);
    tmp.datart(data.resp(data.item == k) == 2) = -1 * tmp.datart(data.resp(data.item == k) == 2);
    tmp.datart(abs(tmp.datart)>3)=nan; % Just remove some outliers for plotting purposes.
    
    [c, e] = hist(tmp.datart, 50);
    b = bar(e, c./trapz(e,c), 'hist'); % * mean(tmp.dataacc == 1), 'hist');
    set(b, 'FaceColor', [0 .95 .95])
    hold on
    
    % Plot line data
    tmp.simrt = simdata.rt;
    tmp.simrt(simdata.resp == 2) = -1 * tmp.simrt(simdata.resp == 2);
    tmp.simrt(abs(tmp.simrt)>3)=nan; % Just remove some outliers for plotting purposes.
    
    hbw = getbandwidth(tmp.simrt(~isnan(tmp.simrt)));
    [dens, xi] = ksdensity(tmp.simrt(~isnan(tmp.simrt)), 'kernel', 'epanechnikov', 'bandwidth', .01); % This uses KDE 
    plot(xi, dens, '-r', 'LineWidth', 2)
end