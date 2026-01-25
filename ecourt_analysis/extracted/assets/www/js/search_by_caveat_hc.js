/*
variables saved in local/ session storage to retain page session after page reload

SESSION_COURT_CODE : court complexes selected value- saved in local storage    
SESSION_BACKLINK : current page- session storage
SESSION_INPUT_1 : party name text box input value- session storage
SESSION_INPUT_2 : year input value- session storage 
SET_RESULT : Result after Go button click- session storage 
*/
var state_selected, district_selected, cavt_cnt_spl_behaviour;

    $(document).ready(function () {
        second_header();
        backButtonHistory.push("searchcasepage");
        sessionStorage.setItem("tab", "#profile");
        document.getElementById("benchName").innerHTML = window.localStorage.district_name;
        //get Caveat Count for case type behaviour for HC...
        getCaveatCount();
        
        
        document.getElementById("anywhere").style.display = "block";
        document.getElementById("starting_with").style.display = "none";
        document.getElementById("subordinate_court").style.display = "none";
        document.getElementById("caveat_no").style.display = "none";
        
        document.getElementById("radioGroup2").style.display = "none";
        document.getElementById("quasiJudicial").style.display = "none";
        document.getElementById("high_court").style.display = "none";
        
         //populate State...
       if (window.localStorage.SESSION_COURT_CODE != null) {
             //populateState();
        }
        
        $('#pickyDate').attr('readonly', true);

        $('#pickyDate').datepicker({dateFormat: 'dd-mm-yy',

//                maxDate: +30 ,
//                minDate: -7,
               // onSelect: clearResult
               });
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();

        $('#pickyDate').val(today);
        
        $('#orderDate').attr('readonly', true);

            $('#orderDate').datepicker({dateFormat: 'dd-mm-yy',

                                        maxDate: +30 ,
                                        minDate: -7,
                                       // onSelect: clearResult
                                       });
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();

        $('#orderDate').val(today); 
        
        $('#select_state').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($('#select_state').val() == '') { 
                state_selected = '';
                //Reset district to empty...
                $("#select_district").empty();
                var select = document.getElementById("select_district");
                var el = document.createElement("option");
                el.textContent = "Select District";
                el.value = '';
                el.selected = true;
                select.appendChild(el);
                
                //Reset subordinate court name to empty...
                $("#subordinate_court_name").empty();
                var select = document.getElementById("subordinate_court_name");
                var el = document.createElement("option");
                el.textContent = "Select Subordinate Court Name";
                el.value = '';
                el.selected = true;
                select.appendChild(el);
                
                //Reset case type to empty...
                document.getElementById('case_type').value = '';
                
               
            } else {
                state_selected =  $('#select_state').val();
                populateDistrict(state_selected);
            }
            
        });
        
        $('#select_district').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($('#select_district').val() == '') {
               district_selected = '';
                
                //Reset subordinate court name to empty...
                $("#subordinate_court_name").empty();
                var select = document.getElementById("subordinate_court_name");
                var el = document.createElement("option");
                el.textContent = "Select Subordinate Court Name";
                el.value = '';
                el.selected = true;
                select.appendChild(el);
                
                //Reset case type to empty...
                document.getElementById('case_type').value = ''; 
                
            } else {
                 
                district_selected = $('#select_district').val();
                
                populateLowerCourt(state_selected, district_selected);
            }
            
        });
        
        
      /*   if (window.sessionStorage.SESSION_INPUT_1 != null) {
            $("#party_name").val(window.sessionStorage.SESSION_INPUT_1);
        }
        if (window.sessionStorage.SESSION_INPUT_2 != null) {
            $("#rgyear").val(window.sessionStorage.SESSION_INPUT_2);
        }
        if (window.sessionStorage.SESSION_PENDING_DISPOSED != null) {
            var selected_radio = window.sessionStorage.SESSION_PENDING_DISPOSED;        
            var $radios = $('input[name=radOpt1]');
            $radios.filter('[value='+selected_radio+']').prop('checked', true);
        }
        if (window.localStorage.SESSION_COURT_CODE != null &&
                window.sessionStorage.SESSION_INPUT_1 != null &&
                window.sessionStorage.SESSION_INPUT_2 != null) {
            $("#goButton").click();
        } */


        $("#party_name").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
        });

        $('input[type=radio][name=radOpt1]').change(function () {
            window.sessionStorage.removeItem("SET_RESULT");
        });

        //validation
        $("#party_name").on('keydown', function () {

            window.sessionStorage.removeItem("SET_RESULT");
            var pat = /^[a-zA-z .'_-]*$/;
            if ($(this).val().length > 99) {
                $(".party_name").html("99 letter and Digits Only in fir number").show().fadeOut("slow");
                $("#party_name").val("");
                return false;
            }
            if (pat.test($(this).val()) == false) {
                $(".party_name").html(" only letters, numbers ").show().fadeOut("slow");
                $("#party_name").val("");
                return false;
            }
        });    

        $("#rgyear").on('keydown', function () {
            window.sessionStorage.removeItem("SET_RESULT");
            if ($(this).val().length > 4) {
                $(".year").html("4 Digits Only in year").show().fadeOut("slow");
               $("#rgyear").val("");    
              return false;
            }
        });
        
        if($('#select_search_type').val() == 'Anywhere'){
            populateDistrict_1();
        }
        

        //High Court CC applied Date...
        $('#hc_cc_aplied_date').attr('readonly', false);

            $('#hc_cc_aplied_date').datepicker({dateFormat: 'dd-mm-yy',

                                        maxDate: +30 ,
                                        minDate: -7,
                                       // onSelect: clearResult
                                       });
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();

        //$('#hc_cc_aplied_date').val(today);  
        
        //High Court CC ready Date...
        $('#hc_cc_ready_date').attr('readonly', false);

            $('#hc_cc_ready_date').datepicker({dateFormat: 'dd-mm-yy',

                                        maxDate: +30 ,
                                        minDate: -7,
                                       // onSelect: clearResult
                                       });
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();

       // $('#hc_cc_ready_date').val(today); 
        
        //High Court CC ready Date...
        $('#hc_order_date').attr('readonly', false);

            $('#hc_order_date').datepicker({dateFormat: 'dd-mm-yy',

                                        maxDate: +30 ,
                                        minDate: -7,
                                       // onSelect: clearResult
                                       });
        var now = new Date();

        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);

        var today = (day) + "-" + (month) + "-" + now.getFullYear();

       // $('#hc_order_date').val(today);
        
        
    });

