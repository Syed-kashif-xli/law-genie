    document.addEventListener("deviceready", onDeviceReady, false);
    var backButtonHistory = [];
    var localizedStateCodesArr = [];
    var state_language = [];
    var versionstr = "";
    // var newVersionStr = "";
    var appReleaseStr='';
    
    function onDeviceReady() {        
        /* document.addEventListener("resume", onResume, false);
        function onResume() {
            rootDetectionFunction();
        }
        rootDetectionFunction();*/
        if(device.platform=='Android'){
            //do not remove following code...  
            if(device.isVirtual){
                // alert('its virtual device');
                navigator.app.exitApp();
            }
    
            document.addEventListener("resume", onResume, false);
            function onResume() {
                rootDetectionFunction(); //do not remove this code...           
            }
            rootDetectionFunction(); //do not remove this code...  
        }

        if(localStorage.CONFIGURE == null){
            $("#both").prop("checked", true);
            localStorage.setItem("CONFIGURE", "DC");
            $(".DC_label").removeClass("active_court_label");
            $(".HC_label").removeClass("active_court_label");
            $(".both_label").addClass("active_court_label"); 
        }
        $("#header").load("header_simple.html", function (response, status, xhr) {
            // sessionStorage.setItem("SESSION_LANGUAGE_FLAG_CHANGED", true);
            if(localStorage.CONFIGURE === "DC"){
                $("#DC").prop("checked", true);
                localStorage.setItem("SELECTED_COURT","DC");
                document.getElementById("lang_icon").style.display = "block"; 
                document.getElementById("hc_btn_id").style.display = "none";
                $(".dc-btn").removeClass("dh-btn-active");
                //$(".dc-btn").addClass("main_title_font");
                $("#dc_btn_id").addClass("singlebtn");
            }else if(localStorage.CONFIGURE === "both"){
                $("#both").prop("checked", true);
                document.getElementById("lang_icon").style.display = "block"; 
                document.getElementById("hc_btn_id").style.display = "float:right;block";            
            } 
        // var version='3.0';
        //check app version if not set in session storage already
        //if (!(sessionStorage.NEW_VERSION) && (sessionStorage.NEW_VERSION == null)) {
            cordova.getAppVersion(function (version) {
                window.sessionStorage.setItem("CURRENT_APP_VERSION", version);
                
                versionstr = version;
                document.getElementById("versions").innerHTML="App Version: " + versionstr;
                var appReleaseUrl = hostIP + "appReleaseWebService.php";
                //TODO: change hardcoded uid if uuid is null
                var data=null;
                cordova.getAppVersion.getPackageName(function(pkgname){ 
                    data = {"version":window.sessionStorage.getItem("CURRENT_APP_VERSION"), "uid":device.uuid ? device.uuid.toString() + ":" + pkgname : "324456" + ":" + pkgname};
                }); 
                // var data = {"version":window.sessionStorage.getItem("CURRENT_APP_VERSION"), "uid":device.uuid ? device.uuid.toString() + ":" + "in.gov.ecourts.eCourtsServices" : "324456" + ":" + "in.gov.ecourts.eCourtsServices"};
       
                setTimeout(function () {  
                    if(isOnline){
                        //web service call to get latest app version from database
                        callToWebService(appReleaseUrl, data, appReleaseWebServiceResult);
                        function appReleaseWebServiceResult(data){                
                            myApp.hidePleaseWait();
                            var decodedres = (data);
                            var decoded = jwt_decode(decodedres.token);
                            jwttoken = decodedres.token;
                            
                            versionChecked = true;
                            versions = version.toString();
                            /*If app version from database and current app version mismatch, then show message that new version is available.
                            If both versions match, then remove the new version available string.
                            */
                            if(data && data.version_compatible){                                
                                    window.sessionStorage.setItem("version_compatible_msg",data.version_compatible);
                                    document.getElementById("updateApp").style.display = "block";
                                    document.getElementById("updateApp").innerHTML = data.version_compatible;
                                }else{                                    
                                    window.sessionStorage.setItem("version_compatible_msg","");
                                    document.getElementById("updateApp").style.display = "none";
                                }                                
                                if (data && (data["appReleaseObj"].version_no!=null) && versions != data["appReleaseObj"].version_no) {                                    
                                    appReleaseStr = data["appReleaseObj"].version_no;                                    
                                    // newVersionStr = "New version " + appReleaseStr + " Available";
                                    $("#newVersionAvailabel").html("New version " + appReleaseStr + " Available");                                   
                                   // document.getElementById("versions").innerHTML="App Version: " + versionstr;
                                    $("#versions").html("App Version: " + versionstr); 
                                    $("#newVersionAvailableId").html("New version " + appReleaseStr + " Available");
                                    var releaseUrl = "";
                                    var string = device.platform;
                                    if(string === "Android"){
                                        releaseUrl = data["appReleaseObj"].release_url;                                
                                    }else if(string === "ios"){
                                        releaseUrl = "#";
                                    }
                                    $("#newVersionAvailableId").attr('href',releaseUrl);
                                    sessionStorage.setItem("NEW_VERSION", "New version " + appReleaseStr + " Available");
                                    sessionStorage.setItem("appReleaseStr",""+appReleaseStr);
                                    sessionStorage.setItem("NEW_VERSION_URL", releaseUrl);
                                }else{                                    
                                    $("#newVersionAvailabel").hide();
                                    $("#newVersionAvailableId").hide();
                                    sessionStorage.setItem("NEW_VERSION", "");
                                }
                                getStatesFromWebService();
                                importLanguageFile();
                             }
                }else{
                    displayConnErrorMsg();
                }
                },3000);
            });
       /* } else { 
            cordova.getAppVersion(function (version) {                
                versionstr=version;
                $("#versions").html("App Version: " + version);
            });                       
            $("#newVersionAvailabel").html(sessionStorage.getItem("NEW_VERSION"));
            $("#newVersionAvailableId").html(sessionStorage.getItem("NEW_VERSION"));
            $("#newVersionAvailableId").attr('href',sessionStorage.getItem("NEW_VERSION_URL"));
            if(window.sessionStorage.version_compatible_msg != ""){
                document.getElementById("updateApp").style.display = "block";
                document.getElementById("updateApp").innerHTML = window.sessionStorage.version_compatible_msg;
            }
        }*/
    //}
    //$(document).ready(function () {
        if(sessionStorage.getItem("DATEWISE") == null){
            sessionStorage.setItem("DATEWISE", true);
        }

        if(localStorage.CONFIGURE == null){
            $("#both").prop("checked", true);
            localStorage.setItem("CONFIGURE", "DC");
            $(".DC_label").removeClass("active_court_label");
            $(".HC_label").removeClass("active_court_label");
            $(".both_label").addClass("active_court_label"); 
        }      
        
        });

            //to check case are saved in app localsorage(i.e.browser storage) and save it to mytext.txt on apps internal storage.
            var CNR_array = localStorage.getItem("CNR Numbers");        
            if(CNR_array && (JSON.parse(CNR_array).length != 0)){                
                backupContent("device",true,true);
            }else{
                importFileFrom("device",true,true);
            }

        if(localStorage.getItem("SELECTED_COURT") == null){
            localStorage.setItem("SELECTED_COURT","DC");
        }else if(localStorage.getItem("SELECTED_COURT") == "HC"){
            window.location = "index_hc.html";
        }
        
        $("#footer").load("footer.html");
        $("#Case_Status_pannel").load("case_status1.html");
        $("#Calendar_panel").load("calender.html");
        $("#My_Cases_pannel").load("my_cases.html");
        $('#state_dist_componant').hide();
        
        var tab = sessionStorage.getItem("tab");
       
        //remove all session data for forms
        window.sessionStorage.removeItem('SESSION_SELECT_2');
        window.sessionStorage.removeItem('SESSION_INPUT_1');
        window.sessionStorage.removeItem('SESSION_INPUT_2');
        window.sessionStorage.removeItem('SESSION_PENDING_DISPOSED');
        window.sessionStorage.removeItem("SET_RESULT");
        window.sessionStorage.removeItem("CAVEAT_SEARCH_RADIO");
        window.sessionStorage.removeItem('tab');
        localStorage.removeItem('panels');

        //code to hide/ show state and district select box
        if (sessionStorage.getItem("tab")) {
           
            $('.nav-tabs a[href="' + tab + '"]').tab('show');
            sessionStorage.removeItem("tab");

            $tab = $('#tablist .active');
            var tab_id = parseInt($tab.index());
            if (tab_id == 0 || tab_id == 3 || tab_id == 4)
                $('#state_dist_componant').hide();
            else if (tab_id == 1 || tab_id == 2)
                $('#state_dist_componant').show();

        }else{
            
            $('.nav-tabs a[href="home"]').tab('show');
        }

        //code to handle swipe left or right -- start
        var direction = '';

        $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {

            if (direction == 'right') {
                var target = $(this).attr('href');
                $(target).css('left', '-' + $(window).width() + 'px');
                var left = $(target).offset().left;
                $(target).css({left: left}).animate({"left": "0px"}, "10");
                $(target).attr("style", "");
            } else {
                var target = $(this).attr('href');
                $(target).css('right', '-' + $(window).width() + 'px');
                var right = $(target).offset().right;
                $(target).css({right: right}).animate({"right": "0px"}, "10");
                $(target).attr("style", "");
            }
        });


    function getStatesFromWebService(){
        //unused parameter (for future use)
        var time_in_seconds = new Date().getTime() / 1000; //returns time in seconds
        
        var statesUrl = hostIP + "stateWebService.php"; 

        var encrypted_data1 = ("fillState");
        var encrypted_data2 = (time_in_seconds.toString());

        var stateData = {action_code: encrypted_data1.toString(), time: encrypted_data2.toString()};

        //To fetch states from webservice and save to local storage(If already saved, then display from local storage) -- start
      
        // setTimeout(function () {  
            if(isOnline){
                //web service call to fetch states
                callToWebService(statesUrl, stateData, appReleaseWebServiceResult);
                function appReleaseWebServiceResult(data){
                    myApp.hidePleaseWait();                    
                    
                    window.sessionStorage.setItem("SESSION_STATES", JSON.stringify(data.states));                    
                    var obj = (data.states);
                    populateStates(obj);
                }                
            }else{
                var items = [];
                items.push("<option value=''>"+stateSelectLabel+"</option>");
                $("#state_code").html(items.join(""));
                var items1 = [];
                items1.push("<option value=''>"+districtSelectLabel+"</option>");
                $("#dist_code").html(items1.join(""));                
                displayConnErrorMsg();
            }
        }
        // },3000);
        //called when state is selected in select box
        $("#state_code").change(function () {
            /*clear data related to previous state code from session storage
            district, court complexes and court names(for cause list)
            */
            var state_code_data = $("#state_code").val();
            var state_name = $("#state_code option:selected").text();
            window.localStorage.removeItem("district_code");
            window.localStorage.removeItem("district_name");        
                        
            bilingual_flag = 0;
            
            if(state_language[state_code_data] == localStorage.LANGUAGE_FLAG){
                bilingual_flag = 1;
            }
            //populate districts for selected state code
            if (state_code_data == '') {
                window.localStorage.removeItem("state_code");
                window.localStorage.removeItem("state_name");
                populateDistricts(null);
            } else {
                window.localStorage.setItem("state_code", state_code_data);
                window.localStorage.setItem("state_name", state_name);
                get_district();
            }

            //Remove all cause list form data saved in session storage
            window.localStorage.removeItem("SESSION_COURT_CODE_CAUSE_LIST");
            window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
            window.sessionStorage.removeItem("SESSION_INPUT_1_CAUSE_LIST");
            window.sessionStorage.removeItem("SESSION_INPUT_2_CAUSE_LIST");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
            window.localStorage.removeItem("SESSION_COURT_CODE");
            complexes = "";
            
            $("#Causelist_pannel").html('');
        });

        //called when district is changed from district select box
        $("#dist_code").change(function () {
            var district_code_data = $("#dist_code").val();
            var district_name = $("#dist_code option:selected").text();
            //code to load court complexes for selected district -- start
            if (district_code_data == '') {
                window.localStorage.removeItem("district_code");
                window.localStorage.removeItem("district_name");
                $("#Causelist_pannel").html('');
            } else {
                window.localStorage.setItem("district_code", district_code_data);
                window.localStorage.setItem("district_name", district_name);
                var tab = $('#tablist .active a').attr("href");
                sessionStorage.setItem("tab", tab);
                complexes = "";
                

                populateCourtComplexes();
                $("#Causelist_pannel").load("cause_list.html");
                $("#Causelist_pannel").trigger("languageChanged");
            }//--end

            //clear cause list form data saved in session storage
            window.localStorage.removeItem("SESSION_COURT_CODE_CAUSE_LIST");
            window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
            window.sessionStorage.removeItem("SESSION_INPUT_1_CAUSE_LIST");
            window.sessionStorage.removeItem("SESSION_INPUT_2_CAUSE_LIST");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
            window.localStorage.removeItem("SESSION_COURT_CODE");
            

            complexes = "";
        });

       

        //called when clicked on cause list tab
        $('.cause_list').on('click', function (event) {
            event.preventDefault(); // To prevent following the link (optional)
            var state_code_data = $("#state_code").val();
            var district_code_data = $("#dist_code").val();
            if (state_code_data === '' || state_code_data === null) {
                showErrorMessage(labelsarr[52]);
               // showErrorMessage("Please select state.");
                return false;
            }
            if (district_code_data === '' || district_code_data === null) {
                showErrorMessage(labelsarr[49]);
                //showErrorMessage("Please select district.");
                return false;
            }
            window.localStorage.setItem("state_code", state_code_data);
            window.localStorage.setItem("district_code", district_code_data);
            window.location = 'cause_list.html';
        });

        //code to set total saved cases count on my cases tab -- start
        if(localStorage.SELECTED_COURT === 'HC'){
            var caseInfoArray = window.localStorage.getItem("CNR Numbers HC");
        }else{
            var caseInfoArray = window.localStorage.getItem("CNR Numbers");
        }
        var totalCasesSaved = 0;
        if (caseInfoArray != null) {
            caseInfoArray = JSON.parse(caseInfoArray);
            totalCasesSaved = caseInfoArray.length;
        }
        document.getElementById("mycases_span_id").innerHTML = totalCasesSaved;
        //--end

        //called when clicked on CNR tab
        $('#cnr').on('click', function (event) {
             sessionStorage.setItem("tab", "#home");
            cnr_numbers_onclick();
            $('#state_dist_componant').hide();
        });
        //called when clicked on Case status tab
        $('#Case_status').on('click', function (event) {
             sessionStorage.setItem("tab", "#profile");
            case_status_onclick();
            $('#state_dist_componant').show();
        });
        //called when clicked on Cause list tab
        $('#causelist').on('click', function (event) {
             sessionStorage.setItem("tab", "#Tab3");            
             cause_list_onclick();
            $('#state_dist_componant').show();
        });

        //called when clicked on My cases tab
        $('#my_cases').on('click', function (event) {
            sessionStorage.setItem("tab", "#Tab4");
            my_cases_onclick();
            $('#state_dist_componant').hide();
        }); 
        
        $('#calendar').on('click', function (event) {
            sessionStorage.setItem("tab", "#Tab5");
            $('#state_dist_componant').hide();
            myCasesSelected();
        }); 
    //});
	}



