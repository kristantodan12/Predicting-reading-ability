%% First way
load('my_005_p.mat') %%Load mask
mask_my = sum(mask_acc_p');
ind = find(mask_my==499);
mask_final_my = zeros(360,1);
mask_final_my(ind) = 1;

load('ROI_List_F.mat') %% load 44 atlas
a = find(ROI_List_F==34);
b = find(ROI_List_F==36);
c = find(ROI_List_F==10);
d = [a;b;c];
e = find(mask_final_my==1);
[C,ia,ib] = intersect(d,e);

idx_p = C;
load('Reading.mat')  %% Load behavioral scores
[B,I] = mink(Reading, 998);
my_ = load('myelin.mat');  %% load the properties
my = my_.groupmyelin;
my2 = my(:,idx_p);
my3 = mean(my2');
my4 = my3(I);

load('my_005_n.mat')
mask_my_n = sum(mask_acc_n');
ind_n = find(mask_my_n==499);
mask_final_my_n = zeros(360,1);
mask_final_my_n(ind_n) = 1;

f = find(ROI_List_F==16);
g = find(ROI_List_F==12);
k = [f;g];
j = find(mask_final_my_n==1);
[C_n,ia,ib] = intersect(j,k);

idx_n = C_n;
my2_n = my(:,idx_n);
my3_n = mean(my2_n');
my4_n = my3_n(I);

%% Second Way
load('ROI_List_F.mat')
load('Reading.mat')
load('myelin.mat')
my_ = load('myelin.mat');
my = my_.groupmyelin;
my2 = zeros(998,44);
for i = 1:44
    idx = find(ROI_List_F == i);
    if length(idx)>1
        my2(:,i) = mean(my(:,idx)');
    else
        my2(:,i) = (my(:,idx));
    end
end

idx_p = [34 36 10];
[B,I] = mink(Reading, 998);
my3 = my2(:,idx_p);
my4 = mean(my3');
my5 = my4(I);
plot(my5,'b+')
lsline
hold on
idx_n = [33 21 28 14];
my6 = my2(:,idx_n);
my7 = mean(my6');
my8 = my7(I);
plot(my8,'ro')
lsline

%% First Way Structural Connectivity
mask_pos = importdata('pos_str_0.05');  %% load the connectivity mask
mask_neg = importdata('neg_str_0.05');
no_node = 360;
pos_mask = sum(mask_pos,3);
neg_mask = sum(mask_neg,3);
pos_ind = find(pos_mask == 499);
neg_ind = find(neg_mask == 499);
pos_mask_final = zeros(no_node,no_node);
neg_mask_final = zeros(no_node,no_node);
pos_mask_final(pos_ind) = 1;
neg_mask_final(neg_ind) = 1;
load('ROI_List.mat')  %% Load the 44 atlas

%Positive
conn = [16 34; 16 43; 16 42; 16 25; 16 19];
%conn = [21 7; 18 22; 18 13; 7 8; 40 39];
[idx1, idx2] = find(pos_mask_final == 1);
idx1_ROI = ROI_List(idx1);
idx2_ROI = ROI_List(idx2);
idx = [idx1_ROI idx2_ROI];
[C,ia] = ismember(idx,conn,'row');
find(C==1);
log1 = find(C==1);
idx1_ = idx1(log1);
idx2_ = idx2(log1);
load('SC.mat')  %% load the structural connectivity
SC = S(:,:,3:end);
SC2 = SC(idx1_,idx2_,:);
SC3 = mean(SC2, [1 2]);
SC4 = reshape(SC3, [1 998]);
load('Reading.mat')
[B,I] = mink(Reading, 998);
SC5 = SC4(I);
plot(SC5)

%% Plot Core + vs -
load('su_005_p.mat')
mask_my = sum(mask_acc_p');
ind = find(mask_my==499);
mask_final_my = zeros(360,1);
mask_final_my(ind) = 1;

load('ROI_List_F.mat')
a = find(ROI_List_F==34);
b = find(ROI_List_F==36);
c = find(ROI_List_F==10);
d = [a;b;c];
e = find(mask_final_my==1);
[C,ia,ib] = intersect(d,e);

idx_p = C;
load('Reading.mat')
[B,I] = mink(Reading, 998);
my_ = load('sulc.mat');
my = my_.groupsulc;
my2 = my(:,idx_p);
my3 = mean(my2');
my4 = my3(I);

load('su_005_n.mat')
mask_my_n = sum(mask_acc_n');
ind_n = find(mask_my_n==499);
mask_final_my_n = zeros(360,1);
mask_final_my_n(ind_n) = 1;

f = find(ROI_List_F==33);
g = find(ROI_List_F==21);
d = find(ROI_List_F==28);
e = find(ROI_List_F==14);
k = [d;e;f;g];
j = find(mask_final_my_n==1);
[C_n,ia,ib] = intersect(j,k);

idx_n = C_n;
my2_n = my(:,idx_n);
my3_n = mean(my2_n');
my4_n = my3_n(I);
[r,p]=corr(my4_n',my4')