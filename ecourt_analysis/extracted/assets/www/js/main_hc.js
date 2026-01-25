// var hostIP = "https://app.ecourts.gov.in/ecourt_mobile_encrypted_HC_debug/"; 
var hostIP = "https://app.ecourts.gov.in/ecourt_mobile_HC/";
// var hostIP = "http://10.249.33.50/ecourt_mobile_encrypted_HC_JWT/";
// var hostIP = "http://10.153.16.219/ecourt_mobile_encrypted/ecourt_mobile_HC/";//jwt live stup
// var hostIP = "http://10.153.16.219/ecourt_mobile_encrypted/ecourt_mobile_encrypted_HC/";//jwt implementation
//var hostIP = "http://10.153.6.215/ecourt_mobile_encrypted_audit/ecourt_mobile_HC/";

var isOnline = true;
var casesCountArr;
var cnrNumbersFromLocalStorage = window.localStorage.getItem("CNR Numbers HC");
var regenerateWebserviceCallFlag = false;
var globaliv = "4B6250655368566D";
var randomiv = "";
var jwttoken = "";
    //Fetch parameter passed to url of html.
    function getParameterByName(name, url) {
        if (!url)
            url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
        if (!results)
            return null;
        if (!results[2])
            return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    }

    function checkDeviceOnlineStatus(){
        var condition = navigator.onLine ? "online" : "offline";
        if (condition == "offline") {            
            isOnline = false;
            //showErrorMessage(labelsarr[717]);
            if(!isOnline){
                showErrorMessage("Please check your internet connection and Try again");}
        }else{           
            isOnline = true;   
            isConnErrorMsgShown=false;           
        }
    }

    //checks connection
    function checkConnection() { 
        var networkState = navigator.connection && navigator.connection.type;   
        if ((networkState == 'offline') || (networkState == 'none')) {        
            //showErrorMessage(labelsarr[717]);
            showErrorMessage("Please check your internet connection and Try again");
            isOnline = false;
        } else {        
            isOnline = true;
        }   
    }

    function ChangeUrl(title, url) {
        if (typeof (history.pushState) != "undefined") {
            var obj = {Title: title, Url: url};
            history.pushState(obj, obj.Title, obj.Url);
        } else {
            show("Browser does not support HTML5.");
        }
    }

    //show case history for selected case
    $(document).on('click', '.case_history_link', function (e) {
        e.preventDefault();
        var case_number = $(this).attr("case_no");
        var court_code = $(this).attr("court_code");
        var ciNumber = $(this).attr("cino");

        var caseHistoryWsUrl = hostIP + "caseHistoryWebService.php";
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

        var data = {state_code:(state_code_data), dist_code:(district_code_data), case_no:(case_number), court_code:(court_code), cino:(ciNumber)};
            //web service call to get case history
                callToWebService(caseHistoryWsUrl, data, caseHistorySearchResult);
                function caseHistorySearchResult(data){
                myApp.hidePleaseWait();  
                if (data.history != null) 
                {
                    if (CheckBrowser()) {
                        window.sessionStorage.setItem("case_history", JSON.stringify((data.history)));
                    }         
                                   
                    if(window.localStorage.getItem("SELECTED_COURT")==="DC")
                    {                           
                        $.ajax({
                            type: "GET",
                            url: "case_history.html"
                        }).done(function(data) { 
                            $("#caseHistoryModal").show();
                            $("#historyData").html(data);
                            $("#caseHistoryModal").modal();
                        });
                    }
                    else if(window.localStorage.getItem("SELECTED_COURT")==="HC")
                    {  
                        $.ajax({
                            type: "GET",
                            url: "case_history_hc.html"
                        }).done(function(data) { 
                            
                            $("#caseHistoryModal_hc").show();
                            $("#historyData_hc").html(data);
                            $("#caseHistoryModal_hc").modal();
                        });
                    }
                } else {
                    showErrorMessage("Error Opening Case History");
                    myApp.hidePleaseWait();  
                }                
            }
    });

    //check if browser supports localstorage
    function CheckBrowser() {
        if ('localStorage' in window && window['localStorage'] !== null) {
            // we can use localStorage object to store data
            return true;
        } else {
            return false;
        }
    }

    /*get data from web service. Called when there is no data in local storage for selected search*/
    function displayCasesTable(url, request_data) {
        arrCourtEstCodes = [];
        arrCourtEstCodes = window.localStorage.SESSION_COURT_CODE.split(',');
        total_Cases = '';
        $("#headers").empty();
        var headerArray = [];
//        headerArray.push('<label">Total Number of Establishments in Court Complex:<span id="totalEstablishmentsSpanId"></span> </label></div>');
        headerArray.push('<a style="color:#212529;" href="#" id="total_est_header">Total Number of Establishments in Court Complex::<span id="totalEstablishmentsSpanId"></span> </a></div>');
        headerArray.push('<br>');
        headerArray.push('<label>Total Number of Cases: <span id="totalcasesId"></span></label></div>');
        $("#headers").append(headerArray);
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        $("#accordion_search").empty();
        //Total number of establishments (comma separated values of court codes)
        var establishments_count = arrCourtEstCodes.length;
        //count used to check if data fetched for all the establishments.
        var count1 = 0;
        myApp.showPleaseWait();
        var jsonData = {};
        for (var i = 0; i <= arrCourtEstCodes.length - 1; i++) {
            if(arrCourtEstCodes[i] != ","){
            var encrypted_data1 = (state_code_data);
            var encrypted_data2 = (district_code_data);
            var encrypted_data3 = (arrCourtEstCodes[i]);
            var data1 = {state_code:encrypted_data1.toString(),dist_code:encrypted_data2.toString(), court_code:encrypted_data3.toString()};
            var data = $.extend({}, data1, request_data); 
            //Establishment name appears on each panel    
            var establishment_name;
            //Id for panels of each establishement
            var collapseid = 0;
            //populate the result table with court establishment as collapse field
                callToWebService(url, data, casesSearchResult);
                function casesSearchResult(data){
                    var obj_caseNos = null;
                    if(data != null){
                        obj_caseNos = (data.caseNos);
                    }
                    if (obj_caseNos != null) {
                        var obj_courtcode = (data.court_code);
                        var obj_establishment_name = (data.establishment_name);   
                        jsonData[JSON.stringify(obj_courtcode)] = JSON.stringify(data);
                        // window.sessionStorage.setItem("SET_RESULT", JSON.stringify(jsonData));
                        window.sessionStorage.setItem("SET_RESULT", true);
                        var panel_body = [];
                        var totalCases = obj_caseNos.length;
                        total_Cases = Number(totalCases) + Number(total_Cases);
                        var trHTML = '';
                        var court_code = obj_courtcode;
                        panel_id = 'card'+state_code_data + '_' + district_code_data + '_' + court_code;
                        establishment_name = obj_establishment_name;
                        
                        establishment_name = establishment_name + " : " + totalCases;
                        panel_body.push('<div class="card" id=' + panel_id + '">');
                        panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + establishment_name + '</a></h4></div>');
                        panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'><table class='table tbl-result'><thead><tr><th>Sr.No</th><th>Case Number</th><th>Party Name</th></tr></thead><tbody>");
                        collapseid++;
                        var index = 0;
                        $.each(obj_caseNos, function (key, val) {
                            index++;
                            var petresName = val.petnameadArr;
                            var case_type_number = val.type_name + '/' + val.case_no2 + '/' + val.reg_year;
                            var casehistorylink = '';
                            var case_no_ = val.case_no;            
                            casehistorylink = 'case_history_link';//                            
                            var hrefurl = "<a style='color:#03A8D8;text-decoration:underline;' href='#' class='" + casehistorylink + "  'court_code='" + court_code + "'cino='" + val.cino + "'case_no='" + case_no_ + "'>" + case_type_number + '</a>';
                            trHTML += "<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td></tr>";
                            panel_body.push("<tr><td>" + index + "</td><td>" + hrefurl + "</td><td>" + petresName + "</td></tr>");
                        });
                        panel_body.push("</tbody></table></div></div>");
                        count1++;
                        panel_body.push('</div>');
                        if (Number(totalCases) != 0) {
                            $("#accordion_search").append(panel_body.join(""));
                        }                        
                        document.getElementById('totalcasesId').innerHTML = total_Cases;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                    } else {
                        establishments_count -= 1;
                        document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
                    }
                    if (count1 == establishments_count){
//                        $('#total_est_header').focus();
//                        $('#total_est_header').prop('autofocus');
                        myApp.hidePleaseWait();
                        $('#goButton').focus();
                    }
            }
        }else {
            /*If connection to establishment fails, reduce the total number of establishments*/
            establishments_count -= 1;
            document.getElementById('totalEstablishmentsSpanId').innerHTML = establishments_count;
        }
        }
    }
    /*function to display header for all forms, case history , view business and writ info*/
    function second_header() {
        $("#header_srchpage").load("header.html", function (response, status, xhr) {
            $('#go_back_link').on('click', function (event) {
                backButtonHistory.pop();
                window.sessionStorage.removeItem("SET_RESULT");
                $("#searchPageModal").modal('hide');
                var prev_selected_btn = window.sessionStorage.getItem("Selected_screen");
                $("."+prev_selected_btn).focus();
            });

            $("#open_close1").on('click', function (event) 
            {
                if ($("#mySidenav1").is(':visible'))
                {
                    closeNav1();
                } else
                {
                    openNav1();
                }                
            });
        });
    }

   /*To Export saved cases from local storage to myCases.txt file from device internal storage*/
    function backupContent(socialSharing,savetodatadir,showSuccessAlert) {
        //var cnrNumbersStr = window.localStorage.getItem("CNR Numbers HC");
        var cnrNumbersStr = 0;
        var cnrNumbersArr_parsed;
        var CNR_array = localStorage.getItem("CNR Numbers HC");
        if(CNR_array){
            cnrNumbersArrLength= JSON.parse(CNR_array).length;
            cnrNumbersArr_parsed = JSON.parse(CNR_array);
        }
        if (CNR_array && cnrNumbersArr_parsed.length != 0) {
            cnrNumbersStr = CNR_array;
            var fileName = '';      
                   
            if(!showSuccessAlert){
                fileName = 'hcMyCases.txt';
            }else{
                fileName = 'hcMyCases_backup.txt';
            }
            
            var data = cnrNumbersStr;
			if(socialSharing === "drive"){
                myApp.showPleaseWait();			
				window.plugins.googleplus.login(
				{
				  //'scopes' : 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.appdata https://www.googleapis.com/auth/drive.apps.readonly https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata https://www.googleapis.com/auth/drive.scripts',
				  'scopes' : 'https://www.googleapis.com/auth/drive.file',
                  'webClientId': '658126779023-qls50eu22l3r5dipb8a4jm6kirdcrg83.apps.googleusercontent.com', // optional clientId of your Web application from Credentials settings of your project - On Android, this MUST be included to get an idToken. On iOS, it is not required.
				  'offline': true, // optional, but requires the webClientId - if set to true the plugin will also return a serverAuthCode, which can be used to grant offline access to a non-Google server
				},
				function (obj) {
					var access_token= obj.accessToken;						
					var boundary = "foo_bar_baz";
					const delimiter = "\r\n--" + boundary + "\r\n";
					const close_delim = "\r\n--" + boundary + "--";
					var fileContent = cnrNumbersStr; // As a sample, upload a text file.
					var tmpfile = new Blob([fileContent], {type: 'text/plain'});
					var contentType = 'text/plain';
					var metadata = {
						"name": 'hcMyCases.txt',
						"mimeType": 'text/plain'
					  };
					 var multipartRequestBody =
					 delimiter +  'Content-Type: application/json\r\n\r\n' +
					 JSON.stringify(metadata) +
					 delimiter + 'Content-Type: ' + contentType + '\r\n' + '\r\n' +
					 cnrNumbersStr + 
					 close_delim;
					
					$.ajax({
						type: "GET",
						beforeSend: function(request) {
							request.setRequestHeader("Authorization", "Bearer" + " " + access_token);								
						},
						url: "https://www.googleapis.com/drive/v3/files?q=(name = 'hcMyCases.txt')",

						success: function (data) {
							//alert(JSON.stringify(data));
							if(data.files.length == 1){
							var fileId = data.files[0].id;
							$.ajax({
								type: "PATCH",
								beforeSend: function(request) {
									request.setRequestHeader("Authorization", "Bearer" + " " + access_token);
									 request.setRequestHeader("Content-Type", 'multipart/related; boundary="'+ boundary + '"');
									
								},
								url: "https://www.googleapis.com/upload/drive/v3/files/"+fileId+"/?uploadType=multipart",
								
								success: function (data) {
                                    myApp.hidePleaseWait();
                                    alert("hcMyCases.txt Updated in Drive Successfully.");
                                    localStorage.setItem("LAST_MyCASES_HC_EXPORT", new Date());
                                    $("#exportCasesWarning").hide();
                                    $("#my_cases_text").show();
								},
								error: function (error) {
                                    myApp.hidePleaseWait();
									alert('error');
									//alert('error'+JSON.stringify(error));
								},
								async: true,
								data: multipartRequestBody,
								cache: false,
								contentType: false,
								 processData: false,
								 crossDomain: true
							});
							}else if(data.files.length == 0){
								$.ajax({
								type: "POST",
								beforeSend: function(request) {
									request.setRequestHeader("Authorization", "Bearer" + " " + access_token);
									 request.setRequestHeader("Content-Type", 'multipart/related; boundary="'+ boundary + '"');
									
								},
								url: "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart",
								
								success: function (data) {
                                    myApp.hidePleaseWait();
                                    alert("hcMyCases.txt Saved to Drive Successfully.");	
                                    localStorage.setItem("LAST_MyCASES_HC_EXPORT", new Date());
                                    $("#exportCasesWarning").hide();
                                    $("#my_cases_text").show();								
								},
								error: function (error) {
                                    myApp.hidePleaseWait();
									//alert('error'+JSON.stringify(error));
                                    alert('Error');
								},
								async: true,
								data: multipartRequestBody,
								cache: false,
								 contentType: false,
								 processData: false,
								 crossDomain: true
							});
							}else if(data.files.length > 1){
                                myApp.hidePleaseWait();
								alert('Multiple files exist in drive with name hcMyCases.txt.');
							}
							
						},
						error: function (error) {
                            myApp.hidePleaseWait();
							alert('Error');							
						}
					});
				},
				function (msg) {
                    myApp.hidePleaseWait();				    
                    alert('Error');
				}

				);                               
            }else if(socialSharing === "telegram"){
                window.resolveLocalFileSystemURL(cordova.file.externalRootDirectory, function (directoryEntry) {
                    directoryEntry.getFile(fileName, {create: true}, function (fileEntry) {
                        fileEntry.createWriter(function (fileWriter) {
                        fileWriter.onwriteend = function (result) {                                
                                    window.plugins.socialsharing.shareVia('telegram','Message via telegram', fileName, cordova.file.externalRootDirectory+fileName, function(e){alert(e)}, function(e){alert(e)});
                                };
                                fileWriter.onerror = function (error) {
                                    showErrorMessage(error);
                                };
                                fileWriter.write(data);
                            }, function (error) {
                                showErrorMessage(error);
                            });
                        }, function (error) {
                            showErrorMessage(error);
                        });
                }, function (error) {
                        showErrorMessage(error);
                });
                
            }else if(socialSharing === "email"){
                var storageLocation;
                switch (device.platform) {
                    case "Android":
                        if(savetodatadir){                        
                            storageLocation = cordova.file.externalDataDirectory;
                        }else{
                            storageLocation = cordova.file.externalRootDirectory+"Download/";
                        }
                    break;

                    case "iOS":
                    storageLocation = cordova.file.documentsDirectory;
                    break;
                }
                window.resolveLocalFileSystemURL(storageLocation, function (directoryEntry) {
                    directoryEntry.getFile(fileName, {create: true}, function (fileEntry) {
                        fileEntry.createWriter(function (fileWriter) {
                        fileWriter.onwriteend = function (result) {          
                            window.plugins.socialsharing.shareViaEmail('Message', 
                                'Subject',
                                null,
                                null, 
                                null, 
                                [storageLocation+fileName],
                                function(e){}, function(e){
                                    
                                    localStorage.setItem("LAST_MyCASES_HC_EXPORT", new Date());
                                    $("#exportCasesWarning").hide();
                                    $("#my_cases_text").show();
                                
                                });
                            };
                                fileWriter.onerror = function (error) {
                                    if(savetodatadir){
                                    showErrorMessage("error1 "+error.code);}
                                };
                                fileWriter.write(data);
                            }, function (error) {
                                if(savetodatadir){
                                showErrorMessage("error2 "+error.code);}
                            });
                        }, function (error) {
                            if(savetodatadir){
                            showErrorMessage("error3 "+error.code);}
                        });
                }, function (error) {
                    if(savetodatadir){
                        showErrorMessage("error4 "+error.code);}
                });
                if(!savetodatadir){
                    backupContent(socialSharing,true);
                }

            }else if(socialSharing === "device"){
                myApp.showPleaseWait();
                var storageLocation;
                switch (device.platform) {
                    case "Android":
                        if(savetodatadir){                    
                            storageLocation = cordova.file.externalDataDirectory;
                        }else{  
                            storageLocation = cordova.file.externalRootDirectory+"Download/";
                        }
                    break;

                    case "iOS":
                    storageLocation = cordova.file.documentsDirectory;
                    break;
                }
    //			 window.resolveLocalFileSystemURL(cordova.file.externalRootDirectory, function (directoryEntry) {
                window.resolveLocalFileSystemURL(storageLocation, function (directoryEntry) {			 
                    directoryEntry.getFile(fileName, {create: true}, function (fileEntry) {
                        fileEntry.createWriter(function (fileWriter) {
                        fileWriter.onwriteend = function (result) { 
                                myApp.hidePleaseWait();   
                                if(savetodatadir && !showSuccessAlert){       
                                    alert("File hcMyCases.txt Saved Successfully to Internal Storage");
                                }
                                if(!showSuccessAlert){
                                    localStorage.setItem("LAST_MyCASES_HC_EXPORT", new Date());
                                    $("#exportCasesWarning").hide();
                                    $("#my_cases_text").show();
                                }
                            };
                                fileWriter.onerror = function (error) {
                                    myApp.hidePleaseWait();
                                    if(savetodatadir){
                                    showErrorMessage(error);}
                                };
                                fileWriter.write(data);
                            }, function (error) {
                                myApp.hidePleaseWait();
                                if(savetodatadir){
                                showErrorMessage(error);}
                            });
                        }, function (error) {
                            myApp.hidePleaseWait();
                            if(savetodatadir){
                            showErrorMessage(error);}
                        });
                }, function (error) {
                    myApp.hidePleaseWait();
                    if(savetodatadir){
                        showErrorMessage(error);}
                });
                if(!savetodatadir){
                    backupContent(socialSharing,true);
                }
                
            }
        } else {
            myApp.hidePleaseWait();
            if(savetodatadir && !showSuccessAlert){
            showErrorMessage("No content to backup.");}
        }
    }

	/*To Import cases from myCases.txt file from device internal storage to local storage and display in My Cases */
    function importFileFrom(socialSharing,readFromDataDir=false,showSuccsAlrt) {
        var fileName = '';  // your file name
        if(!showSuccsAlrt){
            fileName = 'hcMyCases.txt';
        }else{
            fileName = 'hcMyCases_backup.txt';
        }
	    if(socialSharing === "device"){	
            myApp.showPleaseWait();	
            /*$.get('testHC.txt', function(data) {
                               backupcnrNumbersArray = JSON.parse(data);
                                if (backupcnrNumbersArray.length > 0) {
                                    localStorage.setItem("CNR Numbers HC", JSON.stringify(backupcnrNumbersArray));
									
									$("#showCaseDiv").show();
									//resetDatePicker();
									clearSearchText();
									$("#searchCasesButton").click(); 
									$("#allCasesBtn").addClass("active");
									$("#todaysCasesBtn").removeClass("active");
                                    
                                    setCalendarCountArr(backupcnrNumbersArray);

                                    updateAllCasesAcordion(backupcnrNumbersArray);
                                    myApp.hidePleaseWait();
                                    document.getElementById("mycases_span_id").innerHTML = backupcnrNumbersArray.length;
                                    alert("Cases imported successfully.");
                                    
                                } else {
                                    myApp.hidePleaseWait();
                                    showErrorMessage("No cases found");
                                }
                            }, 'text');	*/
				var storageLocation;
            switch (device.platform) {
                case "Android":
                    if(readFromDataDir){
                        storageLocation = cordova.file.externalDataDirectory;
                    }else{
                        storageLocation = cordova.file.externalRootDirectory+"Download";
                    }
                  break;

                case "iOS":
                    storageLocation = cordova.file.documentsDirectory;
                  break;
              }
			window.resolveLocalFileSystemURL(storageLocation, function (directoryEntry) {
				directoryEntry.getFile(fileName, {create: false}, function (fileEntry) {
					fileEntry.file(function (file) {
						
						var reader = new FileReader();

						reader.onloadend = function (e) {
							
							if (reader.result == null) {
                                myApp.hidePleaseWait();
								//showErrorMessage("File "+fileName+" Not Found at Internal Storage");
                                if(!readFromDataDir){
                                    importFileFrom(socialSharing,true);
                                }else if(!showSuccsAlrt){
                                    showErrorMessage("File "+fileName+" Not Found at Internal Storage");
                                }
							} else {								
								backupcnrNumbersArray = JSON.parse(reader.result);
								if (backupcnrNumbersArray.length > 0) {                                    
                                    if(showSuccsAlrt){
                                        $("#importCasesDialog").modal();                                        
                                    }else{
                                        localStorage.setItem("CNR Numbers HC", JSON.stringify(backupcnrNumbersArray));
                                        $("#showCaseDiv").show();                                        
                                        clearSearchText();
                                        $("#searchCasesButton").click(); 
                                        $("#allCasesBtn").addClass("active");
                                        $("#todaysCasesBtn").removeClass("active");
                                        
                                        setCalendarCountArr(backupcnrNumbersArray);
                                        updateAllCasesAcordion(backupcnrNumbersArray);
                                        myApp.hidePleaseWait();
                                        document.getElementById("mycases_span_id").innerHTML = backupcnrNumbersArray.length;
                                        if(!showSuccsAlrt){
                                            alert("Cases imported successfully.");
                                        }
                                    }

                                    $("#btnYes").click(function(){
                                        localStorage.setItem("CNR Numbers HC", JSON.stringify(backupcnrNumbersArray));
                                        $("#showCaseDiv").show();                                        
                                        clearSearchText();
                                        $("#searchCasesButton").click(); 
                                        $("#allCasesBtn").addClass("active");
                                        $("#todaysCasesBtn").removeClass("active");
                                        
                                        setCalendarCountArr(backupcnrNumbersArray);
                                        updateAllCasesAcordion(backupcnrNumbersArray);
                                        myApp.hidePleaseWait();
                                        document.getElementById("mycases_span_id").innerHTML = backupcnrNumbersArray.length;
                                        if(!showSuccsAlrt){
                                            alert("Cases imported successfully.");
                                        }
                                        $("#importCasesDialog").hide();
                                    });
                                    $("#btnCancle").click(function(){
                                        $("#importCasesDialog").hide();
                                        return;
                                    });

								} else {
                                    myApp.hidePleaseWait();
                                    if(!readFromDataDir){
                                        importFileFrom(socialSharing,true);
                                    }else if(!showSuccsAlrt){
									showErrorMessage("No cases found");}
								}
							}
						}

						reader.readAsText(file);
					}, errorHandler);
				},onErrorCreateFile);
            });
            function errorHandler(){
                myApp.hidePleaseWait();                
                if(!readFromDataDir){
                    importFileFrom(socialSharing,true);
                }else if(!showSuccsAlrt){
                    showErrorMessage("File "+fileName+" Not Found at Internal Storage");
                }
            }
            function onErrorCreateFile() {
                myApp.hidePleaseWait();
                if(!readFromDataDir){
                    importFileFrom(socialSharing,true);
                }else if(!showSuccsAlrt){
                    showErrorMessage("File "+fileName+" Not Found at Internal Storage");   
                }           
            }
		}else if(socialSharing === "drive"){
            myApp.showPleaseWait();
			window.plugins.googleplus.login(
				{
				  //'scopes' : 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.appdata https://www.googleapis.com/auth/drive.apps.readonly https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata https://www.googleapis.com/auth/drive.scripts',
				  'scopes' : 'https://www.googleapis.com/auth/drive.file',
                  'webClientId': '658126779023-qls50eu22l3r5dipb8a4jm6kirdcrg83.apps.googleusercontent.com', // optional clientId of your Web application from Credentials settings of your project - On Android, this MUST be included to get an idToken. On iOS, it is not required.
				  'offline': true, // optional, but requires the webClientId - if set to true the plugin will also return a serverAuthCode, which can be used to grant offline access to a non-Google server
				},
				function (obj) {
					var access_token= obj.accessToken;						
			
					var contentType = 'text/plain';

					$.ajax({
						type: "GET",
						beforeSend: function(request) {
							request.setRequestHeader("Authorization", "Bearer" + " " + access_token);								
						},
						url: "https://www.googleapis.com/drive/v3/files?q=(name = 'hcMyCases.txt')",

						success: function (data) {
							
							if(data.files.length == 1){
								var fileId = data.files[0].id;
								$.ajax({
									type: "GET",
									beforeSend: function(request1) {
										request1.setRequestHeader("Authorization", "Bearer" + " " + access_token);
									},
									url: "https://www.googleapis.com/drive/v3/files/"+fileId+"?alt=media",
									
									success: function (data) {
										
										backupcnrNumbersArray = JSON.parse(data);
										if (backupcnrNumbersArray.length > 0) {
											localStorage.setItem("CNR Numbers HC", JSON.stringify(backupcnrNumbersArray));
											
											$("#showCaseDiv").show();
											//resetDatePicker();
											clearSearchText();
											$("#searchCasesButton").click(); 
											$("#allCasesBtn").addClass("active");
											$("#todaysCasesBtn").removeClass("active");
											
											setCalendarCountArr(backupcnrNumbersArray);

                                            updateAllCasesAcordion(backupcnrNumbersArray);
                                            myApp.hidePleaseWait();
											document.getElementById("mycases_span_id").innerHTML = backupcnrNumbersArray.length;
											alert("Cases imported successfully.");
										} else {
                                            myApp.hidePleaseWait();
											showErrorMessage("No cases found");
										}
									},
									error: function (error) {
                                        myApp.hidePleaseWait();
										alert('Error');
										//alert('error'+JSON.stringify(error));
									}
								});
							}else if(data.files.length == 0){
                                myApp.hidePleaseWait();
								alert("hcMyCases.txt does not exist in Drive");
							}else if(data.files.length > 1){
                                myApp.hidePleaseWait();
								alert('Multiple files exist in drive with name hcMyCases.txt.');
							}
						}
					});
			});
		}
	}


     /*To Import cases from hcMyCases.txt file from device internal storage to local storage and display in My Cases */
    function importFile() {
        var fileName = '';  // your file name
            if(window.localStorage.getItem("SELECTED_COURT")==="DC")
            {
                fileName = 'myCases.txt';
            }
            else{
                fileName = 'hcMyCases.txt';
            }
        
      //  var fileNameImport= 'myCases.txt';
        window.resolveLocalFileSystemURL(cordova.file.externalRootDirectory, function (directoryEntry) {
            directoryEntry.getFile(fileName, {create: false}, function (fileEntry) {
                fileEntry.file(function (file) {
                    
                    var reader = new FileReader();

                    reader.onload = function (e) {
                        
                        if (reader.result == null) {
                            showErrorMessage("File "+fileName+" Not Found at internal storage");
                        } else {
                            
                            backupcnrNumbersArray = JSON.parse(reader.result);
                            if (backupcnrNumbersArray.length > 0) {
                                if(localStorage.SELECTED_COURT === 'HC'){
                                    localStorage.setItem("CNR Numbers HC", JSON.stringify(backupcnrNumbersArray));
                                }else{
                                    localStorage.setItem("CNR Numbers", JSON.stringify(backupcnrNumbersArray));
                                }
                                $("#showCaseDiv").show();
//                                resetDatePicker();
                                clearSearchText();
                                $("#searchCasesButton").click(); 
                                $("#allCasesBtn").addClass("active");
                                $("#todaysCasesBtn").removeClass("active");
                                setCalendarCountArr(backupcnrNumbersArray);
                                updateAllCasesAcordion(backupcnrNumbersArray);
                                document.getElementById("mycases_span_id").innerHTML = backupcnrNumbersArray.length;
                            } else {
                                showErrorMessage("No cases found");
                            }
                        }
                    }

                    reader.readAsText(file);
                }, errorHandler);
            });
        });
    }

    //variable to save cause list result in session storage(To avoid repeat ajax calls once result is retrieved)
    var CAUSE_LIST_RESULT = '';

    /*setter for cause list result called after getting the result for cause
    list seatch
    *@cause_list_result : stringified cases json object
    */
    function setCauseListResult(cause_list_result) {
        CAUSE_LIST_RESULT = cause_list_result;
    }

    //getter for cause list result called to get cause list search result after page reload
    function getCauseListResult() {
        return CAUSE_LIST_RESULT;
    }

    //function to retain state of collapse fields after page reload
    // $(document).on("show.bs.collapse", ".collapse", function (event) {
    //     var active = $(this).attr('id');
    //     var panels = localStorage.panels === undefined ? new Array() : JSON.parse(localStorage.panels);
    //     if ($.inArray(active, panels) == -1) //check that the element is not in the array
    //         panels.push(active);
    //     localStorage.panels = JSON.stringify(panels);
    // });

    // //function to retain state of collapse fields after page reload
    // $(document).on("hidden.bs.collapse", ".collapse", function (event) {
    //     var active = $(this).attr('id');
    //     var panels = localStorage.panels === undefined ? new Array() : JSON.parse(localStorage.panels);
    //     var elementIndex = $.inArray(active, panels);
    //     if (elementIndex !== -1) //check the array
    //     {
    //         panels.splice(elementIndex, 1); //remove item from array
    //     }
    //     localStorage.panels = JSON.stringify(panels); //save array on localStorage
    // });


    /*
    *function to encrypt data
    *@data : stringified data to encrypt
    */
    function setRandomIv(riv){
        randomiv = riv;
    }

    function getRandomIv(){
        return randomiv;
    }

    function encryptData(data){
            var dataEncoded = JSON.stringify(data);
            generateGlobalIv();
            var randomiv = genRanHex(16);
            var key = CryptoJS.enc.Hex.parse('4D6251655468576D5A7134743677397A');
            var iv  = CryptoJS.enc.Hex.parse(globaliv + randomiv);
            var encrypted = CryptoJS.AES.encrypt((dataEncoded), key, { iv:  iv });
            var encrypted_data = encrypted.ciphertext.toString(CryptoJS.enc.Base64);
            encrypted_data = randomiv + globalIndex + encrypted_data;
            return encrypted_data;
    }

    /*
    *function to decrypt response
    *@result : encrypted result
    */
    function decodeResponse(result){
        var key = CryptoJS.enc.Hex.parse('3273357638782F413F4428472B4B6250');
        var iv_random = CryptoJS.enc.Hex.parse(result.trim().slice(0,32));
        var result_split = result.trim().slice(32);
        var bytes = CryptoJS.AES.decrypt(result_split.trim(), key, {iv: iv_random}, {mode: CryptoJS.mode.CBC});
        var plaintext = bytes.toString(CryptoJS.enc.Utf8);
        s = plaintext;
        s = s.replace(/\\n/g, "\\n")
                .replace(/\\'/g, "\\'")
                .replace(/\\"/g, '\\"')
                .replace(/\\&/g, "\\&")
                .replace(/\\r/g, "\\r")
                .replace(/\\t/g, "\\t")
                .replace(/\\b/g, "\\b")
                .replace(/\\f/g, "\\f");
        // remove non-printable and other non-valid JSON chars
        s = s.replace(/[\u0000-\u0019]+/g, "");
        return s;
    }

    function generateGlobalIv(){
        var a = ["556A586E32723575", "34743777217A2543" , "413F4428472B4B62" , "48404D635166546A" , "614E645267556B58", "655368566D597133"];           
        var test_arr = [0,1,2,3,4,5];
        shuffle(test_arr);        
        function shuffle (array) {
            var i = 0
            , j = 0
            , temp = null

            for (i = array.length - 1; i > 0; i -= 1) {
            j = Math.floor(Math.random() * (i + 1))
            temp = array[i]
            array[i] = array[j]
            array[j] = temp
            }
        }
        globaliv =  a[test_arr[0]].toString();
        globalIndex = test_arr[0];   
    }

    //Function to generate random hex number
    function genRanHex(size){
        var hex = [...Array(size)]
        .map(() => Math.floor(Math.random() * 16).toString(16)).join('');
        return hex;
    }

    //common code for spinner
    var myApp;
    myApp = myApp || (function () {

        var pleaseWaitDiv = $('<div class="modal" id="pleaseWaitDialog" data-backdrop="static"data-keyboard="false"><div class="modal-content" style="margin-top:50%;"><div class="modal-body text-center"><i class="fa fa-spinner fa-spin fa-3x fa-fw"></i><h3 style="color:#FFF;font-weight: bold;" >loading...</h3></div></div></div>');

        return {
            showPleaseWait: function() {
                pleaseWaitDiv.modal('show');
            },
            hidePleaseWait: function () {
                pleaseWaitDiv.modal('hide');
            },

        };
    })();
    //spinner code ends

    //common function to show error messages
    function showErrorMessage(message){
        $.bootstrapGrowl(message,{
                ele: 'body', // which element to append to
                  type: 'danger', // (null, 'info', 'danger', 'success')
                  offset: {from: 'bottom', amount: 20}, // 'top', or 'bottom'
                  align: 'center', // ('left', 'right', or 'center')
                  width: 'auto', // (integer, or 'auto')
                  delay: 2000, // Time while the message will be displayed. It's not equivalent to the *demo* timeOut!
                  allow_dismiss: false, // If true then will display a cross to close the popup.
                  stackup_spacing: 10 // spacing between consecutively stacked growls.
            });
    }

    //common function to show info messages
    function showInfoMessage(message){
        $.bootstrapGrowl(message,{
                ele: 'body', // which element to append to
                  type: 'info', // (null, 'info', 'danger', 'success')
                  offset: {from: 'bottom', amount: 20}, // 'top', or 'bottom'
                  align: 'center', // ('left', 'right', or 'center')
                  width: 'auto', // (integer, or 'auto')
                  delay: 2000, // Time while the message will be displayed. It's not equivalent to the *demo* timeOut!
                  allow_dismiss: false, // If true then will display a cross to close the popup.
                  stackup_spacing: 10 // spacing between consecutively stacked growls.
            });
    }



    function setCalendarCountArr(cnrNumbersArr){
        if(cnrNumbersArr && cnrNumbersArr.length > 0){
                calendarDates = cnrNumbersArr.reduce(function (calendarDates, current) {

                var caseInfo = JSON.parse(current);

                /*let dtNextStr = "";
                let dtLastStr = "";
                let dtDecStr = "";
                    */
                var dtNextStr = "";
                var dtLastStr = "";
                var dtDecStr = "";
                    
                if(caseInfo.date_next_list){
                    dtNext = caseInfo.date_next_list.split('-');
                    dtNextStr = (dtNext[2] + "-" + dtNext[1] + "-" + dtNext[0]);
                }

                if(caseInfo.date_last_list){
                    dtLast = caseInfo.date_last_list.split('-');                        
                    dtLastStr = (dtLast[2] + "-" + dtLast[1] + "-" + dtLast[0]);
                }

                if(caseInfo.date_of_decision){
                    dtDec = caseInfo.date_of_decision.split('-');                        
                    dtDecStr = (dtDec[2] + "-" + dtDec[1] + "-" + dtDec[0]);
                }                        
                                    
                if(dtNextStr){
                    calendarDates[dtNextStr] = calendarDates[dtNextStr] || [];
                    calendarDates[dtNextStr].push(current);
                }

                if(dtLastStr){
                    if((dtNextStr != dtLastStr) && (dtNextStr != dtDecStr) && (dtLastStr!=dtDecStr)){
                        calendarDates[dtLastStr] = calendarDates[dtLastStr] || [];
                        calendarDates[dtLastStr].push(current);
                    }
                }

                if(dtDecStr){
                    if((dtNextStr != dtLastStr) && (dtNextStr != dtDecStr)){
                        calendarDates[dtDecStr] = calendarDates[dtDecStr] || [];
                        calendarDates[dtDecStr].push(current);
                    }
                }

                return calendarDates;

                }, {});
            
            
                var calendarCntArr = {};
                $.each(calendarDates, function (index, value) {
                    //let length = calendarDates[index].length;                    
                    var length = calendarDates[index].length;                    
                    calendarCntArr[index] = length;
                });
                    
                casesCountArr = calendarCntArr;
        }else{
            casesCountArr = null;
        }
    }

    function getCalendarCountArr(){
        return casesCountArr;
    }

    function callToWebService(url, data, callback){
        checkConnection();
        myApp.showPleaseWait();        
        var data1 = encryptData(data);
        if(url == hostIP + "appReleaseWebService.php"){
            header = {};
        }else{
            header =  {'Authorization' : 'Bearer ' + encryptData(jwttoken)};
        }
        cordova.plugin.http.get(url, {params:data1}, header,function(response) {
            myApp.hidePleaseWait();
            var responseDecoded = JSON.parse(decodeResponse(response.data));
            
            if(responseDecoded.token){
                jwttoken = responseDecoded.token;
            }
            if(responseDecoded.status && responseDecoded.status=='N'){
                if(responseDecoded.status_code == '401'){
                    if(!regenerateWebserviceCallFlag){
                        regenerateWebserviceCallFlag = true;
                        cordova.getAppVersion.getPackageName(function(pkgname){
                            var uidObj = {"uid":device.uuid ? device.uuid.toString() + ":" + pkgname : "324456" + ":" + pkgname}; 
                            data = {...data, ...uidObj};
                            callToWebService(url, data, callback);
                        }); 
                    }else{
                        showErrorMessage("Session expired 1!");
                    }
                }
                if(responseDecoded.msg)
                    showErrorMessage(responseDecoded.msg);
            }else{  
                    callback(responseDecoded);
                    regenerateWebserviceCallFlag = false;
            }
        }, function(response) {
            myApp.hidePleaseWait();   
            regenerateWebserviceCallFlag = false;     
        });

        //var encrypted_session_id = generateSessionId();
        /*myApp.showPleaseWait();
        jQuery.ajax({
          url : url, 
          type: 'GET',
          dataType : "json",
          data: data,*/
          /*beforeSend: function(xhr){xhr.setRequestHeader('session_id', encrypted_session_id);
                                   xhr.setRequestHeader('param', enableEncryption ? (localStorage.getItem("otp")) :decryptLocalStorageData(localStorage.getItem("otp")));
                                    xhr.setRequestHeader('jocode', (window.localStorage.getItem("jocode")));
                                   },*/
         //success: function(result){
            //callback(result);
           /* myApp.hidePleaseWait();
             if(result.status == 'N'){
                 showErrorMessage(result.msg);
             }else{
                callback(decodeResponse(result));
             }*/
           // }, 
          /*error: function(xhr) { 
            myApp.hidePleaseWait();
            showErrorMessage("Error"); 
            } */
        //});
        
    }

    /*function callToWebService(url, data, callback){
        myApp.showPleaseWait();
        cordova.plugin.http.get(url, data, {},function(response) {
            myApp.hidePleaseWait(); 
            var responseobj=JSON.parse(response.data);            
            if(responseobj.status && responseobj.status=='N'){
                if(responseobj.msg!='')
                 showErrorMessage(responseobj.msg);
            }else{                
                callback(JSON.parse(response.data));
            }
        }, function(response) {
            myApp.hidePleaseWait();        
        });
    }*/

    function shareClicked(){
        

        window.plugins.socialsharing.available(function(isAvailable) {
            
            if (isAvailable) {
                var playstoreurl = "https://play.google.com/store/apps/details?id=in.gov.ecourts.eCourtsServices";
                var appstoreurl = "https://appsto.re/in/yv-jlb.i";
    
                var txt = "I recommend eCourts Services app to track your cases in District Courts and High Courts of the country. Please download and share it using this link \nAndroid : \n"+playstoreurl+
                " \niOS : \n"+appstoreurl;            
              // use a local image from inside the www folder:
        //      window.plugins.socialsharing.share('Some text', 'Some subject', null, 'http://www.nu.nl');
             window.plugins.socialsharing.share(txt);
        
        //      window.plugins.socialsharing.share('test', null, 'data:image/png;base64,R0lGODlhDAAMALMBAP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUKAAEALAAAAAAMAAwAQAQZMMhJK7iY4p3nlZ8XgmNlnibXdVqolmhcRQA7', null, function(e){alert("success: " + e)}, function(e){alert("error: " + e)});
            //   window.plugins.socialsharing.share('My text', 'My subject', 'https://www.google.nl/images/srpr/logo11w.png', null, function(){alert("ok")}, function(e){alert("error: " + e)});
              // alternative usage:
        
              // 1) a local image from anywhere else (if permitted):
              // window.plugins.socialsharing.share('Some text', 'http://domain.com', '/Users/username/Library/Application Support/iPhone/6.1/Applications/25A1E7CF-079F-438D-823B-55C6F8CD2DC0/Documents/.nl.x-services.appname/pics/img.jpg');
        
              // 2) an image from the internet:
        //      window.plugins.socialsharing.share('Some text', "Some subject', 'http://domain.com', 'http://domain.com/image.jpg');
        
              // 3) text and link:
            //  window.plugins.socialsharing.share('I recommend eCourts Services app to track your cases in District Courts and High Courts of the country. Please download and share it using this link Android : ', '', '', playstoreurl);
            }
          });
        
    }