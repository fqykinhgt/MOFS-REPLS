clc;
clear;

%% 声明全局变量
global Global;

%% 读取数据集
dataSet=xlsread("Isolet5.xlsx");

%% 计算特征与类标签之间的相关性
dataSet(isnan(dataSet)) = 0;
[Ranking,W] = relieff(dataSet(:,1:end-1),dataSet(:,end),20,'method','classification');
Wd=(W-min(W))./(max(W)-min(W));
Wd(isnan(Wd))=0;

%% 定义参数
Global.dataSet=dataSet;%数据集录入全局变量中
Global.N=100;%种群数量
Global.M=2;%定义目标数量
Global.D=size(Global.dataSet,2)-1;%问题的维度
Global.P1=5;
Global.Wd=Wd;%相关性排序，越大越重要

%% 初始化种群（随机初始化）
Population = InitialPop(Global.N,Global.D,Global.Wd);

%% 定义外部存档
AccArchive=[];  %精度存档，用来保存不同特征所获得的最好的精度
NdArchive=[];   %非支配排序存档
AccArchive = ManageArchive(AccArchive,Population,'AccArchive'); %管理第一个存档
NdArchive = ManageArchive(NdArchive,Population,'NdArchive'); %管理第一个存档

%% 进入主循环，直到达到停止准则
gen=1;
maxGen=100;
while gen<=maxGen
    disp(['Current iterations:',num2str(gen),'/',num2str(maxGen)]);  
    Population=NDSort(Population);
    if gen<=maxGen/2
        if gen<maxGen/4
            tempARC=[AccArchive;NdArchive];
        else
            tempARC=NdArchive;
        end
        for i_pop=1:Global.N
            %对个体进行学习
            tempPop=CoreCode(Population(i_pop),tempARC,'stage1',gen/maxGen);
            tempPop.obj=CalObj(tempPop.dec);%计算适应度
            Population(i_pop)=tempPop;
        end
    end
    
    if gen>maxGen/2
        [~,FNDsort]=sort([Population.rank]);
        Population=Population(FNDsort);
        for i=1:1:Global.N/2 %将适应度差的个体进行替换
            thei=mod(i,size(NdArchive,1));
            thei=size(NdArchive,1)-thei;
            Population(Global.N/2+i)=NdArchive(thei);
        end
        for i_pop=1:Global.N
            %对个体进行学习
            tempPop=CoreCode(Population(i_pop),NdArchive,'stage2',gen/maxGen);
            tempPop.obj=CalObj(tempPop.dec);%计算适应度
            TP=NDSort([Population(i_pop);tempPop]);
            if TP(1).rank>TP(2).rank
                [~,idx]=max(tempPop.opt);
                tempPop.opt(1,idx)=tempPop.opt(1,idx)*0.2;
            else
                [~,idx]=max(tempPop.opt);
                tempPop.opt(1,setdiff(1:3,idx))=tempPop.opt(1,setdiff(1:3,idx)).*0.1;
            end
            tempPop.opt=tempPop.opt./sum(tempPop.opt);
            Population(i_pop)=tempPop;
        end
    end

    AccArchive = ManageArchive(AccArchive,Population,'AccArchive'); %管理第一个存档
    NdArchive = ManageArchive(NdArchive,Population,'NdArchive'); %管理第一个存档

    %% 画图
    figure(1);
    cla;
    hold on;
    Cost=[Population.obj]';
    scatter(Cost(:,1),Cost(:,2),'bo');
    CostNd=[NdArchive.obj]';
    scatter(CostNd(:,1),CostNd(:,2),'r*');
    
    gen=gen+1;
end