function cnr_numbers_onclick()
{
    $('.nav.nav-tabs li:nth-child(1) a').tab('show');
    //$(".sidenav a").css({"background-color": "transparent", "color": "#555"});    
    $(".nav-tabs li").removeClass("active");
    $(".nav-tabs li:nth-child(1)").addClass("active");
    // $(".sidenav a:nth-child(5)").css({"background-color": "white", "color": "#F05539"});
    $("#mySidenav a").removeClass("active");
    $(".sidenav a:nth-child(5)").addClass("active");
    sessionStorage.setItem("tab", "#home");        
    $("#totalEstablishments").remove();
    $(".modal").modal("hide");
    $('#state_dist_componant').hide();
    // closeNav_map();
}

function case_status_onclick()
{
    $('.nav.nav-tabs li:nth-child(2) a').tab('show');
    // $(".sidenav a").css({"background-color": "transparent", "color": "#555"}); 
    $(".nav-tabs li").removeClass("active");
    $(".nav-tabs li:nth-child(2)").addClass("active");
    // $(".sidenav a:nth-child(6)").css({"background-color": "white", "color": "#F05539"});
    $("#mySidenav a").removeClass("active");
    $(".sidenav a:nth-child(6)").addClass("active");
    sessionStorage.setItem("tab", "#profile");
    $("#totalEstablishments").remove();
    $(".modal").modal("hide"); 
    $('#state_dist_componant').show();
    //closeNav_map();
}

