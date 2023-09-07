clc;
clear;


%dataSetName={'Waveform','Ionosphere','Spambase','Sonar','ULC','Musk','SCADI','Semeion','Madelon','Isolet5','CANE-9'};
%dataSetName={'Qsar','Colon','GLIOMA','Prostate_GE','DrivFace','leukemia','Nci9'};
dataSetName={'Waveform','Ionosphere','Spambase','Sonar','ULC','Musk','SCADI','Semeion','Madelon','Isolet5','CANE-9','Qsar','Colon','GLIOMA','Prostate_GE','DrivFace','leukemia','Nci9','Orlraws10P','CLL_SUB_111','Lung_Cancer','11_Tumors'};

TT={'trainData','testData'};
for dataN=1:size(dataSetName,2)
    for opt=1:size(TT,2)
        for run=11:30
            global Global;
            dataSet=xlsread(['../dataSet/',char(TT(opt)),'/',char(dataSetName(dataN)),'.xlsx']);
            
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
                if gen<=maxGen/4
                    for i_pop=1:Global.N
                        tempPop=CoreCode(Population(i_pop),[AccArchive;NdArchive],'stage1');
                        tempPop.obj=CalObj(tempPop.dec);
                        Population(i_pop)=tempPop;
                    end
                end
            
                if gen>maxGen/4 && gen<=maxGen/2
                    for i_pop=1:Global.N
                        tempPop=CoreCode(Population(i_pop),NdArchive,'stage2');
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
                        tempPop=CoreCode(Population(i_pop),NdArchive,'stage3');
                        tempPop.obj=CalObj(tempPop.dec);
                        Population(i_pop)=tempPop;
                    end
                end
            
                AccArchive = ManageArchive(AccArchive,Population,'AccArchive'); 
                NdArchive = ManageArchive(NdArchive,Population,'NdArchive');
            
              
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
%%

