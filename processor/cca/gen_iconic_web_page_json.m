function gen_iconic_web_page_json( clusters, ...
                                    database, ...
                                    result_name, ...
                                    result_output_root, ...
                                    meta_root, ...
                                    show_top_k_images)
                                
    cluster_index = 1:length(clusters);
    is_good_images = [];
    gen_clusters_result(cluster_index,...
                         clusters,...
                         database,...
                         result_output_root,...
                         result_name,...
                         meta_root);
%                         is_good_images, ...
%                         show_top_k_images)

end