function cause_list_onclick()
{
    $('.nav.nav-tabs li:nth-child(3) a').tab('show');
    // $(".sidenav a").css({"background-color": "transparent", "color": "#555"});    
    $(".nav-tabs li").removeClass("active");
    $(".nav-tabs li:nth-child(3)").addClass("active");
    // $(".sidenav a:nth-child(7)").css({"background-color": "white", "color": "#F05539"});
    $("#mySidenav a").removeClass("active");
    $(".sidenav a:nth-child(7)").addClass("active");
    sessionStorage.setItem("tab", "#Tab3");
    $("#totalEstablishments").remove();
    $(".modal").modal("hide");
    $('#state_dist_componant').show();
    //closeNav_map();
}

function my_cases_onclick()
{
    $('.nav.nav-tabs li:nth-child(4) a').tab('show');
    // $(".sidenav a").css({"background-color": "transparent", "color": "#555"});    
    $(".nav-tabs li").removeClass("active");
    $(".nav-tabs li:nth-child(4)").addClass("active");
    // $(".sidenav a:nth-child(8)").css({"background-color": "white", "color": "#F05539"});
    $("#mySidenav a").removeClass("active");
    $(".sidenav a:nth-child(8)").addClass("active");
    sessionStorage.setItem("tab", "#Tab4");
    $("#totalEstablishments").remove();
    $(".modal").modal("hide");
    $('#state_dist_componant').hide();
    //closeNav_map();
}

    //called when clicked on search button for CNR
    $("#searchBtnId").on("click", function (e) {
        e.preventDefault();
        window.sessionStorage.setItem("SESSION_BACKLINK", "index.html");
        sessionStorage.setItem("tab", "#home");
        var ciNumber = $("#searchCNRId").val();

        //validation for ciNumber -- start
        if (ciNumber == "") {
            showErrorMessage(labelsarr[261]);
            return false;
        }
        if (ciNumber.length < 16)
        {
            showErrorMessage(labelsarr[755]);
            $("#searchCNRId").val("");
            return false;
        }
        var pat = /^[a-zA-Z][a-zA-Z0-9]*$/;
            if (pat.test(ciNumber) == false) {
                showErrorMessage(labelsarr[835]);
                $("#search_act").val("");
                 $("#search_act").focus(); 
                return false;
            }
                        
           if((localStorage.LANGUAGE_FLAG!=null || localStorage.LANGUAGE_FLAG!='') && (window.localStorage.getItem("state_code")==null || window.localStorage.getItem("state_code")=='')){
            bilingual_flag=1;
           }
            
        //var data = {cino:(ciNumber)};
        var encrypted_data4 = (localStorage.LANGUAGE_FLAG);
        var encrypted_data5 = (bilingual_flag.toString());
        var data = {cino:(ciNumber),version_number:(window.sessionStorage.getItem("CURRENT_APP_VERSION")), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};

        var listOfCasesWsUrl = hostIP + "listOfCasesWebService.php";
        var case_number = '';
        
        // this web service call is to check if this ci number belongs to filing case or not or if it exists in database or not
        callToWebService(listOfCasesWsUrl, data, listOfCasesWebServiceResult);
        function listOfCasesWebServiceResult(data){
            if (data != null) {
                case_number = (data.case_number);
                //If case_number is null, then this is a filing case
                if (case_number == null) {
                    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);                    
                    var encrypted_data5 = (bilingual_flag.toString());
                    var data1 = {cino:(ciNumber.toString()), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
                    var filingCaseHistoryWsUrl = hostIP + "filingCaseHistory.php";
                    //web service call to fetch data of filing case history
                    callToWebService(filingCaseHistoryWsUrl, data1, filingCaseHistoryWSResult);
                    function filingCaseHistoryWSResult(data){
                        var decodedResponse = (data.history);
                        if (decodedResponse != null) {
                            window.sessionStorage.setItem("filing_case_history", JSON.stringify(decodedResponse));
                            window.sessionStorage.setItem("CINO", (ciNumber));
                            $.ajax({
                                type: "GET",
                                url: "filing_case_history.html"
                            }).done(function(data) { 
                                $("#caseHistoryModal").show();
                                $("#historyData").html(data);
                                $("#caseHistoryModal").modal();
                            });
                        } else {
                            showErrorMessage(labelsarr[834]);
                            myApp.hidePleaseWait();
                        }
                        myApp.hidePleaseWait();
                    }
                   
                } else {
                    //Not a filing case
                    var encrypted_data4 = (localStorage.LANGUAGE_FLAG);                    
                    var encrypted_data5 = (bilingual_flag.toString()); 
                    var data1 = {cinum:(ciNumber), language_flag:encrypted_data4.toString(), bilingual_flag:encrypted_data5.toString()};
                    var caseHistoryWsUrl = hostIP + "caseHistoryWebService.php";
                    //web service call to fetch case history
                    callToWebService(caseHistoryWsUrl, data1, caseHistoryWSResult);
                    function caseHistoryWSResult(data){
                        var decryptedResponse = (data.history);
                        if (decryptedResponse != null) {
                            window.sessionStorage.setItem("case_history", JSON.stringify(decryptedResponse));
                            window.sessionStorage.setItem("CINO", (ciNumber));
                            $.ajax({
                                type: "GET",
                                url: "case_history.html"
                            }).done(function(data) { 
                                $("#caseHistoryModal").show();
                                $("#historyData").html(data);
                                $("#caseHistoryModal").modal();
                            });
                        } else {
                            showErrorMessage(labelsarr[834]);
                            myApp.hidePleaseWait();
                        }
                        myApp.hidePleaseWait();
                    }
                   
                }
            } else {
                myApp.hidePleaseWait();
                showErrorMessage(labelsarr[410]);
                return false;
            }
        }        
    });

    //fetch districts if not saved in local storage, get from web service
    function get_district() {
        var districtsUrl = hostIP + "districtWebService.php";
        var state_code_value = $("#state_code").val();
        var toEncrypt = 'pending';
        // If districts are not saved in local storage, then get from web service.
        if(window.sessionStorage.SESSION_DISTRICTS == null){
            var data = {state_code:(state_code_value),test_param:(toEncrypt.toString())}; 
          
            //web service call to get districts
            callToWebService(districtsUrl, data, districtsWebServiceResult);
            function districtsWebServiceResult(data){
                myApp.hidePleaseWait(); 
                var obj = (data.districts);
                populateDistricts(obj);   
            }                              
        }
    }

    //populates state select box  
    function populateStates(obj){
        $('#state_code').empty();
        var items = [];
        items.push("<option value=''>"+stateSelectLabel+"</option>");
        if(obj){
            var lang = null;
            var obj1 = null;
            var showEnglishLabels = true;
            lang = localStorage.LANGUAGE_FLAG;
            state_language = [];
            localizedStateCodesArr = [];
            $.each(obj, function (key, val) {
                var statecd = val.state_code;
                var lang = val.state_lang;
                state_language[statecd] = lang;
                if(val.state_lang == localStorage.LANGUAGE_FLAG){
                    localizedStateCodesArr.push(val.state_code);
                }
            });
            if(localStorage.LANGUAGE_FLAG != "english"){
                var state_name_bilingual;
                
                $.each(obj, function (key, val) {                   
                    var lang_flag = localStorage.LANGUAGE_FLAG;                                        
                    var temp = Object.fromEntries(Object.entries(val).filter(([key]) => key.includes('state_name_'+lang_flag)));
                  
                    if(Object.entries(temp).length>0){                        
                        const [state_name_key, state_name_val] = Object.entries(temp)[0];
                        state_name_bilingual = state_name_val;
                    }else{                        
                        state_name_bilingual=val.state_name;
                    }                                  
                
                items.push('<option id="' + val.state_code + '" value="' + val.state_code + '">' + state_name_bilingual + '</option>');
            });
            }else{
            $.each(obj, function (key, val) {
                items.push('<option id="' + val.state_code + '" value="' + val.state_code + '">' + val.state_name + '</option>');
            });
            }
        }
        $("#state_code").html(items.join(""));
        if (window.localStorage.state_code != null) {
            $('#state_code').val(window.localStorage.state_code);
            if(state_language[window.localStorage.state_code] == localStorage.LANGUAGE_FLAG){
                bilingual_flag = 1;
            }
            get_district();
        } else {
            $('#state_code').val('');
            populateDistricts(null);
        }
    }

    //populate districts select box
    function populateDistricts(obj){
        myApp.hidePleaseWait();
        $('#dist_code').empty();
        var items = [];
        items.push("<option value=''>"+districtSelectLabel+"</option>");
        if(obj){
            var showEnglishLabels = true;
            // if(localStorage.LANGUAGE_FLAG){
                // if(localStorage.LANGUAGE_FLAG != "english"){
                if(bilingual_flag == 1){
                    $.each(obj, function (key, val) {
                        if(val.mardist_name){
                            if(val.mardist_name!=""){                            
                                items.push('<option id="' + val.dist_code + '" value="' + val.dist_code + '">' + val.mardist_name + '</option>');
                            }
                        }
                    });
                    showEnglishLabels = false;
                }
                // }
            // }

            if(showEnglishLabels){
                $.each(obj, function (key, val) {
                        items.push('<option id="' + val.dist_code + '" value="' + val.dist_code + '">' + val.dist_name + '</option>');
                    });
            }
        
        }
        
        $("#dist_code").html(items.join(""));
        if (window.localStorage.district_code != null) {
            $('#dist_code').val(window.localStorage.district_code);
            if (window.localStorage.getItem("district_code") != null) {
                
                populateCourtComplexes();
                $("#Causelist_pannel").load("cause_list.html");
                $("#Causelist_pannel").trigger("languageChanged");
            }
        }else{
            $('#dist_code').val('');
        }
    }

    //to close menu if clicke anywhere else  other than menu
     function closeNav() {
            document.getElementById("mySidenav").style.display = "none";
        }
    $("#tabpanel").click(function (e)
        {
            if ($("#mySidenav").is(':visible'))
            {
                closeNav();
            } 
        });

