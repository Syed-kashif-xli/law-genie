var stateCodePresentInSelectedLanguage;
/*var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
if(labelsarr){       
        $("#writ_information_label").html(labelsarr[162]);
        
    }*/

    $(document).ready(function () {
        $("#header_writ").load("writ_business_header.html", function (response, status, xhr) {
            // $("#second_header").css('display', 'block');
            // var backlink = window.sessionStorage.SESSION_BACKLINK;
             
            $('#go_back_link_2').on('click', function (event) {   
                           
                backButtonHistory.pop();
                
                $("#header_id_writ").focus();
                window.localStorage.removeItem("writInfoSessionStorageVar");   
                
                $("#writInfoModal").modal('hide');  
                // $("#header_srchpage").remove();              
            });

            $("#open_close2").on('click', function (event) 
            {
                if ($("#mySidenav2").is(':visible'))
                {
                    closeNav2();
                } else
                {
                    openNav2();
                }
            });
        });
        
        backButtonHistory.push("writinfo");

        var writInfoData = window.localStorage.getItem("writInfoSessionStorageVar");

        if (writInfoData != "") {

            document.getElementById("writInformationContainerId").innerHTML = writInfoData;
        }
        var retrievedObject = window.sessionStorage.getItem('case_history');
        var caseHistory = retrievedObject ? JSON.parse(retrievedObject) : null;
        if (caseHistory != null) { 
            if(window.localStorage.getItem("SELECTED_COURT")=="DC"){
                stateCodePresentInSelectedLanguage = localizedStateCodesArr.indexOf(parseInt(caseHistory.state_code)) == -1 ? false : true;
            }
        }
        localizeLabels();

    });
    $("#menubarClose_writ").click(function ()
        {
            if ($("#mySidenav2").is(':visible'))
            {
                document.getElementById("mySidenav2").style.display = "none";
            } 
        });


    // document.addEventListener("backbutton", onBackKeyDown, false);

    // function onBackKeyDown(e) 
    // {
    //     e.preventDefault();  
    //     var flag = getParameterByName('flag');        
    //     window.location.replace("case_history.html?flag="+flag);

    // }

    function go_back_link_writInfo_fun(){
        backButtonHistory.pop(); 
        $("#header_id_writ").focus();                       
        window.localStorage.removeItem("writInfoSessionStorageVar");     
        $("#writInfoModal").modal('hide');  
    }

    function localizeLabels(){
        if(window.sessionStorage.GLOBAL_LABELS){
            //if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
             //   $("#writ_information_label").html("Writ Information");
            //}else{
                var labelsarr = JSON.parse(window.sessionStorage.GLOBAL_LABELS);  
                $("#writ_information_label").html(labelsarr[162]);
           // }               
        }
    }