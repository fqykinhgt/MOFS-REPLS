clc;
clear;

%% 声明全局变量

%dataSetName={'Waveform','Ionosphere','Spambase','Sonar','ULC','Musk','SCADI','Semeion','Madelon','Isolet5','CANE-9'};
%dataSetName={'Qsar','Colon','GLIOMA','Prostate_GE','DrivFace','leukemia','Nci9'};
dataSetName={'Waveform','Ionosphere','Spambase','Sonar','ULC','Musk','SCADI','Semeion','Madelon','Isolet5','CANE-9','Qsar','Colon','GLIOMA','Prostate_GE','DrivFace','leukemia','Nci9','Orlraws10P','CLL_SUB_111','Lung_Cancer','11_Tumors'};

TT={'trainData','testData'};
for dataN=1:size(dataSetName,2)
    for opt=1:size(TT,2)
        for run=11:30
            global Global;
            %% 读取数据集
            dataSet=xlsread(['../dataSet/',char(TT(opt)),'/',char(dataSetName(dataN)),'.xlsx']);
            
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
                %% 阶段一：探索阶段，多样性一定要足
                if gen<=maxGen/4
                    for i_pop=1:Global.N
                        %对个体进行学习
                        tempPop=CoreCode(Population(i_pop),[AccArchive;NdArchive],'stage1');
                        tempPop.obj=CalObj(tempPop.dec);%计算适应度
                        Population(i_pop)=tempPop;
                    end
                end
            
                %% 阶段二：过渡阶段，收敛一定要足
                if gen>maxGen/4 && gen<=maxGen/2
                    for i_pop=1:Global.N
                        %对个体进行学习
                        tempPop=CoreCode(Population(i_pop),NdArchive,'stage2');
                        tempPop.obj=CalObj(tempPop.dec);%计算适应度
                        Population(i_pop)=tempPop;
                    end
                end
                
            
                %% 阶段三：强收敛阶段
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
                        tempPop=CoreCode(Population(i_pop),NdArchive,'stage3');
                        tempPop.obj=CalObj(tempPop.dec);%计算适应度
                        Population(i_pop)=tempPop;
                    end
                end
            
                AccArchive = ManageArchive(AccArchive,Population,'AccArchive'); %管理第一个存档
                NdArchive = ManageArchive(NdArchive,Population,'NdArchive'); %管理第一个存档
            
                %% 画图
%                 figure(1);
%                 cla;
%                 hold on;
                Cost=[Population.obj]';
%                 scatter(Cost(:,1),Cost(:,2),'bo');
                CostNd=[NdArchive.obj]';
%                 scatter(CostNd(:,1),CostNd(:,2),'r*');
%                 pause(0.01);
                
                gen=gen+1;
            end
            Cost=CostNd;
            filename=['result/',char(TT(opt)),'/',char(dataSetName(dataN)),'_',num2str(run),'.xlsx'];
            writematrix(Cost, filename, 'Sheet', 1);
        end
    end
end