function onScanButtonClick(){
        
        // Start a scan. Scanning will continue until something is detected or 
        // `QRScanner.cancelScan()` is called. 
        cordova.plugins.barcodeScanner.scan(
        function (result) {
            if(!result.cancelled)
            {
                if(result.format == "QR_CODE")
                {
                    $("#searchCNRId").val(result.text);
                    $("#searchBtnId").trigger("click");
                }else{
                    alert(labelsarr[833]);
                    backButtonHistory.pop(); 
                    backButtonHistory.push("qrscanner");  
                }
            }else{
                backButtonHistory.pop(); 
                backButtonHistory.push("qrscanner");  
            }
        },
        function (error) {
            //alert("Scanning failed: " + error);
        }
    );
}

function myCasesSelected()
{
    if(localStorage.getItem("CNR Numbers")!=null)
    {
        var cnrFromLocalStorageLenght= JSON.parse(localStorage.getItem("CNR Numbers")).length;
        if(cnrFromLocalStorageLenght>0)
        {
            //Reset date picker to todays date
            resetDatePicker();
            clearSearchText();
            $("#searchCasesButton").click(); 
            //code to retain selected tab from My cases(My cases or Todays cases)
            if ($("#allCasesBtn").hasClass("active")) {
                $("#allCasesBtn").addClass("active");
                $("#todaysCasesBtn").removeClass("active");
            }else{
                $("#allCasesBtn").removeClass("active");
                $("#todaysCasesBtn").addClass("active");
            }
        }
    }
}

