extends Node

var best_score: int = 0

func submit_score(score: int) -> bool:
	if score > best_score:
		best_score = score
		return true
	return false
