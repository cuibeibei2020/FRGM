% data load
data_name = 1;%1=beijing;2=whale;3=chinese;4=cpd_fish;5=fish_2d;
X = load_testdata(data_name);
LX = length(X(:,1));

% normalization of points
[X,X_bound] = normalize_point(X,1);

% generation of noise and outliers
opt_similar.noise = 1;
opt_similar.noise_sigma = 0.0;%0.02
opt_similar.noise_type = 'uniform';%or 'gaussian'
opt_similar.outlier = max(floor(1.1*LX),1);
opt_similar.out_sigma = 0.25;
opt_similar.outlier_type = 'gaussian';%or 'uniform1''gaussian''gaussian1'

% geometric deformation
theta = rand(1)*sign(rand-0.5)*pi;
R = [cos(theta),sin(theta);
    -sin(theta),cos(theta)];
t = X_bound*rand(1,2) + 1;
s = 0.5;

Y = rigid_affine_transform2D(X,R,t,s,opt_similar);
figure,plot(Y(1:LX,1),Y(1:LX,2),'b.',X(:,1),X(:,2),'r.',Y((LX+1):end,1),Y((LX+1):end,2),'g.');

% randomly disrupt the order of points
LY = length(Y(:,1));
order = randperm(LX);
inlier_rate = 1;%1-inlier_rate of inliers are removed
order = order(1:min(floor(inlier_rate*LX)+1,LX));
%order = 1:LX;

X = X(order,:);
%%
option.regist_trans = 'similar';
option.regist_it = 20;%the max number of rigistration iterations
option.regist_rota = 1;% 1=: rotation invariant Shape Context; 0: otherwise
option.regist_display = 1;% 1:show the registrations; 0: otherwise
option.regist_normalize = 1;% 1: with normolization; 0: without
option.regist_save = 0;% save as gif or not

option.GM_initial = 'lap';% initialization 
option.GM_convex_or_non = [zeros(1,3),ones(1,option.regist_it)];%alternation of objective functions
option.GM_lambda1 = 1;% weight of unary potential
option.GM_lam_nonvex = 1;% weight of the non-convex pairwise potential
option.GM_lam_convex = 1;% weight of the convex pairwise potential
option.GM_unary = 1;% linear unary potential
option.GM_connected = 'full';% fully connected graph
option.order = order;

tic;
[Map,para] = FRGM_registration(X,Y,[],option);
toc;

figure,plot(1:length(para.regist_tol),para.regist_tol,'b.-','linewidth',2,'markersize',15);
hold on,plot(1:length(para.regist_err),para.regist_err,'r.-','linewidth',2,'markersize',15);
legend({'tol','err'},'FontSize',15)

