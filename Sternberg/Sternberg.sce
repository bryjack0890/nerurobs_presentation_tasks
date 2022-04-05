scenario = "Sternberg"; #Name, used for references 
scenario_type = fMRI_emulation; #Refer to documentation - switch for developing vs production.
#scenario_type = fMRI; #Refer to documentation - switch for developing vs production.
default_font_size = 48;
default_optimize = false; #Leave false for more modern hardware
active_buttons = 3; #How many buttons
button_codes = 1,2,3; #What they should be coded as, used as a return when pressed. 
target_button_codes = 1,2,3;
response_logging = log_active; # If response_logging is log_active, responses that are ignored during a trial do not appear in the logfile.
response_matching = simple_matching;   # to use the newer features available in versions above 0.47.
scan_period = 2000; #The value of this parameter should be the time between complete MRI scans. For use with fMRI_emulation type.
default_background_color = 179, 179, 179;
pulses_per_scan = 1; #Needed if there are multiple pulses per TR.
pulse_code = 6;
#1 is yes, 2 is no.

#########-START SDL-#########
begin;
#########-START Trial Declations-#########
trial{
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 3;
	stimulus_event{
		picture{
			text { caption ="Please Wait"; 
			font_size = 80; 
			font_color = 0,0,0;
			}; x = 0; y = 0; 
	};
	}waiting;
}waiting_trial; #This is the Waiting period. It waits for a spacebar to proceed. - Not in use, but easy to add. 
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption = "Get ready for the letters"; 
			font_size = 80; 
			font_color = 0,0,0; 
			max_text_width = 675;
			}; 
			x = 0; y = 0; 
		}; 
		duration = 14000;
	}getready;
} getready_trial;
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption = "+"; 
			font_size = 100; 
			font_color = 0,0,0; 
			}; 
			x = 0; y = 0; 
		}; 
		duration = 1000;
	}fixationcross1;
} fixationcross_trial1; #This is the Fixation Cross between Get Ready and Letter Set.
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption = "+"; 
			font_size = 100; 
			font_color = 0,0,0; 
			}; 
			x = 0; y = 0; 
		}; 
		duration = 1800;
	}fixationcross2;
} fixationcross_trial2; #This is the Fixation Cross between Letter Set and first probe.
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption = "+"; 
			font_size = 100; 
			font_color = 0,0,0; 
			}; 
			x = 0; y = 0; 
		}; 
		duration = 800;
	}fixationcross3;
} fixationcross_trial3; #This is the Fixation Cross between probes.
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption = "A  B  C  D  E";
			font_size = 100;
			font_color = 0,0,0;
			}letterset;
			x = 0; y = 0;
		};
		duration = 6200;
	}letterset_stim;
}letterset_trial;
trial{
	trial_type = fixed;
	trial_duration = stimuli_length;
	stimulus_event{
		picture{
			text { caption = "a";
			font_size = 100;
			font_color = 0,0,0;
			}letterprobe;
			x = 0; y = 0;
		};
		response_active = true; 
		duration = 1000;
	}letterprobe_stim;
}letterprobe_trial;
#########-START PCL-#########
begin_pcl;
string filename = logfile.subject() + "Printout";
if file_exists( logfile_directory + filename + ".txt" ) then 
	int n = 1;
	loop until !file_exists( logfile_directory + filename + string( n ) + ".txt" )
	begin 
		n = n + 1;
	end;
	filename = filename + string (n);
end;
output_file output = new output_file; 
output.open( filename + ".txt", false);
output.print( "Subject Name: " );
output.print( logfile.subject() ); 
output.print("\n"); 
output.print("\n");

