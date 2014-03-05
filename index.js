// Generated by CoffeeScript 1.6.3
var STRING_INSERTED, STRING_INVERSIONFIRST, STRING_INVERSIONSECOND, STRING_MATCH, STRING_MISSED, STRING_SPACE, STRING_SUBSTITUTION, addKeyEvent, addNotes, alphabet, blast_text, corpus_lines, d_rows, displayKeyboard, getMusicFileForNote, getNoteAlpha, getSubstitutionScore, getUrlParameters, highlightButton, highlightButtonTarget, highlightNote, highlightNoteAtPosition, highlightNotesInOrder, initLineLog, m_rows, makeButton, make_key_mapping, matchLength, maxLineReached, nextLine, performOnNotesInOrder, playNote, playNotesInOrder, postToServer, q_rows, removeNonAlpha, removeWhitespace, root, sendLineLog, sendStartLog, setCaretToPos, setNotesFromText, setSelectionRange, sharpToFlat, showLine, substitution_table, to_dvorak, to_piano, transformTypedChar, unhighlightButton, updateProgress, updateText;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.targetText = 'hi guys where are you all going';

STRING_MATCH = 1;

STRING_SUBSTITUTION = 2;

STRING_MISSED = 3;

STRING_INSERTED = 4;

STRING_SPACE = 5;

STRING_INVERSIONFIRST = 7;

STRING_INVERSIONSECOND = 8;

alphabet = 'abcdefghijklmnopqrstuvwxyz';

root.stringToIndex = {};

(function() {
  var idx, letter, _i, _len, _results;
  _results = [];
  for (idx = _i = 0, _len = alphabet.length; _i < _len; idx = ++_i) {
    letter = alphabet[idx];
    _results.push(root.stringToIndex[letter] = idx);
  }
  return _results;
})();

getSubstitutionScore = function(letterA, letterB) {
  var indexA, indexB;
  indexA = root.stringToIndex[letterA.toLowerCase()];
  indexB = root.stringToIndex[letterB.toLowerCase()];
  return root.substitutionMatrix[indexA][indexB];
};

blast_text = function(typedText, referenceText) {
  var i, j, maxscore, maxscore_i, maxscore_j, op, operationTypes, output, prevReferenceChar, prevTypedChar, referenceChar, scores, substitutionScore, typedChar, x, y, _i, _j, _k, _ref, _ref1, _ref2;
  scores = [];
  operationTypes = [];
  for (i = _i = 0, _ref = typedText.length + 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    scores[i] = (function() {
      var _j, _ref1, _results;
      _results = [];
      for (j = _j = 0, _ref1 = referenceText.length + 1; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
        _results.push(-1000);
      }
      return _results;
    })();
    operationTypes[i] = (function() {
      var _j, _ref1, _results;
      _results = [];
      for (j = _j = 0, _ref1 = referenceText.length + 1; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
        _results.push(0);
      }
      return _results;
    })();
  }
  scores[0][0] = 0;
  maxscore = 0;
  maxscore_i = 0;
  maxscore_j = 0;
  for (i = _j = 0, _ref1 = typedText.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
    typedChar = typedText[i];
    for (j = _k = 0, _ref2 = referenceText.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; j = 0 <= _ref2 ? ++_k : --_k) {
      referenceChar = referenceText[j];
      if (referenceChar === ' ') {
        scores[i + 1][j + 1] = scores[i + 1][j];
        operationTypes[i + 1][j + 1] = STRING_SPACE;
      } else if (typedChar === referenceChar) {
        scores[i + 1][j + 1] = scores[i][j] + 1;
        operationTypes[i + 1][j + 1] = STRING_MATCH;
      } else {
        substitutionScore = getSubstitutionScore(referenceChar, typedChar) - .1;
        scores[i + 1][j + 1] = scores[i][j] + substitutionScore;
        operationTypes[i + 1][j + 1] = STRING_SUBSTITUTION;
        if (i > 0 && j > 0 && operationTypes[i][j] === STRING_SUBSTITUTION) {
          prevTypedChar = typedText[i - 1];
          prevReferenceChar = referenceText[j - 1];
          if (typedChar === prevReferenceChar && referenceChar === prevTypedChar) {
            scores[i + 1][j + 1] += .8;
            operationTypes[i + 1][j + 1] = STRING_INVERSIONSECOND;
            operationTypes[i][j] = STRING_INVERSIONFIRST;
          }
        }
        if (scores[i][j + 1] - .4 > scores[i + 1][j + 1]) {
          scores[i + 1][j + 1] = scores[i][j + 1] - .4;
          operationTypes[i + 1][j + 1] = STRING_INSERTED;
        }
        if (scores[i + 1][j] - .7 > scores[i + 1][j + 1]) {
          scores[i + 1][j + 1] = scores[i + 1][j] - .7;
          operationTypes[i + 1][j + 1] = STRING_MISSED;
        }
      }
      if (scores[i + 1][j + 1] > maxscore) {
        maxscore = scores[i + 1][j + 1];
        maxscore_i = i + 1;
        maxscore_j = j + 1;
      }
    }
  }
  console.log('maxscore_i: ' + maxscore_i);
  console.log('maxscore_j: ' + maxscore_j);
  console.log('maxscore: ' + maxscore);
  output = [];
  x = typedText.length;
  y = maxscore_j;
  while (x !== 0 && y !== 0) {
    op = operationTypes[x][y];
    if (op === STRING_MATCH || op === STRING_SUBSTITUTION || op === STRING_INVERSIONFIRST || op === STRING_INVERSIONSECOND) {
      x -= 1;
      y -= 1;
      output.push(typedText[x]);
    }
    if (op === STRING_MISSED) {
      y -= 1;
    }
    if (op === STRING_INSERTED) {
      x -= 1;
      output.push(typedText[x]);
    }
    if (op === STRING_SPACE) {
      y -= 1;
      output.push(' ');
    }
  }
  return [output.reverse().join(''), maxscore_j];
};

