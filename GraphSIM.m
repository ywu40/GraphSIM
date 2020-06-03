%% Date 2020.6.2
%% Author: Qi Yang (Any question, please contact:yang_littleqi@sjtu.edu.cn)
%% Affiliation: Shanghai Jiao Tong University
%% If you use our code, please cite our paper: Inferring Point Cloud Quality via Graph Similarity
%% https://arxiv.org/abs/2006.00497
%% Before running this code, please install GSPbox first: https://github.com/epfl-lts2/gspbox
%% ****************************************************************************************************************
T=0.001;
%% resampling version, generated by demo_fast_make.m
name_fast=('redandblack10000_4.ply');
%% reference point cloud
pt_fast=pcread(name_fast);       
name_r=('redandblack.ply'); 
%% distorted point cloud
pt1=pcread(name_r);
name_d=('redandblack_0_0.ply');            
pt2=pcread(name_d);
pc_ori_coordinate=pt1.Location;
%% Neighbor Dimension
max_x=max(pc_ori_coordinate(:,1))-min(pc_ori_coordinate(:,1));
max_y=max(pc_ori_coordinate(:,2))-min(pc_ori_coordinate(:,2));
max_z=max(pc_ori_coordinate(:,3))-min(pc_ori_coordinate(:,3));
box=[max_x,max_y,max_z];
epsilon=floor(min(box)/10);
r=pt_fast.Count;
sample_LMN=cell(r,1);
    for s=1:1:r
        s
        %% reference graph creation, signal type: GCM
        [G_g,pointset,center]=graphcreation(pt1,pt_fast,epsilon,s);
        [LMN_mg_r,LMN_mug_r]=colorgradient_mg_mug(G_g,pointset,center); 
        %% distorted graph creation
        [G_gd,pointsetd,centerd]=graphcreation(pt2,pt_fast,epsilon,s);
        %% zeroth and first Moment 
        [LMN_mg_d,LMN_mug_d]=colorgradient_mg_mug(G_gd,pointsetd,centerd);
        %% Second Moment
        LMN_cg=colorgradient_cg(G_g,G_gd,center,pointset,pointsetd);
        %% feaure similarity
        LMN_mg_sim=similarity(LMN_mg_r,LMN_mg_d,T);
        LMN_mug_sim=similarity(LMN_mug_r,LMN_mug_d,T);
        feature_LMN=[LMN_mg_sim,LMN_mug_sim,LMN_cg];
        sample_LMN{s,1}=feature_LMN;
    end
L=6;M=1;N=1;
%% feature pooling
GraphSIM_score=cal_mos(sample_LMN,L,M,N);
fprintf('GraphSIM: %d\n',GraphSIM_score);