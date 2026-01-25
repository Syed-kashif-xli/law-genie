
// var calendar_response = '{"holiday":["09,13,2018,Shriganesh Chaturthi","09,16,2018,Sunday Mahalaxmi","09,17,2018,Marathwada Mukti Sangram Day","09,20,2018,Moharam","09,22,2018,IV th Saturady","09,23,2018,Sunday Anant Chaturdashi","09,30,2018,Sunday","10,02,2018,Mahatma Gandhi Jayanti","10,07,2018,Sunday","10,13,2018,II nd Saturday","10,14,2018,Sunday","10,18,2018,Dasara","10,21,2018,Sunday","10,27,2018,IV th Saturady","10,28,2018,Sunday","11,04,2018,Sunday","11,05,2018,Dipawali","11,06,2018,Dipawali","11,07,2018,Dipawali","11,08,2018,Dipawali","11,09,2018,Dipawali","11,10,2018,II nd Saturday Dipawali","11,11,2018,Sunday","11,18,2018,Sunday","11,20,2018,Eid A Milad","11,24,2018,IV th Saturady","11,25,2018,Sunday","12,02,2018,Sunday","12,08,2018,II nd Saturday","12,09,2018,Sunday"],"count":{"2018-10-11":"6\/3","2018-10-12":"2\/8","2018-10-15":"1\/0","2018-10-16":"3\/5","2018-10-17":"0\/1","2018-10-19":"1\/2","2018-10-20":"2\/0","2018-10-22":"2\/0","2018-10-23":"1\/0","2018-10-24":"0\/1","2018-10-25":"0\/1","2018-10-26":"0\/1","2018-11-13":"0\/7"},"msg":"","status":"Y"}';

var dynamicCSSRules;
$(document).on("refreshCasesCount", function(){
    refreshCaseCount();
});

// if(typeof(calendar_response) != undefined && calendar_response !== null)
// {
//     var holidays = (JSON.parse(calendar_response)).holiday;
//     var cases_count = (JSON.parse(calendar_response)).count;
// }

savedMyCasesCount = [];

$(document).ready(function () {       
       
        // $("#civil_btn").click(function(){
        //      $("#cases_civil").show();
        //     $("#civil_btn").css("color","red");
        //      $("#crim_btn").css("color","white");
        //     $("#cases_crim").hide();
        //        $("#cases_crim").css("display","none");
            
        //  });
        // $("#crim_btn").click(function(){
        //       $("#cases_crim").show();
        //      $("#cases_civil").hide();
        //     $("#civil_btn").css("color","white");
        //      $("#crim_btn").css("color","red");
        //       $("#cases_civil").css("display","none");
            
        //  });
        
    showDatePicker();
             
    });

function refreshCaseCount(){
    
    var myCasesCount = getCalendarCountArr();
    //savedMyCasesCount = myCasesCount;
    //  if(myCasesCount){
        updateDatePickerCells(myCasesCount);
     
    // }else if(savedMyCasesCount){
    //     updateDatePickerCells(savedMyCasesCount);
    // }
}


var holiday_name = "";



function showDatePicker(){
    var holiday_dt_name_arr = [];
    $(".datepicker").datepicker("destroy");

    var date = new Date();

    $(".datepicker").datepicker({
    //beforeShow: updateDatePickerCells(cases_count),    

     beforeShowDay: function(date) {
         
        //  $(".ui-datepicker-calendar a.ui-state-default").css("background","red");
        /*date.getDate() % 3 == 0 ? 'highlight' : ''; // highlight every third day

        
            var casesondate = cases_on_day();  
            for (i = 0; i < casesondate.length; i++) {
                if (date.getMonth() == casesondate[i][0] - 1 &&
                date.getDate() == casesondate[i][1] &&
                date.getFullYear() == casesondate[i][2]) {
                	
                	addCSSRule('.ui-datepicker td a.::after {"criminal"}');
                    return [true,'crim'];
                }
            }*/

            return [true,'weekday'];
        },
    //onChangeMonthYear: updateDatePickerCells,
    onChangeMonthYear: updatepicker,
    onSelect: updateDatePickerCellss
//    minDate: -30,
//	maxDate: +90,
  });
 
 // updateDatePickerCells();
} 




