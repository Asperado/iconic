if __name__ == "__main__":
    root_dir = '/Users/hongtaohuang/Desktop/Iconic/'
    query = 'cat'
    import os;
    completed_log_dir = os.path.join(root_dir, 'data/rawdata/%s-completed' % query)

    dict = {}
    for file_name in os.listdir(completed_log_dir):
        fin = open(os.path.join(completed_log_dir, file_name), 'r')
        for line in fin:
            word = line.split('_')
            word = word[1]
            word = word.strip()
            if (word in dict):
                print ('bingo')
                dict[word] = dict[word] + 1
            else:
                dict[word] = 1

