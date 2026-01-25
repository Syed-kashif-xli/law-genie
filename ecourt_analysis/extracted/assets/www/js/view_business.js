var stateCodePresentInSelectedLanguage;
    $(document).ready(function () {
        $("#header_view_business").load("view_business_header.html", function (response, status, xhr) {
            // $("#second_header").css('display', 'block');
            // var backlink = window.sessionStorage.SESSION_BACKLINK;
            $('#go_back_link_4').on('click', function (event) {
                backButtonHistory.pop();
                $("#header_id_business").focus();
                window.localStorage.removeItem("viewBusinessLocalStorageVar");   
                $("#viewBusinessModal").modal('hide');
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
        
        backButtonHistory.push("viewbusiness");
        

        var viewBusinessData = window.localStorage.getItem("viewBusinessLocalStorageVar");

        if (viewBusinessData != "") {

            document.getElementById("viewBusinessContainerId").innerHTML = viewBusinessData;
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

    // function closeNav() {

    //         document.getElementById("mySidenav").style.display = "none";
    //     }
    $("#businessData").click(function ()
        {
            if ($("#mySidenav2").is(':visible'))
            {
                // closeNav();
                document.getElementById("mySidenav2").style.display = "none";
            } 
        });

    // document.addEventListener("backbutton", onBackKeyDown, false);

    // function onBackKeyDown(e) 
    // {
    //     e.preventDefault();  
    //     var flag = getParameterByName('flag'); 
    //      if(window.localStorage.getItem("SELECTED_COURT")==="DC")
    //                     {
    //                          window.location.replace("case_history.html?flag="+flag);
    //                     }
    //                     else if(window.localStorage.getItem("SELECTED_COURT")==="HC")
    //                     { 
    //                         window.location.replace("case_history_hc.html?flag="+flag);
    //                     }

    // }

    function go_back_link_viewBusiness_fun(){    
        backButtonHistory.pop();  
        $("#header_id_business").focus();
        window.localStorage.removeItem("viewBusinessLocalStorageVar");      
        $("#viewBusinessModal").modal('hide');       
    }

function localizeLabels(){
    if(window.sessionStorage.GLOBAL_LABELS){
        //if(!stateCodePresentInSelectedLanguage || localStorage.LANGUAGE_FLAG=="english"){
        //    $("#viewBusinessLabel").html("View Business");
        //}else{
            var labelsarr = JSON.parse(window.sessionStorage.GLOBAL_LABELS);  
            $("#viewBusinessLabel").html(labelsarr[749]);
       // }               
    }
}
                


// $("#menubarClose_map").click(function ()
// {
// 	if ($("#mySidenav_map").is(':visible'))
// 	{
// 		// closeNav();
// 		document.getElementById("mySidenav_map").style.display = "none";
// 	} 
// });