function isNumber(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}

$("#select_search_type").change(function () {
    document.getElementById('caveatSearch').innerHTML = "";
    var search_value = $("#select_search_type").val();
    resetSearchOnComplexChange();
    switch(search_value){
           
        case "Anywhere" :
            
            if(cavt_cnt_spl_behaviour>0)
            {
                document.getElementById("spl_behaviour_case_type").style.display = "block";
            }
            else
            {
                document.getElementById("spl_behaviour_case_type").style.display = "none";
            }
            document.getElementById("anywhere").style.display = "block";
            document.getElementById("starting_with").style.display = "none";
            document.getElementById("subordinate_court").style.display = "none";
            document.getElementById("caveat_no").style.display = "none";
            
            document.getElementById("radioGroup2").style.display = "none";
            document.getElementById("quasiJudicial").style.display = "none";
            document.getElementById("high_court").style.display = "none";
            break;
            
        case "StartingWith" :
            if(cavt_cnt_spl_behaviour>0)
            {
                document.getElementById("spl_behaviour_case_type").style.display = "block";
            }
            else
            {
                document.getElementById("spl_behaviour_case_type").style.display = "none";
            }
            document.getElementById("anywhere").style.display = "none";
            document.getElementById("starting_with").style.display = "block";
            document.getElementById("subordinate_court").style.display = "none";
            document.getElementById("caveat_no").style.display = "none";
           
            document.getElementById("radioGroup2").style.display = "none";
            document.getElementById("quasiJudicial").style.display = "none";
            document.getElementById("high_court").style.display = "none";
            break;
            
        case "SubordinateCourt" :
            if(cavt_cnt_spl_behaviour>0)
            {
                document.getElementById("spl_behaviour_case_type").style.display = "block";
            }
            else
            {
                document.getElementById("spl_behaviour_case_type").style.display = "none";
            }
            populateState();
            document.getElementById("anywhere").style.display = "none";
            document.getElementById("starting_with").style.display = "none";
            document.getElementById("subordinate_court").style.display = "block";
            document.getElementById("caveat_no").style.display = "none";
            
            document.getElementById("radioGroup2").style.display = "block";
            document.getElementById("quasiJudicial").style.display = "none";
            document.getElementById("high_court").style.display = "none";
            break;
            
        case "QuasiJudicial" :
            
            document.getElementById("spl_behaviour_case_type").style.display = "none";
            document.getElementById("anywhere").style.display = "none";
            document.getElementById("starting_with").style.display = "none";
            document.getElementById("subordinate_court").style.display = "none";
            document.getElementById("caveat_no").style.display = "none";
            
            document.getElementById("radioGroup2").style.display = "block";
            document.getElementById("quasiJudicial").style.display = "block";
            document.getElementById("high_court").style.display = "none";
            break;
            
        case "HighCourt" :
            populateCaseTypesHC();
            document.getElementById("spl_behaviour_case_type").style.display = "none";
            document.getElementById("anywhere").style.display = "none";
            document.getElementById("starting_with").style.display = "none";
            document.getElementById("subordinate_court").style.display = "none";
            document.getElementById("caveat_no").style.display = "none";
           
            document.getElementById("radioGroup2").style.display = "none";
            document.getElementById("high_court").style.display = "block";
            document.getElementById("quasiJudicial").style.display = "none";
            break;
            
        case "CaveatNo" :
            if(cavt_cnt_spl_behaviour>0)
            {
                document.getElementById("spl_behaviour_case_type").style.display = "block";
            }
            else
            {
                document.getElementById("spl_behaviour_case_type").style.display = "none";
            }
            document.getElementById("anywhere").style.display = "none";
            document.getElementById("starting_with").style.display = "none";
            document.getElementById("subordinate_court").style.display = "none";
            document.getElementById("caveat_no").style.display = "block";
            
            document.getElementById("radioGroup2").style.display = "none";
            document.getElementById("quasiJudicial").style.display = "none";
            document.getElementById("high_court").style.display = "none";
            break;
            
            
    }
    
});

    $('#radOpt_case_no').click(function(e){
        $('#case_filing_number').text("Case Number")
        $('#case_number').attr("placeholder","Enter Case Number")
    });

    $('#radOpt_filing_no').click(function(e){
        $('#case_filing_number').text("Filing Number")
        $('#case_number').attr("placeholder","Enter Filing Number")
    });

    $("#caveator_name").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".caveator_name").html("99 letter in caveator name").show().fadeOut("slow");
            $("#caveator_name").val("");
            return false;
        }
        // if(localStorage.LANGUAGE_FLAG=="english"){
        if (pat.test($(this).val()) == false) {
            $(".caveator_name").html(" only letters ").show().fadeOut("slow");
            $("#caveator_name").val("");
            return false;
        } 
        // } 


    });

    $("#caveatee_name").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".caveatee_name").html("99 letter in caveatee name").show().fadeOut("slow");
            $("#caveatee_name").val("");
            return false;
        }
        // if(localStorage.LANGUAGE_FLAG=="english"){
        if (pat.test($(this).val()) == false) {
            $(".caveatee_name").html(" only letters ").show().fadeOut("slow");
            $("#caveatee_name").val("");
            return false;
        } 
        // } 
    });

    $("#caveator_caveatee_name").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        var pat = /^[a-zA-z .'_-]*$/;
        if ($(this).val().length > 99) {
            $(".caveator_caveatee_name").html("99 letter in caveatee/Caveatee name").show().fadeOut("slow");
            $("#caveator_caveatee_name").val("");
            return false;
        }
        // if(localStorage.LANGUAGE_FLAG=="english"){
        if (pat.test($(this).val()) == false) {
            $(".caveator_caveatee_name").html(" only letters ").show().fadeOut("slow");
            $("#caveator_caveatee_name").val("");
            return false;
        } 
        // }

    });

    $("#case_number").on('keydown', function (e) {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();        
        
        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            //display error message
            $(".case_number_val").html("Digits Only").show().fadeOut("slow");
            $("#case_number").val("");
            return false;
        }   
               
        if ($(this).val().length >= 7) {
            $(".case_number_val").html("7 Digits Only in case number").show().fadeOut("slow");
            $(this).val("");
            return false;
        }

    });

    $("#case_year").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        if ($(this).val().length > 4) {
            $(".case_year").html("4 Digits Only in year").show().fadeOut("slow");
            $("#case_year").val("");    
            return false;
        }

    });

    $("#case_ref_number_input").on('keydown', function (e) {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
        
        // if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        if (e.which != 8 && e.which != 0 && (e.which < 48)) {
            //display error message
            $(".case_ref_number_input").html("Digits and characters Only").show().fadeOut("slow");
            $("#case_ref_number_input").val("");
            return false;
        } 

    });

    $("#hc_case_number").on('keydown', function (e) {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            //display error message
            $(".hc_case_number_val").html("Digits Only").show().fadeOut("slow");
            $("#hc_case_number").val("");
            return false;
        } 
        if ($(this).val().length >= 7) {
            $(".hc_case_number_val").html("7 Digits Only in case number").show().fadeOut("slow");
            $(this).val("");
            return false;
        }
        
    });

    $("#hc_case_year").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
    });

    $("#hc_cc_aplied_date").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
    });

    $("#hc_cc_ready_date").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
    });

    $("#hc_order_date").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();
    });

    $("#caveat_number").on('keydown', function (e) {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            //display error message
            $(".caveat_number").html("Digits Only").show().fadeOut("slow");
            $("#caveat_number").val("");
            return false;
        } 
    });

    $("#caveat_year").on('keydown', function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#totalEstablishments").empty();
        $("#headers").empty();
        $("#accordion_search").empty();

        if ($(this).val().length > 4) {
            $(".caveat_year").html("4 Digits Only in year").show().fadeOut("slow");
            $("#caveat_year").val("");    
            return false;
        }

    });

    $('input[type=radio][name=radOpt2]').change(function () {
        window.sessionStorage.removeItem("SET_RESULT");
        $("#headers").empty();
        $("#accordion_search").empty();
        $("#totalEstablishments").empty();
    });

    //clear form
    $("#resetButton").click(function (e) {
        e.preventDefault();
        resetSearchOnComplexChange();
        resetSearchType();
        window.sessionStorage.removeItem('SET_RESULT');
        $('#caveator_name').val("");
        $('#caveatee_name').val("");
        $('#caveator_caveatee_name').val("");
        $('#case_number').val("");
        $('#case_year').val("");
        $('#case_ref_number_input').val("");
        $('#hc_case_number').val("");
        $('#hc_case_year').val("");
        $('#hc_cc_aplied_date').val("");
        $('#hc_cc_ready_date').val("");
        $('#hc_order_date').val("");
        $('#caveat_number').val("");
        $('#caveat_year').val("");


        $("#spl_behav_case_type").val('');
        var $radios = $('input[name=radOpt2]');
        $radios.filter('[value=Caveator]').prop('checked', true);

        var $radios = $('input[name=court_type]');
        $radios.filter('[value=firstAppletCourt]').prop('checked', true);

        var $radios = $('input[name=radOpt3]');
        $radios.filter('[value=2]').prop('checked', true);
        
        $("#headers").empty();
        $("#accordion_search").empty();
        $("#totalEstablishments").empty();
    });

    //fetch search result after Go button click from web service or session storage
    $("#goButton").click(function (e) {
       e.preventDefault();
       if(window.sessionStorage.SET_RESULT == null){
        populateCaveatSearchHC();
       }
    });

   
   /*  function closeNav() {

            document.getElementById("mySidenav").style.display = "none";
        }
    $("#menubarClose").click(function ()
        {
            if ($("#mySidenav").is(':visible'))
            {
                closeNav();
            } 
        });
 */
   /*  document.addEventListener("backbutton", onBackKeyDown, false);

    function onBackKeyDown(e) 
    {
        e.preventDefault();  
        window.location.replace("index.html");

    }
 */

