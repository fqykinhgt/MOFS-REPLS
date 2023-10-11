clc;
clear;


global Global;


dataSet=xlsread("Isolet5.xlsx");


dataSet(isnan(dataSet)) = 0;
[Ranking,W] = relieff(dataSet(:,1:end-1),dataSet(:,end),20,'method','classification');
Wd=(W-min(W))./(max(W)-min(W));
Wd(isnan(Wd))=0;


Global.dataSet=dataSet;
Global.N=100;
Global.M=2;
Global.D=size(Global.dataSet,2)-1;
Global.P1=5;
Global.Wd=Wd;

Population = InitialPop(Global.N,Global.D,Global.Wd);


AccArchive=[]; 
NdArchive=[]; 
AccArchive = ManageArchive(AccArchive,Population,'AccArchive'); 
NdArchive = ManageArchive(NdArchive,Population,'NdArchive'); 


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
            tempPop=CoreCode2(Population(i_pop),tempARC,'stage1',gen/maxGen);
            tempPop.obj=CalObj(tempPop.dec);
            Population(i_pop)=tempPop;
        end
    end
    
    if gen>maxGen/2
        [~,FNDsort]=sort([Population.rank]);
        Population=Population(FNDsort);
        for i=1:1:Global.N/2 
            thei=mod(i,size(NdArchive,1));
            thei=size(NdArchive,1)-thei;
            Population(Global.N/2+i)=NdArchive(thei);
        end
        for i_pop=1:Global.N

            tempPop=CoreCode2(Population(i_pop),NdArchive,'stage2',gen/maxGen);
            tempPop.obj=CalObj(tempPop.dec);
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