removeWhitespace = function(text) {
  var c, output, _i, _len;
  output = [];
  for (_i = 0, _len = text.length; _i < _len; _i++) {
    c = text[_i];
    output.push(c.trim());
  }
  return output.join('');
};

removeNonAlpha = function(text) {
  var c, output, _i, _len;
  output = [];
  for (_i = 0, _len = text.length; _i < _len; _i++) {
    c = text[_i];
    c = c.toLowerCase();
    if (alphabet.indexOf(c) !== -1) {
      output.push(c);
    }
  }
  return output.join('');
};

root.currentLineNum = 0;

nextLine = function() {
  if (root.currentLineNum < root.corpus_lines.length) {
    root.currentLineNum += 1;
  }
  return showLine();
};

updateProgress = function(lineNum) {
  var songname, totalLines;
  totalLines = root.corpus_lines.length;
  songname = root.songname.split('_').join(' ');
  $('#progressIndicator').css('top', '120px');
  $('#progressIndicator').css('font-size', '24px');
  return $('#progressIndicator').html('Exercise <b>' + (lineNum + 1) + '/' + (totalLines - 1) + '</b> in <b>' + songname + '</b>');
};

setNotesFromText = function(span, text, startnum) {
  var isFirst, note, notenum, notes, _i, _len;
  if (startnum == null) {
    startnum = 0;
  }
  notes = text.split(' ');
  span.empty();
  isFirst = true;
  notenum = startnum;
  for (_i = 0, _len = notes.length; _i < _len; _i++) {
    note = notes[_i];
    if (note === '') {
      continue;
    }
    span.append($('<span>').html(note).attr('note', note).addClass('note_' + notenum).addClass('targetnotes'));
    if (isFirst) {
      isFirst = false;
    } else {

    }
    span.append(' ');
    notenum += 1;
  }
  return notenum;
};

