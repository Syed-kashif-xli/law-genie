document.addEventListener("deviceready", onDeviceReady, false);
var backButtonHistory=[];
var versionstr = "";
function onDeviceReady() {
    // document.addEventListener("resume", onResume, false);
    // function onResume() {
    //     rootDetectionFunction();
    // }
    // rootDetectionFunction();

    localStorage.setItem("SELECTED_COURT","HC");
    $("#header").load("header_simple.html", function (response, status, xhr) {            
        if(localStorage.CONFIGURE === "HC"){
            $("#HC").prop("checked", true);
            document.getElementById("dc_btn_id").style.display = "none"; 
            document.getElementById("lang_icon").style.display = "none";                 
            $(".hc-btn").removeClass("dh-btn-active");
            $(".hc-btn").addClass("main_title_font");
            $("#hc_btn_id").addClass("singlebtn");
        }else if(localStorage.CONFIGURE === "both"){
            $("#both").prop("checked", true);
            document.getElementById("lang_icon").style.display = "none";
            document.getElementById("dc_btn_id").style.display = "float:left;block";            
        }
    // var version='3.0';
    //check app version if not set in session storage already
    // if (!(sessionStorage.NEW_VERSION) && (sessionStorage.NEW_VERSION == null)) {
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
            setTimeout(function () {  
            //web service call to get latest app version from database
                callToWebService(appReleaseUrl, data, getAppVersionResult);
                function getAppVersionResult(data){                    
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
                        //var newVersionStr = "New version " + data["appReleaseObj"].version_no + " Available";
                        $("#newVersionAvailabel").html("New version " + appReleaseStr + " Available");                            
                        //document.getElementById("versions").innerHTML="App Version: " + versionstr;
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
                    } else {
                        $("#newVersionAvailabel").hide();
                        $("#newVersionAvailableId").hide();
                        sessionStorage.setItem("NEW_VERSION", "");
                    }
                    getStatesFromWebService_HC();
                }
            },3000);
        });
    // } else {
        
    //     cordova.getAppVersion(function (version) {                
            
    //         $("#versions").html("App Version: " + version);
    //     });
    //     $("#newVersionAvailabel").html(sessionStorage.getItem("NEW_VERSION"));
    //     $("#newVersionAvailableId").html(sessionStorage.getItem("NEW_VERSION"));
    //     $("#newVersionAvailableId").attr('href',sessionStorage.getItem("NEW_VERSION_URL"));
    //     if(window.sessionStorage.version_compatible_msg != ""){
    //         document.getElementById("updateApp").style.display = "block";
    //         document.getElementById("updateApp").innerHTML = window.sessionStorage.version_compatible_msg;
    //     }
    // }
});
    //}
    //to check case are saved in app localsorage(i.e.browser storage) and save it to mytext.txt on apps internal storage.
    var CNR_array = localStorage.getItem("CNR Numbers HC");        
    if(CNR_array && (JSON.parse(CNR_array).length != 0)){
        backupContent("device",true,true);
    }else{
        importFileFrom("device",true,true);
    }  

