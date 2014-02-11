// Generated by CoffeeScript 1.6.3
(function() {
  var blockify, corpus, fs, lines_to_corpus, main, randstr, root, shuffle, toHitCode;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  fs = require('fs');

  blockify = function(lines, blocksize) {
    var blocks, current_block, line, _i, _len;
    blocks = [];
    current_block = [];
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      current_block.push(line);
      if (current_block.length >= blocksize) {
        blocks.push(current_block);
        current_block = [];
      }
    }
    if (current_block.length > 0) {
      blocks.push(current_block);
    }
    return blocks;
  };

  shuffle = function(array) {
    var counter, index, temp;
    counter = array.length;
    while (counter > 0) {
      index = Math.floor(Math.random() * counter);
      counter -= 1;
      temp = array[counter];
      array[counter] = array[index];
      array[index] = temp;
    }
    return array;
  };

  lines_to_corpus = function(lines) {
    var line, output, _i, _len;
    output = [];
    output.push('root = exports ? this');
    output.push('');
    output.push('corpus = root.corpus = """');
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      output.push(line);
    }
    output.push('"""');
    return output.join('\n');
  };

  randstr = function(length) {
    var i, output, possible, _i;
    output = [];
    possible = 'abcdefghijklmnopqrstuvwxyz';
    for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
      output.push(possible.charAt(Math.floor(Math.random() * possible.length)));
    }
    return output.join('');
  };

  toHitCode = require('./make_hitcode').toHitCode;

  corpus = require('./corpus').corpus;

  main = function() {
    var block, blocks, corpus_filename, corpus_filename_js, corpus_lines, csvfile, finishing_line, htmlfile, htmlfile_lines, iteration, line, lines, new_htmlfile, new_htmlfile_filename, new_htmlfile_lines, scramble_size, taskname, tasknames, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _n, _ref, _ref1;
    htmlfile = fs.readFileSync('index.html', 'utf-8');
    htmlfile_lines = htmlfile.split('\n');
    corpus_lines = corpus.split('\n');
    finishing_line = corpus_lines.slice(-1)[0].split(':')[0] + ': ';
    corpus_lines = corpus_lines.slice(0, -1);
    tasknames = [];
    _ref = [1, 2, 4, 8, 16, 32, 64];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      scramble_size = _ref[_i];
      for (iteration = _j = 0; _j < 2; iteration = ++_j) {
        blocks = blockify(corpus_lines, scramble_size);
        lines = [];
        for (_k = 0, _len1 = blocks.length; _k < _len1; _k++) {
          block = blocks[_k];
          _ref1 = shuffle(block);
          for (_l = 0, _len2 = _ref1.length; _l < _len2; _l++) {
            line = _ref1[_l];
            lines.push(line);
          }
        }
        taskname = scramble_size + '_' + iteration + '_' + randstr(4) + '_v3';
        tasknames.push(taskname);
        lines.push(finishing_line + toHitCode(taskname));
        corpus = lines_to_corpus(lines);
        corpus_filename = 'mturk_corpus_' + taskname + '.coffee';
        corpus_filename_js = 'mturk_corpus_' + taskname + '.js';
        fs.writeFileSync(corpus_filename, corpus, 'utf-8');
        new_htmlfile_lines = [];
        for (_m = 0, _len3 = htmlfile_lines.length; _m < _len3; _m++) {
          line = htmlfile_lines[_m];
          if (line === '<script src="corpus.js"></script>') {
            line = '<script src="' + corpus_filename_js + '"></script>';
          }
          if (line === 'globaltaskname = "foobarrr"') {
            line = 'globaltaskname = "' + taskname + '"';
          }
          new_htmlfile_lines.push(line);
        }
        new_htmlfile = new_htmlfile_lines.join('\n');
        new_htmlfile_filename = 'mturk_index_' + taskname + '.html';
        fs.writeFileSync(new_htmlfile_filename, new_htmlfile, 'utf-8');
      }
    }
    csvfile = [];
    csvfile.push('taskname');
    for (_n = 0, _len4 = tasknames.length; _n < _len4; _n++) {
      taskname = tasknames[_n];
      csvfile.push(taskname);
    }
    csvfile = shuffle(csvfile);
    csvfile = csvfile.join('\n');
    return fs.writeFileSync = fs.writeFileSync('mturk_items.csv', csvfile, 'utf-8');
  };

  if (require.main === module) {
    main();
  }

}).call(this);