showLine = function() {
  var curitem, curlink, i, notenum, toex, _i, _ref, _results;
  window.location.hash = '#' + root.currentLineNum;
  console.log('showLine for line' + currentLineNum);
  root.targetText = root.corpus_lines[root.currentLineNum].toLowerCase();
  if (root.targetText.indexOf('congratulations') !== -1) {
    window.location = 'skilltree.html';
  }
  $('#textDisplay_entered').text('');
  notenum = setNotesFromText($('#textDisplay_entered'), '');
  setNotesFromText($('#textDisplay_todo'), root.targetText, notenum);
  updateText(true);
  updateProgress(root.currentLineNum);
  if (root.currentLineNum > maxLineReached()) {
    $.cookie('maxreached_' + root.globaltaskname, root.currentLineNum, {
      expires: 365
    });
    $.cookie('numparts_' + root.globaltaskname, root.corpus_lines.length - 1, {
      expires: 365
    });
  }
  toex = $('#goto_exercise');
  toex.empty();
  _results = [];
  for (i = _i = 0, _ref = root.corpus_lines.length - 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    curitem = $('<li>');
    curlink = $('<a>');
    curlink.attr('href', '#');
    curlink.text('Exercise ' + (i + 1));
    if (i <= maxLineReached()) {
      curlink.attr('onclick', 'window.location.hash = "#' + i + '"; window.location.reload()');
    } else {
      curitem.addClass('disabled');
    }
    curitem.append(curlink);
    _results.push(toex.append(curitem));
  }
  return _results;
};

root.formValueIncludesInputted = false;

root.haveCheckedFormValueIncludesInputted = false;

matchLength = function(str1, str2) {
  var i, _i, _ref;
  for (i = _i = 0, _ref = Math.min(str1.length, str2.length); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    if (str1[i].toLowerCase() !== str2[i].toLowerCase()) {
      return i;
    }
  }
  return i;
};

root.currentLineStartTime = 0;

root.lineFinishLogs = [];

initLineLog = function() {
  var data;
  data = {};
  data.keyevents = [];
  return data;
};

root.lineLog = initLineLog();

addKeyEvent = root.addKeyEvent = function(key_pressed, key_expected) {
  var currentTime, keyevent;
  currentTime = new Date().getTime();
  keyevent = {
    pressed: key_pressed,
    expected: key_expected,
    position: root.numNotesEntered,
    time: currentTime
  };
  console.log(keyevent);
  return root.lineLog.keyevents.push(keyevent);
};

sendLineLog = root.sendLineLog = function() {
  root.lineLog['logtype'] = 'line';
  root.lineLog['lineNum'] = root.currentLineNum;
  root.lineLog['targetText'] = root.targetText;
  root.lineLog['user'] = root.workerId;
  root.lineLog['taskname'] = root.taskname;
  root.lineLog['posttime'] = new Date().getTime();
  root.lineLog['starttime'] = new Date(root.currentLineStartTime).getTime();
  postToServer(root.lineLog);
  return root.lineLog = initLineLog();
};

sendStartLog = root.sendStartLog = function() {
  var data;
  data = {};
  data['user'] = root.workerId;
  data['taskname'] = root.taskname;
  data['posttime'] = new Date().getTime();
  data['logtype'] = 'start';
  return postToServer(data);
};

root.postToServer = postToServer = function(data) {
  console.log(data);
  return $.ajax({
    type: 'POST',
    url: '/postlog',
    data: JSON.stringify(data),
    contentType: 'application/json; charset=utf-8',
    dataType: 'json'
  });
};

root.sendLogs = function() {
  var startTime;
  startTime = root.lineFinishLogs[0].startedAt;
  return $.get('/varTable?varname=' + escape(startTime) + '&set=' + escape(JSON.stringify(root.lineFinishLogs)), function(data) {
    $('#logLink').attr('href', '/varTable?varname=' + escape(startTime));
    return $('#logLink').show();
  });
};

root.nextNoteToHighlight = 0;

root.highlightNoteSeries = -1;

root.playNotesInOrder = playNotesInOrder = function() {
  return performOnNotesInOrder(function(noteSpan) {
    var note;
    if (!highlightNote(noteSpan)) {
      return false;
    }
    note = noteSpan.attr('note');
    playNote(note);
    return true;
  });
};

root.highlightNotesInOrder = highlightNotesInOrder = function() {
  return performOnNotesInOrder(highlightNote);
};

root.performOnNotesInOrder = performOnNotesInOrder = function(fn, seriesid) {
  var nextnote, nextnote_note_duration, nextnote_note_text;
  if (seriesid == null) {
    seriesid = Math.floor(Math.random() * 10000);
    root.highlightNoteSeries = seriesid;
    root.nextNoteToHighlight = 0;
  }
  if (seriesid !== highlightNoteSeries) {
    return;
  }
  nextnote = $('.note_' + root.nextNoteToHighlight);
  if (!fn(nextnote)) {
    return;
  }
  nextnote_note_text = nextnote.attr('note');
  nextnote_note_duration = 1.0;
  if (nextnote_note_text.indexOf('_') !== -1) {
    nextnote_note_duration = parseFloat(nextnote_note_text.split('_').slice(-1)[0]);
  }
  root.nextNoteToHighlight += 1;
  return setTimeout(function() {
    return root.performOnNotesInOrder(fn, seriesid);
  }, 500 * nextnote_note_duration);
};

