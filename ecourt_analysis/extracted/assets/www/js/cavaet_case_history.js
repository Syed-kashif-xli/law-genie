
$(document).ready(function () {        
    backButtonHistory.push("caveatHistory");
    $("#header_srchpage1").load("case_history_header.html", function (response, status, xhr) {
        $('#go_back_link_3').on('click', function (event) {               
            backButtonHistory.pop();
            $("#header_id").focus();
            window.sessionStorage.removeItem("case_history");
            $("#caseHistoryModal").modal('hide');  
        });
        $("#open_close3").on('click', function (event) 
        {
            if ($("#mySidenav3").is(':visible'))
            {
                closeNav3();
            } else
            {
                openNav3();
            }
        });
    });
    /******end******/


    //get Caveat history data from session storage
    var retrievedObject = window.sessionStorage.getItem('case_history');
    var caveatHistory = JSON.parse(retrievedObject);
    if (caveatHistory != null) {            
        $('#brTrialCourt').hide();
        $('#trialCourtDetailsId').hide();
        $('#brqjCourt').hide();
        $('#qjDetailsId').hide();
        $('#brhighCourt').hide();
        $('#highCourtDetailsId').hide();

        /**************caveatorCaveateeDetails******************/
        var  caveatorCaveateeTable = caveatHistory.caveatorCaveateeDetails;
        if (caveatorCaveateeTable != null) {
            $("#casedetails").append(caveatorCaveateeTable);
        } 

        /**************caveatorDetails******************/
        var  caveatorDetailsTable = caveatHistory.caveatorDetails;
        if (caveatorDetailsTable != null) {
            $('#brCaveatorDetailsId').show();
            $('#divCaveatorDetailsId').show();
            $("#caveatorDetailsId").append(caveatorDetailsTable);
        }else{
            $('#brCaveatorDetailsId').hide();
            $('#divCaveatorDetailsId').hide();
        }
        
        /**************caveatorPartyDetails******************/
        var  caveatorPartyDetailsTable = caveatHistory.caveatorPartyDetails;
        if (caveatorPartyDetailsTable != null) {
            $('#brExtraPartyCaveator').show();
            $('#divExtraPartyCaveator').show();
            $("#extraPartyCaveatorId").append(caveatorPartyDetailsTable);
        }else{
            $('#brExtraPartyCaveator').hide();
            $('#divExtraPartyCaveator').hide();
        } 
        /**************caveateeDetails******************/
        var  caveateeDetailsTable = caveatHistory.caveateeDetails;
        if (caveateeDetailsTable != null) {
            $('#brCaveateeDetailsId').show();
            $('#divCaveateeDetailsId').show();
            $("#caveateeDetailsId").append(caveateeDetailsTable);
        } else{
            $('#brCaveateeDetailsId').hide();
            $('#divCaveateeDetailsId').hide();
        }
        
        /**************ExtraCaveateeParty******************/
        var  ExtraCaveateePartyTable = caveatHistory.ExtraCaveateeParty;
        if (ExtraCaveateePartyTable != null) {
            $('#brExtraPartyCaveatee').show();
            $('#divExtraPartyCaveatee').show();
            $("#extraPartyCaveateeId").append(ExtraCaveateePartyTable);
        } else{
            $('#brExtraPartyCaveatee').hide();
            $('#divExtraPartyCaveatee').hide();
        }
        
        /**************subordinateCourtDetails******************/
        var  subordinateCourtDetailsTable = caveatHistory.subordinateCourtDetails;
        if (subordinateCourtDetailsTable != null) {
            $('#subordinateCourtInfoId').show();
            $('#brSubordinate').show();
            
            $("#subordinateCourtInfo").append(subordinateCourtDetailsTable);
        } else{
            $('#subordinateCourtInfoId').hide();
            $('#brSubordinate').hide();
        }             
    }else{
        $("#cavaethistoryContainer").hide();
        var caseno = getParameterByName('caseno');
        $("#errorOpnening").show();
        document.getElementById("errMsg").innerHTML = "Error opening case history for case number: <br/> "+caseno;
    }
    $("#footer").load("footer.html");
});

function go_back_link_caveat_fun(){    
    backButtonHistory.pop();
    $("#header_id").focus();
    window.sessionStorage.removeItem("case_history");
    $("#caseHistoryModal").modal('hide');     
}
