from nltk.corpus import wordnet as wn

def is_good_word(word):
  keep = 1;
  word = word.strip();
  if (len(word) <= 2):
    keep = 0;
  entry = wn.synsets(str(word));
  if (len(entry) == 0):
      keep = 0;

  return keep;

#task_filter_tag()
print(is_good_word('dog'));
#print(is_good_word('dogfd'));
  
  
