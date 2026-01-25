var selected_state_code = window.localStorage.state_code;
var selected_district_code = window.localStorage.district_code;
var selected_court_code = window.localStorage.SESSION_COURT_CODE;
var selected_complex_code = window.localStorage.SESSION_SELECTED_COMPLEX_CODE;

var stateSelectLabel = "Select State";
var districtSelectLabel = "Select District";
var courtComplexSelectLabel = "Select Court Complex";
var courtComplexLabel = "Court Complex";


var map_bilingual_flag = bilingual_flag;
var map_state_language = [];

//labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;

/*if(labelsarr){
	stateSelectLabel = labelsarr[106];
	districtSelectLabel = labelsarr[107];
	courtComplexSelectLabel = labelsarr[268];
	courtComplexLabel = labelsarr[269];
	$("#courtComplexLabelId").html(courtComplexLabel);
}

if(labelsarr){
	$("#court_complex_location_label1").html(labelsarr[269]);
	$("#court_complex_location_label2").html(labelsarr[573]);
	stateSelectLabel = labelsarr[106];
	districtSelectLabel = labelsarr[107];
	courtComplexSelectLabel = labelsarr[268];
	courtComplexLabel = labelsarr[269];
	$("#courtComplexLabelId").html(courtComplexLabel);
}
*/
var lat = "";
var lon = "";
var court_complex_name = "";

var setResult = false;
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady(){
	if(device.platform.toLowerCase() === "ios"){       
		//$('#mapFrame').hide();
	}
	localizeLabels();
	/*if(labelsarr){            
			stateSelectLabel = labelsarr[106];
			districtSelectLabel = labelsarr[107];
			courtComplexSelectLabel = labelsarr[268];
			courtComplexLabel = labelsarr[269];
		}*/

	navigation_link = window.sessionStorage.navigation_link;//getParameterByName('navigation_link');

	if(navigation_link == 'case_history.html'){
		
		window.sessionStorage.removeItem('navigation_link');
		selected_state_code = window.sessionStorage.getItem('state_code');		
		selected_district_code = window.sessionStorage.getItem('dist_code');
		selected_court_code = window.sessionStorage.getItem('court_code');
		selected_complex_code = window.sessionStorage.getItem('complex_code');

		// window.sessionStorage.removeItem("state_code");
		// window.sessionStorage.removeItem("dist_code");
		// window.sessionStorage.removeItem("court_code");
		// window.sessionStorage.removeItem("complex_code");

		getStatesData();


		window.sessionStorage.removeItem("state_code");
		window.sessionStorage.removeItem("dist_code");
		window.sessionStorage.removeItem("court_code");
		window.sessionStorage.removeItem("complex_code");

	}else{
		
		if(window.sessionStorage.SESSION_STATES != null){
			var obj = (window.sessionStorage.SESSION_STATES);
			var obj1= JSON.parse(obj);
			populateMapStates(obj1); 
		}else{
			getStatesData();
		}

	}
	
	if(selected_state_code != null && selected_district_code != null && selected_court_code != null && selected_complex_code != null){
		if(selected_state_code != "" && selected_district_code != "" && selected_court_code != "" && selected_complex_code != ""){
			$("#get_map_btn").click();
			
		}
	}
}

$(document).ready(function () {

	backButtonHistory.push("map");

	$("#headerMap").load("header_map.html", function (response, status, xhr) {
		// $("#second_header").css('display', 'block');
		// var backlink = window.sessionStorage.SESSION_BACKLINK;
		$('#go_back_link_map').on('click', function (event) {
			backButtonHistory.pop();
			$("#mapModal").modal('hide');  
			// $("#header_srchpage").remove();              
		});

		$("#open_close_map").on('click', function (event) 
		{
			if ($("#mySidenav_map").is(':visible'))
			{
				closeNav_map();
			} else
			{
				openNav_map();
			}
		});
	});

});


$("#mapData").click(function ()
{
	if ($("#mySidenav_map").is(':visible'))
	{
		document.getElementById("mySidenav_map").style.display = "none";
	} 
});


function getStatesData(){
	var statesUrl = hostIP + "stateWebService.php";
	var encrypted_data1 = ("fillState");
	var stateData = {action_code: encrypted_data1.toString()};

	callToWebService(statesUrl, stateData, stateWebServiceResult);
	function stateWebServiceResult(data){
		myApp.hidePleaseWait();
		var obj = (data.states);
		populateMapStates(obj);
	}		
	//DO NOT REMOVE...
	/*.fail(function (result, status) {

		var select = document.getElementById("map_state_code");
		var el = document.createElement("option");
		el.textContent = stateSelectLabel;
		el.value = '';
		el.selected = true;
		select.appendChild(el);
	})*/
}


