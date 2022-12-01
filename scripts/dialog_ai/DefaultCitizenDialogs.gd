class_name DefaultCitizenDialogs

const RandomUtils = preload("res://scripts/util/RandomUtils.gd")
const DialogSharedData = preload("res://scripts/dialogs/DialogSharedData.gd")
const DialogState = preload("res://scripts/dialogs/DialogState.gd")

var random: RandomNumberGenerator
var buy_probability: float = 1
var already_bought: bool = false
var preferred_genres: Array

func _init(buy_probability: float, preferred_genres: Array):
	self.random = RandomNumberGenerator.new()
	self.buy_probability = buy_probability
	self.already_bought = false
	self.preferred_genres = preferred_genres

class HelloState extends DialogState:
	const QUESTIONS: Array = [
		"Hello!", "Hi!", "Good day!"
	]
	const ANSWERS: Array = [
		"Hi! Would you like to purchase a book?",
		"Hello! Do you want a book?"
	]
	
	var dialogs: DefaultCitizenDialogs
	
	func init(data: DialogSharedData):
		init_state(
			RandomUtils.choose_one(QUESTIONS, data.user_data.random),
			[RandomUtils.choose_one(ANSWERS, data.user_data.random)]
		)
	
	func submit_answer(data: DialogSharedData, index: int) -> Object:
		if data.user_data.already_bought:
			return AlreadyBoughtState.new()
		elif data.user_data.random.randf() <= data.user_data.buy_probability:
			return OfferBooksState.new()
		return UnconditionalRejectState.new()

class AlreadyBoughtState extends DialogState:
	const QUESTIONS: Array = [
		"No, unfortunately, I've just bought one from you! I don't need more!",
		"I'm afraid, I've already made a purchase...",
		"No, I already have a book! I've just bought it!"
	]
	const ANSWERS: Array = [
		"OK, sorry...",
		"Well... Thank you! Have a nice day!"
	]
	
	func init(data: DialogSharedData):
		init_state(
			RandomUtils.choose_one(QUESTIONS, data.user_data.random),
			[RandomUtils.choose_one(ANSWERS, data.user_data.random)]
		)
	
	func submit_answer(data: DialogSharedData, index: int) -> Object:
		return null

class OfferBooksState extends DialogState:
	const QUESTIONS: Array = [
		"What books do you have?",
		"What would you like to offer me? I would like to buy a %s book.",
		"Any %s book?"
	]
	
	func init(data: DialogSharedData):
		init_state(
			create_question(
				data.user_data.random, data.user_data.preferred_genres
			),
			create_book_string_array(data.books)
		)
	
	func create_question(
		random: RandomNumberGenerator, preferred_genres: Array
	):
		var question: String = RandomUtils.choose_one(QUESTIONS, random)
		if "%s" in question:
			question = question % RandomUtils.choose_one(
				preferred_genres, random
			)
		return question
	
	func create_book_string_array(books: Array):
		var result = []
		for book in books:
			result.append("%s [%s]" % [book.title, book.genre])
		return result
	
	func submit_answer(data: DialogSharedData, index: int) -> Object:
		if data.books[index].genre in data.user_data.preferred_genres:
			data.user_data.already_bought = true
			return AcceptState.new()
		return ConditionalRejectState.new()

class AcceptState extends DialogState:
	const QUESTIONS: Array = [
		"Yes! I will definitely buy it!",
		"I've always wanted this book! I will purchase it! Thank you!"
	]
	const ANSWERS: Array = [
		"You're welcome!",
		"Have a nice day!",
		"Thank you for buying! Bye!"
	]
	
	func init(data: DialogSharedData):
		init_state(
			RandomUtils.choose_one(QUESTIONS, data.user_data.random),
			[RandomUtils.choose_one(ANSWERS, data.user_data.random)]
		)
	
	func submit_answer(data: DialogSharedData, index: int) -> Object:
		return data.books[0]

class UnconditionalRejectState extends DialogState:
	const QUESTIONS: Array = [
		"I'm afraid I don't want to buy anything today.",
		"No, I don't want your books!"
	]
	const ANSWERS: Array = [
		"That's so sad! Anyway, thanks!",
		"OK, thank you..."
	]
	
	func init(data: DialogSharedData):
		init_state(
			RandomUtils.choose_one(QUESTIONS, data.user_data.random),
			[RandomUtils.choose_one(ANSWERS, data.user_data.random)]
		)
	
	func submit_answer(data: DialogSharedData, index: int) -> Object:
		return null

class ConditionalRejectState extends DialogState:
	const QUESTIONS: Array = [
		"I'm afraid I don't want to buy this book. I prefer %s books...",
		"No, I don't want to purchase this! It's awful!"
	]
	const ANSWERS: Array = [
		"That's so sad! Anyway, thanks!",
		"OK, thank you..."
	]
	
	func init(data: DialogSharedData):
		init_state(
			RandomUtils.choose_one(QUESTIONS, data.user_data.random),
			[RandomUtils.choose_one(ANSWERS, data.user_data.random)]
		)
	
	func create_question(
		random: RandomNumberGenerator, preferred_genres: Array
	):
		var question: String = RandomUtils.choose_one(QUESTIONS, random)
		if "%s" in question:
			question = question % RandomUtils.choose_one(
				preferred_genres, random
			)
		return question
	
	func submit_answer(data: DialogSharedData, index: int) -> Object:
		return null

func create_state():
	return HelloState.new()