function populateCaveatSearchHC(){
    window.sessionStorage.setItem("SESSION_BACKLINK", "search_by_caveat.html");
    var selectedSearchTypeVal = $('#select_search_type').val();
    var searchByCaveatURL = hostIP + "searchCaveat.php";
    
    var state_code_data = window.localStorage.state_code;
    var dist_code_data = window.localStorage.district_code;
    var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
    var court_code_data = courtCodesArr[0];
    
     //var establishments_count = arrCourtEstCodes.length;

        var count = 0;
        var count1 = 0;
    var total_cases = 0;
   
    $("#headers").empty();

    var headerArray = [];
   /* headerArray.push('<label">Total Number of Establishments in Court Complex:<span id="totalEstablishmentsSpanId"></span> </label></div>');
    headerArray.push('<br>');*/
    headerArray.push('<label>Total Number of Cases: <span id="totalcasesId"></span></label></div>');
    
    $("#accordion_search").empty();
    
    var pat = /^[a-zA-z .'_-]*$/;
    
    switch(selectedSearchTypeVal){
            
        case 'Anywhere':
            var spl_behav_case_type=$('#spl_behav_case_type').val();
            var caveator_name= $('#caveator_name').val();
            var caveatee_name= $('#caveatee_name').val(); 
            var district= $('#select_district_1').val();
            if((caveator_name=='' || caveator_name==null) && (caveatee_name=='' || caveatee_name==null))
                {
                    showErrorMessage("Please Enter Caveator or Caveatee Name");
                    $("#caveator_name").val("");
                    $("#caveator_name").focus(); 
                    return false;
                }
            
             if($('#caveator_name').val().length < 3)
                {
                    showErrorMessage("Please Enter at least 3 char in Caveator Name");
                    $('#caveator_name').val("");
                    $('#caveator_name').focus();
                    return false;
                }

            if (pat.test($("#caveator_name").val()) == false) {
                $(".caveator_name").html(" only letters").show().fadeOut("slow");
                $("#caveator_name").val("");
                return false;
            } 

            if (pat.test($("#caveatee_name").val()) == false) {
                $(".caveatee_name").html(" only letters").show().fadeOut("slow");
                $("#caveatee_name").val("");
                return false;
            } 

            if((caveatee_name.length>0 || caveatee_name!='') && ($('#caveatee_name').val().length < 3))
                {
                    showErrorMessage("Please Enter at least 3 char in Caveatee Name");
                    $('#caveatee_name').val("");
                    $('#caveatee_name').focus();
                    return false;
                }
            
           
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),caveator_name:(caveator_name),caveatee_name:(caveatee_name),action_code:('1'),district:(district), spl_behav_case_type:(spl_behav_case_type)};
            break;
            
         case 'StartingWith':
            var spl_behav_case_type=$('#spl_behav_case_type').val();
            var starting_wit_RadioVal = $("input[name='radOpt2']:checked").val();
            if(starting_wit_RadioVal == 'Caveator')
               { 
                    var caveator_name= $('#caveator_caveatee_name').val();
                    var caveatee_name= "";}
            else{
                    var caveatee_name= $('#caveator_caveatee_name').val();
                    var caveator_name="";}
            
            if($('#caveator_caveatee_name').val()=='' || $('#caveator_caveatee_name').val()==null)
                {
                   
                    showErrorMessage("Please Enter Caveator/Caveatee Name");
                    $("#caveator_caveatee_name").val("");
                    $("#caveator_caveatee_name").focus(); 
                    return false;
                }
            if($('#caveator_caveatee_name').val().length < 3)
                {
                    showErrorMessage("Please Enter at least 3 char in Caveator/Caveatee Name");
                    $('#caveator_caveatee_name').val("");
                    $("#caveator_caveatee_name").focus(); 
                    return false;
                }
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),caveator_name:(caveator_name),caveatee_name:(caveatee_name),starting_wit_RadioVal:(starting_wit_RadioVal),spl_behav_case_type:(spl_behav_case_type),action_code:('2')};
            break;
            
        case 'SubordinateCourt':
            var spl_behav_case_type=$('#spl_behav_case_type').val();
            var subordinate_court_name=$('#subordinate_court_name').val();
            var filing_type = $("input[name='radOpt3']:checked").val();
            var case_type=$('#case_type').val();
            var case_number=$('#case_number').val();
            var case_year=$('#case_year').val();
            var date_of_decision=$('#pickyDate').val();
            var court_type = $("input[name='court_type']:checked").val();
           
            
            if ($('#select_state').val() == '') {
                showErrorMessage("Please select state");
                return false;
            }
            if ($('#select_district').val() == '') {
                showErrorMessage("Please select district");
                return false;
            }
            
            if (subordinate_court_name == '') {
                showErrorMessage("Please select subordinate court name");
                return false;
            } 
            
            if (case_type == '') {
                showErrorMessage("Please select case type");
                case_type.focus();
                return false;
            }
            if (case_number == '') {
                showErrorMessage("Please enter case number");
                $("#case_number").val("");
                $("#case_number").focus(); 
                return false;
            } 
            
            if (case_year == '') {
                showErrorMessage("Please enter year");
                $("#case_year").val("");
                $("#case_year").focus(); 
                return false;
            } 
            
             if(case_year.toString().length < 4)
            {
                showErrorMessage("please enter 4 digit year");
                $("#case_year").val("");
                $("#case_year").focus(); 
                return false;
            }
            var d = new Date();
            var n = d.getFullYear();
            if (case_year <= 1900 || case_year > n)
            {
                showErrorMessage("Please Enter Year between 1901 to " + n);
                $("#case_year").val("");
                $("#case_year").focus(); 
                return false;
            }
            
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),subordinate_court_name:(subordinate_court_name),filing_type:(filing_type),case_type:(case_type),case_number:(case_number),case_year:(case_year),date_of_decision:(date_of_decision),spl_behav_case_type:(spl_behav_case_type),action_code:('4'),court_type:(court_type)};
            break;
            
        case 'CaveatNo':
            var spl_behav_case_type=$('#spl_behav_case_type').val();
            var caveat_number=$('#caveat_number').val();
            
            var caveat_year=$('#caveat_year').val();
           
            
            if (caveat_number == '') {
                showErrorMessage("Please enter caveat number");
                $("#case_ref_number_input").val("");
                $("#case_ref_number_input").focus(); 
                return false;
            }
            
            if (caveat_year == '') {
                showErrorMessage("Please enter year");
                $("#caveat_year").val("");  
                $("#caveat_year").focus();  
                return false;
            } 
            
             if(caveat_year.toString().length < 4)
            {
                showErrorMessage("please enter 4 digit year");
                $("#caveat_year").val("");
                $("#caveat_year").focus(); 
                return false;
            }
            var d = new Date();
            var n = d.getFullYear();
            if (caveat_year <= 1900 || caveat_year > n)
            {
                showErrorMessage("Please Enter Year between 1901 to " + n);
                $("#caveat_year").val("");
                $("#caveat_year").focus(); 
                return false;
            }
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),caveat_number:(caveat_number),caveat_year:(caveat_year),action_code:('5'),spl_behav_case_type:(spl_behav_case_type)};
            break;
            
        case 'QuasiJudicial':
            
            var case_ref_number=$('#case_ref_number_input').val();
            
            var order_Date=$('#orderDate').val();
            
            var court_type = $("input[name='court_type']:checked").val();

           
            if (case_ref_number == '') {
                showErrorMessage("Please enter case/referance number");
                $("#case_ref_number_input").val("");
                $("#case_ref_number_input").focus(); 
                return false;
            }
            
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),case_ref_number:(case_ref_number),order_Date:(order_Date),action_code:('6'),court_type:(court_type)};
            break;
            
        case 'HighCourt':
            
            var case_type_hc=$('#case_type_hc').val();
            var hc_case_number=$('#hc_case_number').val();
            var hc_case_year=$('#hc_case_year').val();
            var hc_cc_aplied_date=$('#hc_cc_aplied_date').val();
            var hc_cc_ready_date=$('#hc_cc_ready_date').val();
            var hc_order_date=$('#hc_order_date').val();
           
            if (case_type_hc == '') {
                showErrorMessage("Please select case type");
                case_type_hc.focus();
                return false;
            }
                   
            if (hc_case_number == '') {
                showErrorMessage("Please enter case number");
                $("#hc_case_number").val("");
                $("#hc_case_number").focus(); 
                return false;
            } 
            
             if (hc_case_year == '') {
                showErrorMessage("Please enter year");
                $("#hc_case_year").val("");
                $("#hc_case_year").focus(); 
                return false;
            } 
            
             if(hc_case_year.toString().length < 4)
            {
                showErrorMessage("please enter 4 digit year");
                $("#hc_case_year").val("");
                $("#hc_case_year").focus(); 
                return false;
            }
            var d = new Date();
            var n = d.getFullYear();
            if (hc_case_year <= 1900 || hc_case_year > n)
            {
                showErrorMessage("Please Enter Year between 1901 to " + n);
                $("#hc_case_year").val("");
                $("#hc_case_year").focus(); 
                return false; 
            } 
            
            var caveatData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),
            case_type_hc:(case_type_hc),hc_case_number:(hc_case_number),
            hc_case_year:(hc_case_year),hc_cc_aplied_date:(hc_cc_aplied_date),
            hc_cc_ready_date:(hc_cc_ready_date),hc_order_date:(hc_order_date),
            action_code:('7')};
            break;    
    } 
        $("#headers").append(headerArray); 
         var collapseid = 0;   
         myApp.showPleaseWait();
         //web service call to get states        
        callToWebService(searchByCaveatURL, caveatData, caveatSearchResult);
        function caveatSearchResult(result){                       
            if((result.totalCases) != 0){
            decodedResult = (result.caveatSearchTable);                   
            total_cases += (result.totalCases);
            var panel_body = [];
            var trHTML = '';
            panel_id = 'card' + state_code_data + '_' + dist_code_data + '_' + collapseid;
            var benchName = window.localStorage.district_name + " : " + total_cases;
            panel_body.push('<div class="card">');
            panel_body.push('<div class="card-header"><h4 class="panel-title"><a  class="card-link collapsed panel-title-a" data-parent="#accordion_search" data-toggle="collapse" data-target="#' + panel_id + '" href="#' + panel_id + '">' + benchName + '</a></h4></div>');
            panel_body.push("<div id=" + panel_id + " class='collapse'><div class='card-body'>");                    
            panel_body.push(decodedResult);
            panel_body.push('</div>');
            collapseid++;
            count1++;
            $("#accordion_search").append(panel_body.join(""));
            document.getElementById('totalcasesId').innerHTML = total_cases;
            }else{
                document.getElementById('totalcasesId').innerHTML = "0";
            }
            myApp.hidePleaseWait();
        }            
}