root.highlightNote = highlightNote = function(note) {
  $('.targetnotes').css('background-color', 'white');
  if (note.length === 0) {
    return false;
  }
  note.css('background-color', 'yellow');
  return true;
};

root.highlightNoteAtPosition = highlightNoteAtPosition = function(position) {
  var note;
  note = $('.note_' + position);
  return highlightNote(note);
};

root.numTimesDeletePressed = 0;

root.nextNote = '';

root.lastText = '';

root.numNotesEntered = 0;

updateText = function(forced) {
  var chunk, nextNote, notenum, ntext, numMatched, numNotesEntered, reftext_entered, reftext_todo, _i, _len, _ref;
  if (forced == null) {
    forced = false;
  }
  ntext = $('#textInput').val();
  if (ntext === root.lastText && !forced) {
    return;
  }
  root.lastText = ntext;
  if (root.currentLineStartTime === 0 && ntext.trim().length > 0) {
    root.currentLineStartTime = new Date().getTime();
  }
  if (root.startTime === 0 && ntext.trim().length > 0) {
    root.startTime = new Date().getTime();
    $('#startTime').text(new Date(root.startTime).toString());
  }
  numMatched = matchLength(ntext.trim(), root.targetText);
  reftext_entered = root.targetText.slice(0, numMatched);
  reftext_todo = root.targetText.slice(numMatched);
  numNotesEntered = 0;
  _ref = reftext_entered.split(' ');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    chunk = _ref[_i];
    if (chunk.trim() !== '') {
      numNotesEntered += 1;
    }
  }
  root.numNotesEntered = numNotesEntered;
  notenum = setNotesFromText($('#textDisplay_entered'), reftext_entered);
  setNotesFromText($('#textDisplay_todo'), reftext_todo, notenum);
  if (root.isMusic) {
    console.log(reftext_todo);
    nextNote = reftext_todo.trim().split(' ')[0];
    if ((nextNote != null) && (nextNote.length != null)) {
      nextNote = nextNote.trim();
      if (nextNote.trim().length > 0) {
        console.log('next note is:' + nextNote);
        root.nextNote = nextNote;
        $('.targetButton').css('background-color', 'white').removeClass('targetButton');
        highlightButtonTarget(nextNote);
      }
    }
  }
  if (numMatched === root.targetText.length) {
    $('#textInput').val('');
    sendLineLog();
    root.lineFinishLogs.push({
      'targetText': root.targetText,
      'startedAt': new Date(root.currentLineStartTime).toString(),
      'completedAt': new Date().toString()
    });
    root.currentLineStartTime = 0;
    if (root.targetText === 'you are now done typing') {
      root.sendLogs();
    }
    if (root.numTimesDeletePressed >= 1) {
      root.numTimesDeletePressed = 0;
      return showLine();
    } else {
      return nextLine();
    }
  }
};

root.hashname_to_index = {};

corpus_lines = root.corpus_lines = root.corpus.split('\n');

(function() {
  var hashidx, hashname, idx, line, _i, _ref, _results;
  _results = [];
  for (idx = _i = 0, _ref = corpus_lines.length; 0 <= _ref ? _i < _ref : _i > _ref; idx = 0 <= _ref ? ++_i : --_i) {
    line = corpus_lines[idx];
    hashidx = line.indexOf(' # ');
    if (hashidx !== -1) {
      hashname = line.slice(hashidx + 2).trim();
      root.hashname_to_index[hashname] = idx;
      _results.push(corpus_lines[idx] = line.slice(0, hashidx).trim());
    } else {
      _results.push(void 0);
    }
  }
  return _results;
})();

sharpToFlat = function(basenote) {
  return {
    'g#': 'Ab',
    'a#': 'Bb',
    'c#': 'Db',
    'd#': 'Eb',
    'f#': 'Gb'
  }[basenote.toLowerCase()];
};

