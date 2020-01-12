<?php
	$filename = addslashes(trim($_GET['fileID'])).'.json';
	$file='/var/www/html/CMS/files/'.$filename;
	if(file_exists){
		$filetype=filetype($file);
		header ("Content-Type: ".$filetype);
		//header('Content-Type: text/html');
		header ("Content-Length: ".filesize($file));
		header ('Content-Disposition: attachment; filename="'.$filename.'"');
		header('Expires: 0');
		header('Cache-Control: must-revalidate');
		header('Pragma: public');
		readfile($file);
	}
?>
