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

addMilestones = ->
  for milestone in milestone_list
    milestone_name = milestone_fullnames[milestone]
    milestone_button = $('<button>')
    milestone_button.attr 'onclick', "window.location = 'practice?songname=#{milestone}#0'"
    milestone_button.attr 'type', 'button'
    milestone_button.addClass 'btn btn-default btn-lg'
    milestone_button.css 'width', '100%'
    milestone_button.css 'text-align', 'left'
    milestone_button.append $('<span>').addClass('glyphicon glyphicon-music')
    milestone_button.append ' '
    milestone_button.append milestone_name
    $('#milestones').append(milestone_button)

$(document).ready ->
  addMilestones()
  console.log 'stuff happened!'
