function A = TriArea(F,V)
% Numerically stable Heron's formula for area of triangle.

if nargin == 1
    E2 = F;
else
    V1 = V(F(:,1),:); V2 = V(F(:,2),:); V3 = V(F(:,3),:);
    E2 = [BatchNorm(V1 - V2,2), BatchNorm(V2 - V3,2), BatchNorm(V3 - V1,2)];
end
E2 = sort(E2,2,'descend');
a = E2(:,1); b = E2(:,2);  c = E2(:,3);

terms = [a+(b+c), c-(a-b), c+(a-b), a+(b-c)];  % do not remove the blackets
A = sqrt(prod(terms,2))/4;
end