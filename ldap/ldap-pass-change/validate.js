/* Following reg expression match only alphanumeric characters and spaces 
 * \w Finds a word character (a-z,A-Z,0-9 ,_)
 * \w+ matches string that contents atleast one word
 * ^\w+ matches anything that begins with a word
 * ^\w+$ matches anything that end with a word.
*/
function checkForm()
  {
    if(form.uname.value == "") {
      alert("Error: Username cannot be left  blank!");
      form.uname.focus();
      return false;
    }
    re = /^\w+$/;
    if(!re.test(form.uname.value)) {
      alert("Error: Username must contain only letters, numbers and underscores!");
      form.uname.focus();
      return false;
    }

    if(form.newpass.value != "" && form.newpass.value == form.newpass1.value) {
      if(form.newpass.value.length < 6) {
        alert("Error: Password must contain at least six characters!");
        form.newpass.focus();
        return false;
      }
      if(form.newpass.value == form.uname.value) {
        alert("Error: Password must be different from Username!");
        form.newpass.focus();
        return false;
      }
      re = /[0-9]/;
      if(!re.test(form.newpass.value)) {
        alert("Error: password must contain at least one number (0-9)!");
        form.newpass.focus();
        return false;
      }
      re = /[a-z]/;
      if(!re.test(form.newpass.value)) {
        alert("Error: password must contain at least one lowercase letter (a-z)!");
        form.newpass.focus();
        return false;
      }
      re = /[A-Z]/;
      if(!re.test(form.newpass.value)) {
        alert("Error: password must contain at least one uppercase letter (A-Z)!");
        form.newpass.focus();
        return false;
      }
    } else {
      alert("Error: New passwords are not matching !");
      form.newpass.focus();
      return false;
    }

  }
function cancelForm()
{
	document.getElementById('myform').reset();
}
