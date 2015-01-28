import os

current_folder_path, current_folder_name = os.path.split(os.getcwd())
str2=current_folder_path.split('/')
n=len(str2)
print str2[2]
