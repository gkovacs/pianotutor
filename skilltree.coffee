root = exports ? this

milestone_list = [
  'mary_had_a_little_lamb_chorus',
  'mary_had_a_little_lamb_full',
  'fur_elise_chorus',
  'fur_elise_full',
  'fur_elise_complete',
]

milestone_fullnames =
  mary_had_a_little_lamb_chorus: 'Mary Had a Little Lamb (chorus only)'
  mary_had_a_little_lamb_full: 'Mary Had a Little Lamb (full lesson)'
  fur_elise_chorus: 'Fur Elise (chorus only)'
  fur_elise_full: 'Fur Elise (full lesson)'
  fur_elise_complete: 'Fur Elise (complete song)'

milestone_numparts = 
  mary_had_a_little_lamb_chorus: 16
  mary_had_a_little_lamb_full: 15
  fur_elise_chorus: 16
  fur_elise_full: 13
  fur_elise_complete: 1

addMilestones = ->
  for milestone in milestone_list
    milestone_name = milestone_fullnames[milestone]
    milestone_button = $('<button>')
    milestone_button.attr 'onclick', "window.location = 'practice?songname=#{milestone}'"
    milestone_button.attr 'type', 'button'
    milestone_button.addClass 'btn btn-default btn-lg'
    milestone_button.css 'width', '100%'
    milestone_button.css 'text-align', 'left'
    glyphicon = $('<span>').addClass('glyphicon glyphicon-music')
    milestone_button.append glyphicon
    milestone_button.append ' '
    milestone_button.append milestone_name
    numparts = parseInt $.cookie('numparts_' + milestone)
    maxreached = parseInt $.cookie('maxreached_' + milestone)
    if numparts?
      numparts = parseInt numparts
    else
      numparts = milestone_numparts[milestone]
    if maxreached?
      maxreached = parseInt maxreached
    else
      maxreached = 0
    progress_span = $('<span>')
    progress_span.css 'float', 'right'
    if maxreached == numparts
      progress_span.css 'color', 'green'
      glyphicon.removeClass 'glyphicon-music'
      glyphicon.addClass 'glyphicon-ok'
    else if maxreached == 0
      progress_span.css 'color', 'grey'
    else if maxreached < numparts
      progress_span.css 'color', 'red'
    progress_span.text "#{maxreached} / #{numparts}"
    milestone_button.append progress_span
    $('#milestones').append(milestone_button)

$(document).ready ->
  addMilestones()
  console.log 'stuff happened!'
