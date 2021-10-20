%% Looping th mask 44 regions
mask = importdata('pos_funcfilt_0.05');
load('ROI_List_F.mat')

for k = 1:length(mask)
    mask_ind = mask(:,:,k);
    [a,b] = find(mask_ind==1);
    a2 = ROI_List_F(a);
    b2 = ROI_List_F(b);
    c = [a2 b2];
    [C,ia,ic] = unique(c(:,1:2),'rows');
    a_counts = accumarray(ic,1);
    counts = [C, a_counts];
    conn_mat = zeros(44,44);
    conn_mat_log = zeros(44,44);
    row = counts(:,1);
    col = counts(:,2);
    value = counts(:,3);
    for i = 1:length(row)
        conn_mat(row(i),col(i)) = value(i);
        conn_mat_log(row(i),col(i)) = 1;
    end
    mask_ind_{k} = conn_mat;
end

mask_tot = cat(3, mask_ind_{:});
means = mean(mask_tot,3);
con = means;
con2 = round(con);
x = repmat(1:44,44,1);
y = x';
t = num2cell(con2);
t = cellfun(@num2str, t, 'UniformOutput', false);
imagesc(con2)
text(x(:), y(:), t, 'HorizontalAlignment', 'Center')
set(gcf,'color','w');

load('ROI_List_neg2.mat');
 load('index_pos_final.mat')
for i = 1:5
    no_node(:,i) = length(find(index_pos == i));
end
no_node(5) = no_node(5)+50;
mask = con2;
[a,b] = find(mask>0);
a2 = ROI_List_neg(a);
b2 = ROI_List_neg(b);
c = [a2 b2];
[C,ia,ic] = unique(c(:,1:2),'rows');
a_counts = accumarray(ic,1);
counts = [C, a_counts];
conn_mat = zeros(5,5);
conn_mat_log = zeros(5,5);
row = counts(:,1);
col = counts(:,2);
value = counts(:,3);
for i = 1:length(row)
    conn_mat(row(i),col(i)) = value(i);
    conn_mat_log(row(i),col(i)) = 1;
end
con3 = conn_mat./no_node';

figure
x = repmat(1:5,5,1);
y = x';
t = num2cell(con3);
t = cellfun(@num2str, t, 'UniformOutput', false);
imagesc(con3)
text(x(:), y(:), t, 'HorizontalAlignment', 'Center')
xticklabels({' ','1',' ','2',' ','3',' ','4',' ','5'})
yticklabels({' ','1',' ','2',' ','3',' ','4',' ','5'})
xlabel('End of connections')
ylabel('Start of connections')
set(gcf,'color','w');

%% Coef of varianceub
avr = mean(CM_vcts);
stdv = std(CM_vcts);
CV = stdv./avr;
CV = reshape(CV,360,360);
b = find(isnan(CV));
CV(b)=0;
weak = find(CV>=1);
weak2 = find(CV<=-1);
strong = find(CV<1&CV>0);
strong2 = find(CV<0&CV>-1);
CV_pos = zeros(360,360);
CV_pos(weak) = -1;
CV_pos(weak2) = -1;
CV_pos(strong) = 1;
CV_pos(strong2) = 1;

%% Covariance of mask
e = find(all(CM_vcts==0));
CM_vcts2 = CM_vcts;
CM_vcts2(:,e) = [];
C = cov(CM_vcts2);
[r,p] = corr(CM_vcts2);
