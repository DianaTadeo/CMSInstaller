<?php
	if(isset($_GET['fileID'])){
		$filename_json = strip_tags(htmlentities(stripslashes($_GET['fileID'])));
		$file_json = strip_tags(htmlentities(stripslashes('./files/'))).$filename_json.'.json';
		if(file_exists($file_json)){
			try {
				$read_json = file_get_contents($file_json);
				$json_data = json_decode($read_json, true);
				$SO = str_replace(' ', '_', $json_data["SO"]);

				$options_name = $SO."_".ucfirst($json_data["CMS"])."_".$json_data["WebServer"]."_".$json_data["DatabaseManager"]."_";
				$tarFile = strip_tags(htmlentities(stripslashes('./Downloads/')))."$options_name$filename_json.tar"; // tar file destination path
				if(!file_exists($tarFile.".gz")){
					$phar_tar = new PharData($tarFile);
					$phar_tar->addFile($file_json, basename($file_json));  // json file with form data
					$dir_scripts = strip_tags(htmlentities(stripslashes('./Installer/'))); // directory with bash scripts
					$phar_tar->buildFromDirectory(dirname(__FILE__) . '/'.$dir_scripts);
					$phar_tar->compress(Phar::GZ);  // compress tarFile -> name.tar.gz
					unlink($tarFile);  // remove uncompressed tarFile from server-> name.tar

					file_put_contents(strip_tags(htmlentities(stripslashes('./hashes/'))).basename($tarFile).".gz.sha256", basename($tarFile).".gz\t\tSHA256: ".hash_file('sha256', $tarFile.".gz"));
				}

				$filetype=filetype($tarFile.".gz");
				header("Content-Type: ".$filetype);
				header("Content-Length: ".filesize($tarFile.".gz"));
				header('Content-Disposition: attachment; filename="'.basename($tarFile).'.gz"');
				header('Expires: 0');
				header('Cache-Control: must-revalidate');
				header('Pragma: public');
				readfile($tarFile.".gz");

			} catch (Exception $e){
				#echo 'Ocurrió un error:';
				#echo $e->getMessage();
			}
		}
	}
?>
