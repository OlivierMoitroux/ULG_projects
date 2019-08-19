function [K,p,Ke,B,Re,Be] = BuildStructure(Nodes,Elements,Appui,Force)

Materials(1).Young = 1;

for igeo=1:length(Elements.ELEM_EA)
    Geometries(igeo).A = Elements.ELEM_EA(igeo);
end   

NNode = length(Nodes.XNOD);
NElem = length(Elements.ELEMNOA);


[K,Ke,Re,ELEMLEN,ELEMDOF] = Assemble(NNode,NElem,Nodes,Elements, Geometries,Materials);

P = zeros(2*NNode,1);
Fappu =  2*(Force(:,1)-1)+Force(:,2);
P(Fappu) = Force(:,3);

Dofappu = 2*(Appui(:,1)-1)+Appui(:,2);
CORRES = setdiff(1:2*NNode,Dofappu);


K = K(CORRES,CORRES);
p = P(CORRES);

% Forces internes
B = zeros(NElem,2*NNode);
for iel=1:NElem
    b = Re(:,:,iel)'*Ke(:,:,iel);
    b = b(1,:);
    B(iel,ELEMDOF(:,iel)) = -b;
end
B = B(:,CORRES);

Be = zeros(NElem,size(B,2),NElem);
for iel=1:NElem
    Be(iel,:,iel) = B(iel,:);
end


% augmenter la taille des matrices élémentaires
Ke_ = zeros(2*NNode,2*NNode,NElem);
for iel=1:NElem
    Ke_(ELEMDOF(:,iel),ELEMDOF(:,iel),iel) = Ke(:,:,iel);
end
Ke = Ke_(CORRES,CORRES,:);

end

function [K,Ke,Re,ELEMLEN,ELEMDOF] = Assemble(NNode,NElem,Nodes,Elements, Geometries,Materials)
%
% Boucle sur les éléments de la structure et assemble les matrices de
% raideur et de masse élémentaire
%
% SEE ALSO : RaideurBeam3, MasseBeam3 pour les expressions des matrices élémentaires

lib = 2; % 2 DDL par noeud
NDOF =lib*NNode; 

XNOD = Nodes.XNOD;
YNOD = Nodes.YNOD;

ELEMGEO = 1:NElem;
ELEMNOA = Elements.ELEMNOA;
ELEMNOB = Elements.ELEMNOB;


K=zeros(NDOF,NDOF); % Matrice de raideur structurelle

Re=zeros(2*lib,2*lib,NElem);
Ke=zeros(2*lib,2*lib,NElem);

for el=1:NElem
    
    L = norm([diff(XNOD([ELEMNOA(el) ELEMNOB(el)])); diff(YNOD([ELEMNOA(el) ELEMNOB(el)]))]);
    ELEMLEN(el) = L;
    SinA = (YNOD(ELEMNOB(el))-YNOD(ELEMNOA(el))) / L;
    CosA = (XNOD(ELEMNOB(el))-XNOD(ELEMNOA(el))) / L;
    
    Igeo = ELEMGEO(el); Imat = 1;
    A = Geometries(Igeo).A;
    E = Materials(Imat).Young;
    Raide = E*A/L;
    
    Kel = zeros(2*lib,2*lib);
    Kel(1,1) =  Raide  ; Kel(1,3) = -Raide;
    Kel(3,1) = -Raide  ; Kel(3,3) =  Raide;
    
    % Rotation
    ROT = [CosA -SinA; SinA CosA]; ROT = [ROT zeros(lib,lib);zeros(lib,lib) ROT];
    Kel = ROT * Kel * ROT';
    
    % Assemblage
    NDOF1 = lib*ELEMNOA(el) - lib+1;
    NDOF2 = lib*ELEMNOB(el) - lib+1;
    ELEMDOF(:,el) = [NDOF1:NDOF1+lib-1 NDOF2:NDOF2+lib-1];
    
    K(ELEMDOF(:,el),ELEMDOF(:,el)) = K(ELEMDOF(:,el),ELEMDOF(:,el)) + Kel;
    
    Ke(:,:,el)=Kel;
    Re(:,:,el)=ROT;
    
end

end

