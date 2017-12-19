function [ poid ] = poid(voisinA,voisinB, A,B )
    poid = sum(abs(A(voisinA(1),voisinA(2),:)-B(voisinA(1),voisinA(2),:)) + abs(A(voisinB(1),voisinB(2),:)-B(voisinB(1),voisinB(2),:)),3);
end

