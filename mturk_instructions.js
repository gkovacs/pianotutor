// Generated by CoffeeScript 1.6.3
var checkCode, codeKeypress, documentReady, isChrome, isComboBoxZero, isRadioEmpty, isTextEmpty, pleaseAnswer, root, testPlayNote, toHitCode, validateForm;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.taskname = '${taskname}';

if (root.taskname.indexOf('taskname') !== -1) {
  root.taskname = 'foobarrr';
}

toHitCode = function(taskname) {
  var output, x, _i, _len;
  output = 0;
  for (_i = 0, _len = taskname.length; _i < _len; _i++) {
    x = taskname[_i];
    output += x.charCodeAt(0);
  }
  return output;
};

root.testPlayNote = testPlayNote = function() {
  return console.log('note played!');
};

root.codeKeypress = codeKeypress = function(event) {
  if (event.keyCode === 13) {
    return checkCode();
  } else {
    document.getElementById('codeCorrect').style.display = 'none';
    return document.getElementById('codeIncorrect').style.display = 'none';
  }
};

root.checkCode = checkCode = function() {
  var expected_hitcode, hitcode, submitButton;
  expected_hitcode = toHitCode(root.taskname).toString();
  hitcode = document.getElementById('hitcode').value.trim();
  if (hitcode !== expected_hitcode) {
    document.getElementById('codeCorrect').style.display = 'none';
    return document.getElementById('codeIncorrect').style.display = '';
  } else {
    document.getElementById('codeCorrect').style.display = '';
    document.getElementById('codeIncorrect').style.display = 'none';
    document.getElementById('checkCodeButton').disabled = true;
    document.getElementById('hitcode').disabled = true;
    document.getElementById('survey').style.display = '';
    submitButton = document.getElementById('submitButton');
    if (submitButton != null) {
      return submitButton.style.display = '';
    }
  }
};

isComboBoxZero = root.isComboBoxZero = function(name) {
  return document.getElementsByName(name)[0].value === '0';
};

isTextEmpty = root.isTextEmpty = function(name) {
  return document.getElementsByName(name)[0].value === '';
};

isRadioEmpty = root.isRadioEmpty = function(name) {
  var checked, x, _i, _len, _ref;
  checked = false;
  _ref = document.getElementsByName(name);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    x = _ref[_i];
    if (x.checked) {
      checked = true;
    }
  }
  return !checked;
};

pleaseAnswer = function(name) {
  return alert('please answer survey question ' + name);
};

root.validateForm = validateForm = function() {
  var expected_hitcode, hitcode;
  expected_hitcode = toHitCode(root.taskname).toString();
  hitcode = document.getElementById('hitcode').value.trim();
  if (hitcode !== expected_hitcode) {
    alert('the code you input: "' + hitcode + '" is not correct');
    return false;
  }
  if (!isChrome()) {
    alert('You must use Google Chrome to do this task');
    return false;
  }
  if (isComboBoxZero('musicexperience')) {
    pleaseAnswer(3);
    return false;
  }
  if (isComboBoxZero('musicrecency')) {
    pleaseAnswer(4);
    return false;
  }
  if (isComboBoxZero('pianoexperience')) {
    pleaseAnswer(5);
    return false;
  }
  if (isComboBoxZero('pianorecency')) {
    pleaseAnswer(6);
    return false;
  }
  if (isRadioEmpty('piece1heard')) {
    pleaseAnswer(7);
    return false;
  }
  if (isRadioEmpty('piece1played')) {
    pleaseAnswer(7);
    return false;
  }
  if (isRadioEmpty('piece2heard')) {
    pleaseAnswer(7);
    return false;
  }
  if (isRadioEmpty('piece2played')) {
    pleaseAnswer(7);
    return false;
  }
  return true;
};

isChrome = function() {
  return /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor);
};

documentReady = function() {
  var startTask, submitButton;
  submitButton = document.getElementById('submitButton');
  if (submitButton != null) {
    submitButton.onclick = 'return validateForm()';
  }
  if (!isChrome()) {
    document.getElementById('chromewarning').style.display = '';
    if (submitButton != null) {
      submitButton.disabled = true;
    }
    startTask = document.getElementById('startTask');
    if (startTask.text != null) {
      startTask.text = 'You must use Google Chrome to do this task. Open this HIT in Google Chrome to do the task.';
    }
    if (startTask.textContent != null) {
      startTask.textContent = 'You must use Google Chrome to do this task. Open this HIT in Google Chrome to do the task.';
    }
    startTask.href = 'http://www.google.com/chrome';
    document.getElementById('checkCodeButton').disabled = true;
    return document.getElementById('hitcode').disabled = true;
  }
};

document.onreadystatechange = function() {
  if (document.readyState === 'complete') {
    return documentReady();
  }
};
