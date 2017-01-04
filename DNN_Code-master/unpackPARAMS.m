function [W,b] = unpackPARAMS(M,layersizes)

    numlayers = length(layersizes) - 1;
    
    W = cell( numlayers, 1 );
    b = cell( numlayers, 1 );
    
    cur = 0;
    for i = 1:numlayers
        W{i} = reshape( M((cur+1):(cur + layersizes(i)*layersizes(i+1)), 1), [layersizes(i+1) layersizes(i)] );

        cur = cur + layersizes(i)*layersizes(i+1);
        
        b{i} = reshape( M((cur+1):(cur + layersizes(i+1)), 1), [layersizes(i+1) 1] );

        cur = cur + layersizes(i+1);
    end
    
end