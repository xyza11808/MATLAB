function IsTopdownShow = SlicedAreaNamePlots(PlotAx, sliceName, LateralPos, uacr, colors, st, av, tpidx)

if strcmpi(sliceName, 'sagittal')
    sliceName = 'sagittal'; 
    
    slicePos = LateralPos; 
    avs = squeeze(av(:,:,slicePos))';
    
    IsSagitalShow = plotRLMBChelp(PlotAx, avs, uacr, colors, st, tpidx);
end
if strcmpi(sliceName, 'topdown')
    % sagittal
    [~,ii] = max(av>1, [], 2);
    ii = squeeze(ii);
    [xx,yy] = meshgrid(1:size(ii,2), 1:size(ii,1));
    avs = reshape(av(sub2ind(size(av),yy(:),ii(:),xx(:))), size(av,1), size(av,3));
    % avs = avs(:,1:size(avs,2)/2);
    slicePos = LateralPos;
    
    IsTopdownShow = plotRLMBChelp(PlotAx, avs, uacr, colors, st, tpidx);
end


function IsAreaShow = plotRLMBChelp(ax, avs, uacr, colors, st, tpidx)

IsAreaShow = zeros(numel(uacr),1);

[~,~,h] = sliceOutlineWithRegionVec(avs, [], [],ax);

set(h, 'Color', 0.5*[1 1 1]); 
hold on;
IsAreaStrctGiven = 0;
if isstruct(tpidx)
    AreaNameStrs = fieldnames(tpidx);
    IsAreaStrctGiven = 1;
end
for q = 1:numel(uacr)
    if IsAreaStrctGiven
        uIdx = strcmpi(AreaNameStrs, uacr{q});
        below = tpidx.(AreaNameStrs{uIdx});
    else
        uIdx = find(strcmp(st.acronym, uacr{q}));
        below = [uIdx; tpidx(tpidx(:,1)==uIdx,2)];
    end
    
    [ii,jj] = find(ismember(avs,below)); 
    if ~isempty(ii)
                
        thisColor = colors(q,:);
        
        c = contourc(double(ismember(avs,below)), [0.5 0.5]);
        coordsReg = makeSmoothCoords(c);
%         title(ax, uacr{q});
        for cidx = 1:numel(coordsReg)
            h = patch(ax, coordsReg(cidx).x,coordsReg(cidx).y, thisColor); hold on;
            h.FaceAlpha = 0.75;
            
            CoordCentx = mean(coordsReg(cidx).x);
            CoordCenty = mean(coordsReg(cidx).y);
            text(CoordCentx,CoordCenty,uacr{q},'HorizontalAlignment','cent','FontSize',10);
        end                
        
    else
       IsAreaShow(q) = 1; 
        
    end
end

% colorbar
% % add annotations last so they're on top
% for q = 1:numel(uIdx)
%     
%     below = [uIdx(q); tpidx(tpidx(:,1)==uIdx(q),2)];
%     
%     [ii,jj] = find(ismember(avs,below));
%     if ~isempty(ii)
%         
%         gIdx = find(strcmp(arrayfun(@(x)g(x).acr{1}, 1:numel(g), 'uni', false), uacr{q}));
%         thisColor = g(gIdx).color;
%         
%         comX = mean(ii); comY = mean(jj);
%         thisAcr = st.acronym{uIdx(q)};
%         theseR = strcmp(recTable.acr, thisAcr);
%         ah = annotation('textbox','String', ...
%             {sprintf('%s', thisAcr), ...
%             sprintf('(%d; %d/%d)', sum(theseR), ...
%             sum(recTable.incl(theseR)), sum(recTable.all(theseR)))});
%         ah.HorizontalAlignment = 'center';
%         set(ah, 'Parent', gca, 'Position', [comY-25 comX-10 1 1],...
%             'LineStyle', 'none', 'Color', thisColor, 'FontWeight', 'bold');
%     end
% end
