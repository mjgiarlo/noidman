// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Add fields dynamically to the create form

function addURL() {
 var field = "pid";
 var area = "urls";

 var field_area = document.getElementById(area);
 var all_inputs = field_area.getElementsByTagName("input"); //Get all the input fields in the given area.

 // Find the count of the last element of the list. It will be in the format '<field><number>'. If the 
 //   field given in the argument is 'friend_' the last id will be 'friend_4'.
 var last_item = all_inputs.length - 1;
 var last = all_inputs[last_item].id;
 var count = Number(last.split("_")[1]) + 1;
 
 if(document.createElement) { // W3C Dom method.
  var li = document.createElement("li");
  var input = document.createElement("input");
  input.setAttribute("onfocus", "addURL();");
  input.setAttribute("class", "text");
  input.id = field + "_" + count;
  input.name = field + "[" + count + "]";
  input.type = "text"; 
  li.appendChild(input);
  field_area.appendChild(li);
 } else { //Older Method
  field_area.innerHTML += "  <li><input name='"+(field+"_"+count)+"' id='"+(field+"["+count+"]")+"' type='text' onfocus='addURL();'/></li>\n";
 }
}