function task_gen_visual_theme(config_path)
    addpath('../cca');
    addpath('../DataAccessObject');
    eval(config_path);
    generator = visual_theme_generator();
    generator.Run(config.query, config.iconic_methods, config.webpage_name, config.db_root, config.tag_dim, config.gen_page_style, config.webpage_output_dir);
end
