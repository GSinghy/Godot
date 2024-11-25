extends Node

var total_award_amount: int = 0  # Total coins collected

signal on_collectible_award_received  # Signal to notify when coins are collected

func give_pickup_award(collectible_award: int):
	# Add to the total collectible count
	total_award_amount += collectible_award
	print("Signal emitted with total award amount:", total_award_amount)
	# Emit the signal to notify any listeners
	on_collectible_award_received.emit(total_award_amount)