function rootDetectionFunction(){
    var successCallback = function (result) {                        
        if(result == '1'){          
            //alert('Rooted device;'+result);
            navigator.app.exitApp(); 
        }/*else{
            alert('Non Rooted device;'+result);            
            return;
        }*/
    };
    var errorCallback = function (error) {
        // alert('error=> '+error+' in rooted device.');
    }        
    rootdetection.isDeviceRooted(successCallback, errorCallback);
}

var stateSelectLabel = "Select State";
var districtSelectLabel = "Select District";

function resetStateDistrict(){
   $("#state_code").val('');  
    // localStorage.removeItem('state_code');
    // localStorage.removeItem('district_code');
    populateDistricts(null);
}
document.addEventListener("backbutton", onBackKeyDown, false);

function onBackKeyDown(e) 
    {
        e.preventDefault(); 
        if(backButtonHistory.length <=0)
        {
            navigator.app.exitApp();
        }
        switch(backButtonHistory[backButtonHistory.length-1]){
            case "searchcasepage": 
                if ($("#ui-datepicker-div")) {
                    $("#ui-datepicker-div").hide()
                }; 
                go_back_link_searchPage_fun();
                break;
                
            case "casehistory":                
                go_back_link_history_fun();
                break;
                
            case "viewbusiness":
                go_back_link_viewBusiness_fun();
                break;
                
            case "writinfo": 
                go_back_link_writInfo_fun();
                break;
                
            case "map":
                go_back_link_map_fun();
                break;

            case "caveatHistory":
                go_back_link_caveat_fun();
                break;
            case "qrscanner":                
                backButtonHistory.pop();                 
                break;
    
        }
    }
window.addEventListener('online', checkDeviceOnlineStatus);
window.addEventListener('offline', checkDeviceOnlineStatus);