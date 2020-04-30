# I wanted to make a script that would go through all the sound files in a directory
# Which already have annotated TextGrids, open all of the Sounds and TextGrids, 
# Calculate the duration of each labelled interval in the 'component' tier, 
# (V -- vowel, VLC -- voiceless closure, VCD -- voiced closure, BT -- burst time, 
# PBI -- post-burst interval), output that information to a .txt file with the
# accompanying phonetic segment and word labels, and list formant data of vowels. 

####################################################################################################

#Since I want to work with many tiers, it is helpful to make a 'procedure'
#Which will repeat and assign numbers to each tier, so we don't have to put
#The tier number automatically in the code

procedure TierNumber name$ variable$
	#Gets the number of tiers
	numberOfTiers = Get number of tiers
	# Makes a variable that will count how many tiers
	itier = 1
	#Creates a repeating loop of commands that will end in certain conditions
	repeat
		#Gets the tier name for a tier each time it loops, starting with 1
		tier$ = Get tier name... itier
		#Increases the number of the tier it will check with each loop
		itier = itier + 1
	#End conditions for the loop -- when it finds the tier you named, or passes through all
	until tier$ = name$ or itier > numberOfTiers
	#Gives the variable a 0 value if it doesn't find your tier
	if tier$ <> name$
		'variable$' = 0
	#Gives the variable the number value of the tier it is on 
	else 
		'variable$' = itier - 1
	endif
endproc

#######################################################################################################

#First I want to have a form that will ask for all the necessary information
form Find the duration of consonant components and formant data of vowels
	comment Directory of the Sound files
	text sound_directory C:\Users\jacob\Desktop\Praat Project 1\
	sentence Sound_extension .wav
	comment Directory of the TextGrid files
	text textGrid_directory C:\Users\jacob\Desktop\Praat Project 1\
	sentence TextGrid_extension .TextGrid
	comment Path of output file?
	text resultfile C:\Users\jacob\Desktop\Praat Project 1\measurementresults.txt
	comment Which tier contains the components?
	sentence component_tier component
	comment Which tier contains the speech sound segments?
	sentence target_tier target
	comment Which tier contains the word labels?
	sentence word_tier word
	comment Formant analysis parameters
	positive Time_step 0.01
	integer Maximum_number_of_formants 3
	positive Maximum_formant_(Hz) 5500_(=adult female)
	positive Window_length_(s) 0.025
	real Preemphasis_from_(Hz) 50
endform

#Now make a Strings list of all the sounds file in the listed directory and count them for the loop
Create Strings as file list... list 'sound_directory$'*'sound_extension$'
numberOfFiles = Get number of strings

#Make the column titles for the .txt file which will be generated
titleline$ = "Filename	Word		Target	Component	Component Duration	F1	F2	F3	'newline$'"
fileappend "'resultfile$'" 'titleline$'

#Big for loop that will do everything we want
for ifile to numberOfFiles
	filename$ = Get string... ifile
	#Open one sound at a time
	Read from file... 'sound_directory$''filename$'
	#This selects the Sound and assigns it the variable 
	#Everything from here will be what repeats for each Sound
	soundname$ = selected$ ("Sound", 1)
	#To Formant (burg)... time_step maximum_number_of_formants maximum_formant window_length preemphasis_from
	#Now open the TextGrid
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_extension$'"
	#Check to see if there are any TextGrid files, and if so, start the if loop
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		#Find the tier number of tiers using the process and labels from the form
		call TierNumber 'component_tier$' component_tier
		call TierNumber 'target_tier$' target_tier
		call TierNumber 'word_tier$' word_tier
		#Now make sure there is a value for all the tiers...
		if component_tier > 0 and target_tier > 0 and word_tier > 0
			#Count all the intervals in the component tier (the one we're looking at) so we can make a loop
			numberOfIntervals = Get number of intervals... component_tier
			#Select TextGrid and cycle through all the intervals
			select TextGrid 'soundname$'
			for interval to numberOfIntervals
				#Define a variable for the label of every interval in the component tier
				label$ = Get label of interval... component_tier interval
				#Applies to only non-empty intervals
				if label$ <> ""
					#Get the start and end point to calculate duration
					start = Get starting point... component_tier interval
					end = Get end point... component_tier interval
					#Calculate duration of the interval
					duration = end - start
					#Calculate midpoint for formant data
					midpoint = (start + end) / 2
					#Get labels for target and word tier to list in final .txt file
					target = Get interval at time... target_tier start
					target_label$ = Get label of interval... target_tier target
					word = Get interval at time... word_tier start
					word_label$ = Get label of interval... word_tier word
					#Calculate formants for vowel with a loop that checks for a V label
					#if label$ = "V" 
						#select Formant 'soundname$'
						#f1 = Get value at time... 1 midpoint Hertz Linear
						#f2 = Get value at time... 2 midpoint Hertz Linear
						#f3 = Get value at time... 3 midpoint Hertz Linear
					#Give 0 value for non-vowel components
					#else 
						#f1 = 0
						#f2 = 0
						#f3 = 0
					#endif
					#Save results to the .txt file (Be careful of quotes!!)
					resultline$ = "'soundname$'	'word_label$'	'target_label$'	'label$'	'duration'	'f1'	'f2'	'f3' 'newline$'"
					#Writes the new data to a new line line each time it goes through
					fileappend "'resultfile$'" 'resultline$'
					select TextGrid 'soundname$'
				endif
			endfor
		endif
		#Remove the TextGrid
		select TextGrid 'soundname$'
		Remove
	endif
	#Remove Sound and Formant objects
	select Sound 'soundname$'
	#plus Formant 'soundname$'
	Remove
	#select the Strings list and it will repeat with more files
	select Strings list
endfor

#Removes the Strings list when it is all done. 
Remove

#Some notes
# --If using PC, make sure you have a slash on the end of the directory, or it won't work.
# --Single and double quotes... really important. Tiny but will break the whole code. 
# --Don't forget $ if you are trying to assign or call a string variable. 
# --Keep trying and making tiny changes until you get it to work. It feels like a Jenga tower
# 	but that is the best way to get it all to come together. 
# --for loops, if conditions, and repeat/until loops are extremely useful for doing a lot at once. 
# --patience is the secret... there are a lot of internet resources and probably a lot of people
# 	you know who could help you figure out your problem.
# --watch out for spaces next to variables!!!

#########################################################################################################
#References
#https://github.com/FieldDB/Praat-Scripts/blob/master/collect_data_from_two_tiers_in_files.praat
#https://github.com/FieldDB/Praat-Scripts/blob/master/collect_formant_data_from_files.praat
#My scripts are heavily based on these two, but instead of just copy and pasting them, I typed out each
#line individually, from memory when I could, making changes so it would make the analyses I wanted.