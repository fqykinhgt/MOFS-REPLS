function selectedFeatures=TournamentSelection(W,Varlen)

    cumulativeSum = cumsum(W);
    

    normalizedSum = cumulativeSum / sum(W);
    

    selectedFeatures = [];
    

    for i = 1:Varlen

        r = rand();
        

        index = find(normalizedSum >= r, 1);
        

        selectedFeatures = [selectedFeatures, index];
        

        W(index) = 0;
        

        cumulativeSum = cumsum(W);
        normalizedSum = cumulativeSum / sum(W);
    end
end

