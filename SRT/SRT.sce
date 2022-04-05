scenario = "SRT"; #Name, used for references 
scenario_type = fMRI_emulation; #Refer to documentation - switch for developing vs production.
#scenario_type = fMRI; #Refer to documentation - switch for developing vs production.
default_font_size = 48;
default_optimize = false; #Leave false for more modern hardware
active_buttons = 5; #How many buttons
button_codes = 1,2,3,4,5; #What they should be coded as, used as a return when pressed. 
target_button_codes = 1,2,3,4,5;
response_logging = log_active; # If response_logging is log_active, responses that are ignored during a trial do not appear in the logfile.
response_matching = simple_matching;   # to use the newer features available in versions above 0.47.
scan_period = 2000; #The value of this parameter should be the time between complete MRI scans. For use with fMRI_emulation type.
default_background_color = 179, 179, 179;
pulses_per_scan = 1; #Needed if there are multiple pulses per TR.
pulse_code = 6;

#########-START SDL-#########
begin;
#########-START Instruction Cues-#########
array {
   LOOP $r 5; #How many cues
   $q = '$r + 1';
   bitmap { filename = "InstructionCues\\InstructionCue$q.png"; description = "ic$q"; } "ic$q"; 
   ENDLOOP;
} instructioncues_array;
#########-END Instruction Cues-#########
#########-START Trial Declarations-#########
trial{
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 5;
	stimulus_event{
		picture{
			text { caption ="Please Wait"; 
			font_size = 80; 
			font_color = 0,0,0;
			}; x = 0; y = 0; 
	};
	}waiting;
}waiting_trial; 
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption ="R"; 
			font_size = 100; 
			font_color = 0,0,0; 
			}; 
			x = 0; y = 0; 
		}; 
		duration = 16000;
		code = "R";
	}R_stim;
} R_trial;
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption ="S"; 
			font_size = 100; 
			font_color = 0,0,0; 
			}; 
			x = 0; y = 0; 
		}; 
		code = "S";
		duration = 16000;
	}S_stim;
} S_trial;
trial{
	trial_type = fixed;
	trial_duration = stimuli_length; 
	clear_active_stimuli = true;
	stimulus_event{
		picture { bitmap "ic1"; x = 0; y = 0; } instructioncue;
		time = 0;
		code = "cue1";
		target_button = 1;
		stimulus_time_out = 1000;
		duration = 200;
		response_active = true;
		} InstructionCue_stim; 
	stimulus_event{
		picture { bitmap "ic5"; x = 0; y = 0; } instructioncue_blank;
		time = 200;
		duration = 800;
		} InstructionCueBlank_stim; 
} instructioncue_trial;
#########-START PCL-#########
begin_pcl;
string filename = logfile.subject() + "PrintOut";
if file_exists( logfile_directory + filename + ".txt" ) then 
	int n = 1;
	loop until !file_exists( logfile_directory + filename + string( n ) + ".txt" )
	begin 
		n = n + 1;
	end;
	filename = filename + string (n);
end;
output_file output = new output_file; #creates output file variable
output.open( filename + ".txt", false); #creates and names output file
output.print( "Subject Name: " );
output.print( logfile.subject() ); #prints Subject Name/ID
output.print("\n"); #then inserts a line break
output.print("\n");

#########-Variables-#########
int sscreent =; #Length of time S screen is displayed.
int rscreent =; #Length of time R screen is displayed. 
int ict =; #Length of time Instruction Cue is displayed.
int icbt =; #Length of time Instruction Cue blank is displayed. 
int nmsq = 6; #How many numbers in the sequence. 
int runssq = 6; #How many runs through the S sequence.
int nmr = 18; #How many trials within an R block.
int nmblocks = 5; #How many blocks within a run. 
int nmruns = 3; #How many runs.
array<int> sequence_array[nmsq] = {1,3,2,3,4,2}; #Sequence.
array<string> block_array[nmblocks] = {"R", "S", "S", "S", "R"}; #Order of Trials. Insert or remove to change the number/order of trials. If an additional trial is added, be sure to edit the nmblocks variable above. 
#########-END Variables-#########

S_stim.set_duration( sscreent );
R_stim.set_duration( rscreent );
InstructionCue_stim.set_duration( ict );
InstructionCueBlank_stim.set_duration( icbt );
sub wait_for_pulse ( int pulse_num )
	begin
	loop until pulse_manager.main_pulse_count() > pulse_num
	begin
	end;
end;
loop int p = 1 until p > nmruns
	begin
	waiting_trial.present();
	wait_for_pulse( pulse_manager.main_pulse_count() + 1 ); #Inserts waits to sync beginning of Fixation Cross Trial with MRI Pulse
	output.print( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	output.print( "\n");
	output.print( "Run ");
	output.print( p );
	output.print("\n");
	string s = "S";
	loop int i = 1 until i > nmblocks
		begin
		output.print( "---------------------------------------------");
		output.print( "\n");
		output.print( "Block ");
		output.print( i );
		output.print("\n");
		output.print("\n");
		output.print( "Block Set: ");
		if block_array[i] == "R" then
			R_trial.present();
			output.print( "R");
			output.print("\n");
			output.print("\n");
			loop int k = 1 until k > nmr 
				begin 
				output.print( "Trial ");
				output.print( k );
				output.print("\n");
				output.print( "Cue Shown: ");
				int y = random(1,4);
				output.print( y );
				output.print("\n");
				instructioncue.set_part( 1, instructioncues_array[y] );
				InstructionCue_stim.set_event_code( instructioncues_array[y].description() );
				InstructionCue_stim.set_target_button(y);
				instructioncue_trial.present();
				stimulus_data last = stimulus_manager.last_stimulus_data();
				output.print( "Button Pressed: " );
				output.print( last.button() );
				output.print( " - ");
				if last.button() == y
					then output.print( "Correct" ); logfile.add_event_entry( "Correct" );
				elseif last.button() == 0
					then output.print( "Miss" ); logfile.add_event_entry( "Miss" );
				else output.print( "Incorrect" ); term.print( "Incorrect" );
				end;
			output.print("\n");
			output.print( "Reaction Time: ");
			output.print( last.reaction_time() );
			output.print("\n");
			output.print("\n");
			k = k + 1;
			end;
		else 
			output.print( "S");
			output.print("\n");
			output.print("\n");
			S_trial.present();
			loop int j = 1 until j > (runssq * nmsq)
				begin
				loop int m = 1 until m > nmsq
					begin
					output.print( "Trial ");
					output.print( m * j );
					output.print("\n");
					output.print( "Cue Shown: ");
					output.print( sequence_array[m] );
					output.print("\n");
					instructioncue.set_part( 1, instructioncues_array[sequence_array[m]] );
					InstructionCue_stim.set_event_code( instructioncues_array[sequence_array[m]].description() );
					InstructionCue_stim.set_target_button(sequence_array[m]);
					instructioncue_trial.present();
					stimulus_data last = stimulus_manager.last_stimulus_data();
					output.print( "Button Pressed: " );
					output.print( last.button() );
					output.print( " - ");			
					if last.button() ==  sequence_array[m]
						then output.print( "Correct" ); logfile.add_event_entry( "Correct" );
					elseif last.button() == 0
						then output.print( "Miss" ); logfile.add_event_entry( "Miss" );
					else output.print( "Incorrect" ); term.print( "Incorrect" );
					end;			
					output.print("\n");
					output.print( "Reaction Time: ");
					output.print( last.reaction_time() );
					output.print("\n");
					output.print("\n");
					m = m + 1;
				end;
			j = j +1;
			end;
		end;
		i = i + 1;
	end;
	p = p + 1;
end;