# county-election-benchmarks

## short methodology: 

- take county-level results of recent pres elections in each state
- take county-level results of recent statewide elections in each state
- combine those files
- compute partisan lean of each county based on how far left/right it is of the statewide vote, for each election
- average those county-level partisan leans, giving more weight to recent presidential elections
	- (70% most recent POTUS, 20% lagged POTUS, 10% statewide 

credit for much of this methodology goes to Geoffrey Skelley, who developed an initial version at fivethirtyeight some years ago.

## data sources:

- pres results archived from Matt Stiles: https://github.com/stiles/presidential-elections
- David Nir, The Downballot