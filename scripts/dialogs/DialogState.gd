# Single dialog state

## Preloads

# Dialog shared data
const DialogSharedData = preload("res://scripts/dialogs/DialogSharedData.gd")

## State

# Current question
var question: String
# Currently possible answers
var answers: Array

# Initializes question and answers
func init_state(question: String, answers: Array):
	self.question = question
	self.answers = answers

## Abstract methods

# Initializes state
func init(data: DialogSharedData):
	assert(false, "Not implemented!")
	
	# Unreachable
	return null

# Submits answer. Returns either:
#
# 1. New state;
# 2. Book instance (in case when book is bought and dialog is ended);
# 3. `null` (in case when no book is bought and dialog is ended).
func submit_answer(data: DialogSharedData, index: int) -> Object:
	assert(false, "Not implemented!")
	
	# Unreachable
	return null
