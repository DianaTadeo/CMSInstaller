
jQuery(document).ready(function() {

		/*
				Fullscreen background
		*/
		$.backstretch("assets/img/backgrounds/1.jpg");

	$(".settings-form form input[name='DB']").click(function () {
		if($("#DB").is(":checked"))
			$("#dbIP").show();
		else
			$("#dbIP").hide();
	});

	// function to set CMS version
	function cmsVersion(){
		var cmsOptions = {
			drupal : ["8.x", "7.x"],
			joomla : ["3.9.12"],
			moodle : ["3.7.2", "3.6.6"],
			ojs : ["3.1.2-1", "2.4.8-5"],
			wordpress : ["5.0.2", "4.9.8", "4.8.11", "4.7.15"]
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
		var dbOptions = {
			mysql : [" 8.0.12", "7.x"],
			postgresql : ["3.9.12"],
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
		var webServerOptions = {
			nginx : ["8.x", "7.x"],
			apache : ["2.4.41"],
		}
		$('#webServerVersion').empty();
			webServerOptions[$('#webserver').val()].forEach(function(element,index){
				$('#webServerVersion').append('<option value="'+element+'">'+element+'</option>');
			});
		}
		$('#webserver').change(webServerVersion);
	webServerVersion();

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
						/*	if(json.backupDaysMessage != '')
								$('.settings-form form .backupdays').addClass('input-error');*/
							if(json.emailMessage == '' && json.domainnameMessage == '' &&
								json.databaseIPMessage == '' && json.databaseUserMessage == '' &&
								json.databasePortMessage == '' && json.backupDaysMessage == '') {
									$('.settings-form form').fadeOut('fast', function() {
											$('.settings-form').append('<p>El script de configuración e instalación se descargará de inmediato.</p>');
											// reload background
							$.backstretch("resize");
									});
							}
					}
			});
	});


});
