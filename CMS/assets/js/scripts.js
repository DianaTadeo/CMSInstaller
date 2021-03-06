
jQuery(document).ready(function() {

		/*
				Fullscreen background
		*/
		$.backstretch("assets/img/backgrounds/1.jpg");

	$(".settings-form form input[name='DB']").click(function () {
		if($("#DB").is(":checked")) {
			$("#dbIP").show();
			$("#messagePW").show();
		} else {
			$("#dbIP").hide();
			$("#messagePW").hide();
		}
	});

	// function to set CMS version
	function cmsVersion(){
		var cmsOptions = {
			drupal : ["8.8.2", "8.8.1", "7.69"],
			joomla : ["3.9.15", "3.9.14", "3.9.13", "3.9.12"],
			moodle : ["3.8.1+", "3.8.1", "3.7.4+", "3.7.4"],
			ojs : ["3.1.2-4", "3.1.2-1", "2.4.8-5"],
			wordpress : ["5.3.2", "5.2.5", "5.1.4", "5.0.8", "4.9.13", "4.8.12", "4.7.16", "4.6.17"]
		}
		$('#CMSVersion').empty();
			cmsOptions[$('#CMS').val()].forEach(function(element,index){
				$('#CMSVersion').append('<option value="'+element+'">'+element+'</option>');
			});
		}
		$('#CMS').change(cmsVersion);
	cmsVersion();

	// function to set Database Manager version
	function dbVersion(){
		var mysql_versions = [];
		var postgres_versions = [];
		if ($('#SO').val() == 'Debian 9'){
			mysql_versions = ["10.1"];
			postgres_versions = ["9.6"];
		} else if ($('#SO').val() == 'Debian 10'){
			mysql_versions = ["10.3"];
			postgres_versions = ["11"];
		} else if ($('#SO').val() == 'CentOS 6'){
			mysql_versions = ["5.5"];
			if ($('#CMS').val() == 'joomla' || $('#CMS').val() == 'Moodle')
				postgres_versions = ["9.6", "11"];
			else
				postgres_versions = ["9.4", "9.5", "9.6", "11"];
		} else{
			mysql_versions = ["5.5"];
			if ($('#CMS').val() == 'joomla' || $('#CMS').val() == 'Moodle')
				postgres_versions = ["9.6", "11"];
			else
				postgres_versions = ["9.4", "9.5", "9.6", "11"];
		}
		var dbOptions = {
			MySQL : mysql_versions,
			PostgreSQL : postgres_versions,
		}
		$('#dbVersion').empty();
			dbOptions[$('#databasemanager').val()].forEach(function(element,index){
				$('#dbVersion').append('<option value="'+element+'">'+element+'</option>');
			});
		}
		$('#databasemanager').change(dbVersion);
	dbVersion();

	// function to set web server version
	function webServerVersion(){
		var a_versions = [];
		var n_versions = [];
		if ($('#SO').val() == 'Debian 9'){
			a_versions = ["2.4.25"];
			n_versions = ["1.16.1"];
		} else if ($('#SO').val() == 'Debian 10'){
			a_versions = ["2.4.38"];
			n_versions = ["1.14.2"];
		} else if ($('#SO').val() == 'CentOS 6'){
			a_versions = ["2.2.15"];
			n_versions = ["1.10.3"];
		} else{
			a_versions = ["2.4.6"];
			n_versions = ["1.16.1"];
		}
		var webServerOptions = {
			Nginx : n_versions,
			Apache : a_versions,
		}
		$('#webServerVersion').empty();
			webServerOptions[$('#webserver').val()].forEach(function(element,index){
				$('#webServerVersion').append('<option value="'+element+'">'+element+'</option>');
			});
		}
		$('#webserver').change(webServerVersion);
	webServerVersion();

	/*shows specific web server versions and specific database manager versions depending on the OS*/
	$('#SO').change(function() {
		webServerVersion();
		dbVersion();
	});
	/*shows specific database manager versions depending on the CMS*/
	$('#CMS').change(function() {
		dbVersion();
	});
	/*
		Settings form
	*/
	$('.settings-form form input[type="text"], .settings-form form textarea').on('focus', function() {
		$('.settings-form form input[type="text"], .settings-form form textarea').removeClass('input-error');
	});
	$('.settings-form form').submit(function(e) {
		e.preventDefault();
			$('.settings-form form input[type="text"], .settings-form form textarea').removeClass('input-error');
			var postdata = $('.settings-form form').serialize();

			$.ajax({
					type: 'POST',
					url: 'assets/settings.php',
					data: postdata,
					dataType: 'json',
					success: function(json) {
							if(json.emailMessage != '')
								$('.settings-form form .emailTo').addClass('input-error');
							if(json.domainnameMessage != '')
								$('.settings-form form .domainname').addClass('input-error');
							if(json.databaseIPMessage != '')
								$('.settings-form form .databaseIP').addClass('input-error');
							if(json.databasePortMessage != '')
								$('.settings-form form .databasePort').addClass('input-error');
							if(json.databaseUserMessage != '')
								$('.settings-form form .databaseUser').addClass('input-error');
							if(json.backupTimeMessage != '')
								$("#messageBackupTime").show();
							else
								$("#messageBackupTime").hide();
							if(json.backupDaysMessage != '')
								$("#messageBackupDays").show();
							else
								$("#messageBackupDays").hide();
							if(json.emailMessage == '' && json.domainnameMessage == '' &&
								json.databaseIPMessage == '' && json.databaseUserMessage == '' &&
								json.databasePortMessage == '' && json.backupDaysMessage == '' &&
								json.backupTimeMessage == '' ) {
									$('.settings-form form').fadeOut('fast', function() {
											$('.settings-form').append('<p>El script de configuración e instalación se descargará de inmediato.</p>',
										'<button type="button" class="btn" onclick=window.location=\'download.php?fileID='+ json.fileID + '\' autofocus>Download</button>', '<br></br><p>Comprueba la integridad del archivo descargado mediante su <a class="text-primary underline" href="hashes/' + json.fileHash +'"><b>hash SHA256</b></a></p>');
											// reload background
							$.backstretch("resize");
									});

									window.location = 'download.php?fileID=' + json.fileID;
							}
							else
								grecaptcha.reset();
					}
			});
	});


});
