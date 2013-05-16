classdef IconicDatabase < handle
    %DATABASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        query_ = '';
        imageFilePaths_ = {};
        image_ids_ = {};
        tags_ = {};
        taglist_ = {};
        root_path_ = '';
        tag_dim_ = 6000;
    end
    
    methods        
        function self = IconicDatabase(query, root_path, tag_dim)
            self.query_ = query;
            if(exist('root_path', 'var')) 
                self.root_path_ = root_path;
            end
            if(exist('tag_dim', 'var')) 
                self.tag_dim_ = tag_dim;
            end            
	    assert(exist(root_path, 'file') ~= 0);
            self = self.ResetRootPath(self.root_path_);
        end
        
        function self = ResetRootPath(self, root_path)
            self.root_path_ = root_path;
            image_file_paths_file = sprintf('%s/data/dataset/%s_path.txt', self.root_path_, self.query_)    
            if(exist(image_file_paths_file, 'file'))
                self.imageFilePaths_ = getStringListFromTxt(image_file_paths_file);            
            end
        end
        
        function image_ids = get_image_ids(obj, image_index)
            if (isempty(obj.image_ids_))
                image_ids_file = sprintf('%s/data/dataset/%s.txt', obj.root_path_, obj.query_)
                fprintf('Load image ids from %s\n', image_ids_file);
                obj.image_ids_ = getStringListFromTxt(image_ids_file);
            end
            if (exist('image_index', 'var'))
                image_ids = obj.image_ids_(image_index);
            else
                image_ids = obj.image_ids_;
            end
        end
        
        function save_image_ids(obj, image_ids)
            image_ids_path = sprintf('%s/data/dataset/%s.txt', obj.root_path_, obj.query_)
            fprintf('Save image ids to %s\n', image_ids_path);
            [output_dir, drop] = fileparts(image_ids_path);
            mkDir(output_dir);
            fout = fopen(image_ids_path, 'w');
            for i = 1:length(image_ids)
                fprintf(fout, '%s\n', image_ids{i});
            end
            fclose(fout);
        end
        
        function image_ids = GetImageIds(obj, image_index)
            if (isempty(obj.image_ids_))
                image_ids_file = sprintf('%s/data/dataset/%s.txt', obj.root_path_, obj.query_)
                image_ids_file
                obj.image_ids_ = getStringListFromTxt(image_ids_file);
            end
            image_ids = obj.image_ids_(image_index);
        end
        function image_file_paths = GetImageFilePaths(obj, image_ids)
            image_file_paths = obj.imageFilePaths_(image_ids);
        end
        
        function [tags] = get_taglist_raw(obj, taglist_path) 
            if (~exist('taglist_path', 'var'))
                taglist_path = sprintf('%s/data/features/tag%d/%s/tag%d_tags.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_);
            end
            tags = load(taglist_path);
            tags = tags.tags;
        end
        
        function [taglist] = get_taglist(obj, taglist_path) 
            if (~exist('taglist_path', 'var'))
                taglist_path = sprintf('%s/data/features/tag%d/%s/tag%d_tags.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_);
            end
            tags = load(taglist_path);
            tags = tags.tags;
            taglist = {};
            for i = 1:length(tags)
                taglist{i} =  strtrim(tags(i,:));
                taglist{i} = strrep(taglist{i}, '?', '_');
            end
            obj.taglist_ = taglist;
        end
        
        function save_taglist_raw(obj, taglist_path, tags)
            fprintf('Save tag list to %s.\n', taglist_path);
            [output_dir, drop] = fileparts(taglist_path);
            mkDir(output_dir);
            save(taglist_path, 'tags');
        end
        
        function [tag_mat] = get_tag_feature(obj, tag_feature_path)
            if (~exist('tag_feature_path', 'var'))
                tag_feature_path = sprintf('%s/data/features/tag%d/%s/tag%d_sparse.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_);
            end
            fprintf('Load tag feature.\n');
            tag_feature_data = load(tag_feature_path);    
            tag_mat = tag_feature_data.featureData;
            clear tag_feature_data;
        end
        
        function save_tag_feature(obj, tag_feature_path, featureData)
            fprintf('Save tag feature.\n');
            [output_dir, drop] = fileparts(tag_feature_path);
            mkdir(output_dir);
            save(tag_feature_path, 'featureData', '-v7.3');    
        end
        
        
        function [iconic_results] = get_iconic_results(obj, iconic_path)
            fprintf('Load iconic result.\n');
            iconic_data = load(iconic_path);
            iconic_results = iconic_data.result;
        end
        
        function [clusters] = get_iconic_clusters(obj, iconic_path)
            fprintf('Load iconic clusters.\n');
            iconic_data = load(iconic_path);
            clusters = iconic_data.result{1}.clusters;
        end
        
        function [tags, obj] = GetImageTags(obj, image_ids)
            if (isempty(obj.taglist_)) 
                taglist_path = (sprintf('%s/data/features/tag%d/%s/tag%d_tags.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_));
                get_taglist(obj, taglist_path);
            end
            if (isempty(obj.tags_))
                input = load(sprintf('%s/data/features/tag%d/%s/tag%d.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_));
                obj.tags_ = input.featureData;
                clear input;
            end
            tags = obj.tags_(image_ids, :);
        end
        
        function [tags, obj] = get_image_tags(obj, image_ids)
            if (isempty(obj.taglist_)) 
                taglist_path = (sprintf('%s/data/features/tag%d/%s/tag%d_tags.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_));
                get_taglist(obj, taglist_path);
            end
            if (isempty(obj.tags_))
                tag_path = sprintf('%s/data/features/tag%d/%s/tag%d.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_);
                if (~exist(tag_path, 'file'))
                    tag_path = sprintf('%s/data/features/tag%d/%s/tag%d_sparse.mat', obj.root_path_, obj.tag_dim_, obj.query_, obj.tag_dim_)
                end
                input = load(tag_path);
                obj.tags_ = input.featureData;
                clear input;
            end
            tags = obj.tags_(image_ids, :);
        end
        
        function [features] = GetVisualFeatures(obj)
            input = load(sprintf('%s/data/features/VisualFeatures/%s/visFeatures.mat', obj.root_path_, obj.query_));
            features = input.visFeatures;
        end
        
        function save_visual_feautre(obj, visual_feature_path, visFeatures)
            fprintf('Save visual feature to %s\n', visual_feature_path);
            [output_dir, drop] = fileparts(visual_feature_path);
            mkdir(output_dir);
            save(visual_feature_path, 'visFeatures', '-v7.3');
        end

        function [features] = get_visual_feature(obj, filepath)
            if (~exist('filepath', 'var'))
                filepath = sprintf('%s/data/features/VisualFeatures/%s/visFeatures.mat', obj.root_path_, obj.query_);
            end
            input = load(filepath);
            features = input.visFeatures;
        end
        
        function [clusters] = get_visual_clusters(obj)
            input = load(sprintf('%s/data/visual_clusters/%s/vis_clusters.mat', obj.root_path_, obj.query_));
            clusters = input.results;
        end
        function save_visual_clusters(obj, results)
            output_dir = sprintf('%s/data/visual_clusters/%s', obj.root_path_, obj.query_);
            mkdir(output_dir);
            save(sprintf('%s/vis_clusters.mat', output_dir), 'results', '-v7.3');
        end
        
        function [clusters] = GetTagClusters(obj)
            input = load(sprintf('%s/data/features/tag%d/%s/cluster.mat', obj.root_path_, obj.tag_dim_, obj.query_));
            clusters = input.IDXs;
        end
        
        function [clusters] = get_tag_clusters(obj, tag_cluster_path)
            input = load(tag_cluster_path);
            clusters = input.cluster;
        end
        
        function save_tag_clusters(obj, tag_cluster_path, cluster)
            [output_dir, drop] = fileparts(tag_cluster_path);
            mkDir(output_dir);
            save(tag_cluster_path, 'cluster', '-v7.3');
        end
        
        function [cluster_index, n_clusters] = get_tag_cluster_index(obj, tag_cluster_path)
            data = load(tag_cluster_path);
            cluster_index = data.cluster.index.data;
            n_clusters = data.cluster.dim;
        end        
    end
    
end

