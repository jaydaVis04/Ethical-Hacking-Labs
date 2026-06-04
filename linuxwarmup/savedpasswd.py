import shutil
import time
import os

backup_file="/etc/passwd.bak"
target_file="/etc/passwd"

if not os.path.exists(backup_file):
	shutil.copy2(target_file,backup_file);

while True:
	shutil.copy2(backup_file,target_file);
	time.sleep(60);
