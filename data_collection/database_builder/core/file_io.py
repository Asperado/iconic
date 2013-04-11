class FileIO:
  def write_strings_to_file(self, lines, file_path):
    import os
    print(file_path)
    dir_name = os.path.dirname(file_path)
    self.create_folders(dir_name)
    fout = open(file_path, 'w')
    for line in lines:
      fout.write(line + '\n')
    fout.close()

  def create_folders(self, dir_name):
    import os
    if (not os.path.exists(dir_name)):
      os.makedirs(dir_name)

  def create_folders_for_path(self, path_name):
    import os
    dirname = os.path.dirname(path_name)
    self.create_folders(dirname)
