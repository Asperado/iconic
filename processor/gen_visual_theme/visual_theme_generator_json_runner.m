function visual_theme_generator_json_runner()
    eval('config_iconic_love');
    web_page_output_root = config.web_page_output_root;
    result_name = sprintf('visual_theme_vary_size_%s', config.query);

    iconic_methods = {};
    all_db = {};

    iconic_method = {};
    iconic_method.iconic_path = config.default_iconic_path;
    iconic_method.name = config.query;
    iconic_method.result_feed = config.iconic_result_id;
    iconic_methods{end + 1} = iconic_method;
    all_db{end + 1} = config.database;
    config = [];

    % You can add other configuration to compare visual themes under different setting.
    %eval('config_iconic_love_small');
    %iconic_method = {};
    %iconic_method.iconic_path = config.default_iconic_path;
    %iconic_method.name = config.query;
    %iconic_method.result_feed = config.iconic_result_id;
    %iconic_methods{end + 1} = iconic_method;
    %all_db{end + 1} = config.database;
    %config = [];

    generator = visual_theme_generator_json();
    generator.Run(iconic_methods, web_page_output_root, result_name, all_db)
end
