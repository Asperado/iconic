def main(argv):      
  from CmdArgumentsHelper import CmdArgumentsHelper;
  arg_helper = CmdArgumentsHelper();
  arg_helper.add_argument('query', 'q', 'query', 1);
  arg_helper.add_argument('root_dir', 'r', 'root', 1);
  arg_helper.add_argument('output_dir', 'o', 'outdir', 1);
  args = arg_helper.read_arguments(argv);
  print (args);

  query = args['query'];
  images = gen_flickr_image_info(args['root'], query);
  image_urls = images['image_urls'];
  image_ids = images['image_ids'];
  downloader = ImageDownloader();
  output_dir = args['output_dir'] + query;
  from FileIO import FileIO;
  fileIO = FileIO();
  fileIO.create_folders(output_dir);
  downloader.download_images(image_urls, image_ids, output_dir);
  
if __name__ == "__main__":
  import sys;
  main(sys.argv[1:]);


