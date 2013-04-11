function feat = normalizeFeature(feat)
    for i =1:size(feat,1)
        feat(i,:) = feat(i,:)./sum(feat(i,:));
    end
end