//fetch states from web service or session storage
    function populateState() {
        state_selected = '';
        $('#select_state').empty();
        $('#select_state').append('<option id="" value="">Select State</option>');
        $('#case_type').empty();
        $('#case_type').append('<option id="" value="">Select Case Type</option>');
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var district_code_data = window.localStorage.district_code;
        var stateWebService_hcUrl = hostIP + "stateWebServiceCaveat.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
        court_code_data = courtCodesArr[0];
        var stateData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data)};
        //web service call to get states
        callToWebService(stateWebService_hcUrl, stateData, caveatStatesResult);
        function caveatStatesResult(result){
            var decodedResult = (result.states);  
            $.each(decodedResult, function (key, val) {
                    $('#select_state').append('<option id="" value="' + val.state_id + '">' + val.state_name + '</option>');
            });                                                  
            var decodedResult1 = (result.lcaseType);                         
            $.each(decodedResult1, function (key, val) {
                    $('#case_type').append('<option id="" value="' + val.lcase_type + '">' + val.type_name + '</option>');
            });                         
            if (state_selected != null) {
                document.getElementById('select_state').value = state_selected;
            }else{
                document.getElementById('select_state').value = '';
            }
            myApp.hidePleaseWait();
        }
    }


//these districts are populated under caveat search for 'Anywhere' search option...
function populateDistrict_1() {
        $('#select_district_1').empty();
        $('#select_district_1').append('<option id="" value="">Select District</option>');
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var stateWebService_hcUrl = hostIP + "districtWebService.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
        court_code_data = courtCodesArr[0];
        var stateData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), action_code:('caveat_anywhere')};
        //web service call to get states
        callToWebService(stateWebService_hcUrl, stateData, caveatDistrictsAnywhereResult);
        function caveatDistrictsAnywhereResult(result){
            var decodedResult = (result.districts);
            $.each(decodedResult, function (key, val) {
                    $('#select_district_1').append('<option id="" value="' + val.dist_code + '">' + val.dist_name + '</option>');
            });
            myApp.hidePleaseWait();
        }
    }



