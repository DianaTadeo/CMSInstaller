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

if($_POST) {
		$clientEmail = 'rafavafer@hotmail.com';
		$SO = $_POST['SO'];
		$domainname = addslashes(trim($_POST['domainname']));
		$IPv4 = $_POST['IPv4'];
		$IPv6 = $_POST['IPv6'];
		$CMS = $_POST['CMS'];
		$CMS_version = $_POST['CMSVersion'];
		$database_manager = $_POST['databasemanager'];
		$dbVersion = $_POST['dbVersion'];
		$DB = $_POST['DB'];
		$webserver = $_POST['webserver'];
		$webServerVersion = $_POST['webServerVersion'];
		$emailTo = addslashes(trim($_POST['emailTo']));
		if($DB === 'Yes'){
			$databaseIP = $_POST['databaseIP'];
			$databasePort = $_POST['databasePort'];
			$databaseUser = $_POST['databaseUser'];
		}
		if (empty($_POST['path']))
			$path_install = '/var/www/html';
		else
			$path_install = addslashes(trim($_POST['path']));
		$backupdays = $_POST['backupdays'];
		$backuptime = $_POST['backuptime'];

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
//					downloadFile($filename);
			}
		}

		echo json_encode($array);

}

?>