addNotes = function() {
  var note, noteAlpha, noteFile, notenode, _i, _len, _ref, _results;
  _ref = $('.key');
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    notenode = _ref[_i];
    note = $(notenode).text();
    noteFile = getMusicFileForNote(note);
    noteAlpha = note.split('#').join('s');
    _results.push($('#notes').append($('<audio>').attr('src', noteFile).attr('id', 'note_' + noteAlpha).css('display', 'none')));
  }
  return _results;
};

getNoteAlpha = function(note) {
  return note.split('#').join('s');
};

playNote = root.playNote = function(note) {
  var audioTag, audioTagJquery, currentTime, noteAlpha;
  highlightButton(note.split('_').slice(0, 1)[0]);
  noteAlpha = getNoteAlpha(note.split('_').slice(0, 1)[0]);
  audioTagJquery = $('#note_' + noteAlpha);
  currentTime = (new Date).getTime();
  audioTagJquery.attr('playEnd', currentTime + 500);
  audioTagJquery.attr('highlightEnd', currentTime + 100);
  audioTag = audioTagJquery[0];
  audioTag.pause();
  audioTag.currentTime = 0.0;
  audioTag.play();
  return setTimeout(function() {
    var highlightEnd;
    highlightEnd = parseInt(audioTagJquery.attr('highlightEnd'));
    if ((new Date).getTime() >= highlightEnd) {
      return unhighlightButton(note.split('_').slice(0, 1)[0]);
    }
  }, 101);
};

unhighlightButton = root.unhighlightButton = function(note) {
  var button;
  button = $('#button_' + getNoteAlpha(note));
  button.attr('highlighted', false);
  if (note === root.nextNote) {
    return button.css('background-color', 'yellow');
  } else {
    button.css('background-color', 'white');
    return button.removeClass('targetButton');
  }
};

highlightButton = root.highlightButton = function(note) {
  var button;
  button = $('#button_' + getNoteAlpha(note));
  button.attr('highlighted', true);
  button.attr('isTarget', false);
  return button.css('background-color', 'lightblue');
};

highlightButtonTarget = root.highlightButtonTarget = function(note) {
  var button;
  button = $('#button_' + getNoteAlpha(note));
  button.addClass('targetButton');
  return button.css('background-color', 'yellow');
};

getMusicFileForNote = root.getMusicFileForNote = function(note) {
  var basenote, octave;
  octave = parseInt(note.slice(-1)) + 3;
  basenote = note.slice(0, -1);
  if (basenote.slice(-1) === '#') {
    basenote = sharpToFlat(basenote);
  } else {
    basenote = basenote.toUpperCase();
  }
  return 'piano/Piano.ff.' + basenote + octave + '.m4a';
};

makeButton = function(name) {
  var button;
  button = $('<div>').text(name).addClass('keybase');
  button.attr('id', 'button_' + getNoteAlpha(name));
  if (name === 'tab' || name === 'caps' || name === 'shift' || name === 'delete' || name === 'return') {
    button.addClass(name);
  } else {
    button.addClass('key');
  }
  return button;
};

displayKeyboard = function() {
  var letter, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
  _ref = ['`'].concat('1234567890'.split('').concat('-='.split('').concat(['delete'])));
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    letter = _ref[_i];
    $('#keyboard').append(makeButton(transformTypedChar(letter)));
  }
  $('#keyboard').append($('<div>').css('clear', 'both'));
  _ref1 = ['tab'].concat('QWERTYUIOP'.split('').concat('[]\\'.split('')));
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    letter = _ref1[_j];
    $('#keyboard').append(makeButton(transformTypedChar(letter)));
  }
  $('#keyboard').append($('<div>').css('clear', 'both'));
  _ref2 = ['caps'].concat('ASDFGHJKL'.split('').concat(";'".split('').concat(['return'])));
  for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
    letter = _ref2[_k];
    $('#keyboard').append(makeButton(transformTypedChar(letter)));
  }
  $('#keyboard').append($('<div>').css('clear', 'both'));
  _ref3 = ['shift'].concat('ZXCVBNM'.split('').concat(',./'.split('').concat(['shift'])));
  for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
    letter = _ref3[_l];
    $('#keyboard').append(makeButton(transformTypedChar(letter)));
  }
  return console.log('keyboard displayed');
};