//fetch District from web service or session storage for subordinate search option
    function populateDistrict(state_selected) {
        district_selected = '';
        $('#select_district').empty();
        $('#select_district').append('<option id="" value="">Select District</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }

        var establishment_state_code = state_selected;
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;

//        var stateWebService_hcUrl = "http://" + hostIP + "districtWebServiceCaveat.php";
        var stateWebService_hcUrl = hostIP + "districtWebService.php";
        
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];

        var stateData = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data), establishment_state_code:(establishment_state_code),action_code:('fir_subordinate')};
        //web service call to get states
        callToWebService(stateWebService_hcUrl, stateData, caveatStatesSubordinateResult);
        function caveatStatesSubordinateResult(result){
            var decodedResult = (result.districts);
            $.each(decodedResult, function (key, val) {
                    $('#select_district').append('<option id="" value="' + val.dist_code + '">' + val.dist_name + '</option>');
            }); 
                if (district_selected != null) {
                document.getElementById('select_district').value = district_selected;
            }else{
                document.getElementById('select_district').value = '';
            }                   
            myApp.hidePleaseWait();
        }

    }


//fetch court Names from web service or session storage
    function populateLowerCourt(state_selected, district_selected) {
        $('#subordinate_court_name').empty();
        $('#subordinate_court_name').append('<option id="" value="">Select Subordinate Court Name</option>');
//        var selectboxText = $("#court_code option:selected").text();
//        var selectboxText = $select.text();
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }

        var establishment_state_code = state_selected;
        var state_code_data = window.localStorage.state_code;
        var dist_code_data = window.localStorage.district_code;
        var establishment_district_code = district_selected;
        
        var stateWebService_hcUrl = hostIP + "lowerCourtCaveat.php";
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");

        court_code_data = courtCodesArr[0];

        var lowerCourtData = {state_code:(state_code_data), dist_code:(dist_code_data), court_code:(court_code_data),establishment_state_code:(establishment_state_code),establishment_district_code:(establishment_district_code)};
        //web service call to get states
        callToWebService(stateWebService_hcUrl, lowerCourtData, caveatLowerCourtResult);
        function caveatLowerCourtResult(result){
            var decodedResult = (result.lowerCourt);
            $.each(decodedResult, function (key, val) {
                    $('#subordinate_court_name').append('<option id="" value="' + val.lower_court_code + '">' + val.oname + '</option>');
            });                 
            myApp.hidePleaseWait();
        }
    }

    function caveatHistory(caveat_number) {
        var state_code_data = window.localStorage.state_code;
        var dist_code_data = window.localStorage.district_code;
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
        var court_code_data = courtCodesArr[0];
        var caveatHistoryData = {court_code:(court_code_data), dist_code:(dist_code_data), caveat_number:(caveat_number), state_code:(state_code_data)};
        var caveatCaseHistoryWebServiceUrl = hostIP + "caveatCaseHistoryWebService.php";
        //web service call to get data for view business screen
        callToWebService(caveatCaseHistoryWebServiceUrl, caveatHistoryData, caveatHistoryResult);
        function caveatHistoryResult(data){
            myApp.hidePleaseWait();
            var data = JSON.stringify(data.caveathistory);
            data = data.replace(/"/g, "");
            backButtonHistory.push("casehistory");
            var strheader = '<div class="row page-header-title" style="position:fixed;top:0;left:0;right:0;z-index:996;height:38px"><div class="col-12 "><h4 style="font-size: 1.2rem;padding-top: 5px;" class="">eCourts Services</h4></div></div>';
            strheader+='<div class="row container1" id="second_header3" style="background:#fff; border-bottom: 1px solid gray;position:fixed;top:0;left:0;right:0;z-index:996;margin-top:38px;"><div class="col-6 text-left"><h4 style="font-size:30px;cursor:pointer;margin-left:10px;margin:5px;"><a href="#" class="text-white" id="go_back_link_3" data-rel="back" onclick="goBackLinkClicked();return false;"><img src="images/back-icon.png" height="40"></a></h4></div></div>';
            data = strheader + data;                
            $("#caseHistoryModal_hc").show();
            $("#historyData_hc").html(data);
            $("#historyData_hc").css("margin-top", "100px");
            $("#caseHistoryModal_hc").modal();
         }
    }

//fetch case types from web service or session storage for 'High Court' Caveat Search...
    function populateCaseTypesHC() {
        $('#case_type_hc').empty();
        $('#case_type_hc').append('<option id="" value="">Select Case Type</option>');
        $('#spl_behav_case_type').empty();
        $('#spl_behav_case_type').append('<option id="" value="">Select Case Type</option>');
        if (window.localStorage.SESSION_COURT_CODE == null) {
            return false;
        }
        var state_code_data = window.localStorage.state_code;
        var district_code_data = window.localStorage.district_code;
        var caseTypeWebServiceUrl = hostIP + "caseTypeCaveat_hc.php"; 
        var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
        court_code_data = courtCodesArr[0];
        var caseTypedata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data)};
        myApp.showPleaseWait();
        //web service call to fetch case types for selected case complex
        callToWebService(caseTypeWebServiceUrl, caseTypedata, caveatCaseTypesResult);
        function caveatCaseTypesResult(result){
            var decodedResult = (result.CourtCodeHC);
            $.each(decodedResult, function (key, val) {                        
                $('#case_type_hc').append('<option id="" value="' + val.case_code + '">' +val.type_name + '</option>');
                $('#spl_behav_case_type').append('<option id="" value="' + val.case_code + '">' +val.type_name + '</option>');
            });
            myApp.hidePleaseWait();
        }
    }


