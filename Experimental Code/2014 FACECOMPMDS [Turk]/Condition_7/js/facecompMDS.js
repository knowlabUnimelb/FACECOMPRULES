// CONDITION ONE FOR SPLIT-ALIGNED FACE EXPERIMENTS - INVERTED ALIGNED FACES

//The code is evaluated line by line in order
//
// Generate the list of trials
 function permutate(x) {
    var tempArray = [];
    var c = 0;
     for (i = 0; i < x; i++) {
         for (j = 0; j < x; j ++) {
             if (i !== j) {         
                    tempArray[c] = [i+1, j+1];
                    c++;
             }
         }  
      }
    return(tempArray);
    };    
	
// Fisher Yates Shuffle function
function shuffle ( myArray ) {
  var i = myArray.length, j, tempi, tempj;
  if ( i === 0 ) return false;
  while ( --i ) {
     j = Math.floor( Math.random() * ( i + 1 ) );
     tempi = myArray[i];
     tempj = myArray[j];
     myArray[i] = tempj;
     myArray[j] = tempi;
   }
   return(myArray);
};

// Declare Experimental Variables
var condition
var subjectID
var textID
var stimuli_set;

// There are FIVE face sets in this MDS experiment
var face_set1 = ["blank.bmp", "Set_UA_1.bmp", "Set_UA_2.bmp", "Set_UA_3.bmp", "Set_UA_4.bmp", "Set_UA_5.bmp", "Set_UA_6.bmp", "Set_UA_7.bmp", "Set_UA_8.bmp", "Set_UA_9.bmp"];
var face_set2 = ["blank.bmp", "Set_US_1.bmp", "Set_US_2.bmp", "Set_US_3.bmp", "Set_US_4.bmp", "Set_US_5.bmp", "Set_US_6.bmp", "Set_US_7.bmp", "Set_US_8.bmp", "Set_US_9.bmp"];
var face_set3 = ["blank.bmp", "Set_IA_1.bmp", "Set_IA_2.bmp", "Set_IA_3.bmp", "Set_IA_4.bmp", "Set_IA_5.bmp", "Set_IA_6.bmp", "Set_IA_7.bmp", "Set_IA_8.bmp", "Set_IA_9.bmp"];
var face_set4 = ["blank.bmp", "Set_IS_1.bmp", "Set_IS_2.bmp", "Set_IS_3.bmp", "Set_IS_4.bmp", "Set_IS_5.bmp", "Set_IS_6.bmp", "Set_IS_7.bmp", "Set_IS_8.bmp", "Set_IS_9.bmp"];

var trialCount = 0; // Trial count starts from 0 since JScript indexes from 0
var nstim = 9; // Number of stimuli in the MDS experiment
var nblocks = 3; // Number of blocks
var blockCount = 1; // Start at block 1 (obviously)
var trialOrder = permutate(9); // Create permutations of no. stimuli
var trialOrder = shuffle(trialOrder); // Shuffle the order

var previewOrder = [1, 2, 3, 4, 5, 6, 7, 8, 9];
var previewCount = 0;
var previewOrder = shuffle(previewOrder);

$(document).ready(function() {

	// Hide everything on the first page of the experiment  
   	hideElements(); 
	
	// generate a subject ID by generating a random number between 1 and 1000000
    subjectID = Math.round(Math.random()*1000000);
	textID = subjectID.toString;

    // CONDITION 
    // randomize experimental conditions
    // condition = Math.ceil(Math.random()*5); // generate random number between 1 to 5 to rotate between each face set	
	condition  = 3; 
	console.log(condition);
	
	switch (condition) 
	{
	case 1:
	stimuli_set = face_set1;
	break;
	case 2:
	stimuli_set = face_set2;
	break;
	case 3:
	stimuli_set = face_set3;
	break;
	case 4:
	stimuli_set = face_set4;
	break;
	default:
	console.log('Condition Out of Range');
	}
	console.log(stimuli_set)	
	console.log(previewOrder)
	
	// Brief introduction to the experiment. This is just a test page. It may be removed later.
	$('#warning').show();
	$('#warning').load('html/warning.html?n=1');
		
	// Click on the 'next' button to go to the demographics page.
	$('#next').show();
    $('#next').click(validateWarning); 
});

function validateWarning() {
	// Hide elements and show the form (which is just the checkbox in this case)
		hideElements();
		$('form').show();
	// Note that serializeArray saves the elements of the form into a convenient variable object
		warningCheck = $('form').serializeArray();
		var ok = true;

		$('form').trigger("reset"); // Reset the radio button on the instructions check page
		
	// check for empty answers
		if(warningCheck.length == 0) {
			alert('You need to click on the checkbox to proceed.');
			ok = false;
		};
		if(!ok) {
			// Warning page for participants who might have done the experiment before
			$('#warning').show();
			$('#warning').load('html/warning.html');
			// Click on the 'next' button to acknowledge warning and display Instructions page if ok.
			$('#next').show();
			$('#next').click(validateWarning); 
		}
		else {
			// Move on to Instructions page
			showConsent(); 
		}
} 

