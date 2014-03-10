// Generated by IcedCoffeeScript 1.6.3-g
(function() {
  var acceptHIT, checkCode, checkIfHITDoneCookies, codeKeypress, codeKeyup, documentReady, getUrlParameters, getWorkerId, insertScript, isChrome, isComboBoxZero, isHitCodeCorrect, isRadioEmpty, isTextEmpty, nextYearDateString, pleaseAnswer, previewHIT, root, taskAcceptedByWorker, testPlayNote, toHitCode, validateForm;



  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  getUrlParameters = root.getUrlParameters = function() {
    var map, parts;
    map = {};
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
      return map[key] = decodeURI(value);
    });
    return map;
  };

  getWorkerId = root.getWorkerId = function() {
    var params;
    params = getUrlParameters();
    if (params.workerId != null) {
      return params.workerId;
    }
    return '';
  };

  insertScript = root.insertScript = function(url) {
    var scriptTag;
    scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.src = url;
    return document.documentElement.appendChild(scriptTag);
  };

  nextYearDateString = function() {
    var nextyear;
    nextyear = new Date();
    nextyear.setFullYear(nextyear.getFullYear() + 1);
    return nextyear.toGMTString();
  };

  taskAcceptedByWorker = root.taskAcceptedByWorker = function(accepted_taskname) {
    if (accepted_taskname === '' || accepted_taskname === root.taskname) {
      console.log('taskname matches: ' + accepted_taskname);
      if ($.cookie('taskname') == null) {
        return $.cookie('taskname', root.taskname, {
          expires: 365
        });
      }
    } else {
      console.log('taskname mismatch: ' + accepted_taskname + ' vs ' + root.taskname);
      document.getElementById('returnwarning').style.display = '';
      if ($.cookie('taskname') == null) {
        return $.cookie('taskname', accepted_taskname, {
          expires: 365
        });
      }
    }
  };

  acceptHIT = root.acceptHIT = function() {
    console.log('hit accepted');
    return insertScript('//pianotutor.herokuapp.com/taskAcceptedByWorker.js?callback=taskAcceptedByWorker&workerid=' + encodeURI(getWorkerId()) + '&taskname=' + encodeURI(root.taskname));
  };

  toHitCode = root.toHitCode = function(taskname) {
    var char, hash, i, _i, _ref;
    hash = 0;
    if (taskname.length === 0) {
      return hash;
    }
    for (i = _i = 0, _ref = taskname.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      char = taskname.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash |= 0;
    }
    if (hash < 0) {
      return Math.floor(-hash / 4096);
    }
    return Math.floor(hash / 4096);
  };

  root.testPlayNote = testPlayNote = function() {
    var audioTag;
    console.log('note played!');
    audioTag = document.getElementById('testNote');
    audioTag.pause();
    audioTag.currentTime = 0.0;
    audioTag.play();
    return false;
  };

  root.isHitCodeCorrect = isHitCodeCorrect = function() {
    var expected_hitcode, hitcode;
    expected_hitcode = toHitCode(root.taskname).toString();
    hitcode = document.getElementById('hitcode').value.trim();
    return expected_hitcode === hitcode;
  };

  root.codeKeypress = codeKeypress = function(event) {
    if (event.keyCode === 13) {
      checkCode();
      event.preventDefault();
      return false;
    } else {
      document.getElementById('codeCorrect').style.display = 'none';
      document.getElementById('codeIncorrect').style.display = 'none';
      return true;
    }
  };

  root.codeKeyup = codeKeyup = function(event) {
    if (isHitCodeCorrect()) {
      checkCode();
    }
    return true;
  };

  root.checkCode = checkCode = function() {
    var submitButton;
    if (!isHitCodeCorrect()) {
      document.getElementById('codeCorrect').style.display = 'none';
      document.getElementById('codeIncorrect').style.display = '';
    } else {
      document.getElementById('codeCorrect').style.display = '';
      document.getElementById('codeIncorrect').style.display = 'none';
      document.getElementById('checkCodeButton').disabled = true;
      document.getElementById('survey').style.display = '';
      submitButton = document.getElementById('submitButton');
      if (submitButton != null) {
        submitButton.style.display = '';
      }
    }
    return false;
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
    return /chrom(e|ium)/.test(navigator.userAgent.toLowerCase());
  };

  previewHIT = root.previewHIT = function() {
    var acceptedTask;
    acceptedTask = $.cookie('taskname');
    if ((acceptedTask != null) && acceptedTask !== '' && acceptedTask !== root.taskname) {
      $('#dontacceptwarning').show();
      $('#taskBody').hide();
      return $('#submitButton').hide();
    }
  };

  checkIfHITDoneCookies = root.checkIfHITDoneCookies = function() {
    var acceptedTask;
    acceptedTask = $.cookie('taskname');
    if ((acceptedTask != null) && acceptedTask !== '' && acceptedTask !== root.taskname) {
      $('#returnwarning').show();
      $('#taskBody').hide();
      return $('#submitButton').hide();
    }
  };

  documentReady = function() {
    var workerid;
    $('#submitButton').click(function() {
      return validateForm();
    });
    if ($.browser.mobile) {
      $('#mobilewarning').show();
      $('#taskBody').hide();
      $('#submitButton').hide();
      $('#submitButton').attr('disabled', 'disabled');
      $('#startTask').text('You must use a desktop computer or laptop to do this task. Open this HIT on a desktop computer or laptop to do the task.');
      $('#startTask').attr('href', 'http://www.google.com/chrome');
      $('#checkCodeButton').attr('disabled', 'disabled');
      $('#hitcode').attr('disabled', 'disabled');
    }
    if (!isChrome()) {
      $('#chromewarning').show();
      $('#taskBody').hide();
      $('#submitButton').hide();
      $('#submitButton').attr('disabled', 'disabled');
      $('#startTask').text('You must use Google Chrome to do this task. Open this HIT in Google Chrome to do the task.');
      $('#startTask').attr('href', 'http://www.google.com/chrome');
      $('#checkCodeButton').attr('disabled', 'disabled');
      $('#hitcode').attr('disabled', 'disabled');
      return;
    }
    $('#useragent').val(navigator.userAgent.toString());
    workerid = getWorkerId();
    if (workerid !== '') {
      $('#startTask').text('Start the task to get a code (will open a new window)');
      $('#startTask').attr('href', '//pianotutor.herokuapp.com/mturk_index_' + root.taskname + '.html?workerId=' + encodeURI(workerid) + '&taskname=' + encodeURI(root.taskname));
      checkIfHITDoneCookies();
      return acceptHIT();
    } else {
      return previewHIT();
    }
  };

  document.onreadystatechange = function() {
    if (document.readyState === 'complete') {
      return documentReady();
    }
  };

}).call(this);
