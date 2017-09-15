function rate = computeAcceptanceRate(theta)

nmc = size(theta, 2);
for i = 2:nmc
    accept(i-1) = sum(theta(:,i) ~= theta(:,i-1));
end
rate = sum(accept)./(size(theta,1) * (size(theta,2)-1));
% rate = accept./(size(samples,2)-1);
% plot(accept./(size(samples,2)-1))
    