function getCaveatCount()
{
    var state_code_data = window.localStorage.state_code;
    var district_code_data = window.localStorage.district_code;
    var caveatCountWebServiceUrl = hostIP + "caveatCount.php";  
    var courtCodesArr = window.localStorage.SESSION_COURT_CODE.split(",");
    court_code_data = courtCodesArr[0];
    var caveatCountdata = {state_code:(state_code_data), dist_code:(district_code_data), court_code:(court_code_data)};

    callToWebService(caveatCountWebServiceUrl, caveatCountdata, caveatCountResult);
    function caveatCountResult(result){
        if(result.caveatCount != null){
            var decodedResult = (result.caveatCount);
            cavt_cnt_spl_behaviour = decodedResult;
            if(cavt_cnt_spl_behaviour>0)
                {
                    populateCaseTypesHC();                        
                    document.getElementById("spl_behaviour_case_type").style.display = "block";
                }
            else{
                document.getElementById("spl_behaviour_case_type").style.display = "none";
            }
        }        
        myApp.hidePleaseWait();
    }
}

function resetSearchType(){
    $("#select_search_type").val(""); 
      document.getElementById('select_search_type').value = 'Anywhere';
      $("#select_search_type").trigger("change"); 
}

function resetSearchOnComplexChange(){
    $("#caveator_name").val(""); 
    $("#caveatee_name").val("");
    $("#caveator_caveatee_name").val("");
    $("#case_number").val("");
    $("#case_year").val("");
    $("#caveat_number").val("");
    $("#caveat_year").val("");
    $("#case_ref_number_input").val("");
    
    //high court fields.
    $("#hc_case_number").val("");
    $("#hc_case_year").val("");
    $("#hc_cc_aplied_date").val("");
    $("#hc_cc_ready_date").val("");
    $("#hc_order_date").val("");
    
     state_selected = '';
    //Reset state to empty...
    document.getElementById('select_state').value = '';
    
    district_selected = '';
    //Reset district to empty...
    $("#select_district").empty();
    var select2 = document.getElementById("select_district");
    var el = document.createElement("option");
    el.textContent = "Select District";
    el.value = '';
    el.selected = true;
    select2.appendChild(el); 
    
    //Reset select_district_1 to empty...
    document.getElementById('select_district_1').value = '';
   
    //Reset subordinate court name to empty...
    $("#subordinate_court_name").empty();
    var select3 = document.getElementById("subordinate_court_name");
    var el = document.createElement("option");
    el.textContent = "Select Subordinate Court Name";
    el.value = '';
    el.selected = true;
    select3.appendChild(el);

    //Reset case type to empty...
    document.getElementById('case_type').value = '';
    
    //Reset HC case type to empty...
   document.getElementById('case_type_hc').value = '';
     $("#headers").empty();
     $("#accordion_search").empty();
     $("#totalEstablishments").empty();

    //set Todays Date default...
    var now = new Date();
    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);
    var today = (day) + "-" + (month) + "-" + now.getFullYear();
    $('#pickyDate').val(today);
    $('#orderDate').val(today);

    $("#headers").empty();
    $("#accordion_search").empty();
    $("#totalEstablishments").empty();
}

function go_back_link_searchPage_fun_hc(){    
    backButtonHistory.pop(); 
    window.sessionStorage.removeItem("SET_RESULT");
    $("#searchPageModal").modal('hide');
}
function goBackLinkClicked(){
    backButtonHistory.pop();
    $("#caveatDetailsHeader").focus();
    window.sessionStorage.removeItem("case_history");
    $("#caseHistoryModal_hc").modal('hide'); 
}

function go_back_link_history_fun_hc(){        
    backButtonHistory.pop();
    $("#caveatDetailsHeader").focus();
    window.sessionStorage.removeItem("case_history");
    $("#caseHistoryModal_hc").modal('hide');  

}

$("#menubarClose").click(function (e)
{
    if ($("#mySidenav1").is(':visible'))
    {
        closeNav1();
    }
});