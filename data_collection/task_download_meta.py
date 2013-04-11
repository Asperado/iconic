import flickr_data_downloader.core.config as config
from flickr_data_downloader.core.mr_download_flickr_query import downloadQuery
from database_builder.tools.cmd_arguments_helper import CmdArgumentsHelper
from database_builder.core.database import DBHelper

def main():      
  arg_helper = CmdArgumentsHelper();
  arg_helper.add_argument('query', 'q', 'query', 1);
  arg_helper.add_argument('root_dir', 'r', 'root', 1);
  args = arg_helper.read_arguments();
  print (args);

  query_string = args['query'];
  
  dbHelper = DBHelper();
  dbHelper.init(args['root_dir'])
  dbHelper.gen_config_file(query_string)
  configFileName = dbHelper.get_config_filepath(query_string)
  dbHelper.genPCDBFile(query_string)
  pcdbFileName = dbHelper.getPCDBPath(query_string)
  outputDir = dbHelper.rawdataDir

  total_division = config.numSearchDivisions / config.numThreadPerDivisions
  for division_id in range(0, total_division):
    downloadQuery(query_string, configFileName, pcdbFileName, outputDir, division_id)
  
if __name__ == "__main__":
  main()
