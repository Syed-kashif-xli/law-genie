
$(document).ready(function () {
    second_header();
    backButtonHistory.push("searchcasepage");
    sessionStorage.setItem("tab", "#profile");
    populateCourtComplexes();

    var selectYearLabel = "Enter year";
    var partyName = "Enter Party Name";

    var labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){       
            $("#casestatus_heading1_label").html(labelsarr[11]);
            $("#search_by_party_name_label").html(labelsarr[98]);
            $("#court_complex_label").html(labelsarr[269]);
            $("#pet_res_label").html(labelsarr[32]);

            $("#registration_year_label1").html(labelsarr[400]);
            $("#registration_year_label2").html(labelsarr[81]);

            $("#goButton").html(labelsarr[26]);
            $("#resetButton").html(labelsarr[57]);
            document.getElementById("rad1").innerHTML=(labelsarr[31]);
            document.getElementById("rad2").innerHTML=(labelsarr[21]);
            document.getElementById("rad3").innerHTML=(labelsarr[7]);
            selectYearLabel = labelsarr[683];
            $('#rgyear').attr('placeholder',selectYearLabel);

            partyName = labelsarr[684];
            $('#party_name').attr('placeholder',partyName);
    }    
    $('#court_code').change(function () {
        // window.sessionStorage.removeItem("SESSION_COURTNAMES");
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();       
        if ($('#court_code').val() != "") {
            window.localStorage.setItem("SESSION_COURT_CODE", $('#court_code').val());
            window.localStorage.setItem("SESSION_SELECTED_COMPLEX_CODE", $('#court_code option:selected').attr('complex_code'));

        } else {
            window.localStorage.removeItem("SESSION_COURT_CODE");
            window.localStorage.removeItem("SESSION_SELECTED_COMPLEX_CODE");
        }
        $("#Causelist_pannel").trigger("courtCodeChanged");
    });

    $('input[type=radio][name=radOpt1]').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#accordion_search").empty();
        $("#headers").empty();       
    });

    //validation
    $("#party_name").on('keydown', function (e) {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();       
        }
        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".party_name_err_msg").html("99 letter Only in party name").show().fadeOut("slow");
            $("#party_name").val("");
            return false;
        }
        if(localStorage.LANGUAGE_FLAG=="english"){
        // if(bilingual_flag == "1"){
            if (pat.test($(this).val()) == false) {
                $(".party_name_err_msg").html(" only letters").show().fadeOut("slow");
                $("#party_name").val("");
                return false;
            } 
        }       
    });       

    $("#rgyear").on('keydown', function () {
        if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();  
        }
        if ($(this).val().length > 4) {
            $(".year").html(labelsarr[808]).show().fadeOut("slow");
        $("#rgyear").val("");    
        return false;
        }
    });

});

//clear form
$("#resetButton").click(function (e) {
    e.preventDefault();
    window.localStorage.removeItem('SESSION_COURT_CODE');
    window.sessionStorage.removeItem('SET_RESULT');
    $('#court_code').val("");
    $("#rgyear").val("");   
    $("#party_name").val(""); 
    var $radios = $('input[name=radOpt1]');
    $radios.filter('[value=Pending]').prop('checked', true);       
    $("#accordion_search").empty();
    $("#headers").empty(); 
    $("#Causelist_pannel").trigger("courtCodeChanged");        
});

//fetch search result after Go button click from web service or session storage
$("#goButton").click(function (e) {
    e.preventDefault();        
    if(window.sessionStorage.SET_RESULT == null){
        return populateCasesTable();
    }
});

function populateCasesTable() {
    $("#accordion_search").empty();

    var selectboxText = $("#court_code option:selected").val();
    if (selectboxText == null || selectboxText=='') {
        showErrorMessage(labelsarr[277]);
        //showErrorMessage("Please Select Court Complex");
        return false;
    }
    /*var patt = new RegExp(/^[a-zA-z.\ ] ?([a-zA-z.\ ]|[a-zA-z.\ ] )*[a-zA-z.\ ]$/);*/
    var patt = new RegExp(/^[a-zA-z.\' ] ?([a-zA-z.\' ]|[a-zA-z.\' ] )*[a-zA-z.\' ]$/);
    var petitionarName = $("#party_name").val();
    if (petitionarName === '' || petitionarName === null) {
        showErrorMessage(labelsarr[40]);
        $("#party_name").val("");
        $("#party_name").focus(); 
        return false;
    }
///for validation of starting charectors
    for(i=0;i<petitionarName.length;i++){
        var schar = petitionarName.charAt(i);
        var achar = schar.charCodeAt(0);    

        if (i === 4) { break; }

        if((achar>=33 && achar <=39) || (achar>=40 && achar <=45) ||(achar>=47 && achar <=64)){
            showErrorMessage(labelsarr[757]);
            $("#party_name").val("");
            $("#party_name").focus();
            return false;
        }                   

    }


if ($("#party_name").val().length < 3 || $("#party_name").val().length > 99){
        showErrorMessage(labelsarr[34]);
        $("#party_name").val("");
        $("#party_name").focus(); 
        return false;
    }

    if(localStorage.LANGUAGE_FLAG=="english"){
    // if(bilingual_flag == "1"){
        if (!patt.test(petitionarName)) {
            showErrorMessage(labelsarr[707]);
            //$("#party_name").val("");
            $("#party_name").focus(); 
            return false;
        }
    }else{
        var format = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~/0-9]/;       
        if(format.test(petitionarName)){            
            showErrorMessage(labelsarr[707]);           
            $("#party_name").focus(); 
            return false;
        }
    } 

    var year = $("#rgyear").val();

    if (year === '' || year === null) {
        showErrorMessage(labelsarr[115]);
        $("#rgyear").val("");
        $("#rgyear").focus(); 
        return false;
    }

    if (year <= 0) {
        showErrorMessage(labelsarr[708]);

        $("#rgyear").val("");
        $("#rgyear").focus(); 
        return false;
    }
    if(year.toString().length < 4)
    {
        showErrorMessage(labelsarr[42]);
        $("#rgyear").val("");
        $("#rgyear").focus(); 
        return false;
    }
    var d = new Date();
    var n = d.getFullYear();
    if (year <= 1900 || year > n)
    {
        showErrorMessage(labelsarr[43] + n);
        $("#rgyear").val("");
        $("#rgyear").focus(); 
        return false;
    }

    // window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_party_name.html");
    if (window.sessionStorage.getItem("SET_RESULT") == null) {
        var pendingDisposed = $("input[name='radOpt1']:checked").val();

        var showDataUrl = hostIP + "showDataWebService.php";

        var encrypted_data1 = ($("#party_name").val());
        var encrypted_data2 = (pendingDisposed.toString());
        var encrypted_data3 = (year.toString());        

        var request_data = {pet_name:encrypted_data1, pendingDisposed:encrypted_data2.toString(), year:encrypted_data3.toString()};

        displayCasesTable(showDataUrl, request_data);
    } 
    // else {
    //     displayCasesTable1();
    // }
}


//blocked tab swipe for cause list result table since this table has horizontal scroll
// $(function () {
//     $("#cases").swipe({
//         swipeStatus: function (event, phase, direction, distance, fingerCount) {
//             return false;
//         }
//     });
// });

function go_back_link_searchPage_fun(){    
    backButtonHistory.pop();  
    window.sessionStorage.removeItem("SET_RESULT");      
    $("#searchPageModal").modal('hide');    
    $(".party_name").focus();
}

$("#menubarClose").click(function (e)
{
    if ($("#mySidenav1").is(':visible'))
    {
        closeNav1();
    }
});