#########-Variables-#########
int blockcount = 6; #Number of blocks.
int trialcount = 25; #Number of trials with a block. 
double probeprobability = 37.5; #Probability that any one trial's letter probe will be from within the letter set (percent).
int getreadyt = 14000; #Time for Get Ready Screen.
int fixationcross1t = 1000; #Time fixation cross 1 is displayed. This is the Fixation Cross between Get Ready and Letter Set.
int fixationcross2t = 1800; #Time fixation cross 2 is displayed. This is the Fixation Cross between Letter Set and first probe.
int fixationcross3t = 800; #Time fixation cross 3 is displayed. This is the Fixation Cross between probes.
int probet = 1000; #Time probe is displayed. 
int lettersett = 6200; #Time letter set is displayed. 
array<int> count_array[blockcount] = {1,1,3,3,5,5}; #Each position is a run, each digit is how many characters are in a Letter Set. Edit this to change either of these values. 
array<string> capital_array[17] = {"A","B","D","E","F","G","H","J","K","M","N","Q","R","T","U","W","Y"}; #See below.
array<string> lowercase_array[17] = { "a", "b", "d", "e", "f", "g", "h", "j", "k", "m", "n", "q", "r", "t", "u", "w", "y" }; #Edit these three lines together. Change only if a different subset of letters are applicable to the study. 
array<int> position_array[17] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}; #See above.
#########-END Variables-#########

getready.set_duration( getreadyt );
fixationcross1.set_duration( fixationcross1t );
fixationcross2.set_duration( fixationcross2t );
fixationcross3.set_duration( fixationcross3t );
letterprobe_stim.set_duration( probet );
letterset_stim.set_duration( lettersett );
probeprobability = (probeprobability/100);
sub wait_for_pulse ( int pulse_num )
	begin
	loop until pulse_manager.main_pulse_count() > pulse_num
	begin
	end;
end;
sub int weighted_randomizer(int w)
	begin
	double x = random();
	int y = 0;
	if x < probeprobability then	
		y = random(1,w);
	else  
		y = random(w+1,capital_array.count());
	end;
	return y;
end;
waiting_trial.present();
wait_for_pulse( pulse_manager.main_pulse_count() + 1 ); #Inserts waits to sync beginning of Fixation Cross Trial with MRI Pulse. Comment out to remove the pause waiting for an fMRI pulse. 
count_array.shuffle();
loop int i = 1 until i > count_array.count()
begin
	position_array.shuffle(); 
	int f = count_array[i];
	output.print( "--------------------------------------------- ");
	output.print( "\n");
	output.print( "Block ");
	output.print( i );
	output.print("\n");
	output.print( "Letter Set: ");
	output.print("\n");
	string letterset_caps = capital_array[position_array[1]];
	if f > 2 then 
		loop int g = 1 until g > f-1
		begin
			letterset_caps = letterset_caps + " " + capital_array[position_array[g+1]];
			g = g + 1;
		end;
	end;
	letterset.set_caption( letterset_caps );
	letterset_stim.set_event_code( letterset_caps );
	letterset.redraw();
	output.print( letterset_caps );
	output.print("\n");
	output.print("\n");
	getready_trial.present();
	fixationcross_trial1.present();
	letterset_trial.present();
	fixationcross_trial2.present();
	loop int k = 1 until k > trialcount
	begin
		int r = weighted_randomizer(f);
		string z = lowercase_array[position_array[r]];
		letterprobe.set_caption( z );
		letterprobe_stim.set_event_code( z );
		output.print( "Trial ");
		output.print( k );
		output.print("\n");
		output.print( "Letter Shown: " );
		output.print( z );
		output.print("\n");
		letterprobe.redraw();
		letterprobe_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		output.print( "Button Pressed: " );
		output.print( last.button() );
		output.print( " - ");		
		if last.reaction_time() == 0 then 
			output.print( "Miss" ); logfile.add_event_entry( "Miss" );
		else
			loop int s = 1 until s > f begin
				if lowercase_array[position_array[s]] == z && last.button() == 1  
					then 	output.print( "Correct" ); logfile.add_event_entry( "Correct" ); break;
				elseif s == f && ( lowercase_array[position_array[s]] != z ) && last.button() == 2
					then 	output.print( "Correct" ); logfile.add_event_entry( "Correct" ); break;
				elseif s == f 
					then 	output.print( "Incorrect" ); logfile.add_event_entry( "Incorrect" );
				end;
				s = s + 1;
			end;
		end;
		output.print("\n");
		output.print( "Reaction Time: ");
		output.print( last.reaction_time() );
		output.print("\n");
		output.print("\n");
		fixationcross_trial3.present();
		k = k + 1;
		end;
	i = i + 1;
end;