function getDistrictsData() {
	var districtsUrl = hostIP + "districtWebService.php";
	$("#map_dist_code").empty();
	var state_code_value = $("#map_state_code").val();
	var data = {state_code:(state_code_value)};   
	//web service call to get districts
	callToWebService(districtsUrl, data, districtWebServiceResult);
	function districtWebServiceResult(data){
        myApp.hidePleaseWait();
		var obj = (data.districts);
		populateMapDistricts(obj);

	}
	//DO NOT REMOVE...
	/*.fail(function (result, status) {
		var select = document.getElementById("map_dist_code");
		var el = document.createElement("option");
		el.textContent = districtSelectLabel;
		el.value = '';
		el.selected = true;
		select.appendChild(el);
		})*/

}


//populates state select box  
function populateMapStates(obj){
	var getDistricts = false;
	var items = [];
	items.push("<option value=''>"+stateSelectLabel+"</option>");
		if(obj){

            $.each(obj, function (key, val) {
                var statecd = val.state_code;
                var lang = val.state_lang;
                map_state_language[statecd] = lang;                
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
    
	/*var lang = null;
	var obj1 = null;

	var showEnglishLabels = true;

	if(localStorage.LANGUAGE_FLAG){
		if(localStorage.LANGUAGE_FLAG != "english"){
			lang = localStorage.LANGUAGE_FLAG;
			obj1 = obj.filter(function(element){
			   return  (element.state_lang == lang);
			});
			$.each(obj1, function (key, val) {
				items.push('<option id="' + val.state_code + '" value="' + val.state_code + '">' + val.marstate_name + '</option>');
			});
			showEnglishLabels = false;
		}
	}


	if(showEnglishLabels){
		$.each(obj, function (key, val) {
			items.push('<option id="' + val.state_code + '" value="' + val.state_code + '">' + val.state_name + '</option>');
		});
	}*/

	$("#map_state_code").html(items.join(""));

	if (selected_state_code != null && selected_state_code != "") {
		document.getElementById('map_state_code').value = selected_state_code;
		map_bilingual_flag = 0;
		
		if(map_state_language[selected_state_code] == localStorage.LANGUAGE_FLAG){
			map_bilingual_flag = 1;
		}
		getDistrictsData();
	} else {
		document.getElementById('map_state_code').value = '';
		$( "#map_dist_code option:selected" ).text(districtSelectLabel);
		$( "#map_court_code option:selected" ).text(courtComplexSelectLabel);
	}
}

//populate districts select box
function populateMapDistricts(obj){
    var items = [];
    items.push("<option value=''>"+districtSelectLabel+"</option>");
    if(obj){
        // $.each(obj, function (key, val) {
		// 	console.log(val.mardist_name);
        //     items.push('<option id="' + val.dist_code + '" value="' + val.dist_code + '">' + val.dist_name + '</option>');
        // });
			var showEnglishLabels = true;
            // if(localStorage.LANGUAGE_FLAG){
                // if(localStorage.LANGUAGE_FLAG != "english"){
                if(map_bilingual_flag == 1){
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
		
	/*
	var showEnglishLabels = true;

	if(localStorage.LANGUAGE_FLAG){
		if(localStorage.LANGUAGE_FLAG != "english"){
			$.each(obj, function (key, val) {
				if(val.mardist_name!=""){
					items.push('<option id="' + val.dist_code + '" value="' + val.dist_code + '">' + val.mardist_name + '</option>');
				}
			});
			showEnglishLabels = false;
		}
	}

	if(showEnglishLabels){
		$.each(obj, function (key, val) {
				items.push('<option id="' + val.dist_code + '" value="' + val.dist_code + '">' + val.dist_name + '</option>');
			});
	}*/

	$("#map_dist_code").html(items.join(""));
	if (selected_district_code != null && selected_district_code != "") {
		document.getElementById('map_dist_code').value = selected_district_code;
		populateMapCourtComplexes();
	}else{
		document.getElementById('map_dist_code').value = '';
		$( "#map_court_code option:selected" ).text(courtComplexSelectLabel);
	}
}

//Fetches court complexes data from web service
function populateMapCourtComplexes() {
	$select = $('#map_court_code');
	var courtComplexWebServiceUrl = hostIP + "courtEstWebService.php";        

	var encrypted_data1 = ("fillCourtComplex");
	var encrypted_data2 = (selected_state_code);
	var encrypted_data3 = (selected_district_code);

	var data = {action_code: encrypted_data1.toString(), state_code: encrypted_data2.toString(), dist_code: encrypted_data3.toString()};

	//web service call to get court complexes
	callToWebService(courtComplexWebServiceUrl, data, courtcomplexesResult);
	function courtcomplexesResult(data){
	    myApp.hidePleaseWait();
		var obj = (data.courtComplex);		
		if(obj != null){  
			populateMapComplexes(obj);            
		}else{
			$select.append('<option id="" value="">'+courtComplexSelectLabel+'</option>');
		}
	}
}

//Fills court complex select box
function populateMapComplexes(obj){
	$select = $('#map_court_code');
	$select.empty();
	$select.append('<option id="" value="">'+courtComplexSelectLabel+'</option>');
	//var txt_court_complex_name=null;
	$.each(obj, function (key, val) {
		/* if(localStorage.LANGUAGE_FLAG=="english"){
			txt_court_complex_name = val.court_complex_name;
		 }else{
			txt_court_complex_name = val.lcourt_complex_name;
		}*/
		if(map_bilingual_flag == 0){
            var txt_court_complex_name = val.court_complex_name;
		}else{
			var txt_court_complex_name = val.lcourt_complex_name;
		}
		$select.append('<option id="' + val.njdg_est_code + '" value="' + val.njdg_est_code + '" complex_code="' + val.complex_code + '">' + txt_court_complex_name + '</option>');
	});
	if (selected_court_code != "") {

		if(selected_complex_code != ""){
			$('[name=map_court_code] option').filter(function() { 
				return ($(this).attr('complex_code') == selected_complex_code); 
			}).prop('selected', true);
		}else{
			document.getElementById('map_court_code').val(selected_court_code);
		}


	}
}


$("#map_state_code").change(function () {
	setResult = false;
//    $("#mapdiv").empty();
   // $('#mapFrame').attr('src', "");

	selected_district_code = "";
	selected_court_code = "";
	selected_complex_code = "";

	resetCourtComplexSelectBox();
	selected_state_code = $("#map_state_code").val();
	if(selected_state_code != ""){
		map_bilingual_flag = 0;
		if(map_state_language[selected_state_code] == localStorage.LANGUAGE_FLAG){
			map_bilingual_flag = 1;
		}
		getDistrictsData();
	}else{
		resetDistrictSelectBox();            
	}

});

$("#map_dist_code").change(function () {
	setResult = false;
//    $("#mapdiv").empty();
	//$('#mapFrame').attr('src', "");
	selected_district_code = $("#map_dist_code").val();
	selected_court_code = "";
	selected_complex_code = "";
	if(selected_district_code != ""){
		populateMapCourtComplexes();
	}else{
		resetCourtComplexSelectBox();
	}        
}); 

$("#map_court_code").change(function () {
	setResult = false;
//    $("#mapdiv").empty();
  //  $('#mapFrame').attr('src', "");
	selected_court_code = $("#map_court_code").val(); 
	selected_complex_code = $("#map_court_code option:selected").attr('complex_code');   	
});

function resetDistrictSelectBox(){
	$("#map_dist_code").empty();
	var select = document.getElementById("map_dist_code");    
	var el = document.createElement("option");
	el.textContent = districtSelectLabel;
	el.value = '';
	el.selected = true;
	select.appendChild(el);
}

function resetCourtComplexSelectBox(){
	$("#map_court_code").empty();
	var select = document.getElementById("map_court_code");
	var el = document.createElement("option");
	el.textContent = courtComplexSelectLabel;
	el.value = '';
	el.selected = true;
	select.appendChild(el);
}


function getMap(e){
	
	e.preventDefault();
	if(selected_state_code == ""){ 
		alert("Please select state");
		//alert(labelsarr[52]);
		return;
	}else if(selected_district_code == ""){
		alert("Please select district");
		//alert(labelsarr[49]);
		return;
	}else if(selected_court_code == ""){
		alert(labelsarr[759]);
		//alert(labelsarr[277]);
		return;
	}else{
		
//        if(setResult == false){
			getLatLong();
//        }
	}
}


function getLatLong() {
	var latLongUrl = hostIP + "latlong.php";

	var courtCodesArr = selected_court_code.split(",");
	var court_code_data = courtCodesArr[0];
	var data = {state_code:(selected_state_code), dist_code:(selected_district_code), court_code:(court_code_data), complex_code:(selected_complex_code)};   

	//web service call to get map...
	callToWebService(latLongUrl, data, showMapResult);
	function showMapResult(data){
        myApp.hidePleaseWait();
		var decodedResponse = (data);
		setResult = true;
		if(decodedResponse != null){
			
			lat = decodedResponse.latitude;
			lon = decodedResponse.longitude;
			mapURL = decodedResponse.map_url;
			if(lat != "" && lon != ""){
				//Bhuvan map
				if(device.platform.toLowerCase() == "ios"){
					//navigate to new window                       
					window.location.href = mapURL+"x="+lon+"&y="+lat+"&buff=0";
				}else{                                    
					//iFrame
					// $('#mapFrame').attr('src', mapURL+"x="+lon+"&y="+lat+"&buff=0");
					var ref = cordova.InAppBrowser.open(mapURL+"x="+lon+"&y="+lat+"&buff=0", '_blank', 'location=yes');
					ref.addEventListener('loadstart', function(event) { console.log('Loading started') });
				}

				/*var mymap = L.map('mapFrame');

				var marker = L.marker([19.901054, 75.21]).addTo(mymap);
				marker.bindPopup("DISTRICT & SESSIONS COURT, OLD HIGH COURT BUILDING, ADALAT ROAD, AURANGABAD.").openPopup();



				var marker = L.marker([lat, lon]).addTo($('#mapFrame'));
				marker.bindPopup("DISTRICT & SESSIONS COURT, OLD HIGH COURT BUILDING, ADALAT ROAD, AURANGABAD.").openPopup();*/
//                    window.open('https://bhuvan-web.nrsc.gov.in/web_view/index.php?x="+lon+"&y="+lat+"&buff=0', '_self ', 'location=yes');

				//Openstreet map
				/*court_complex_name = decodedResponse.court_complex;

				map = new OpenLayers.Map("mapdiv");
				map.addLayer(new OpenLayers.Layer.OSM());

				epsg4326 =  new OpenLayers.Projection("EPSG:4326"); //WGS 1984 projection
				projectTo = map.getProjectionObject(); //The map projection (Spherical Mercator)

				var lonLat = new OpenLayers.LonLat( lon ,lat).transform(epsg4326, projectTo);              
				var zoom=14;
				map.setCenter (lonLat, zoom);

				var vectorLayer = new OpenLayers.Layer.Vector("Overlay");
				//First Marker
				var feature = new OpenLayers.Feature.Vector(
					new OpenLayers.Geometry.Point(lon,lat).transform(epsg4326, projectTo),
					{description:court_complex_name} ,
					{externalGraphic: 'images/marker-red.png', graphicHeight: 30, graphicWidth: 20, graphicXOffset:-12, graphicYOffset:-25  }
				);    
				vectorLayer.addFeatures(feature);	

				map.addLayer(vectorLayer);

				//Add a selector control to the vectorLayer with popup functions
				var controls = {
				selector: new OpenLayers.Control.SelectFeature(vectorLayer,
					{ onSelect: createPopup, onUnselect: destroyPopup } 
				)
				};

				map.addControl(controls['selector']);
				controls['selector'].activate();

				//Show Pop-Up
				function createPopup(feature) {
					feature.popup = new OpenLayers.Popup.FramedCloud("pop",
						feature.geometry.getBounds().getCenterLonLat(),
						null,
						'<div class="markerContent">'+feature.attributes.description+'</div>',		
						null,
						true,
						function() { controls['selector'].unselectAll(); }
					);
					//feature.popup.closeOnMove = true;
					map.addPopup(feature.popup);
				}

				//Close Pop -Up
				function destroyPopup(feature) {
					feature.popup.destroy();
					feature.popup = null;		 
				}        

				map.setCenter (lonLat, zoom);*/
			}
		}

	}

}

function localizeLabels(){
    labelsarr = window.sessionStorage.GLOBAL_LABELS != null ? JSON.parse(window.sessionStorage.GLOBAL_LABELS) : null;
    if(labelsarr){
		$("#courtComplexLocationLabel").html(labelsarr[832]);
        $("#courtComplexLabelId").html(labelsarr[269]);
        $("#get_map_btn").html(labelsarr[613]);
		stateSelectLabel = labelsarr[106];
		districtSelectLabel = labelsarr[107];
		courtComplexSelectLabel = labelsarr[277];
		courtComplexLabel = labelsarr[269];		
    }
}

$("#menubarClose_map").click(function ()
{
	if ($("#mySidenav_map").is(':visible'))
	{
		// closeNav();
		document.getElementById("mySidenav_map").style.display = "none";
	} 
});

function go_back_link_map_fun(){        
	backButtonHistory.pop();
	$("#mapModal").modal('hide');    
}