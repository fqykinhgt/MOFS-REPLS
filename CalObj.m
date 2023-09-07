function PopObj = CalObj(X)  %计算多个的目标函数值  X:种群（parent或者offspring）
    global Global;
    [N,~] = size(X);
    PopObj = zeros(Global.M,N); %存放目标函数值
    for i = 1 : N
        subx=X(i,:);  %选取第i个特征组合方案
    
     %  Objective function one
         PopObj(1,i) =size(unique(subx),2)    ;%解大小
       
     %  Objective function two   
        data_tr=Global.dataSet(:,subx);  %用特征子集抽取新的数据集 没有标签
        dataLab = Global.dataSet(:,end);  %个体的标签
        CVF = 3;       % No. of cross-validation folds 交差验证分组数量
        indices = crossvalind('Kfold',length(dataLab),CVF); % 将样本按比例分组，得到分组情况数组；
        fac = 0.00000000000000000000001; 
        classif='KNN';
        PopObj(2,i) = Fit_classify(data_tr, dataLab, indices, classif) + fac;  %输入特征集合，标签集合，分组索引              
    end
       
end

function Fit = Fit_classify(data, dataLab, indices, classif)  
    CVF = max(indices);  %获取交叉验证试验次数，即分组数量
    Fit = zeros(CVF,1);  %存每次交叉试验的错误率，
    for k=1:CVF  
       testn = (indices == k); %得到测试索引，每一次取一组作为测试数据，获得测试数据的索引，用1表示测试数据
       trainn = ~testn;        %得到训练索引，剩下的所有组为训练数据
       NTest = sum(testn);     %得到测试数据个数
    %     nn=sum(trainn)
    
       switch classif
           case 'KNN'
               %输入训练数据集合，训练数据集合的标签，先训练，再输入测试数据集合，预测其类标签。
               mdl=ClassificationKNN.fit(data(trainn,:),dataLab(trainn,:),'NumNeighbors',3);%建立模型
    
               Ac1=predict(mdl,data(testn,:));  %根据模型预测
               %Ac1 = knnclassify(data(testn,:),data(trainn,:),dataLab(trainn),3); 
               if size(Ac1,1) == sum(testn)
                   Fit(k) = sum(Ac1~=dataLab(testn))/NTest;  %计算第K次的预测误差
                   %Fit(k) = sum(Ac1~=dataLab(testn))/NTest;
               else
                   Fit(k) = 1;  %否则的话错误率100%
               end
       end
    end
    Fit = mean(Fit);  %取K次的预测误差的平均作为最终预测误差
end