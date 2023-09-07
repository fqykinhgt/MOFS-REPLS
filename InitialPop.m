function Population = InitialPop(N,D,Wd)
  
    interval=D/(3*N);

    Pop.dec=[];
    Pop.obj=[];
    Pop.rank=0;
    Pop.opt=zeros(1,3);
    Population=repmat(Pop,N,1);

    for i=1:N
        SelNum=1+ceil(interval*i);
        Population(i).dec=TournamentSelection(Wd,SelNum);
        Population(i).obj=CalObj(Population(i).dec);
        Population(i).opt=rand(1,3);
        Population(i).opt=Population(i).opt./sum(Population(i).opt);
    end
end