// $(document).ready(function () {
    if(sessionStorage.getItem("DATEWISE") == null){
        sessionStorage.setItem("DATEWISE", true);
    }        
        
    $("#footer").load("footer.html");
    $("#Case_Status_pannel").load("case_status_hc.html");
    $("#Calendar_panel").load("calender.html");
    $("#My_Cases_pannel").load("my_cases_hc.html");
    $('#state_dist_componant').hide();
    var tab = sessionStorage.getItem("tab");
    //remove all session data for forms
    window.sessionStorage.removeItem('SESSION_SELECT_2');
    window.sessionStorage.removeItem('SESSION_INPUT_1');
    window.sessionStorage.removeItem('SESSION_INPUT_2');
    window.sessionStorage.removeItem('SESSION_PENDING_DISPOSED');
    window.sessionStorage.removeItem("SET_RESULT");
    window.sessionStorage.removeItem('SESSION_SELECT_STATE');
    window.sessionStorage.removeItem('SESSION_SELECT_DISTRICT');
    window.sessionStorage.removeItem('SESSION_SELECT_2');
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

    /*$(function () {
        $(".tab-content").swiperight(function () {
            direction = 'right';
            var $tab = $('#tablist .active').prev();
            var tab_id = parseInt($tab.index());
            if ($tab.length > 0) {
                $tab.find('a').tab('show');
            }
            if (tab_id == 0 || tab_id == 3) {
                $('#state_dist_componant').hide();
            } else if (tab_id == 1 || tab_id == 2) {
                $('#state_dist_componant').show();
            }                
        });

        $(".tab-content").swipeleft(function () {
            direction = 'left';
            var $tab = $('#tablist .active').next();
            var tab_id = parseInt($tab.index());
            if ($tab.length > 0) {
                $tab.find('a').tab('show');
            }
            if (tab_id == 0 || tab_id == 3) {
                $('#state_dist_componant').hide();
            } else if (tab_id == 1 || tab_id == 2) {
                $('#state_dist_componant').show();
            }
        });
    });*/

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

    function getStatesFromWebService_HC(){
        //unused parameter (for future use)
        var time_in_seconds = new Date().getTime() / 1000; //returns time in seconds
        var statesUrl = hostIP + "stateWebService.php";
        var encrypted_data1 = ("fillState");
        var encrypted_data2 = (time_in_seconds.toString());
        var stateData = {action_code: encrypted_data1.toString(), time: encrypted_data2.toString()};

        //To fetch states from webservice and save to local storage(If already saved, then display from local storage) -- start
            //web service call to fetch states
        callToWebService(statesUrl, stateData, getStatesResult);
        function getStatesResult(data){
            window.sessionStorage.setItem("SESSION_STATES", data.states);
            var obj = (data.states);
            myApp.hidePleaseWait();
            populateStates(obj);
        }
    }
    //called when state is selected in select box
    $("#state_code").change(function () {
        /*clear data related to previous state code from session storage
        district, court complexes and court names(for cause list)
        */
        window.sessionStorage.removeItem("SESSION_DISTRICTS");
        window.sessionStorage.removeItem("SESSION_COMPLEXES");
        window.sessionStorage.removeItem("SESSION_BENCHES");  
        window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
        var state_code_data = $("#state_code").val();
        var state_name = $("#state_code option:selected").text();
        window.localStorage.removeItem("district_code");
        window.localStorage.removeItem("district_name");  
        //populate districts for selected state code
        if (state_code_data == '') {
            window.localStorage.removeItem("state_code");
            window.localStorage.removeItem("state_name");
            populateDistricts(null);
        } else if($("#state_code option:selected").attr('webservice') == 'Y'){
            window.localStorage.removeItem("state_code");
            window.localStorage.removeItem("state_name");
            populateDistricts(null);
            alert("Selected High Court not migrated to NC");
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
        window.sessionStorage.removeItem("RESULT_CAUSE_LIST");
        window.localStorage.removeItem("SESSION_COURT_CODE");
        window.sessionStorage.removeItem('SESSION_SELECT_STATE');
        window.sessionStorage.removeItem('SESSION_SELECT_DISTRICT');
        window.sessionStorage.removeItem('SESSION_SELECT_2');
        $("#Causelist_pannel").html('');
    });

    var select = document.getElementById("dist_code");
    var el = document.createElement("option");
    el.textContent = "Select Bench";
    el.value = '';
    el.selected = true;
    select.appendChild(el);
    //called when district is changed from district select box
    $("#dist_code").change(function () {
        var district_code_data = $("#dist_code").val();
        var district_name = $("#dist_code option:selected").text();
        window.localStorage.SESSION_COURT_CODE = district_code_data;
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
            // populateCourtComplexes();
            $("#Causelist_pannel").load("cause_list_hc.html");
        }//--end

        //clear cause list form data saved in session storage
        window.localStorage.removeItem("SESSION_COURT_CODE_CAUSE_LIST");
        window.sessionStorage.removeItem("SESSION_SELECT_2_CAUSE_LIST");
        window.sessionStorage.removeItem("SESSION_INPUT_1_CAUSE_LIST");
        window.sessionStorage.removeItem("SESSION_INPUT_2_CAUSE_LIST");
        window.sessionStorage.removeItem("RESULT_CAUSE_LIST");
        window.sessionStorage.removeItem("SESSION_BENCHES");
        window.sessionStorage.removeItem('SESSION_SELECT_STATE');
        window.sessionStorage.removeItem('SESSION_SELECT_DISTRICT');
        window.sessionStorage.removeItem('SESSION_SELECT_2');
    });

    if (window.localStorage.getItem("district_code") != null) {
        $("#Causelist_pannel").load("cause_list_hc.html");
    }

    //called when clicked on cause list tab
    $('.cause_list').on('click', function (event) {
        event.preventDefault(); // To prevent following the link (optional)
        var state_code_data = $("#state_code").val();
        var district_code_data = $("#dist_code").val();
        if (state_code_data === '' || state_code_data === null) {
            showErrorMessage("Please select High Court.");
            return false;
        }
        if (district_code_data === '' || district_code_data === null) {
            showErrorMessage("Please select Bench.");
            return false;
        }
        window.localStorage.setItem("state_code", state_code_data);
        window.localStorage.setItem("district_code", "1");
        window.location = 'cause_list_hc.html';
    });

    //code to set total saved cases count on my cases tab -- start