maxLineReached = root.maxLineReached = function() {
  var maxreached;
  maxreached = $.cookie('maxreached_' + root.globaltaskname);
  if (maxreached != null) {
    return parseInt(maxreached);
  }
  return 0;
};

setSelectionRange = root.setSelectionRange = function(input, selectionStart, selectionEnd) {
  var range;
  if (input.setSelectionRange) {
    input.focus();
    return input.setSelectionRange(selectionStart, selectionEnd);
  } else if (input.createTextRange) {
    range = input.createTextRange();
    range.collapse(true);
    range.moveEnd('character', selectionEnd);
    range.moveStart('character', selectionStart);
    return range.select();
  }
};

setCaretToPos = root.setCaretToPos = function(input, pos) {
  return setSelectionRange(input, pos, pos);
};

getUrlParameters = root.getUrlParameters = function() {
  var map, parts;
  map = {};
  parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
    return map[key] = decodeURI(value);
  });
  return map;
};

root.workerId = 'foobar';

root.taskname = 'sometask';

root.songname = 'practice';

$(document).ready(function() {
  var hashstring, hashstringAsInt, i, maxlinereached, urlparams;
  urlparams = getUrlParameters();
  if (urlparams['workerId'] != null) {
    root.workerId = urlparams['workerId'];
  } else {
    if ($.cookie('username') == null) {
      $.cookie('username', ((function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; _i < 10; i = ++_i) {
          _results.push(Math.floor(Math.random() * 10));
        }
        return _results;
      })()).join(''));
    }
    root.workerId = $.cookie('username');
  }
  if (urlparams['taskname'] != null) {
    root.taskname = urlparams['taskname'];
  }
  if (urlparams.songname != null) {
    root.songname = urlparams.songname;
    if (root.songname.indexOf('#') !== -1) {
      root.songname = root.songname.slice(0, root.songname.indexOf('#'));
    }
    if (root.taskname === 'sometask') {
      root.taskname = root.songname;
    }
  }
  maxlinereached = maxLineReached();
  if ((window.location.hash != null) && window.location.hash.trim() !== '') {
    console.log('hash is:' + window.location.hash);
    hashstring = window.location.hash.split('#').join('');
    if (root.hashname_to_index[hashstring] != null) {
      root.currentLineNum = root.hashname_to_index[hashstring];
    } else {
      hashstringAsInt = parseInt(hashstring);
      if (!isNaN(hashstringAsInt)) {
        root.currentLineNum = hashstringAsInt;
      }
    }
    if (root.currentLineNum > maxlinereached) {
      root.currentLineNum = maxlinereached;
    }
  } else {
    root.currentLineNum = maxlinereached;
  }
  showLine();
  $('#textInput').focus();
  $('#textInput').bind('blur', function(event) {
    $('#textInput').focus();
    setCaretToPos(document.getElementById('textInput'), $('#textInput').val().length);
    event.preventDefault();
    return false;
  });
  $('#textInput').bind('cut copy paste drop', function(event) {
    event.preventDefault();
    return false;
  });
  $('#textInput').bind('propertychange keyup input', function(event) {
    updateText();
    return false;
  });
  $("#textInput").bind('keydown', function(evt) {
    var end, lastSpace, newvalue, origChar, start, transformedChar, val;
    $('#textInput').focus();
    setCaretToPos(document.getElementById('textInput'), $('#textInput').val().length);
    if (evt.which != null) {
      console.log(evt.which);
      if (evt.which === 8) {
        root.numTimesDeletePressed += 1;
        if (root.isMusic) {
          start = this.selectionStart;
          end = this.selectionEnd;
          val = this.value;
          lastSpace = start - 2;
          while (lastSpace > 0) {
            if (val[lastSpace] === ' ') {
              break;
            }
            lastSpace -= 1;
          }
          this.value = val.slice(0, lastSpace) + ' ' + val.slice(end);
          if (this.value === ' ') {
            this.value = '';
          }
          return false;
        }
      }
      origChar = root.mapKeyPressToActualCharacter(evt.shiftKey, evt.which);
      console.log(origChar);
      transformedChar = transformTypedChar(origChar);
      if (transformedChar !== origChar) {
        if (root.isMusic) {
          playNote(transformedChar);
          addKeyEvent(transformedChar, root.nextNote);
          transformedChar = transformedChar + ' ';
        }
        start = this.selectionStart;
        end = this.selectionEnd;
        val = this.value;
        newvalue = val.slice(0, start) + transformedChar + val.slice(end);
        if (targetText.indexOf(newvalue.trim()) !== 0 && targetText !== 'freestyle' && targetText.indexOf('you have finished the task. enter this code on the hit page:') !== 0 && targetText.indexOf('congratulations') !== 0) {
          numTimesDeletePressed += 1;
          return false;
        }
        transformedChar = targetText.slice(start).split(' ')[0] + ' ';
        newvalue = val.slice(0, start) + transformedChar + val.slice(end);
        this.value = newvalue;
        this.selectionStart = this.selectionEnd = start + transformedChar.length;
        return false;
      }
    }
  });
  displayKeyboard();
  if (root.isMusic) {
    addNotes();
    updateText(true);
  }
  return sendStartLog();
});

