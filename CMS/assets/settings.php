<?php
// Email address verification
function isEmail($email) {
	return filter_var($email, FILTER_VALIDATE_EMAIL);
}
// Domain name verification
function isDomainName($domainname) {
	return filter_var($domainname, FILTER_VALIDATE_DOMAIN);
}
// IP address verification
function isIP($IP){
	return filter_var($IP, FILTER_VALIDATE_IP);
}
// Port verification
function isPort($port){
	return filter_var($port, FILTER_VALIDATE_INT);
}

function sanitizeInput($input){
			return strip_tags(htmlentities(stripslashes($input)));
 }

if(isset($_POST["g-recaptcha-response"])){
	 $response = $_POST["g-recaptcha-response"];

		 $url = 'https://www.google.com/recaptcha/api/siteverify';
		 $data = array(
			 'secret' => 'CLAVE_SECRETA_AQUI',
			 'response' => $_POST["g-recaptcha-response"]
		 );
		 $options = array(
			 'http' => array (
				 'method' => 'POST',
				 'content' => http_build_query($data)
			 )
		 );
		 $context  = stream_context_create($options);
		 $verify = file_get_contents($url, false, $context);
		 $captcha_success=json_decode($verify);

	if($captcha_success->success==true) {
		if($_POST) {
				$clientEmail = 'rafavafer@hotmail.com';
				if(isset($_POST['SO']))
					$SO = sanitizeInput($_POST['SO']);
				if(isset($_POST['domainname']))
					$domainname = sanitizeInput(($_POST['domainname']));
				if(isset($_POST['IPv4']))
					$IPv4 = sanitizeInput($_POST['IPv4']);
				if(isset($_POST['IPv6']))
					$IPv6 = sanitizeInput($_POST['IPv6']);
				if(isset($_POST['CMS']))
					$CMS = sanitizeInput($_POST['CMS']);
				if(isset($_POST['CMSVersion']))
					$CMS_version = sanitizeInput($_POST['CMSVersion']);
				if(isset($_POST['databasemanager']))
					$database_manager = sanitizeInput($_POST['databasemanager']);
				if(isset($_POST['dbVersion']))
					$dbVersion = sanitizeInput($_POST['dbVersion']);
				if(isset($_POST['DB']))
					$DB = sanitizeInput($_POST['DB']);
				if(isset($_POST['webserver']))
					$webserver = sanitizeInput($_POST['webserver']);
				if(isset($_POST['webServerVersion']))
					$webServerVersion = sanitizeInput($_POST['webServerVersion']);
				if(isset($_POST['emailTo']))
					$emailTo = sanitizeInput(($_POST['emailTo']));

				if($DB === 'Yes'){
					if(isset($_POST['databaseIP']))
						$databaseIP = sanitizeInput($_POST['databaseIP']);
					if(isset($_POST['databasePort']))
						$databasePort = sanitizeInput($_POST['databasePort']);
					if(isset($_POST['databaseUser']))
						$databaseUser = sanitizeInput($_POST['databaseUser']);
				}
				if (empty($_POST['path']))
					$path_install = sanitizeInput('/var/www/html');
				else
					$path_install = sanitizeInput($_POST['path']);
				if(isset($_POST['backupdays']))
					$backupdays = $_POST['backupdays'];
				if(isset($_POST['backuptime']))
					$backuptime = sanitizeInput($_POST['backuptime']);

				$array = array('emailMessage' => '', 'domainnameMessage' => '', 'databaseIPMessage' => '',
												'databasePortMessage' => '', 'databaseUserMessage' => '', 'backupDaysMessage' => ''
											);

				if(!isEmail($emailTo))
						$array['emailMessage'] = 'Invalid email!';
				if(!isDomainName($domainname))
						$array['domainnameMessage'] = 'Invalid domain name!';
				if($DB == 'Yes'){
					if(!isIP($databaseIP))
						$array['databaseIPMessage'] = 'Invalid IP address!';
					if(!isPort($databasePort))
						$array['databasePortMessage'] = 'Invalid Port!';
					if(empty($databaseUser))
						$array['databaseUserMessage'] = 'Empty username!';
				}
				if(empty($backupdays))
					$array['backupDaysMessage'] = 'Empty backup days!';
				if(isEmail($emailTo) && isDomainName($domainname)) {
					if($DB === 'Yes' && isIP($databaseIP) && isPort($databasePort) && !empty($databaseUser) || $DB === 'No') {
						// Send email
						$headers = "From: " . $clientEmail . " <" . $clientEmail . ">" . "\r\n" . "Reply-To: " . $clientEmail;
						mail($emailTo, "CMS seguros" . "Se ha generado un script para realizar una instalación y configuración de CMS.", $headers);
						$options = array(
							'SO' => $SO, 'DomainName' => $domainname, 'IPv4' => $IPv4,
							'IPv6' => $IPv6, 'CMS' => $CMS, 'CMSVersion' => $CMS_version,
							'DatabaseManager' => $database_manager, 'DBVersion' => $dbVersion,
							'WebServer' => $webserver, 'WSVersion' => $webServerVersion, 'PathInstall' => $path_install,
							'BackupDays' => $backupdays, 'BackupTime' => $backuptime, 'EmailTo' => $emailTo,
							'DBExists' => $DB
						);
						if($options['DBExists'] === 'Yes'){
							$options['DBIP'] = $databaseIP;
							$options['DBPort'] = $databasePort;
							$options['DBUser'] = $databaseUser;
						}
							$json_options = json_encode($options);
							$dir = '/var/www/html/CMS/files/';
							$file = uniqid().getmypid();
							$filename = $dir.$file.'.json';
							file_put_contents($filename, $json_options);
							$array['fileID'] = $file;
					}
				}

				echo json_encode($array);

		}
	}
}
?>
