%% Load data
th_ = load('myelin.mat');
read_ = load('Reading.mat');
th = th_.groupmyelin;
read = read_.Reading;
thres = 0.05;

%% Divide data
o = length(th);
P = 0.5;
idx = 1:o;
th=th';
train_input = th(:,idx(1:round(P*o))); 
test_input = th(:,idx(round(P*o)+1:end)); 
train_output = read(idx(1:round(P*o)),:) ; 
test_output = read(idx(round(P*o)+1:end),:);

%% Model Development LOOV (+ and -)
for leftout = 1:length(train_input)
    fprintf('\n Leaving out subj # %6.3f',leftout);
    train_mats = train_input;
    train_mats(:,leftout) = [];
    
    train_behav = train_output;
    train_behav(leftout) = [];
    
    [r,p] = corr(train_mats',train_behav);
    mask_p = zeros(360,1);
    mask_n = zeros(360,1);
    idx_p = find(r > 0 & p < thres);
    idx_n = find(r < 0 & p < thres);
    mask_p(idx_p) = 1;
    mask_n(idx_n) = 1;
    
    for s = 1:length(train_mats)
        X_p(:,s) = train_mats(:,s).*mask_p;
        X_n(:,s) = train_mats(:,s).*mask_n;
    end
    
    e_p = find(all(X_p'==0));
    predictor_p = X_p;
    predictor_p(e_p,:) = [];
    
    e_n = find(all(X_n'==0));
    predictor_n = X_n;
    predictor_n(e_n,:) = [];
    
    k = 15;
    
    %Using ridge
%     B1_p = ridge(train_behav,predictor_p',k,0);
%     B1_n = ridge(train_behav,predictor_n',k,0);
    
    %Using Elastic Net
    [B_p,FitInfo_p] = lasso(predictor_p',train_behav,'Alpha',1,'CV',10);
    idxLambda1SE_p = FitInfo_p.Index1SE;
    coef_p = B_p(:,idxLambda1SE_p);
    coef0_p = FitInfo_p.Intercept(idxLambda1SE_p);
    [B_n,FitInfo_n] = lasso(predictor_n',train_behav,'Alpha',1,'CV',10);
    idxLambda1SE_n = FitInfo_n.Index1SE;
    coef_n = B_n(:,idxLambda1SE_n);
    coef0_n = FitInfo_n.Intercept(idxLambda1SE_n);
    
    test_mats = train_input(:,leftout);
    Xtest_p = test_mats.*mask_p;
    Xtest_p(e_p) = [];
    Xtest_n = test_mats.*mask_n;
    Xtest_n(e_n) = [];
    
    %Using Ridge
%     pred_p(leftout) = B1_p(1) + Xtest_p'*B1_p(2:end);
%     pred_n(leftout) = B1_n(1) + Xtest_n'*B1_n(2:end);
    
    %Using Elastic Net
    pred_p(leftout) = coef0_p + Xtest_p'*coef_p;
    pred_n(leftout) = coef0_n + Xtest_n'*coef_n;
    
    mask_acc_p(:,leftout) = mask_p;
    mask_acc_n(:,leftout) = mask_n;
end
[R_LOOV_p, P_LOOV_p] = corr(train_output,pred_p')
[R_LOOV_n, P_LOOV_n] = corr(train_output,pred_n')

%% Prediction (+ and -)
mask_p = sum(mask_acc_p');
mask_n = sum(mask_acc_n');
ind_p = find(mask_p == 499);
ind_n = find(mask_n == 499);
mask_final_p = zeros(360,1);
mask_final_p(ind_p) = 1;
mask_final_n = zeros(360,1);
mask_final_n(ind_n) = 1;

for s2 = 1:length(train_input)
    Xtrain_p(:,s2) = train_input(:,s2).*mask_final_p;
    Xtrain_n(:,s2) = train_input(:,s2).*mask_final_n;
end
f_p = find(all(Xtrain_p'==0));
train_p = Xtrain_p;
train_p(f_p,:) = [];
f_n = find(all(Xtrain_n'==0));
train_n = Xtrain_n;
train_n(f_n,:) = [];

%Using Ridge
% l = length(ind_p)+1;
% B2_p = ridge(train_output,train_p',l,0);
% B2_n = ridge(train_output,train_n',l,0);

%Using Elastic Net
[B_p,FitInfo_p] = lasso(train_p',train_output,'Alpha',1,'CV',10);
idxLambda1SE_p = FitInfo_p.Index1SE;
coef_p = B_p(:,idxLambda1SE_p);
coef0_p = FitInfo_p.Intercept(idxLambda1SE_p);
[B_n,FitInfo_n] = lasso(train_n',train_output,'Alpha',1,'CV',10);
idxLambda1SE_n = FitInfo_n.Index1SE;
coef_n = B_n(:,idxLambda1SE_n);
coef0_n = FitInfo_n.Intercept(idxLambda1SE_n);
    
for s3 = 1:length(test_input)
        Xtest2_p(:,s3) = test_input(:,s3).*mask_final_p;
        Xtest2_n(:,s3) = test_input(:,s3).*mask_final_n;
end
g_p = find(all(Xtest2_p'==0));
g_n = find(all(Xtest2_n'==0));
test_p = Xtest2_p;
test_n = Xtest2_n;
test_p(g_p,:) = [];
test_n(g_n,:) = [];

%Using Ridge
% final_pred_p = B2_p(1) + test_p'*B2_p(2:end);
% final_pred_n = B2_n(1) + test_n'*B2_n(2:end);

%Using elastic net
final_pred_p = coef0_p + test_p'*coef_p;
final_pred_n = coef0_n + test_n'*coef_n;

[R_test_p, P_test_p] = corr(test_output,final_pred_p)
[R_test_n, P_test_n] = corr(test_output,final_pred_n)
