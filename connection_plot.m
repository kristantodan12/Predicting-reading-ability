%Connection Density
SC_avg = importdata('SC_RL_50p.mat');
load('union_ab.mat')
load('areas_ab.mat')
matrix = union_ab;
for i = 1:3
    % Ability 1
    abb_uni1 = matrix(:,i);
    ind_abb_uni1 = find(abb_uni1==1);
    for j = 1:3
        % Ability 2
        clear SC_total_all
        abb_uni2 = matrix(:,j);
        ind_abb_uni2 = find(abb_uni2==1);
        for y = 1:length(ind_abb_uni1)
            ind_y = ind_abb_uni1(y);
            for z  = 1:length(ind_abb_uni2)
                ind_z = ind_abb_uni2(z);
                if ind_y == ind_z
                    SC_total = nan;
                else
                    SC_total = SC_avg(ind_y,ind_z);
                end
                SC_total_all(y,z) = SC_total;
            end
        end
        [sz1,sz2] = size(SC_total_all);
        sz3 = length(find(isnan(SC_total_all)));
        total = length(find(SC_total_all>0))/((sz1*sz2)-sz3);
        total_all(i,j) = total;
    end
end
