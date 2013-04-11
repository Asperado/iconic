config.query = 'home';
config.iconic_methods = {};
method.name = '3000_cluster_2000_dim_features';
method.cca_path = sprintf('/nas11/compsci/hongtao/Iconic/data/iconic_result/%s/result_2000_iconic_%s_all_large_scale_all_data.mat', config.query, config.query);
config.iconic_methods{end + 1} = method;

% To add extra method to compare the result.
% method.name = 'new method name';
% method.cca_path = 'new method cca path';
% iconic_methods{end + 1} = method;

config.webpage_output_root = sprintf('/netscr/hongtao/Iconic/output/iconic_web_pages');
config.webpage_output_dir = sprintf('%s/%s', config.webpage_output_root, config.query);
config.webpage_name = sprintf('visual_theme_%s_features_full_large_scale_all_3000_tag_cluster', config.query);
config.tag_dim = 6000;
config.db_root = '/nas11/compsci/hongtao';
config.PAGE_STYLE_COMBINE = 'combine';
config.PAGE_STYLE_SEPERATE = 'seperate';
config.gen_page_style = config.PAGE_STYLE_COMBINE;
