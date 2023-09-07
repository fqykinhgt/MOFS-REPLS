function PopObj = CalObj(X)
    global Global;
    [N,~] = size(X);
    PopObj = zeros(Global.M,N);
    for i = 1 : N
        subx=X(i,:);
    
     %  Objective function one
         PopObj(1,i) =size(unique(subx),2)    ;
       
     %  Objective function two   
        data_tr=Global.dataSet(:,subx);  
        dataLab = Global.dataSet(:,end);  
        CVF = 3;       % No. of cross-validation folds
        indices = crossvalind('Kfold',length(dataLab),CVF); % 
        fac = 0.00000000000000000000001; 
        classif='KNN';
        PopObj(2,i) = Fit_classify(data_tr, dataLab, indices, classif) + fac;      
    end
       
end

function Fit = Fit_classify(data, dataLab, indices, classif)  
    CVF = max(indices);  
    Fit = zeros(CVF,1);  
    for k=1:CVF  
       testn = (indices == k);
       trainn = ~testn;       
       NTest = sum(testn);   
    %     nn=sum(trainn)
    
       switch classif
           case 'KNN'
             
               mdl=ClassificationKNN.fit(data(trainn,:),dataLab(trainn,:),'NumNeighbors',3);
    
               Ac1=predict(mdl,data(testn,:)); 
               %Ac1 = knnclassify(data(testn,:),data(trainn,:),dataLab(trainn),3); 
               if size(Ac1,1) == sum(testn)
                   Fit(k) = sum(Ac1~=dataLab(testn))/NTest; 
                   %Fit(k) = sum(Ac1~=dataLab(testn))/NTest;
               else
                   Fit(k) = 1;  
               end
       end
    end
    Fit = mean(Fit);  
end
