function Display(Nodes,Elements,Appui,x,ampl)

XNOD     = Nodes.XNOD;
YNOD     = Nodes.YNOD;
ELEMNOA  = Elements.ELEMNOA;
ELEMNOB  = Elements.ELEMNOB;

NNode = length(XNOD);

Dofappu = 2*(Appui(:,1)-1)+Appui(:,2);
CORRES = setdiff(1:2*NNode,Dofappu);

X = zeros(2*NNode,1);


cmp = get(groot,'DefaultAxesColorOrder');

for i=1:length(ELEMNOA)
    ii = [ELEMNOA(i) ELEMNOB(i)];
    idof = [2*(ii(1)-1)+(1:2) 2*(ii(2)-1)+(1:2)]';
    
    xn= XNOD(ii);
    yn= YNOD(ii);
    
    plot(xn,yn,'k:o'), hold on
    
    for j = 1:size(x,2)
        
        X(CORRES)=x(:,j);
        
        u = X(idof);
        xxn = xn' + ampl * u([1 3]);
        yyn = yn' + ampl * u([2 4]);
        
        plot(xxn,yyn,'--','color',cmp(j,:),'linewidth',2)
        
        
        hold on;
        
    end
    
end