function showConsent () {
    hideElements();
	
	$('#introduction').show();
    $('#introduction').load('html/introduction.html');

    $('#next').show();
    $('#next').click(validateConsent)    
}

function validateConsent() {
    hideElements();
    
    $('form').show();
    consentCheck = $('form').serializeArray();

    var ok = true;
    for(var i = 0; i < consentCheck.length; i++) {
        // check for incorrect responses
        if(consentCheck[i].value != "correct") {
            ok = false;
    	    break;
        }

    	// check for empty answers
    	if(consentCheck[i].value == "") {
    	    alert('Please fill out all fields.');
    	    ok = false;
    	    break;
    	}
    }
    
    // where this is the number of questions in the instruction check
    if (consentCheck.length != 1) {
   	    alert('You must consent proceed to the experiment');
        ok = false;
    }
        
	$('form').trigger("reset"); // Reset the radio button on the instructions check page

    if(!ok) {
		// Brief introduction to the experiment. This is just a test page. It may be removed later.
		$('#introduction').show();
		$('#introduction').load('html/introduction.html');
	
		// Click on the 'next' button to go to the demographics page.
		$('#next').show();
  		$('#next').click(validateConsent); 
    }
    else {
		// startPage(); // start experiment
		showDemographics(); // go to a preview section start experiment
    }
}

function showDemographics() {
    hideElements();
    
    // modify here if you want to get different demographic information
    // DEFAULT: subjectID, age, gender, country
    $('#demographics').show();
    $('#demographics').load('html/demographics.html');

    $('#next').show();
    $('#next').click(validateDemographics)    
}

function validateDemographics() {
    demographics = $('form').serializeArray();

    var ok = true;
    var gender_exists = false;
    for(var i = 0; i < demographics.length; i++) {
        // validate age
    	if ((demographics[i].name == "age") & (/[^0-9]/.test(demographics[i].value))) {
    	    alert('Please only use numbers in age.');
    	    ok = false;
    	    break;
    	}
    	else {
    	    // test to only include alphanumeric characters
            if ((demographics[i].name != "country") & (/[^a-zA-Z0-9]/.test(demographics[i].value))) {
        	    alert('Please only use alphanumeric characters.');
        	    ok = false;
        	    break;
        	}
        }

    	// test for empty answers
    	if(demographics[i].value == "") {
    	    alert('Please fill out all fields.');
    	    ok = false;
    	    break;
    	}
    	
    	if(demographics[i].name == "gender") {
    	    gender_exists = true;
    	}
    }
    
    if ((gender_exists == false) && ok){
        alert('Please select a gender.');
	    ok = false;
    }
    
    if(!ok) {
        showDemographics();
    }
    else {
	// remove demographics form
        $('#demographics').html('');
        showInstructions();
    }
}

// displays experiment instructions
function showInstructions() {
    hideElements();

    $('#instructions').show();
  	$('#instructions').load('html/instruction-facecompmds.html');
	// $('#examplefaces').show();	
  	// $('#examplefaces').load('html/examplefaces.jpg');
	
    $('#next').show();
    $('#next').click(showExamplePair);
}

function showExamplePair() {
hideElements();
	$('#instructions').show();
  	$('#instructions').load('html/instruction-examplepage.html');	
	
    $('#next').show();
    $('#next').click(showInstructionChecks);
}

function showInstructionChecks() {
    hideElements();

    $('#instructions').show();
    $('#instructions').text('Here are some questions to check if you have read the instructions correctly. If you answer all the questions correct you will begin the experiment, otherwise you will be redirected to the instructions page again.');

    $('#instruction-checks').show();
    $('#instruction-checks').load('html/instruction-checks.html');
    
    $('#next').show();
    $('#next').click(validateInstructionChecks);
}

function validateInstructionChecks() {
    hideElements();
    
    $('form').show();
    instructionChecks = $('form').serializeArray();

    var ok = true;
    for(var i = 0; i < instructionChecks.length; i++) {
        // check for incorrect responses
        if(instructionChecks[i].value != "correct") {
            ok = false;
    	    break;
        }

    	// check for empty answers
    	if(instructionChecks[i].value == "") {
    	    alert('Please fill out all fields.');
    	    ok = false;
    	    break;
    	}
    }
    
    // where this is the number of questions in the instruction check
    if (instructionChecks.length != 4) {
        ok = false;
    }
        
	$('form').trigger("reset"); // Reset the radio button on the instructions check page

    if(!ok) {
        showInstructions(); // go back to instruction screen
    }
    else {
		// startPage(); // start experiment
		previewPage(); // go to a preview section start experiment
    }
}

function previewPage () {
	hideElements();
	
	$('#start_page').show();
	$('#start_page').load('html/preview_page.html');
	
	$('#next').show();
    $('#next').click(previewPhase);
}

function previewPhase () {
	hideElements();
	
	if (previewCount === 0) {
	previewImage(previewCount) // no intervals on the first trial. 
	} else {
	setTimeout("previewImage(previewCount)",500); //This provides the inter-trial interval
	}
	
	console.log(previewOrder)
}