make_key_mapping = function(qwerty_rows, dvorak_rows) {
  var dvorak_key, dvorak_row, i, j, output, qwerty_key, qwerty_row, _i, _j, _ref, _ref1;
  output = {};
  for (i = _i = 0, _ref = qwerty_rows.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    qwerty_row = qwerty_rows[i];
    if (qwerty_row == null) {
      continue;
    }
    dvorak_row = dvorak_rows[i];
    if (dvorak_row == null) {
      continue;
    }
    for (j = _j = 0, _ref1 = qwerty_row.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
      qwerty_key = qwerty_row[j];
      if (qwerty_key == null) {
        continue;
      }
      dvorak_key = dvorak_row[j];
      if (dvorak_key == null) {
        continue;
      }
      output[qwerty_key] = dvorak_key;
    }
  }
  console.log(output);
  return output;
};

q_rows = ['`1234567890-='.split(''), 'qwertyuiop[]\\'.split(''), "asdfghjkl;'".split(''), 'zxcvbnm,./'.split(''), '~!@#$%^&*()_+'.split(''), 'QWERTYUIOP{}'.split(''), 'ASDFGHJKL:"'.split(''), 'ZXCVBNM<>?'.split('')];

m_rows = [['c3', 'c#3', 'd3', 'd#3', 'e3', 'f3', 'f#3', 'g3', 'g#3', 'a3', 'a#3', 'b3', 'c4'], ['b1', 'c2', 'c#2', 'd2', 'd#2', 'e2', 'f2', 'f#2', 'g2', 'g#2', 'a2', 'a#2', 'b2'], ['c1', 'c#1', 'd1', 'd#1', 'e1', 'f1', 'f#1', 'g1', 'g#1', 'a1', 'a#1'], ['d0', 'd#0', 'e0', 'f0', 'f#0', 'g0', 'g#0', 'a0', 'a#0', 'b0'], ['c3', 'c#3', 'd3', 'd#3', 'e3', 'f3', 'f#3', 'g3', 'g#3', 'a3', 'a#3', 'b3', 'c4'], ['b1', 'c2', 'c#2', 'd2', 'd#2', 'e2', 'f2', 'f#2', 'g2', 'g#2', 'a2', 'a#2', 'b2'], ['c1', 'c#1', 'd1', 'd#1', 'e1', 'f1', 'f#1', 'g1', 'g#1', 'a1', 'a#1'], ['d0', 'd#0', 'e0', 'f0', 'f#0', 'g0', 'g#0', 'a0', 'a#0', 'b0']];

d_rows = ['`1234567890[]'.split(''), "',.pyfgcrl/=\\".split(''), 'aoeuidhtns-'.split(''), ';qjkxbmwvz'.split(''), '~!@#$%^&*(){}'.split(''), '"<>PYFGCRL?+'.split(''), 'AOEUIDHTNS_'.split(''), ':QJKXBMWVZ'.split('')];

to_dvorak = make_key_mapping(q_rows, d_rows);

to_piano = make_key_mapping(q_rows, m_rows);

substitution_table = to_piano;

root.isMusic = true;

transformTypedChar = function(origChar) {
  if (substitution_table[origChar] != null) {
    return substitution_table[origChar];
  }
  return origChar;
};