function updateDatePickerCellss(date)
{  
    updatepicker();	
    sessionStorage.setItem("tab", "#Tab4");
    
    var tab = sessionStorage.getItem("tab");
    if (tab) {
        $('.nav-tabs a[href="' + tab + '"]').tab('show');               
    }
    
    /*let dtarr = date.toString().split("/");
    let newDt = dtarr[1]+"-"+dtarr[0]+"-"+dtarr[2];*/
    
    var dtarr = date.toString().split("/");
    var newDt = dtarr[1]+"-"+dtarr[0]+"-"+dtarr[2];
    var dateVal = newDt;
    dateText = dateVal;
    var cnrNumbersLocalStorage = (localStorage.getItem("SELECTED_COURT")==="DC") ? localStorage.getItem("CNR Numbers") : localStorage.getItem("CNR Numbers HC");
    if(cnrNumbersLocalStorage != null){
        var cnrNumbersArray = JSON.parse(cnrNumbersLocalStorage);
        updateSelectedDateCinosArray(cnrNumbersArray);
       if(($("#todaysCasesBtn").hasClass("active"))){      
           if(localStorage.getItem("SELECTED_COURT")==="DC")
            {
                updateTodaysCasesAcordion(JSON.parse(window.localStorage.TODAYS_SAVED_CASES));
            }else{
                updateTodaysCasesAcordion(JSON.parse(window.localStorage.TODAYS_SAVED_CASES_HC));

            }
        }else{
            updateAllCasesAcordion();
        }
    }
    //$( document ).trigger("calenderCaseClicked",newDt);
}

function updatepicker()
{
    refreshCaseCount();
}
function updateDatePickerCells(cellContents)
{
    setTimeout(function () {
	///////////////////////////////////////////
    
    /* Wait until current callstack is finished so the datepicker
       is fully rendered before attempting to modify contents */
    

            
        //Select disabled days (span) for proper indexing but // apply the rule only to enabled days(a)
        $('.ui-datepicker td > *').each(function (idx, elem) {
            
            var month = $(this).parent().attr("data-month");
            
            var year = $(this).parent().attr("data-year");
            var day = $(this).text();
            
            month = parseInt(month)+1; 
            if(month < 10){
                month = "0" + month;
            }
            if(day < 10){
                day = "0" + day;
            }            
            var date = day +'-'+month+'-'+year;
            // var value = cellContents[date] || 0;
            var value=cellContents?cellContents[date]:"0";            
            if(value && value != "0")
               {               
                    var className = 'datepicker-content-'+value.toString();
                    val=value;
                    addCSSRule('.ui-datepicker td a.' + className + ':after {content: "' + val+ '";color:white;margin-left:9px;font-size: 10px;font-weight: bold;background:#01a1d3;border:none;height:15px;border-radius:2px;}');
                    $(this).addClass(className);
                }else{                    
                    var className = 'datepicker-content-1';
                    $(this).removeClass(className);
                }            
        });
     },200);
  

    //////////////////////////////////////////
	
	
}



/*
function cases_on_day()
{
    var cases= [[12, 1, 2018],[12, 26, 2017],[12, 28, 2017],[12, 20, 2017], [1, 15, 2018],[1, 29, 2018],[12, 12, 2017]]; //here get your list of cases date
    return cases;
}*/

function addCSSRule(rule) {
    if ($.inArray(rule, dynamicCSSRules) == -1) {
        $('head').append('<style>' + rule + '</style>');
        //dynamicCSSRules.push(rule);
    }
}





 