function previewImage (count) {
	hideElements()
	
	var pImage = ("stimuli/"+stimuli_set[previewOrder[count]]);
 	document.images.preview_image.src = pImage;
	$('#preview_image').show();
	
	setTimeout("advancePreview()",1000);
	// $('#next').show();
    // $('#next').click(advancePreview)	
}

function advancePreview () {
	
	// hideElements();			
	previewCount++ 	
	
	if (previewCount < previewOrder.length) {	
	// setTimeout("previewImage(previewCount)",500);
	// previewImage(previewCount);
	// $('#next').click(previewImage(previewCount))	
	$('#next').show();
    $('#next').click(previewPhase)
	} else {	
	// $('#next').click(startPage)
	$('#next').show();
    $('#next').click(startPage)
	}
}

function startPage () {
	hideElements();
		console.log(stimuli_set)

	$('#start_page').show();
	$('#start_page').load('html/start_page.html');
	
	$('#next').show();
    $('#next').click(trainingPhase);
}

function trainingPhase() {
	hideElements ();	

	if (trialCount === 0) {
	showImage(trialCount) // no intervals on the first trial. 
	} else {
	setTimeout("showImage(trialCount)",500); //This provides the inter-trial interval
	}
		
}

function showImage (row) {

	$('#instruction-train').show();
	$('#instruction-train').load('html/instruction-train.html');

	var image1 = ("stimuli/"+stimuli_set[trialOrder[row][0]]);
	var image2 = ("stimuli/"+stimuli_set[trialOrder[row][1]]);

	document.images.left_image.src = image1;
	document.images.right_image.src = image2;	
	
	$('#left_image').show();
	$('#right_image').show();
	
	setTimeout("advanceTrial()",500);
}

function advanceTrial() {
	// hideElements()
	$('#training-scale').show();
	$('#training-scale').load('html/training-scale.html');
	
	$('#next').show();
    $('#next').click(validateResponse);		
}

function validateResponse() {	
	$('form').show();    
	var responseCheck = $('form').serializeArray();
			
	var ok = true;
	
	// check for empty answers	
	if (responseCheck.length != 1) {
	    alert('Please make a response.');
    	ok = false;
	}	
	
	if (ok) {
	
	var exp_data = {};
    
    // add demographics data to trial output
    for (i = 0; i < demographics.length; i++) {
        exp_data[demographics[i].name] = demographics[i].value;
    }
    //  exp_data["age"] = parseInt(exp_data["age"]);
    
    // add trial data to trial output
    exp_data["subjectID"] = subjectID;
    exp_data["condition"] = condition;
	exp_data["block"]     = blockCount;
	exp_data["trialCount"] = trialCount + 1;        
	exp_data["image1"] = trialOrder[trialCount][0]; 
	exp_data["image2"] = trialOrder[trialCount][1];
    exp_data["response"] = responseCheck[0].value; 
    // exp_data["rt"] = rt;
    exp_data["experiment"] = "FACE_COMP_MDS_con7";
    exp_data["consent"] = consentCheck[0].value;
	// SLIDER
    // exp_data["slider_value"] = $('#slider').slider('value');
    
    console.log(exp_data);

    // save trial data
    saveData([[exp_data]]);

	// determine which section to go to next		
    trialCount++
	if (trialCount < trialOrder.length) {
		trainingPhase();
	} else {
		nextBlock();
	}	
	}	
}

function nextBlock() {
	blockCount++;	
	hideElements ();

	if (blockCount <= nblocks) {	
	
	trialCount = 0; // trialcount needs to start/restart at 0 since JScript indexes from 0 
	
	trialOrder = shuffle(trialOrder);

	$('#instruction-block').show();
	$('#instruction-block').load('html/instruction-block.html');
	
	$('#next').show();
    $('#next').click(trainingPhase);
	
	} else {
		
		endExp();	
		
	};	
}

function endExp(){
	hideElements();
    $('#instruction-finish').show();
	$('#instruction-finish').load('html/instruction-finish.html');
	$(".code").append(  subjectID );
	console.log(subjectID)
}

// save experiment data with AJAX
function saveData(args) {
    var data = args;
    $.ajax({
	type: 'post',
	cache: false,
	url: 'submit_data_mysql.php', // name of the file that inserts data into MySQL database
	data: {"table": "facecomp_con7", "json": JSON.stringify(data)}, // Table refers to the name of the table in the db
	success: function(data) { console.log(data); }
    });
}

// Save experiment data to a text file on the server
function savetoText(args) {
var data = args;

	$.post("textwrite.php", {
	'data': JSON.stringify(data)
	})
	
}

// Custom function to hide all elements on the page
function hideElements() {
   
    // hides the canvas drawing
    $('#drawing').hide();

    // hides all divs
    $('div').hide();

    // hides all buttons
    $(':button').hide();
    
    // unbinds all buttons
    $(':button').unbind();
	
	hideImage()
}

// Custom function to hide the left and right images on the screen
function hideImage () {
	// hide images
	$('#left_image').hide();
	$('#right_image').hide();	
	$('#examplefaces').hide();	
	$('#preview_image').hide();	
}