//        var caseInfoArray = window.localStorage.getItem("CNR Numbers");
    
    // if(localStorage.SELECTED_COURT === 'HC'){
        var caseInfoArray = window.localStorage.getItem("CNR Numbers HC");
    // }
    // else{
    //     var caseInfoArray = window.localStorage.getItem("CNR Numbers");
    // }
    var totalCasesSaved = 0;
    if (caseInfoArray != null) {
        caseInfoArray = JSON.parse(caseInfoArray);
        totalCasesSaved = caseInfoArray.length;
    }
    document.getElementById("mycases_span_id").innerHTML = totalCasesSaved;
    
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
        //$(".sidenav a").css({"background-color": "transparent", "color": "#555"});
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
        //$(".sidenav a").css({"background-color": "transparent", "color": "#555"});
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
        //$(".sidenav a").css({"background-color": "transparent", "color": "#555"});
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
        sessionStorage.setItem("tab", "#home");
        var ciNumber = $("#searchCNRId").val();

        //validation for ciNumber -- start
        if (ciNumber == "") {
            showErrorMessage("Please enter CNR number");
            return false;
        }
        if (ciNumber.length < 16)
        {
            showErrorMessage("Invalid CNR Number");
            $("#searchCNRId").val("");
            return false;
        }
        var pat = /^[a-zA-Z][a-zA-Z0-9]*$/;
            if (pat.test(ciNumber) == false) {
                showErrorMessage("CNR special characters not allowed ");
                $("#search_act").val("");
                 $("#search_act").focus(); 
                return false;
            }
        //validation for ci number -- end

        var data = {cino:(ciNumber)};        
        var caseHistoryWsUrl = hostIP + "caseHistoryWebService.php";
        //web service call to fetch case history
            callToWebService(caseHistoryWsUrl, data, getCaseHistoryResult);
            function getCaseHistoryResult(data){
                myApp.hidePleaseWait();
                if(data!=null){               
                var decryptedResponse = (data.history);
                if (decryptedResponse != null) {
                    window.sessionStorage.setItem("case_history", JSON.stringify(decryptedResponse));
                    window.sessionStorage.setItem("CINO", (ciNumber));
                    $.ajax({
                        type: "GET",
                        url: "case_history_hc.html"
                    }).done(function(data) { 
                        $("#caseHistoryModal_hc").show();
                        $("#historyData_hc").html(data);
                        $("#caseHistoryModal_hc").modal();
                    });                    
                } else {
                    showErrorMessage("This case code does not exist");                    
                }               
            }else {
                showErrorMessage("This case code does not exist");               
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
        var data = {state_code:(state_code_value),test_param:(toEncrypt.toString()), action_code:('benches')};   
            
            //web service call to get districts
            callToWebService(districtsUrl, data, getDistrictsResult);
            function getDistrictsResult(data){
                myApp.hidePleaseWait();
                var obj = (data.districts);
                populateDistricts(obj);                    
            }                   
        }            
    }

    //populates state select box  
    function populateStates(obj){
        if(obj){
            $('#state_code').empty();
            var items = [];
            items.push("<option value=''>Select High Court</option>");
            $.each(obj, function (key, val) {
                items.push('<option id="' + val.state_code + '" value="' + val.state_code + '" webservice="' + val.webservice + '">' + val.state_name + '</option>');
            });
            $("#state_code").html(items.join(""));
            if (window.localStorage.state_code != null) {
                document.getElementById('state_code').value = window.localStorage.state_code;
                get_district();
            } else {
                document.getElementById('state_code').value = '';
                populateDistricts(null);
            }
        }
    }

    //populate districts select box
    function populateDistricts(obj){
        var items = [];
        items.push("<option value=''>Select Bench</option>");
        if(obj){            
                $.each(obj, function (key, val) {
                items.push('<option id="' + val.dist_code + '" value="' + val.dist_code + '">' + val.dist_name + '</option>');
            });
            $("#dist_code").html(items.join(""));
            if (window.localStorage.district_code != null) {
                document.getElementById('dist_code').value = window.localStorage.district_code;
            }else{
                document.getElementById('dist_code').value = '';
    
            }
        }else{
            $("#dist_code").html(items.join(""));
            document.getElementById('dist_code').value = '';
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
                        alert("Not a QR code");
                        backButtonHistory.pop(); 
                        backButtonHistory.push("qrscanner"); 
                    }
                }else{
                    backButtonHistory.pop(); 
                    backButtonHistory.push("qrscanner"); 
                }
            },
            function (error) {
                alert("Scanning failed: " + error);
            }
        );
    }

function myCasesSelected()
{
    if(localStorage.getItem("CNR Numbers HC")!=null)
    {
        var cnrFromLocalStorageLenght= JSON.parse(localStorage.getItem("CNR Numbers HC")).length;
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


function importLanguageFile()
{
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
                go_back_link_searchPage_fun_hc();
                break;
                
            case "casehistory": 
                go_back_link_history_fun_hc();
                break;
                
            case "viewbusiness":               
                go_back_link_viewBusiness_fun();
                break;
                
            case "writinfo": 
                go_back_link_writInfo_fun();
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