
    $(document).ready(function () {
        second_header();
        backButtonHistory.push("searchcasepage");
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;
       
        $("#party_name").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();  
            }
        });

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();  
        });

        //validation
        $("#party_name").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty(); 
            }
            var pat = /^[a-zA-z .'_-]*$/;
            if ($(this).val().length > 99) {
                $(".party_name_err_msg").html("99 letter and Digits Only in fir number").show().fadeOut("slow");
                $("#party_name").val("");
                return false;
            }
            if (pat.test($(this).val()) == false) {
                $(".party_name_err_msg").html(" only letters, numbers ").show().fadeOut("slow");
                $("#party_name").val("");
                return false;
            }
        });    

        $("#rgyear").on('keydown', function () {
            if(window.sessionStorage.SET_RESULT != null){
            window.sessionStorage.removeItem("SET_RESULT");
            $("#accordion_search").empty();
            $("#headers").empty();  
            }
            if ($(this).val().length > 4) {
                $(".year").html("4 Digits Only in year").show().fadeOut("slow");
               $("#rgyear").val("");    
              return false;
            }
        });

    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        window.sessionStorage.removeItem('SET_RESULT'); 
         $("#party_name").val('');
         $("#rgyear").val('');
         var $radios = $('input[name=radOpt1]');
         $radios.filter('[value=Pending]').prop('checked', true);
         $("#accordion_search").empty();
         $("#headers").empty();  
        $("#totalEstablishments").empty();
       
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
        /*var patt = new RegExp(/^[a-zA-z.\ ] ?([a-zA-z.\ ]|[a-zA-z.\ ] )*[a-zA-z.\ ]$/);*/
        var patt = new RegExp(/^[a-zA-z.\' ] ?([a-zA-z.\' ]|[a-zA-z.\' ] )*[a-zA-z.\' ]$/);
        var petitionarName = $("#party_name").val();
        if (petitionarName === '' || petitionarName === null) {
            showErrorMessage("Please Enter Party Name");
            $("#party_name").val("");
              $("#party_name").focus(); 
            return false;
        }
    ///for validation of starting charectors
        for(i=0;i<petitionarName.length;i++) 
            {
            var schar = petitionarName.charAt(i);
            var achar = schar.charCodeAt(0);    
            if (i === 4) { break; }
            if((achar>=33 && achar <=39) || (achar>=40 && achar <=45) ||(achar>=47 && achar <=64))
            {
                showErrorMessage("Party Name should start with letter");
                $("#party_name").val("");
                    $("#party_name").focus(); 

                return false;
            }                   
        }

    if ($("#party_name").val().length < 3 || $("#party_name").val().length > 99)
        {
            showErrorMessage("Please Enter at least 3 char in Party Name");
            $("#party_name").val("");
             $("#party_name").focus(); 
            return false;
        }

        if (!patt.test(petitionarName)) {

            showErrorMessage("Please Enter valid Party Name");
            //$("#party_name").val("");
              $("#party_name").focus(); 
            return false;
        }

        var year = $("#rgyear").val();

        if (year === '' || year === null) {
            showErrorMessage("Please enter Year");
            $("#rgyear").val("");
            $("#rgyear").focus(); 
            return false;
        }

        if (year <= 0) {
            showErrorMessage("Please Enter Non Zero Year");

            $("#rgyear").val("");
            $("#rgyear").focus(); 
            return false;
        }
         if(year.toString().length < 4)
        {
             showErrorMessage("please enter 4 digit year");
            $("#rgyear").val("");
             $("#rgyear").focus(); 
            return false;
        }
        var d = new Date();
        var n = d.getFullYear();
        if (year <= 1900 || year > n)
        {
            showErrorMessage("Please Enter Year between 1901 to " + n);
            $("#rgyear").val("");
            $("#rgyear").focus(); 
            return false;
        }
        var pendingDisposed = $("input[name='radOpt1']:checked").val();
        var showDataUrl = hostIP + "showDataWebService.php";
        var encrypted_data1 = ($("#party_name").val());
        var encrypted_data2 = (pendingDisposed.toString());
        var encrypted_data3 = (year.toString());        
        var request_data = {pet_name:encrypted_data1, pendingDisposed:encrypted_data2.toString(), year:encrypted_data3.toString()};
        displayCasesTable(showDataUrl, request_data);
    }
    
function go_back_link_searchPage_fun_hc(){    
    backButtonHistory.pop();   
    window.sessionStorage.removeItem("SET_RESULT"); 
    $("#searchPageModal").modal('hide');
}

$("#menubarClose").click(function (e)
{
    //e.preventDefault();
    if ($("#mySidenav1").is(':visible'))
    {
        closeNav1();
    }
});

