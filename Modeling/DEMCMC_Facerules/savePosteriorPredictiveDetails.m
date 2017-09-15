%% Posterior predictive check
% figure
subplotloc = [3 6 2 5 9 8 1 4 7];
n.items = 9;
nd = 10000;
[nr, nc] = nsubplots(n.items);
cnt = 1;
n.burnin = n.mc - 750;
titles = {'x_2y_2', 'x_2y_1', 'x_1y_2', 'x_1y_1', 'x_2y_0', 'x_1y_0', 'x_0y_2', 'x_0y_1', 'x_0y_0'};

for k = 1:n.items
%     subplot(nr,nc,subplotloc(k)); 
    n.simsamps = 20;
    
    % Select samples and get posterior samples

    simdata.rt = []; simdata.resp = []; 
    cnt = 1; 
    for i = round(linspace(n.burnin, n.mc, n.simsamps))
        db1  = theta.('db1')(datasample(1:n.chains, 1),i);
        db2  = theta.('db2')(datasample(1:n.chains, 1),i);
        sp1  = theta.('sp1')(datasample(1:n.chains, 1),i);
        sp2  = theta.('sp2')(datasample(1:n.chains, 1),i);
%         A    = theta.('A')(datasample(1:n.chains, 1),i);
        bMa1 = theta.('bMa1')(datasample(1:n.chains, 1),i);
        bMa2 = theta.('bMa2')(datasample(1:n.chains, 1),i);
        s    = theta.('s')(datasample(1:n.chains, 1),i);
        t0   = theta.('t0')(datasample(1:n.chains, 1),i);
        
        if strcmp(model, 'serialst')
            A    = theta.('A')(datasample(1:n.chains, 1),i);
            pX = theta.('pX')(datasample(1:n.chains, 1),i);
            parmstr = 'db1, db2, sp1, sp2, A, bMa1, bMa2, s, t0, pX';
        elseif strcmp(model, 'mixedSPst')
            A = [];
            pX   = theta.('pX')(datasample(1:n.chains, 1),i);
            m    = theta.('m')(datasample(1:n.chains, 1),i);
            pSer = theta.('pSer')(datasample(1:n.chains, 1),i);
            Aser = theta.('Aser')(datasample(1:n.chains, 1),i);
            Apar = theta.('Apar')(datasample(1:n.chains, 1),i);
            parmstr = 'db1, db2, sp1, sp2, A, bMa1, bMa2, s, t0, pX, m, pSer, Aser, Apar';
        else
            A    = theta.('A')(datasample(1:n.chains, 1),i);
            parmstr = 'db1, db2, sp1, sp2, A, bMa1, bMa2, s, t0';
        end
%         eval(sprintf('[tmp.rt, tmp.resp] = sim%s(nd, x, stoppingrule, %s);', model(1:end-2), parmstr))
       eval(sprintf('[tmp, simparms] = generateTestData(model, nd, data.stimloc, %s);', parmstr)) 

        simdata.rt = [simdata.rt; tmp.rt(tmp.item == k)];
        simdata.resp = [simdata.resp; tmp.resp(tmp.item == k)];
        simdata.item = [simdata.item; tmp.item(tmp.item == k)];
        
        sim.rt{k,cnt} = tmp.rt(tmp.item == k);
        sim.resp{k,cnt} = tmp.resp(tmp.item == k);
        cnt = cnt + 1; 
    end
    
    % Histogram actual data
    tmp.datart = data.rt(data.item == k);
    tmp.datart(data.resp(data.item == k) == 2) = -1 * tmp.datart(data.resp(data.item == k) == 2);
    tmp.datart(abs(tmp.datart)>3)=nan; % Just remove some outliers for plotting purposes.
    
%     t = linspace(-4, 4, 50);
%     [c, e] = hist(tmp.datart, t);
%     b = bar(e, c./trapz(e,c), 'hist'); % * mean(tmp.dataacc == 1), 'hist');
%     set(b, 'FaceColor', [0 .95 .95])
%     hold on
    
%     % Plot line data
%     tmp.simrt = simdata.rt;
%     tmp.simrt(simdata.resp == 2) = -1 * tmp.simrt(simdata.resp == 2);
%     tmp.simrt(abs(tmp.simrt)>3)=nan; % Just remove some outliers for plotting purposes.
%     
%     hbw = getbandwidth(tmp.simrt(~isnan(tmp.simrt)));
%     [dens, xi] = ksdensity(tmp.simrt(~isnan(tmp.simrt)), 'kernel', 'epanechnikov', 'bandwidth', .01); % This uses KDE 
%     plot(xi, dens, '-r', 'LineWidth', 2)
%     xlabel('RT (secs)')
%     ylabel('Density')
%     title(titles{k});
end