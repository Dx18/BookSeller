extends Node

# Global game data

# Available book titles
var book_titles: Array = []
# Available book genres
var book_genres: Array = []

func _init():
	var titles_file = File.new()
	titles_file.open("res://data/titles.tres", File.READ)
	while not titles_file.eof_reached():
		var line = titles_file.get_line().strip_edges()
		if line != "":
			book_titles.append(line)
	titles_file.close()
	
	var genres_file = File.new()
	genres_file.open("res://data/genres.tres", File.READ)
	while not genres_file.eof_reached():
		var line = genres_file.get_line().strip_edges()
		if line != "":
			book_genres.append(line)
	genres_file.close()
