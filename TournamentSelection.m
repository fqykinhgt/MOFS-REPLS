function selectedFeatures=TournamentSelection(W,Varlen)
    % 计算权重的累积和
    cumulativeSum = cumsum(W);
    
    % 归一化累积和
    normalizedSum = cumulativeSum / sum(W);
    
    % 初始化选择的特征集合
    selectedFeatures = [];
    
    % 进行 n 次选择
    for i = 1:Varlen
        % 生成一个随机数 r
        r = rand();
        
        % 找到第一个大于随机数 r 的索引
        index = find(normalizedSum >= r, 1);
        
        % 将对应索引的特征添加到选择集合中
        selectedFeatures = [selectedFeatures, index];
        
        % 将已选择的特征的权重置为 0，以避免再次选择
        W(index) = 0;
        
        % 重新计算归一化累积和
        cumulativeSum = cumsum(W);
        normalizedSum = cumulativeSum / sum(W);
    end
end

